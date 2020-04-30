function searchFavorite(){
    console.log(document.getElementById("searchWord").value);

    console.log(document.getElementById("favoritesList"));

    document.getElementById("resultArea").innerHTML = document.getElementById("searchWord").value;
}

function clearResult(){
    document.getElementById("resultArea").innerHTML = "";
}
