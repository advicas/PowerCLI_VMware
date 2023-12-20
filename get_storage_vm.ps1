#Create a CSV file with a Column called name containing all your VM names, 1 per line.
$vmlist = import-csv "c:\your\csv\here.csv"
$totaldiskgb = @()
foreach ($vm in $vmlist) {
    $disksum = get-vm $vm.name | get-harddisk | Select-Object CapacityGB | Measure-Object CapacityGB -Sum
    $totaldiskgb += $disksum.sum
}
$gb = ($totaldiskgb | measure-object -sum).sum
Write-host " Total Size $t GB"
