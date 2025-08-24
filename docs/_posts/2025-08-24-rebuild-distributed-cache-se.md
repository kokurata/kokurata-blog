---
title: "SharePoint Server Subscription Edition: 分散キャッシュ ホストの再構築手順（単一サーバー ファーム）"
date: 2025-08-24
categories: [SharePoint]
tags: [SharePoint, 分散キャッシュ, SharePoint Server Subscription Edition]
excerpt: "SharePoint Server Subscription Edition の単一サーバー ファームで分散キャッシュを再構築する手順です。"
---

本記事では、SharePoint Server Subscription Edition を単一サーバー構成で利用している環境を前提に、分散キャッシュ (Distributed Cache) ホストを再構築する手順をご紹介します。

目次

a. 分散キャッシュ ホストをファームから削除する

b. 分散キャッシュ ホストを構成する

---

## a. 分散キャッシュ ホストをファームから削除する

1) SharePoint サーバーに管理者アカウントでログオンし、[SharePoint 管理シェル] を管理者権限で開始します。

2) 以下のコマンドを実行してサービス インスタンスを削除します。

```powershell
Remove-SPDistributedCacheServiceInstance;
```

3) SQL Server に管理者アカウントでログオンし、SQL Server Management Studio を開始してデータベース インスタンスに接続します。

4) [新しいクエリ] をクリックし、クエリ ウィンドウに下記を入力して [実行] をクリックします。

```sql
USE <構成データベース名>
SELECT * FROM CacheClusterConfig WHERE EntryType = 'hosts';
SELECT * FROM Objects WHERE Properties LIKE '%SPDistributedCacheServiceInstance%';
SELECT * FROM Objects WHERE Properties LIKE '%SPDistributedCacheHostInfo%';
```

例:

```sql
USE SharePoint_Config
SELECT * FROM CacheClusterConfig WHERE EntryType = 'hosts';
SELECT * FROM Objects WHERE Properties LIKE '%SPDistributedCacheServiceInstance%';
SELECT * FROM Objects WHERE Properties LIKE '%SPDistributedCacheHostInfo%';
```

6) 結果ウィンドウに結果が何も表示されないことを確認します。

⚠️ 結果が表示された場合は、分散キャッシュ サービスの構成情報が削除されていないため、以下を追加で実施してください。

6-a) SharePoint サーバーの [SharePoint 管理シェル] で下記のコマンドを実行します。

```powershell
$instanceName ="SPDistributedCacheService Name=SPCache"
$serviceInstance = Get-SPServiceInstance | ? {($_.service.tostring()) -eq $instanceName -and ($_.server.name) -eq $env:computername}
If($serviceInstance -ne $null)
{
    $serviceInstance.Delete()
}
```

6-b) SSMS で再度クエリを実行し、結果が表示されないことを確認

6-c) 引き続き、結果が表示される場合は、以下のコマンドを実行します。

```powershell
Add-SPDistributedCacheServiceInstance;
Remove-SPDistributedCacheServiceInstance;
```

6-d) SSMS で再度クエリを実行し、結果が表示されないことを確認。それでも表示される場合は、結果を記録してください。

---

## b. 分散キャッシュ ホストを構成する

1) 分散キャッシュ サービスを開始する SharePoint サーバーに管理者アカウントでログオンし、[SharePoint 管理シェル] を管理者権限で開始します。

2) 以下のコマンドを実行してサービス インスタンスを追加します。

```powershell
Add-SPDistributedCacheServiceInstance;
```

3) 以下のコマンドを順に実行し、分散キャッシュホストの Status が Online であることを確認します。

```powershell
$instanceName ="SPDistributedCacheService Name=SPCache"
$serviceInstance = Get-SPServiceInstance | ? {($_.service.tostring()) -eq $instanceName -and ($_.server.name) -eq $env:computername}
$serviceInstance
```

4) 分散キャッシュ サービスを開始させる SharePoint サーバーで下記のコマンドを実行し、サービス インスタンスを開始します。

```powershell
$instanceName ="SPDistributedCacheService Name=SPCache"
$serviceInstance = Get-SPServiceInstance | ? {($_.service.tostring()) -eq $instanceName -and ($_.server.name) -eq $env:computername}
$serviceInstance.Provision()
```

5) 以下のコマンドを実行し、分散キャッシュ ホストの Status が Online であることを確認します。

```powershell
$instanceName ="SPDistributedCacheService Name=SPCache"
$serviceInstance = Get-SPServiceInstance | ? {($_.service.tostring()) -eq $instanceName}
$serviceInstance
```

6) 以下のコマンドを実行し、分散キャッシュホストの Service Status に UP が表示されることを確認します。

```powershell
Get-SPCacheHost -HostName <ホスト名> -CachePort 22233
```

注: コマンドの結果が表示されるまでに時間がかかり、Status が UNKNOWN と表示される場合は分散キャッシュ サービスの構成が完了していません。10 分程度待ってから再度上記のコマンドを実行してください。

実行例:

```
> Get-SPCacheHost -HostName hosta -CachePort 22233

HostName : CachePort    Service Name Service Status Version Info
--------------------    ------------ -------------- ------------
Hosta.contoso.lab:22233 SPCache      UNKNOWN        3 [3,3][1,3]

> Get-SPCacheHost -HostName hosta -CachePort 22233

HostName : CachePort    Service Name Service Status Version Info
--------------------    ------------ -------------- ------------
Hosta.contoso.lab:22233 SPCache      UP             3 [3,3][1,3]
```

7) 事象が解消されているか確認してください。

---

## トラブルシューティング用コマンド

再構築後もエラーが続く場合は、以下の情報を取得して調査を進めてください。

### サービス インスタンス情報

```powershell
$instanceName ="SPDistributedCacheService Name=SPCache"
$serviceInstance = Get-SPServiceInstance | ? {($_.service.tostring()) -eq $instanceName -and ($_.server.name) -eq $env:computername}
$serviceInstance
```

### キャッシュ ホストの状態

```powershell
Get-SPCacheHost -HostName <ホスト名> -CachePort 22233
```

### キャッシュ ホスト構成

```powershell
Get-SPCacheHostConfig -HostName <ホスト名>
```

### キャッシュ クラスター情報

```powershell
Get-SPCacheClusterInfo
```

### キャッシュ クラスター構成のエクスポート

```powershell
Export-SPCacheClusterConfig -Path c:\temp\clusterconfig.xml
```
