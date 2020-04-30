param(
    [string]$favorites_path    # �����Ώۃp�X(�f�B���N�g���ł��t�@�C�����ł��󂯕t����)
)

# �G���[�����������_�ŏ����I��
$ErrorActionPreference = "stop"

function script:getURLArray($favorites_path) {
    $favorites = (Get-ChildItem -Recurse $favorites_path | Where-Object { $_.Attributes -ne "Directory" -and $_.Extension -eq ".url" })

    foreach ($favorite in $favorites) {
        $tempVal = (get-content $favorite.fullname) -match "^URL=.+"
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
    $favorites_list = '<ul id="favoritesList" style="display:none">' + "`r`n"
    foreach ($cols in $urlArray) {
        $favorites_list += "<li><a href='" + $cols[0] + "' target='_blank'>" + $cols[1] + "</a></li>`r`n"
    }
    $favorites_list += "</ul>"

    # �q�A�h�L�������g�ɏ�L�̃��X�g�𖄂ߍ���
    $htmlTemplate = @"
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title>Favorites Search</title>
<meta charset="utf-8">
<script type="text/javascript" src="./util.js"></script>
</head>
<body>
<h1>Favorites Search</h1>
<form>
<input type="text" value="" id="searchWord" onKeyUp="searchFavorite()"/>
<input type="reset" value="���Z�b�g" onclick="clearResult()"/>
</form>
<ul id="resultArea">
</ul>
$favorites_list
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
