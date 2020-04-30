var resultSet = new Set();

function narrowFavorites(searchWord) {
  var parentNode = document.getElementById("resultArea");
  parentNode.innerHTML = "";

  resultSet.forEach(function (value) {
    console.log(value);
    if (value.indexOf(searchWord) > 0) {
      var li = document.createElement("li");
      li.innerHTML = value;

      parentNode.appendChild(li);
    }
  });
}

function searchFavorite() {
  var searchWord = document.getElementById("searchWord").value;
  console.log(searchWord);

  if (searchWord == "") {
    clearResult();
    return;
  }

  if (resultSet.size > 0) {
    narrowFavorites(searchWord);
    return;
  }

  var lis = document.getElementById("favoritesList").getElementsByTagName("li");

  for (var i = 0; i < lis.length; i++) {
    var li = lis[i];
    var a = li.firstChild;

    var line = a.href + "\t" + a.innerHTML;

    if (line.indexOf(searchWord) > 0) {
      resultSet.add(line);
    }
  }

  narrowFavorites(searchWord);
}

function clearResult() {
  document.getElementById("resultArea").innerHTML = "";
  resultSet.clear();
}
