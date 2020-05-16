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
      var li = document.createElement("li");

      // URL\tタイトル　を分割して配列化
      var tempArray = value.split("\t");

      // 結果表示はリンク形式にする(新規タブで表示)
      var a = document.createElement("a");
      a.href = tempArray[0];

      // マッチする文字列に着色する
      // マッチする文字列を取得
      var regex = new RegExp(searchWord, "gi");
      var matched = tempArray[1].match(regex);

      tempArray[1] = tempArray[1].replace(
        regex,
        "<span>" + matched + "</span>"
      );
      a.innerHTML = tempArray[1];
      a.setAttribute("target", "_blank");

      li.appendChild(a);
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
    var li = lis[i];
    var a = li.firstChild;

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
