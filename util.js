// 入力にマッチする要素を格納するセット(重複なし、順序保持)
var resultSet = new Set();

// 入力にマッチする要素をさらに絞り込み、結果表示する処理
function narrowFavorites(searchWord) {
  var parentNode = document.getElementById("resultArea");
  
  // 呼び出しのたびに結果表示エリアをクリア
  parentNode.innerHTML = "";

  // セットを回しながら合致する要素を結果表示エリアに表示
  resultSet.forEach(function (value) {
    console.log(value);
    
    // 検索文字列、検索対象ともに小文字同士で比較する
    if (value.toLowerCase().indexOf(searchWord) > 0) {
      var li = document.createElement("li");

      // URL\tタイトル　を分割して配列化
      var tempArray = value.split("\t");

      // 結果表示はリンク形式にする(新規タブで表示)
      var a = document.createElement("a")
      a.href = tempArray[0];
      a.innerHTML = tempArray[1]
      a.setAttribute("target","_blank")

      li.appendChild(a);
      parentNode.appendChild(li);
    }
  });
}

// キーが押し上げられたら呼び出される処理
function searchFavorite() {
  // 検索を始めたらお気に入り一覧を非表示にする
  document.getElementById("favoritesList").style ="display:none";

  var searchWord = document.getElementById("searchWord").value;
  console.log(searchWord);

  // 検索文字列は小文字に変換する
  searchWord = new String(searchWord).toLowerCase();

  // BSキーなどで入力エリアが空になったらリセット
  if (searchWord == "") {
    clearResult();
    return;
  }

  //　すでにセットに要素が入っていたら絞り込み処理に移行
  if (resultSet.size > 0) {
    narrowFavorites(searchWord);
    return;
  }

  // 以降の処理はセットが空の時(一番最初に文字入力されたとき)に行われる
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
  narrowFavorites(searchWord);
}

// リセット処理
function clearResult() {
  document.getElementById("resultArea").innerHTML = "";
  resultSet.clear();

  // 初期表示状態同様、お気に入り一覧を表示する
  document.getElementById("favoritesList").style ="";
}
