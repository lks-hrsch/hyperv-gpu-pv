. scripts\load-config.ps1

$yaml = ReadConfigYAML

foreach ($vm in $yaml.vm) {
    $vmPath = ($vm.vhdx.path, "\" , $vm.name , ".vhdx" -join "")
    $vmMemory = $vm.memory * 1GB
    $vdhxSize = $vm.vhdx.size * 1GB

    New-VM -Name $vm.name -MemoryStartupBytes $vmMemory -SwitchName $yaml.network.bridge.name -NewVHDPath $vmPath -NewVHDSizeBytes $vdhxSize -Generation 2
    Set-VM -Name $vm.name -CheckpointType Disabled
    Set-VMProcessor -VMName $vm.name -Count $vm.cores
    Set-VMMemory -VMName $vm.name -DynamicMemoryEnabled $False
    Set-VMVideo -VMName $vm.name -HorizontalResolution 2560 -VerticalResolution 1440
    Set-VMKeyProtector -VMName $vm.name -NewLocalKeyProtector
    Enable-VMTPM -VMName $vm.name


    # needed for GPU-PV
    Add-VMGpuPartitionAdapter -VMName $vm.name
    Set-VMGpuPartitionAdapter -VMName $vm.name -MinPartitionVRAM 80000000 -MaxPartitionVRAM 100000000 -OptimalPartitionVRAM 100000000 -MinPartitionEncode 80000000 -MaxPartitionEncode 100000000 -OptimalPartitionEncode 100000000 -MinPartitionDecode 80000000 -MaxPartitionDecode 100000000 -OptimalPartitionDecode 100000000 -MinPartitionCompute 80000000 -MaxPartitionCompute 100000000 -OptimalPartitionCompute 100000000

    Set-VM -GuestControlledCacheTypes $true -VMName $vm.name
    Set-VM -LowMemoryMappedIoSpace 1Gb -VMName $vm.name
    Set-VM -HighMemoryMappedIoSpace 32GB -VMName $vm.name
}