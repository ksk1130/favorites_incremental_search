param(
    [string]$favorites_path    # 処理対象パス(ディレクトリでもファイル名でも受け付ける)
)

# エラーがあった時点で処理終了
$ErrorActionPreference = "stop"

function script:getURLArray($favorites_path) {
    $favorites = (Get-ChildItem -Recurse $favorites_path | Where-Object { $_.Attributes -ne "Directory" -and $_.Extension -eq ".url" })

    foreach ($favorite in $favorites) {
        $tempVal = (get-content $favorite.fullname) -match "^URL=.+"
        # 先頭の「URL=」を削る。$tempVal自体はオブジェクト配列なので、添え字[0](マッチの1個目,String)を直接指定してアクセス
        $url = $tempVal[0].Substring(4, $tempVal[0].Length - 4)

        $urlArray += , @($favorite.name, $url)
    }
    return $urlArray
}

function script:createHtml($urlArray) {
    # 順序なしリストを組み立て
    $favorites_list = '<ul id="favoritesList" style="display:none">'
    foreach ($cols in $urlArray) {
        $favorites_list += "<li><a href='" + $cols[1] + "' target='_blank'>" + $cols[0] + "</a></li>`r`n"
    }
    $favorites_list += "</ul>"

    # ヒアドキュメントに上記のリストを埋め込み
    $htmlTemplate = @"
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title>Favorites Search</title>
<meta charset="utf-8">
<script type="text/javascript">
    function searchFavorite(){
        console.log(document.getElementById("searchWord").value);
    
        console.log(document.getElementById("favoritesList"));

        document.getElementById("resultArea").innerHTML = document.getElementById("searchWord").value;
    }

    function clearResult(){
        document.getElementById("resultArea").innerHTML = "";
    }
</script>
</head>
<body>
<h1>Favorites Search</h1>
<form>
<input type="text" value="" id="searchWord" onKeyUp="searchFavorite()"/>
<input type="reset" value="リセット" onclick="clearResult()"/>
</form>
<div id="resultArea">
</div>
$favorites_list
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