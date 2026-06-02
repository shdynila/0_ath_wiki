# Sync Obsidian Vault to Hugo Content
$obsidianVault = "C:\Users\nil\Documents\0ath"
$hugoContent = "C:\Users\nil\Desktop\prjcts\0_ath_wiki\content"

# Copy everything except the Wiki_Repo junction/symlink
Get-ChildItem -Path $obsidianVault -Exclude "Wiki_Repo" | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $hugoContent -Recurse -Force
}

# Rename README.md to _index.md to serve as the Hugo homepage
if (Test-Path "$hugoContent\README.md") {
    if (Test-Path "$hugoContent\_index.md") {
        Remove-Item -Path "$hugoContent\_index.md" -Force
    }
    Rename-Item -Path "$hugoContent\README.md" -NewName "_index.md" -Force
}

Write-Host "Synced Obsidian vault to Hugo!"
