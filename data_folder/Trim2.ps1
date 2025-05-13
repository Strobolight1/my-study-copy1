Get-ChildItem -Filter *.html | ForEach-Object {
    $oldName = $_.Name
    $base = [System.IO.Path]::GetFileNameWithoutExtension($oldName)

    # "No_����" ��T���?A���?���??c��
    if ($base -match "^(.*?No_\d+)") {
        $newName = "$($Matches[1]).html"

        if ($oldName -ne $newName) {
            Rename-Item -Path $_.FullName -NewName $newName
            Write-Host "Renamed: $oldName �� $newName"
        } else {
            Write-Host "Skipped (no change): $oldName"
        }
    } else {
        Write-Host "Skipped (No_x not found): $oldName"
    }
}
