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
    if (value.indexOf(searchWord) > 0) {
      var li = document.createElement("li");
      li.innerHTML = value;

      parentNode.appendChild(li);
    }
  });
}

// キーが押し上げられたら呼び出される処理
function searchFavorite() {
  var searchWord = document.getElementById("searchWord").value;
  console.log(searchWord);

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

    if (line.indexOf(searchWord) > 0) {
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
}
