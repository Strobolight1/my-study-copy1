$htmlPath = "r06_p2_q2_no4.html"
$backupPath = "$htmlPath.bak"
Copy-Item $htmlPath $backupPath

$html = Get-Content $htmlPath -Raw

# �u�?n�C���C�g�v������???u���ivk_highlighter, rgba, f78da7 ���??��?j
$html = $html -replace '(?s)(<span[^>]*?(vk_highlighter|rgba\(247,\s*141,\s*167|f78da7)[^>]*>)(.*?)(</span>)', `
    '<button onclick="toggleAnswer(this)">�?�\��</button><div class="answer" style="display:none;">$1$3$4</div>'

# toggleAnswer�X�N���v�g�}���i<body>�?��O�j
$toggleScript = @"
<script>
function toggleAnswer(button) {
  const answer = button.nextElementSibling;
  if (answer.style.display === 'none') {
    answer.style.display = 'block';
    button.textContent = '�?��\��';
  } else {
    answer.style.display = 'none';
    button.textContent = '�?�\��';
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
Write-Host "? �?W�����i�?�����?j: $htmlPath�i�o�b�N�A�b�v: $backupPath�j"
