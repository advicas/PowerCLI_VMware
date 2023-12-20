#Reboot VM's
$vmlist = "RMIP6S",
"rmipcs",
"rmipts",
"rmivcm",
"RCIACCT03",
"RMIVAPP8"

foreach ($vm in $vmlist){get-vm $vm | restart-vmguest}
