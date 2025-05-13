# 処理対象フォルダ（変更なし）
$targetFolder = "C:\Users\xenob\OneDrive\ドキュメント\NW HPcreate\html"  # ← 実際のパス

# 全 .html ファイルを取得
Get-ChildItem -Path $targetFolder -Filter *.html | ForEach-Object {

    $file = $_.FullName

    Write-Host "? 処理中: $($_.Name)"

    $html = Get-Content $file -Raw

    # 赤解答だけ対象にボタン＋非表示化
    $html = $html -replace '(?s)(<span[^>]*?(vk_highlighter|rgba\(247,\s*141,\s*167|f78da7)[^>]*>)(.*?)(</span>)', `
        '<button onclick="toggleAnswer(this)">解答を表示</button><div class="answer" style="display:none;">$1$3$4</div>'

    # toggleAnswer関数を末尾または </body> の直前に挿入
    $toggleScript = @"
<script>
function toggleAnswer(button) {
  const answer = button.nextElementSibling;
  if (answer.style.display === 'none') {
    answer.style.display = 'block';
    button.textContent = '解答を非表示';
  } else {
    answer.style.display = 'none';
    button.textContent = '解答を表示';
  }
}
</script>
"@

    if ($html -match '</body>') {
        $html = $html -replace '</body>', "$toggleScript`n</body>"
    } else {
        $html += "`n$toggleScript"
    }

    # 変更内容を直接保存
    Set-Content $file -Value $html -Encoding UTF8
    Write-Host "? 完了: $($_.Name)"
}

Write-Host "`n? 全ファイル処理完了！"
