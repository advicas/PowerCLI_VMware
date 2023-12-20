connect-viserver rmivc.rci.local

$vmlist = "rmiacct","rmifiles1"
foreach ($vm in $vmlist) {get-vm $vm | move-vm -Destination NS2}
