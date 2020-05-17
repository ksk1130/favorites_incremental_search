param(
    [string]$favorites_path    # �����Ώۃp�X(�f�B���N�g���ł��t�@�C�����ł��󂯕t����)
)

# �G���[�����������_�ŏ����I��
$ErrorActionPreference = "stop"

function script:escapeFileName($targetFileName){
    $resultFileName = $targetFileName

    $resultFileName = $resultFileName -replace "\[","``["
    $resultFileName = $resultFileName -replace "\]","``]"

    return $resultFileName
}

function script:getURLArray($favorites_path) {
    $favorites = (Get-ChildItem -Recurse $favorites_path | Where-Object { $_.Attributes -ne "Directory" -and $_.Extension -eq ".url" })

    foreach ($favorite in $favorites) {
        $tempStr = $favorite.fullname
        $tempPath = escapeFileName $tempStr

        $tempVal = (get-content $tempPath) -match "^URL=.+"
        # �擪�́uURL=�v�����
        # $tempVal���̂̓I�u�W�F�N�g�z��Ȃ̂ŁA�Y����[0](�}�b�`��1��,String)�𒼐ڎw�肵�ăA�N�Z�X
        $url = $tempVal[0].Substring(4, $tempVal[0].Length - 4)

        # �������z��Ƃ��ėv�f��ǉ�
        $urlArray += , @($url, $favorite.name)
    }

    # URL�̏����Ń\�[�g����
    $urlArray = $urlArray | Sort-Object 

    return $urlArray
}

function script:createHtml($urlArray) {
    # �����Ȃ����X�g��g�ݗ���
    $favorites_list = '<ol id="favoritesList">' + "`r`n"
    foreach ($cols in $urlArray) {
        $favorites_list += "<li><a href='" + $cols[0] + "' target='_blank'>" + $cols[1] + "</a></li>`r`n"
    }
    $favorites_list += "</ol>"

    # �q�A�h�L�������g�ɏ�L�̃��X�g�𖄂ߍ���
    $htmlTemplate = @"
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title>Favorites Search</title>
<meta charset="utf-8">
<script type="text/javascript">
<!-- 
// ���͂Ƀ}�b�`����v�f���i�[����Z�b�g(�d���Ȃ��A�����ێ�)
var resultSet = new Set();

window.onload = init;

// onload�Ŏ��s���������͂����ɏ���
function init() {
  focusForm();

  // �t�H�[�J�X���������onkeyup���������߁A��x�N���A���������s
  clearResult();

  // ���C�ɓ���̐��𐔂���
  countFavorites();
}

// ���C�ɓ���ꗗ�̌�����\�����鏈��
function countFavorites() {
  var lis = document.getElementById("favoritesList").getElementsByTagName("li");

  var h2Elem = document
    .getElementsByTagName("div")
    .item(2)
    .getElementsByTagName("h2")
    .item(0);
  h2Elem.innerHTML = "���C�ɓ��� (" + lis.length + ")";
}

// �������Ƀt�H�[�J�X�𓖂Ă鏈��
function focusForm() {
  document.getElementById("searchWord").focus();
}

// ���ʕ\���p��li�v�f�𐶐����鏈��
function getViewLiElem(value) {
  var li = document.createElement("li");

  // URL\t�^�C�g���@�𕪊����Ĕz��
  var tempArray = value.split("\t");

  // ���ʕ\���̓����N�`���ɂ���(�V�K�^�u�ŕ\��)
  var a = document.createElement("a");
  a.href = tempArray[0];

  // �}�b�`���镶����ɒ��F����
  // �}�b�`���镶������擾
  var regex = new RegExp(searchWord, "i");
  var matched = tempArray[1].match(regex);

  tempArray[1] = tempArray[1].replace(regex, "<span>" + matched + "</span>");
  a.innerHTML = tempArray[1];
  a.setAttribute("target", "_blank");

  li.appendChild(a);

  return li;
}

// ���͂Ƀ}�b�`����v�f������ɍi�荞�݁A���ʕ\�����鏈��
function narrowFavorites(searchWord) {
  // �������n�߂��炨�C�ɓ���ꗗ���\���ɂ���
  document.getElementsByTagName("div").item(2).style.display = "none";

  var parentNode = document.getElementById("resultArea");

  // �Ăяo���̂��тɌ��ʕ\���G���A���N���A
  document.getElementsByTagName("div").item(1).style.display = "block";
  parentNode.innerHTML = "";

  // �Z�b�g���񂵂Ȃ��獇�v����v�f�����ʕ\���G���A�ɕ\��
  resultSet.forEach(function (value) {
    // ����������A�����ΏۂƂ��ɏ��������m�Ŕ�r����
    if (value.toLowerCase().indexOf(searchWord.toLowerCase()) > 0) {
      var li = getViewLiElem(value);

      parentNode.appendChild(li);
    }
  });

  var lis = document.getElementById("resultArea").getElementsByTagName("li");

  var h2Elem = document
    .getElementsByTagName("div")
    .item(1)
    .getElementsByTagName("h2")
    .item(0);
  h2Elem.innerHTML = "�������� (" + lis.length + ")";
}

// �L�[�������グ��ꂽ��Ăяo����鏈��
function searchFavorite() {
  var orgSearchWord = document.getElementById("searchWord").value;
  console.log(orgSearchWord);

  // �Z�b�g�͌Ăяo�����ɃN���A
  resultSet.clear();

  // ����������͏������ɕϊ�����
  searchWord = new String(orgSearchWord).toLowerCase();

  // BS�L�[�Ȃǂœ��̓G���A����ɂȂ����烊�Z�b�g
  if (searchWord == "") {
    clearResult();
    return;
  }

  // URL<�^�u>�^�C�g�� �ɓ��͕������}�b�`������A�Z�b�g�ɋl�߂Ă���
  var lis = document.getElementById("favoritesList").getElementsByTagName("li");

  for (var i = 0; i < lis.length; i++) {
    var a = lis[i].firstChild;

    var line = a.href + "\t" + a.innerHTML;

    // ����������A�����ΏۂƂ��ɏ��������m�Ŕ�r����
    if (line.toLowerCase().indexOf(searchWord) > 0) {
      resultSet.add(line);
    }
  }

  // ��ʕ\�����s�����߁A�i�荞�ݏ��������s
  narrowFavorites(orgSearchWord);
}

// ���Z�b�g����
function clearResult() {
  document.getElementsByTagName("div").item(1).style.display = "none";
  resultSet.clear();

  // �����\����ԓ��l�A���C�ɓ���ꗗ��\������
  document.getElementsByTagName("div").item(2).style.display = "block";
}
-->
</script>
<style type="text/css">
<!--
    div {
        margin-top:30px;
    }

    span {
        color:red;
    }
-->
</style>
</head>
<body>
<h1>Favorites Search</h1>
<form>
<input type="text" value="" id="searchWord" onKeyUp="searchFavorite()"/>
<input type="reset" value="���Z�b�g" onclick="clearResult()"/>
</form>
<div>
<div>
<h2 class="section_header">��������</h2>
<ol id="resultArea">
</ol>
</div>
<div>
<h2 class="section_header">���C�ɓ���ꗗ</h2>
$favorites_list
</div>
</div>
</body>
</html>
"@
    # HTML�t�@�C���Ƃ��ďo��
    Write-Output $htmlTemplate | Set-Content -Encoding UTF8 favorites_search.html
}

function script:Main($favorites_path) {
    $urlArray = getUrlArray $favorites_path
    
    createHtml $urlArray
}

Main $favorites_path
