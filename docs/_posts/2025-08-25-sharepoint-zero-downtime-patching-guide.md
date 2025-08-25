---
title: "SharePoint Server ゼロダウンタイム パッチ適用の実践ガイド"
date: 2025-08-25 09:00:00 +0900
categories: [SharePoint]
tags: [SharePoint, パッチ適用, Side-by-Side, ゼロダウンタイム]
excerpt: "SharePoint Server でのゼロダウンタイム パッチ適用について、Side-by-Side 機能の活用方法から複数台構成での手順まで詳しく解説します。"
---

## はじめに

SharePoint Server 環境において、サービスを停止せずに更新プログラムを適用する「ゼロダウンタイム パッチ適用」は、業務継続性の観点から非常に重要な技術です。本記事では、SharePoint Server 2016/2019 における Side-by-Side 機能を活用したゼロダウンタイム パッチ適用の具体的な手順と、よくある質問への回答をまとめました。

## 参考資料

ゼロダウンタイム パッチ適用については、以下の資料もご参照ください。

- [SharePoint Server 2016/2019 patching using side-by-side functionality explained](https://blog.stefan-gossner.com/2017/01/10/sharepoint-server-2016-patching-using-side-by-side-functionality-explained/)
- [ゼロ ダウンタイム修正プログラム適用のビデオ デモ (SharePoint Server 2016)](https://docs.microsoft.com/ja-jp/sharepoint/upgrade-and-update/video-demo-of-zero-downtime-patching-in-sharepoint-server-2016)

---

## Side-by-Side 機能の確認と有効化

### 有効化状況の確認

SharePoint 管理シェルから以下のコマンドを実行し、`EnableSideBySide` が `True` であれば有効化されています。

```powershell
# 有効化状況の確認
$webapp = Get-SPWebApplication <WebアプリケーションのURL>
$webapp.WebService.EnableSideBySide  # Trueなら有効、Falseなら無効

# 無効なら有効化
$webapp.WebService.EnableSideBySide = $true
$webapp.WebService.Update()
```

---

## ゼロダウンタイム パッチ適用の基本手順

### 1. Side-by-Side の有効化

はじめに以下のコマンドを実行し、Side-by-Side を有効化します。

```powershell
$webapp = Get-SPWebApplication <Web アプリケーション>
$webapp.WebService.EnableSideBySide = $true
$webapp.WebService.Update()
```

### 2. Side-by-Side ファイルのコピー

`C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\TEMPLATE\LAYOUTS` 配下に、「16.0.XXXXX.XXXXX」のフォルダーが存在することを確認してください。

存在しない場合は、以下のコマンドでコピー処理を実施します。

```powershell
Copy-SPSideBySideFiles -LogFile "C:\CopySideBySideFiles.log"
```

### 3. SideBySideToken で現在のバージョンを指定

```powershell
$webapp = Get-SPWebApplication <Web アプリケーション>
$webapp.WebService.SideBySideToken = "16.0.xxxxx.xxxxx"
$webapp.WebService.Update()
```

例：現在のバージョンが 16.0.10390.20000 の場合

```powershell
$webapp = Get-SPWebApplication <Web アプリケーション>
$webapp.WebService.SideBySideToken = "16.0.10390.20000"
$webapp.WebService.Update()
```

キャッシュをクリアするため、`iisreset` を実行します。

```cmd
iisreset
```

### 4. 更新プログラムの適用

[SharePoint Server ゼロダウンタイム修正プログラムの適用手順](https://learn.microsoft.com/ja-jp/sharepoint/upgrade-and-update/sharepoint-server-2016-zero-downtime-patching-steps) に従い更新プログラムを適用し、PSCONFIG を実行します。

```cmd
PSCONFIG.exe -cmd upgrade -inplace b2b -wait -cmd applicationcontent -install -cmd installfeatures -cmd secureresources -cmd services -install
```

### 5. カスタマイズの再適用（必要に応じて）

カスタマイズがある場合は再適用後、以下のコマンドを実行します。

```powershell
Copy-SPSideBySideFiles -LogFile "C:\CopySideBySideFiles.log"
```

### 6. 新しいバージョンの指定

ファーム内のすべてのサーバーのアップグレード処理完了後に新しいバージョンを指定します。

```powershell
$webapp = Get-SPWebApplication <Web アプリケーション>
$webapp.WebService.SideBySideToken = "16.0.10417.20037"
$webapp.WebService.Update()
```

---

## 複数台構成での適用手順

### フロントエンドサーバーが 3 台の場合

フロントエンドサーバーが 3 台ある場合、常に最低 2 台が稼働し続ける状態を維持できます。

#### フェーズ 1: パッチのインストール

1. WFE1 を LB から除外 → 更新プログラム適用 → 再起動 → LB に戻す
2. WFE2 を LB から除外 → 更新プログラム適用 → 再起動 → LB に戻す
3. WFE3 を LB から除外 → 更新プログラム適用 → 再起動 → LB へ戻さず待機
4. その他のサーバーも、更新プログラムを適用し、再起動

#### フェーズ 2: PSCONFIG のアップグレード

5. LB のローテーションから外れている WFE3 にて、PSCONFIG を実行 → LB 戻す

### AP/キャッシュ/検索サーバーの適用順序

各ロールのサーバーが冗長構成である場合、それぞれを同時に停止しないように注意しながら作業してください。各サーバーは以下の手順で実施します：

1. LB からの切り離し（LB 利用時）
2. 更新プログラムの適用
3. 再起動
4. LB への復帰（LB 利用時）

---

## 分散キャッシュの取り扱い

### 削除と追加のタイミング

分散キャッシュサービスは以下の順序で処理します：

```powershell
# 1. 分散キャッシュサービスの削除
Remove-SPDistributedCacheServiceInstance

# 2. PSCONFIG コマンドレットを実行
# （上記の PSCONFIG コマンド）

# 3. 分散キャッシュサービスの追加
Add-SPDistributedCacheServiceInstance
```

**注意：** PSCONFIG 実行中に AppFabric サービスが稼働していると、キャッシュ クラスターに不整合が発生する可能性があるため、事前にサービス インスタンスを停止する必要があります。

### サービスインスタンスの確認

`Add-SPDistributedCacheServiceInstance` コマンド実行後、以下のコマンドで状態を確認します。

```powershell
# 分散キャッシュ ホストの Status が Online であることを確認
$instanceName = "SPDistributedCacheService Name=AppFabricCachingService"
$serviceInstance = Get-SPServiceInstance | ? {($_.service.tostring()) -eq $instanceName}
$serviceInstance

# Service Status に UP が表示されることを確認
Use-CacheCluster
Get-CacheHost
```

---

## よくある質問

### Q1: Side-by-Side Token のビルド番号はどのように指定しますか？

A1: psconfig コマンド完了後に以下のフォルダーが作成されていることを確認してください。

```
C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\TEMPLATE\LAYOUTS\16.0.10417.20037
```

上記のフォルダーが作成されている場合は、そのバージョン番号を指定します。

```powershell
$webapp = Get-SPWebApplication <web アプリケーションのurl>
$webapp.WebService.SideBySideToken = "16.0.10417.20037"
$webapp.WebService.Update()
```

このコマンドは、任意の 1 台のフロントエンドサーバーで実行可能です。

### Q2: セキュリティ更新プログラムの適用順序は決まっていますか？

A2: 決まった適用順序はありませんので、どちらから実行しても問題ありません。

---

## 所要時間の見積もりについて

更新プログラムのインストールおよび製品構成ウィザードの実行に要する時間は、以下の要因に左右されます：

- サーバーの負荷状況
- ファーム構成
- ハードウェアの性能
- データベースの容量
- 検索インデックスの規模
- サービス アプリケーションの構成
- カスタマイズの有無

より正確な所要時間を見積もるには、本番環境と同等の構成およびデータ規模を備えた検証環境で実際に更新プログラムの適用と構成ウィザードの実行を行い、所要時間を計測することが最も有効です。

---

## まとめ

SharePoint Server のゼロダウンタイム パッチ適用は、Side-by-Side 機能を適切に活用することで実現できます。複数台構成の環境では、ロードバランサーからの切り離しと復帰を適切に管理し、分散キャッシュサービスの処理順序に注意することが重要です。

実際の適用前には、必ず検証環境での事前テストを実施し、本番環境に適した手順を確立することをお勧めします。
