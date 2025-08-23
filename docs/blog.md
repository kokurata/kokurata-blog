---
layout: default
title: "ブログ記事一覧"
permalink: /blog/
---

# ブログ記事一覧

{% if site.posts.size > 0 %}
<div class="post-list">
  {% for post in site.posts %}
  <article class="post-preview">
    <h2><a href="{{ post.url | relative_url }}">{{ post.title | escape }}</a></h2>
    <p class="post-meta">
      <time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%Y年%m月%d日" }}</time>
      {% if post.author %} • {{ post.author }}{% endif %}
      {% if post.categories.size > 0 %}
      • カテゴリ: 
      {% for category in post.categories %}
        <span class="category">{{ category }}</span>{% unless forloop.last %}, {% endunless %}
      {% endfor %}
      {% endif %}
    </p>
    {% if post.excerpt %}
    <div class="post-excerpt">
      {{ post.excerpt | strip_html | truncatewords: 50 }}
      <a href="{{ post.url | relative_url }}">続きを読む →</a>
    </div>
    {% endif %}
  </article>
  <hr>
  {% endfor %}
</div>
{% else %}
<div class="no-posts">
  <p>投稿はまだありません。</p>
</div>
{% endif %}
