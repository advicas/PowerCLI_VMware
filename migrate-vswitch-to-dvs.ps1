# ESXi hosts to migrate from VSS-&gt;VDS
$vmhost_array = @("RMIESXI01.rci.local", "RMIESXI02.rci.local", "RMIESXI03.rci.local", "RMIESXI04.rci.local", "RMIESXI05.rci.local", "RMIESXI06.rci.local")
 
# Create VDS Switches
$vds_name = "VDS-Production"
Write-Host "`nCreating new VDS" $vds_name
New-VDSwitch -Name $vds_name -Location (Get-Datacenter)


$vds = get-vdswitch -Name $vds_name

 
# Create DVPortgroup
Write-Host "Creating new Management DVPortgroup"
New-VDPortgroup -Name "Management" -Vds $vds | Out-Null

Write-Host "Creating new VM Network DVPortgroup"
New-VDPortgroup -Name "VM Network" -Vds $vds | Out-Null

Write-Host "Creating new DMZ Network DVPortgroup"
New-VDPortgroup -Name "DMZ" -vlanid 300 -Vds $vds | Out-Null

Write-Host "Creating new ISCSI-1 Network DVPortgroup"
New-VDPortgroup -Name "ISCSI-1" -vlanid 100 -Vds $vds | Out-Null

Write-Host "Creating new ISCSI-2 Network DVPortgroup"
New-VDPortgroup -Name "ISCSI-2" -vlanid 100 -Vds $vds | Out-Null

Write-Host "Creating new vMotion Network DVPortgroup"
New-VDPortgroup -Name "vMotion" -vlanid 200 -Vds $vds | Out-Null
 
foreach ($vmhost in $vmhost_array) {
# Add ESXi host to VDS
Write-Host "Adding" $vmhost "to" $vds_name
$vds | Add-VDSwitchVMHost -VMHost $vmhost | Out-Null
 
# Migrate pNIC to VDS (vmnic0/vmnic1)
Write-Host "Adding vmnic0/vmnic1 to" $vds_name
$vmhostNetworkAdapter = Get-VMHost $vmhost | Get-VMHostNetworkAdapter -Physical -Name vmnic0
$vds | Add-VDSwitchPhysicalNetworkAdapter -VMHostNetworkAdapter $vmhostNetworkAdapter -Confirm:$false
$vmhostNetworkAdapter = Get-VMHost $vmhost | Get-VMHostNetworkAdapter -Physical -Name vmnic1
$vds | Add-VDSwitchPhysicalNetworkAdapter -VMHostNetworkAdapter $vmhostNetworkAdapter -Confirm:$false
 
# Migrate VMkernel interfaces to VDS
 
# Management 
$mgmt_portgroup = "Management"
Write-Host "Migrating" $mgmt_portgroup "to" $vds_name
$dvportgroup = Get-VDPortgroup -name $mgmt_portgroup -VDSwitch $vds
$vmk = Get-VMHostNetworkAdapter -Name vmk0 -VMHost $vmhost
Set-VMHostNetworkAdapter -PortGroup $dvportgroup -VirtualNic $vmk -confirm:$false | Out-Null
 


# Remove old vSwitch portgroups
$vswitch = Get-VirtualSwitch -VMHost $vmhost -Name vSwitch0
 
Write-Host "Removing vSwitch portgroup" $mgmt_portgroup
$mgmt_pg = Get-VirtualPortGroup -Name $mgmt_portgroup -VirtualSwitch $vswitch
Remove-VirtualPortGroup -VirtualPortGroup $mgmt_pg -confirm:$false
}
