---
layout: default
title: ホーム
---

# 私のブログ

このブログでは主に以下の製品について投稿します。

- SharePoint Online と OneDrive for Business
- SharePoint Server（オンプレミス）
- Microsoft Stream

最新記事は以下に表示されます。

{% for post in site.posts %}
- [{{ post.title }}]({{ post.url }}) — {{ post.date | date: "%Y-%m-%d" }}
{% endfor %}