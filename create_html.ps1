param(
    [string]$favorites_path    # 処理対象パス(ディレクトリでもファイル名でも受け付ける)
)

# エラーがあった時点で処理終了
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
        # 先頭の「URL=」を削る
        # $tempVal自体はオブジェクト配列なので、添え字[0](マッチの1個目,String)を直接指定してアクセス
        $url = $tempVal[0].Substring(4, $tempVal[0].Length - 4)

        # 多次元配列として要素を追加
        $urlArray += , @($url, $favorite.name)
    }

    # URLの昇順でソートする
    $urlArray = $urlArray | Sort-Object 

    return $urlArray
}

function script:createHtml($urlArray) {
    # 順序なしリストを組み立て
    $favorites_list = '<ol id="favoritesList">' + "`r`n"
    foreach ($cols in $urlArray) {
        $favorites_list += "<li><a href='" + $cols[0] + "' target='_blank'>" + $cols[1] + "</a></li>`r`n"
    }
    $favorites_list += "</ol>"

    # ヒアドキュメントに上記のリストを埋め込み
    $htmlTemplate = @"
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title>Favorites Search</title>
<meta charset="utf-8">
<script type="text/javascript" src="./util.js"></script>
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
<input type="reset" value="リセット" onclick="clearResult()"/>
</form>
<div>
<div>
<h2 class="section_header">検索結果</h2>
<ol id="resultArea">
</ol>
</div>
<div>
<h2 class="section_header">お気に入り一覧</h2>
$favorites_list
</div>
</div>
</body>
</html>
"@
    # HTMLファイルとして出力
    Write-Output $htmlTemplate | Set-Content -Encoding UTF8 favorites_search.html
}

function script:Main($favorites_path) {
    $urlArray = getUrlArray $favorites_path
    
    createHtml $urlArray
}

Main $favorites_path
