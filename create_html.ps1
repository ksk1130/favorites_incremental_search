param(
    [string]$favorites_path    # 処理対象パス(ディレクトリでもファイル名でも受け付ける)
)

function script:getURLArray($favorites_path){
    $favorites = (Get-ChildItem -Recurse $favorites_path | Where-Object { $_.Attributes -ne "Directory" -and $_.Extension -eq ".url" })

    foreach ($favorite in $favorites) {
        $tempVal = (get-content $favorite.fullname) -match "^URL=.+"
        $url = $tempVal[0].Substring(4,$tempVal[0].Length-4)

        $urlArray += ,@($favorite.fullname,$url)
    }
    return $urlArray
}

function script:Main($favorites_path) {
    $urlArray = getUrlArray $favorites_path
    
    foreach($cols in $urlArray){
        write-host $cols[0] $cols[1]
    }
}

Main $favorites_path