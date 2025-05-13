# �����Ώۃt�H���_�i�ύX�Ȃ��j
$targetFolder = "C:\Users\xenob\OneDrive\�h�L�������g\NW HPcreate\html"  # �� ���ۂ̃p�X

# �S .html �t�@�C�����擾
Get-ChildItem -Path $targetFolder -Filter *.html | ForEach-Object {

    $file = $_.FullName

    Write-Host "? ������: $($_.Name)"

    $html = Get-Content $file -Raw

    # �ԉ𓚂����ΏۂɃ{�^���{��\����
    $html = $html -replace '(?s)(<span[^>]*?(vk_highlighter|rgba\(247,\s*141,\s*167|f78da7)[^>]*>)(.*?)(</span>)', `
        '<button onclick="toggleAnswer(this)">�𓚂�\��</button><div class="answer" style="display:none;">$1$3$4</div>'

    # toggleAnswer�֐��𖖔��܂��� </body> �̒��O�ɑ}��
    $toggleScript = @"
<script>
function toggleAnswer(button) {
  const answer = button.nextElementSibling;
  if (answer.style.display === 'none') {
    answer.style.display = 'block';
    button.textContent = '�𓚂��\��';
  } else {
    answer.style.display = 'none';
    button.textContent = '�𓚂�\��';
  }
}
</script>
"@

    if ($html -match '</body>') {
        $html = $html -replace '</body>', "$toggleScript`n</body>"
    } else {
        $html += "`n$toggleScript"
    }

    # �ύX���e�𒼐ڕۑ�
    Set-Content $file -Value $html -Encoding UTF8
    Write-Host "? ����: $($_.Name)"
}

Write-Host "`n? �S�t�@�C�����������I"
