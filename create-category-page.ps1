# PowerShell script to create category pages for Jekyll blog
# Usage: .\create-category-page.ps1 "CategoryName"

param(
    [Parameter(Mandatory=$true)]
    [string]$CategoryName
)

$CategoryNameSafe = $CategoryName -replace '[^a-zA-Z0-9\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF]', '-'
$CategoryFileName = "${CategoryNameSafe}.html"
$CategoryFilePath = "docs\categories\${CategoryFileName}"

$CategoryPageContent = @"
---
layout: default
title: "カテゴリ: ${CategoryName}"
permalink: /categories/${CategoryFileName}
---

<div class="archive">
  <h1 class="page-title">カテゴリ: ${CategoryName}</h1>
  
  <p class="category-description">「${CategoryName}」カテゴリの記事一覧</p>
  
  {% assign category_posts = site.posts | where_exp: "post", "post.categories contains '${CategoryName}'" %}
  
  {% if category_posts.size > 0 %}
    <p class="post-count">{{ category_posts.size }}件の記事</p>
    
    {% for post in category_posts %}
      <article class="archive-article archive-type-post">
        <div class="archive-article-inner">
          <div class="article-meta">
            <a href="{{ post.url | relative_url }}" class="article-date">
              <time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%Y年%m月%d日" }}</time>
            </a>
            {% if post.categories and post.categories.size > 0 %}
              <div class="article-category">
                {% for category in post.categories %}
                  <a href="{{ '/categories/' | append: category | append: '.html' | relative_url }}" class="article-category-link">{{ category }}</a>
                {% endfor %}
              </div>
            {% endif %}
          </div>
          <div class="article-inner">
            <header class="article-header">
              <h3 class="article-title">
                <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
              </h3>
            </header>
            {% if post.excerpt %}
              <div class="article-entry">
                {{ post.excerpt | strip_html | truncatewords: 30 }}
              </div>
            {% endif %}
            {% if post.tags and post.tags.size > 0 %}
              <div class="article-tag-list">
                {% for tag in post.tags %}
                  <a href="{{ '/tags/' | append: tag | downcase | append: '.html' | relative_url }}" class="article-tag-list-link">#{{ tag }}</a>
                {% endfor %}
              </div>
            {% endif %}
          </div>
        </div>
      </article>
    {% endfor %}
  {% else %}
    <p>このカテゴリの記事はまだありません。</p>
  {% endif %}
  
  <div class="category-navigation">
    <a href="{{ '/categories/' | relative_url }}" class="btn">すべてのカテゴリを見る</a>
  </div>
</div>

<style>
.category-description {
  margin-bottom: 20px;
  font-size: 16px;
  color: #666;
}

.post-count {
  margin-bottom: 30px;
  font-weight: bold;
  color: #0366d6;
}

.category-navigation {
  margin-top: 40px;
  text-align: center;
}

.btn {
  display: inline-block;
  padding: 10px 20px;
  background-color: #0366d6;
  color: white;
  text-decoration: none;
  border-radius: 6px;
  transition: background-color 0.3s ease;
}

.btn:hover {
  background-color: #0256cc;
  color: white;
  text-decoration: none;
}
</style>
"@

# Create the category page file
if (!(Test-Path "docs\categories")) {
    New-Item -ItemType Directory -Path "docs\categories" -Force
}

$CategoryPageContent | Out-File -FilePath $CategoryFilePath -Encoding UTF8

Write-Host "カテゴリページを作成しました: $CategoryFilePath"
Write-Host "URL: /categories/${CategoryFileName}"
