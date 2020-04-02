param(
    [string]$favorites_path    # 処理対象パス(ディレクトリでもファイル名でも受け付ける)
)

function script:Main($favorites_path) {
    $favorites = (Get-ChildItem -Recurse $favorites_path | Where-Object { $_.Attributes -ne "Directory" -and $_.Extension -eq ".url" })

    foreach ($favorite in $favorites) {
        $url = (get-content $favorite.fullname) -match "^URL=.+"
        Write-Host $favorite.fullname $url
    }
}

Main $favorites_path