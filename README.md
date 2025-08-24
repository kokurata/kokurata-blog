# kokurata-blog

GitHub Pages で公開する日本語ブログのリポジトリです。`docs/` フォルダが公開対象で、Jekyll（GitHub Pages 管理版）でビルドされます。

URL:
- サイト: https://kokurata.github.io/kokurata-blog/
- フィード: https://kokurata.github.io/kokurata-blog/feed.xml

構成のポイント:
- `docs/_config.yml` にサイト設定（title/description/url/baseurl、プラグイン、著者、レイアウト既定など）。
- テーマは Primer ベース＋`docs/assets/styles.css` でカスタム。
- 記事は `docs/_posts/YYYY-MM-DD-title.md`。
- カテゴリ/タグ/アーカイブ導線あり。RSS 自動検出あり。

公開（初回/更新）手順
1) 記事を追加（例）
  - `docs/_posts/2025-08-23-welcome.md` を参考に、同形式の Markdown を作成。
2) 変更をコミットして GitHub に push

PowerShell（既にリモート設定済みの場合）:
```powershell
# 変更確認
git -C "C:\temp\githubpages" status

# 追加・コミット・プッシュ
git -C "C:\temp\githubpages" add -A
git -C "C:\temp\githubpages" commit -m "chore: publish new post"
git -C "C:\temp\githubpages" push
```

GitHub Pages の再ビルド確認（GitHub CLI を使用）
```powershell
# 直近の Pages デプロイワークフロー実行を取得
$run = gh run list --workflow "pages-build-deployment" --limit 1 --json databaseId,status,conclusion | ConvertFrom-Json
$runId = $run[0].databaseId

# 進行状況をウォッチ
gh run watch $runId

# 実行の詳細を表示
gh run view $runId --log
```

ブラウザでの確認
- サイト: https://kokurata.github.io/kokurata-blog/
- 反映直後はキャッシュを避けるため `?ts=<任意>` を末尾につける（例: `?ts=now`）。

よく使うコマンド（初期設定系）
```powershell
# まだ origin を設定していない場合
git -C "C:\temp\githubpages" remote add origin https://github.com/kokurata/kokurata-blog.git
git -C "C:\temp\githubpages" branch -M main
git -C "C:\temp\githubpages" push -u origin main
```

免責事項
本ブログはマイクロソフトの公式見解ではなく、筆者個人の見解になります。本ブログの内容（添付文書、リンク先などを含む）は作成日時点のものであり、予告なく変更される場合があります。実運用での適用は、必ず公式ドキュメントやサービス提供元で最新情報を確認してください。

---

記事を削除する場合
1) 物理削除（推奨）
```powershell
# 削除したい投稿ファイルを確認して削除
Remove-Item "C:\temp\githubpages\docs\_posts\2025-08-23-welcome.md"

# 変更をコミット・プッシュ
git -C "C:\temp\githubpages" add -A
git -C "C:\temp\githubpages" commit -m "chore(posts): remove 2025-08-23-welcome"
git -C "C:\temp\githubpages" push
```

2) 非公開化（ファイルは残す）
対象投稿の Front Matter に `published: false` を追加します。
```yaml
---
title: "タイトル"
date: 2025-08-23
categories: [Sample]
tags: [welcome]
published: false
---
```

タグの追加方法
1) 投稿にタグを付与
対象投稿の Front Matter の `tags:` に追加します。表記は任意ですが、当サイトでは小文字リンク（`/tags/<tag>.html`）になるため、タグ名の大文字小文字は統一推奨です。
```yaml
tags: [sharepoint, onedrive]
```

2) タグページを作成（必須）
投稿一覧・記事内のタグリンクは `/tags/<tag>.html` を参照します。新規タグを作ったら、次のスクリプトでタグページを作成してください。
```powershell
# 例: sharepoint タグページを作成
powershell -ExecutionPolicy Bypass -File .\create-tag-page.ps1 "sharepoint"

# 例: onedrive タグページを作成
powershell -ExecutionPolicy Bypass -File .\create-tag-page.ps1 "onedrive"

# 変更をコミット・プッシュ
git -C "C:\temp\githubpages" add -A
git -C "C:\temp\githubpages" commit -m "feat(tags): add tag pages for sharepoint, onedrive"
git -C "C:\temp\githubpages" push
```

タグの削除方法
1) 投稿からタグをすべて外す（検索の例）
```powershell
# タグ 'sharepoint' を含む投稿を検索
Select-String -Path "C:\temp\githubpages\docs\_posts\*.md" -Pattern "tags:|\bsharepoint\b" -Context 0,3
```
該当投稿の `tags:` から当該タグを削除し、コミット・プッシュします。

2) タグページを削除
投稿からタグを外した後、対応するページを削除します。
```powershell
Remove-Item "C:\temp\githubpages\docs\tags\sharepoint.html" -Force

git -C "C:\temp\githubpages" add -A
git -C "C:\temp\githubpages" commit -m "chore(tags): remove sharepoint tag page"
git -C "C:\temp\githubpages" push
```
（補足）タグページを残したままでもタグが付いた投稿が無ければ一覧には現れませんが、直接 URL にアクセスすると空のページが表示されます。リンク切れを避けるため、不要になったタグページは削除を推奨します。
