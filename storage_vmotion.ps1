Start-Transcript
$vms = Get-VM

foreach ($vm in $vms) { 
    write-host "Moving $($vm.name) Compute"
    $vm | move-vm -destination rmiesxi01.rci.local

    write-host "Moving $($vm.name) Disks"
    Get-HardDisk -VM $vm.name | % { Move-HardDisk $_ -Datastore ($_.Filename -replace '\[NS(.+?)\].*', 'NS2$1') -Confirm:$false } 

    write-host "Moving $($vm.name) Networking"
    $oldnet = $vm | Get-NetworkAdapter 
        foreach ($network in $oldnet){
            $newnet = Get-VDPortgroup -name $network.NetworkName
            Set-NetworkAdapter -NetworkAdapter $network -PortGroup $newnet -confirm $false
    }

}
Stop-Transcript
