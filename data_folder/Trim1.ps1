Get-ChildItem -Filter *.html | ForEach-Object {
    $oldName = $_.Name
    if ($oldName -match "(_ネットワークスペシャリスト試験.*)") {
        $newName = $Matches[1]
        Rename-Item -Path $_.FullName -NewName $newName
        Write-Host "✅ Renamed: $oldName → $newName"
    }
}