param(
  [Parameter(Mandatory=$false)]
  [string]$Dir = (Get-Location).Path
)

$dirPath = Resolve-Path $Dir
$reName  = [regex]'^(?<grp>(?:r|h)\d{2}_p[12]_q\d+)_no(?<no>\d+)\.html$'

# entry-body の「内側だけ」取得（relatedPosts直前まで）
function Get-EntryBodyInner([string]$html) {
  $m = [regex]::Match(
    $html,
    '(?is)<div\s+class="entry-body"\s*>(?<inner>.*?)(?=<!--\s*\[\s*\.relatedPosts\s*\])'
  )
  if ($m.Success) { return $m.Groups['inner'].Value }
  return $null
}

# entry-body の「内側だけ」置換（外側構造は保持）
function Replace-EntryBodyInner([string]$html, [string]$newInner) {
  $pattern = '(?is)(<div\s+class="entry-body"\s*>).*?(?=<!--\s*\[\s*\.relatedPosts\s*\])'
  if ($html -notmatch $pattern) { return $null }
  return [regex]::Replace($html, $pattern, "`$1$newInner", 1)
}

# no2以降の本文を掃除
function Clean-InnerForAppend([string]$inner) {

  $t = $inner

  # script削除（toggleAnswerなど）
  $t = [regex]::Replace($t, '(?is)<script\b[^>]*>.*?</script>', '')

  # 先頭h2削除（ページタイトル）
  $t = [regex]::Replace($t, '(?is)^\s*<h2\b[^>]*>.*?</h2>\s*', '', 1)

  # 先頭出典削除
  $t = [regex]::Replace($t, '(?is)^\s*<p\b[^>]*>.*?出典.*?</p>\s*', '', 1)

  return $t
}

# HTML収集
$items = Get-ChildItem -Path $dirPath -Filter "*.html" | ForEach-Object {
  $m = $reName.Match($_.Name)
  if ($m.Success) {
    [pscustomobject]@{
      File = $_
      Key  = $m.Groups['grp'].Value
      No   = [int]$m.Groups['no'].Value
    }
  }
}

$groups = $items | Group-Object Key

foreach ($g in $groups) {

  $parts = $g.Group | Sort-Object No
  if ($parts.Count -le 1) { continue }

  $base = $parts | Where-Object { $_.No -eq 1 } | Select-Object -First 1
  if (-not $base) { continue }

  $basePath = $base.File.FullName
  $baseHtml = Get-Content -Path $basePath -Raw -Encoding UTF8

  $baseInner = Get-EntryBodyInner $baseHtml
  if (-not $baseInner) {
    Write-Host "SKIP(entry-body not found): $($base.File.Name)"
    continue
  }

  $merged = $baseInner

  foreach ($p in ($parts | Where-Object { $_.No -ge 2 })) {

    $h = Get-Content -Path $p.File.FullName -Raw -Encoding UTF8
    $inner = Get-EntryBodyInner $h
    if (-not $inner) { continue }

    $inner = Clean-InnerForAppend $inner

    # デバッグ用区切り
    $merged += "`n<!-- merged from: $($p.File.Name) -->`n"
    $merged += "<hr class=`"merge-sep`">`n"
    $merged += $inner

    # no2以降は削除（不要なら）
    Remove-Item $p.File.FullName -Force
  }

  $newHtml = Replace-EntryBodyInner $baseHtml $merged
  if (-not $newHtml) {
    Write-Host "SKIP(replace failed): $($base.File.Name)"
    continue
  }

  Set-Content -Path $basePath -Value $newHtml -Encoding UTF8

  Write-Host "MERGED (safe mode): $($g.Name)"
}

Write-Host "DONE."
