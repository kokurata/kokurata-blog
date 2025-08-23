git remote add origin https://github.com/<OWNER>/<REPO>.git
git branch -M main
git push -u origin main
```
# GitHub Pages ブログ（サンプル）

このリポジトリは GitHub Pages で公開するための最小限の静的ブログのテンプレートです。サイトの公開用ファイルは `docs/` フォルダに置いてあります。

やること（大まかな流れ）:

1. ローカルでリポジトリを用意（このフォルダは既に準備済みです）。
2. GitHub に新しいリポジトリを作成する。
3. リモートを追加してプッシュする。
4. リポジトリの Settings > Pages で Branch を `main`、Folder を `/docs` に設定して公開する（多くの場合 GitHub が自動検出します）。

GitHub リポジトリの作り方（選択肢）:

- Web から作成: https://github.com/new で新しいリポジトリを作成します。
- GitHub CLI がインストール済みなら（便利）:

  gh repo create <OWNER>/<REPO> --public --source=. --remote=origin --push

例: PowerShell での基本的な手順（Web でリポジトリを作成した場合）:

```powershell
Set-Location -Path 'C:\temp\githubpages'
git remote add origin https://github.com/<OWNER>/<REPO>.git
git branch -M main
git push -u origin main
```

注意:
- `<OWNER>/<REPO>` は GitHub のユーザー名（または org）とリポジトリ名に置き換えてください。
- gh CLI で作成する場合は認証済みであることを確認してください。
- 自動で Markdown をビルドしたい、CI で公開したい等の要望があれば、追加で GitHub Actions のワークフローを用意できます。

ブログのトピック:

- SharePoint Online と OneDrive for Business
- SharePoint Server（オンプレミス）
- Microsoft Stream

免責事項:

本ブログはマイクロソフトの公式見解ではなく、筆者個人の見解になります。本ブログの内容（添付文書、リンク先などを含む）は作成日時点のものであり、予告なく変更される場合があります。実運用での適用は、必ず公式ドキュメントやサービス提供元で最新情報を確認してください。
