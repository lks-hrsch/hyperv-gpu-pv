Write-Host "try to update gpu driver"

. scripts\load-config.ps1

$yaml = ReadConfigYAML

foreach ($vm in $yaml.vm) {
    # check if the hyper-v vm is running
    # $VMName = Get-VM -Name "GPU-PV-Ghostspectre"
    $VMName = Get-VM -Name $vm.name
    if ($VMName.State -ne "Running") {
        Write-Host "$VMName is not running"
        exit 0
    }

    $TmpDestination = "C:\Temp\"
    # TODO: clear dir on VM

    # Copy the files to the VM
    $SourcePath1 = "C:\Windows\System32\nv*"
    $SourcePath2 = "C:\Windows\System32\Nv*"

    # Get all files that match the regex patterns
    $Files1 = Get-Item -Path $SourcePath1
    $Files2 = Get-Item -Path $SourcePath2

    # Combine the two lists of files
    $AllFiles = $Files1 + $Files2

    # Print the list of files
    foreach ($File in $AllFiles) {
        # check if the file is a directory
        if ($File.Attributes -eq "Directory") {
            continue
        }
        $Source = $File.FullName
        $Tmp = $TmpDestination + "System32\" + $File.Name
        $Destination = $File.FullName
        Write-Host "try copying ... $Source to $Destination over $Tmp"
        # Copy files to the VM
        try {
            Copy-VMFile -VM $VMName -SourcePath $Source -DestinationPath $Tmp -Force -CreateFullPath -FileSource Host -ErrorAction Stop
        } catch {
            Write-Error "Error copying file: $_"
        }
    }


    # Copy the files to the VM
    $SourcePath = "C:\Windows\System32\DriverStore\FileRepository\nv_disp*"

    # Get all files that match the regex patterns
    $Dirs = Get-Item -Path $SourcePath

    # Print the list of files
    foreach ($Dir in $Dirs) {
        # check if the file is a directory
        if ($Dir.Attributes -ne "Directory") {
            continue
        }
        $Source = $Dir.FullName
        $SourceZip = $TmpDestination + $Dir.Name + ".zip"
        $Tmp = $TmpDestination + "System32\HostDriverStore\FileRepository\" + $Dir.Name + ".zip"
        $Destination = $Dir.FullName
        Write-Host "try copying ... $Source to $Destination over $Tmp"
        # Copy files to the VM
        try {
            Compress-Archive -Path $Source -DestinationPath $SourceZip -Force -ErrorAction Stop
            Copy-VMFile -VM $VMName -SourcePath $SourceZip -DestinationPath $Tmp -Force -CreateFullPath -FileSource Host -ErrorAction Stop
        } catch {
            Write-Error "Error copying file: $_"
        }
    }
}

