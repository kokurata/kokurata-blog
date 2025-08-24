---
title: "SharePoint Server 2016 / 2019 分散キャッシュ サービス再構成手順"
date: 2025-08-24 10:30:00 +0900
categories: [SharePoint]
tags: [SharePoint, 分散キャッシュ,SharePoint Server 2016,SharePoint Server 2019]
excerpt: "SharePoint Server 2016 / 2019 環境で分散キャッシュ サービスを一度削除して再構成する手順のまとめ。プロキシ設定の確認から、既存ホストの削除、再構成とクラスタ確認までを解説します。"
---

## はじめに

SharePoint Server 環境では、分散キャッシュ サービス (Distributed Cache Service) がセッション状態の管理やニュースフィード機能などに利用されています。 しかし、構成に不整合が生じたり、サービスが正しく起動しない状態になることがあります。そのような場合には、一度サービスを削除して再構成することで復旧を図るのが有効です。

本記事では、SharePoint Server 2016 および SharePoint Server 2019 に適用できる分散キャッシュ サービスの削除・再構成手順を解説します。

## 手順の概要

分散キャッシュ サービスの再構成は、以下の 3 ステップで行います。

1. ファーム アカウントの IE プロキシ設定をオフにする
2. 既存の分散キャッシュ ホストをファームから削除する
3. 分散キャッシュ ホストを再構成する

---

## 1. ファーム アカウントの IE プロキシ設定を変更

分散キャッシュの構成では、ファーム アカウント (SharePoint Timer Service 実行アカウント) のプロキシ設定が影響する場合があります。以下の手順でオフにしてください。

1) 任意の SharePoint サーバーにファーム アカウントでログオンし、IE を起動

2) [ツール] → [インターネット オプション] → [接続] → [LAN の設定] を開く

3) すべてのチェックをオフにして保存

4) 管理者権限でコマンド プロンプトを開き、以下を実行

```cmd
netsh winhttp show proxy
```

→ 「直接アクセス (プロキシ サーバーなし)」と表示されれば OK

異なる結果が出た場合は以下を実行

```cmd
netsh winhttp import proxy source=ie
```

5) 残りのすべての SharePoint サーバーでも同様に実施

---

## 2. 分散キャッシュ ホストをファームから削除

不整合を解消するため、一度サービスを削除します。

1) 管理者アカウントでサーバーにログオンし、SharePoint 管理シェルを管理者権限で起動

2) 以下を実行

```powershell
Remove-SPDistributedCacheServiceInstance
```

3) すべての SharePoint サーバーで同様に実行

4) SQL Server Management Studio (SSMS) を開き、構成データベースに接続し以下を実行

```sql
USE <構成データベース名>
exec proc_getCacheConfigEntries @type=N'hosts'
SELECT * FROM Objects 
WHERE Properties LIKE '%SPDistributedCacheServiceInstance%' 
   OR Properties LIKE '%SPDistributedCacheHostInfo%';
```

5) 結果が空であることを確認

6) 結果が残っている場合は PowerShell で再度サービス インスタンス削除を実施。それでも残る場合は、構成 DB のバックアップを取得した上で対応を検討

---

## 3. 分散キャッシュ ホストを再構成

削除が完了したら、新しく分散キャッシュを構成します。

1) 管理者アカウントでサーバーにログオンし、管理シェルを起動

2) 以下を実行してサービスを追加

```powershell
Add-SPDistributedCacheServiceInstance
```

3) 以下を実行し、Status が Online であることを確認

```powershell
$instanceName = "SPDistributedCacheService Name=AppFabricCachingService"
Get-SPServiceInstance | ? { ($_.Service.ToString()) -eq $instanceName }
```

4) 各サーバーでサービスを開始

```powershell
$instanceName = "SPDistributedCacheService Name=AppFabricCachingService"
$serviceInstance = Get-SPServiceInstance | ? {
    ($_.Service.ToString()) -eq $instanceName -and 
    ($_.Server.Name) -eq $env:computername
}
$serviceInstance.Provision()
```

5) 最後にクラスタ全体を確認

```powershell
Use-CacheCluster
Get-CacheHost
```

→ すべてのホストが UP と表示されれば正常完了。 ※「UNKNOWN」と表示される場合は 10 分程度待ってから再実行してください。

---

## まとめ

- 本手順は SharePoint Server 2016 および SharePoint Server 2019 に適用可能
- プロキシ設定の確認は最初に必須
- 削除は「全サーバー → 構成 DB 確認」がポイント
- 再構成後は全ホストの状態を必ず確認

分散キャッシュは SharePoint 環境の安定性・パフォーマンスに直結する重要なコンポーネントです。トラブル発生時には「削除 → 再構成」のフローを実施することで、安定動作を取り戻すことができます。
