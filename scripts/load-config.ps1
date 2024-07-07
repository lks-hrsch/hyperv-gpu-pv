Import-Module powershell-yaml

function ReadConfigYAML {
    Process {
        $fileContent = Get-Content -Path "config.yaml" -Raw
        $yaml = ConvertFrom-Yaml $fileContent
        $yaml
    }
}