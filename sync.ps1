# Sync Obsidian Vault to Hugo Content
$obsidianVault = "C:\Users\nil\Documents\0ath"
$hugoContent = "C:\Users\nil\Desktop\prjcts\0_ath_wiki\content"

# Copy everything
Copy-Item -Path "$obsidianVault\*" -Destination $hugoContent -Recurse -Force

# Rename README.md to _index.md to serve as the Hugo homepage
if (Test-Path "$hugoContent\README.md") {
    Rename-Item -Path "$hugoContent\README.md" -NewName "_index.md" -Force
}

Write-Host "Synced Obsidian vault to Hugo!"
