Get-ChildItem -Filter *.html | ForEach-Object {
    $oldName = $_.Name
    $base = [System.IO.Path]::GetFileNameWithoutExtension($oldName)

    if ($base -match "^(�ߘa|����)(\d+)�N�x_(�t��|�H��)_(�ߌ�)(\d)_(��)(\d+)_No_(\d+)$") {
        $era = if ($Matches[1] -eq "�ߘa") { "r" } else { "h" }
        $year = "{0:D2}" -f [int]$Matches[2]
        $term = if ($Matches[3] -eq "�t��") { "s" } else { "a" }
        $pm = "p$($Matches[5])"
        $q = "q$($Matches[7])"
        $no = "no$($Matches[8])"

        $newName = "${era}${year}_${pm}_${q}_${no}.html"

        if ($oldName -ne $newName) {
            Rename-Item -Path $_.FullName -NewName $newName
            Write-Host "? Renamed: $oldName �� $newName"
        } else {
            Write-Host "? Skipped (already OK): $oldName"
        }
    } else {
        Write-Host "?? Skipped (not matching pattern): $oldName"
    }
}
