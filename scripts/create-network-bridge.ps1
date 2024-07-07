. scripts\load-config.ps1

$yaml = ReadConfigYAML
New-VMSwitch -Name $yaml.network.bridge.name -AllowManagementOS $True -NetAdapterName $yaml.network.bridge.external_interface
