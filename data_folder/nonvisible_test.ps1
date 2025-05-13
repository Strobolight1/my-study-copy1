$htmlPath = "r06_p2_q2_no4.html"
$backupPath = "$htmlPath.bak"
Copy-Item $htmlPath $backupPath

$html = Get-Content $htmlPath -Raw

# u?nƒCƒ‰ƒCƒgv‚¾‚¯‚ğ‘???uŠ·ivk_highlighter, rgba, f78da7 ‚ğŠ??à‚?j
$html = $html -replace '(?s)(<span[^>]*?(vk_highlighter|rgba\(247,\s*141,\s*167|f78da7)[^>]*>)(.*?)(</span>)', `
    '<button onclick="toggleAnswer(this)">‰?ğ•\¦</button><div class="answer" style="display:none;">$1$3$4</div>'

# toggleAnswerƒXƒNƒŠƒvƒg‘}“üi<body>‚?¼‘Oj
$toggleScript = @"
<script>
function toggleAnswer(button) {
  const answer = button.nextElementSibling;
  if (answer.style.display === 'none') {
    answer.style.display = 'block';
    button.textContent = '‰?ğ”ñ•\¦';
  } else {
    answer.style.display = 'none';
    button.textContent = '‰?ğ•\¦';
  }
}
</script>
"@

if ($html -match '</body>') {
    $html = $html -replace '</body>', "$toggleScript`n</body>"
} else {
    $html += "`n$toggleScript"
}

Set-Content $htmlPath -Value $html -Encoding UTF8
Write-Host "? •?WŠ®—¹i?üŒÀ’è”?j: $htmlPathiƒoƒbƒNƒAƒbƒv: $backupPathj"
