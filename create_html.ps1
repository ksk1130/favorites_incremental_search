param(
  [string]$favorites_path                   # 処理対象パス(ディレクトリでもファイル名でも受け付ける)
  , [string]$output_path = (Convert-Path .) # 結果ファイルの出力パス(指定しなかったらスクリプトと同じパス)
)

# エラーがあった時点で処理終了
$ErrorActionPreference = "stop"

function script:escapeFileName($targetFileName) {
  $resultFileName = $targetFileName

  $resultFileName = $resultFileName -replace "\[", "``["
  $resultFileName = $resultFileName -replace "\]", "``]"

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

function script:createHtml($urlArray, $output_path) {
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
<script type="text/javascript">
<!-- 
// 入力にマッチする要素を格納するセット(重複なし、順序保持)
var resultSet = new Set();

window.onload = init;

// onloadで実行した処理はここに書く
function init() {
  focusForm();

  // フォーカスが当たるとonkeyupが働くため、一度クリア処理を実行
  clearResult();

  // お気に入りの数を数える
  countFavorites();
}

// お気に入り一覧の件数を表示する処理
function countFavorites() {
  var lis = document.getElementById("favoritesList").getElementsByTagName("li");

  var h2Elem = document
    .getElementsByTagName("div")
    .item(2)
    .getElementsByTagName("h2")
    .item(0);
  h2Elem.innerHTML = "お気に入り (" + lis.length + ")";
}

// 検索窓にフォーカスを当てる処理
function focusForm() {
  document.getElementById("searchWord").focus();
}

// 結果表示用のli要素を生成する処理
function getViewLiElem(value) {
  var li = document.createElement("li");

  // URL\tタイトル　を分割して配列化
  var tempArray = value.split("\t");

  // 結果表示はリンク形式にする(新規タブで表示)
  var a = document.createElement("a");
  a.href = tempArray[0];

  // マッチする文字列に着色する
  // マッチする文字列を取得
  var regex = new RegExp(searchWord, "i");
  var matched = tempArray[1].match(regex);

  tempArray[1] = tempArray[1].replace(regex, "<span>" + matched + "</span>");
  a.innerHTML = tempArray[1];
  a.setAttribute("target", "_blank");

  li.appendChild(a);

  return li;
}

// 入力にマッチする要素をさらに絞り込み、結果表示する処理
function narrowFavorites(searchWord) {
  // 検索を始めたらお気に入り一覧を非表示にする
  document.getElementsByTagName("div").item(2).style.display = "none";

  var parentNode = document.getElementById("resultArea");

  // 呼び出しのたびに結果表示エリアをクリア
  document.getElementsByTagName("div").item(1).style.display = "block";
  parentNode.innerHTML = "";

  // セットを回しながら合致する要素を結果表示エリアに表示
  resultSet.forEach(function (value) {
    // 検索文字列、検索対象ともに小文字同士で比較する
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
  h2Elem.innerHTML = "検索結果 (" + lis.length + ")";
}

// キーが押し上げられたら呼び出される処理
function searchFavorite() {
  var orgSearchWord = document.getElementById("searchWord").value;
  console.log(orgSearchWord);

  // セットは呼び出し毎にクリア
  resultSet.clear();

  // 検索文字列は小文字に変換する
  searchWord = new String(orgSearchWord).toLowerCase();

  // BSキーなどで入力エリアが空になったらリセット
  if (searchWord == "") {
    clearResult();
    return;
  }

  // URL<タブ>タイトル に入力文字がマッチしたら、セットに詰めていく
  var lis = document.getElementById("favoritesList").getElementsByTagName("li");

  for (var i = 0; i < lis.length; i++) {
    var a = lis[i].firstChild;

    var line = a.href + "\t" + a.innerHTML;

    // 検索文字列、検索対象ともに小文字同士で比較する
    if (line.toLowerCase().indexOf(searchWord) > 0) {
      resultSet.add(line);
    }
  }

  // 画面表示を行うため、絞り込み処理を実行
  narrowFavorites(orgSearchWord);
}

// リセット処理
function clearResult() {
  document.getElementsByTagName("div").item(1).style.display = "none";
  resultSet.clear();

  // 初期表示状態同様、お気に入り一覧を表示する
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
  Write-Output $htmlTemplate | Set-Content -Encoding UTF8 (Join-path $output_path "favorites_search.html")
}

function script:Main($favorites_path, $output_path) {
  $urlArray = getUrlArray $favorites_path
    
  createHtml $urlArray $output_path
}

Main $favorites_path $output_path
