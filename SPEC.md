# Hifresh - 商品点评社区

## 1. Concept & Vision

Hifresh 是一个商品点评社区，用户可以浏览商品分类、提交自己喜欢的商品链接、其他用户进行点评和打分。整体风格清新、年轻化，强调社区互动和真实评价。

## 2. Design Language

**Aesthetic**: 清新简洁，类似小红书 + 什么值得买的风格
**Colors**:
- Primary: `#FF6B35` (活力橙)
- Secondary: `#2EC4B6` (清新绿)
- Background: `#FAFAFA`
- Card: `#FFFFFF`
- Text: `#1A1A2E`
- Text Light: `#6B7280`
- Border: `#E5E7EB`
- Rating Gold: `#F59E0B`

**Typography**: 
- Headings: Inter (Google Fonts)
- Body: Inter
- Fallback: system-ui, sans-serif

**Motion**: 微动效，按钮悬停 scale 1.02，页面切换 fade-in 300ms

## 3. Layout & Structure

**页面结构**:
1. **导航栏**: Logo + 搜索 + 登录/用户菜单
2. **分类导航**: 横向滚动的分类标签
3. **商品瀑布流**: 卡片展示商品
4. **底部**: 版权信息

**响应式**: 移动端优先，桌面端最多3-4列瀑布流

## 4. Features & Interactions

### 核心功能

**浏览**:
- 分类筛选（点击分类标签过滤）
- 搜索商品（标题搜索）
- 瀑布流展示商品卡片

**商品卡片**:
- 商品图片、标题、分类标签
- 平均评分（星星 + 数字）
- 点评数量
- 提交者头像
- 点击进入详情页

**商品详情页**:
- 商品信息头部
- 原始链接按钮
- 点评列表（评分、内容、时间、用户）
- 提交点评表单（1-10分 + 文字）

**用户系统**:
- 邮箱注册/登录
- 手机号登录
- 用户名登录
- 个人主页（我的点评、我的发布）

**发布商品**:
- 选择分类
- 填写标题、描述、图片链接、商品链接
- 提交后显示在对应分类下

### 数据模型

**categories**: id, name, slug, icon, sort_order
**products**: id, category_id, title, description, image_url, product_url, user_id, created_at, avg_rating, review_count
**reviews**: id, product_id, user_id, rating(1-10), content, created_at
**profiles**: id, username, avatar_url, bio

### 错误处理
- 空分类: 显示"暂无商品，去发布一个吧"
- 加载失败: 显示重试按钮
- 未登录点评: 提示登录

## 5. Component Inventory

**NavBar**: Logo + 搜索框 + 登录按钮/用户菜单
**CategoryTabs**: 横向滚动分类标签，支持"全部"
**ProductCard**: 图片、标题、评分星星、点评数、发布者
**StarRating**: 1-10分显示为星星（满10星）
**ReviewItem**: 用户头像 + 用户名 + 评分 + 时间 + 内容
**AuthModal**: 登录/注册表单（邮箱/手机/用户名）
**ProductForm**: 发布商品表单
**ReviewForm**: 提交点评表单

## 6. Technical Approach

**Frontend**: 纯HTML + TailwindCSS + Alpine.js（单文件，无构建步骤）
**Backend**: Supabase (PostgreSQL + Auth + Row Level Security)
**Deployment**: 静态部署到 Vercel / Cloudflare Pages

**Supabase Schema**:
```sql
-- Categories
create table categories (
  id serial primary key,
  name text not null,
  slug text unique not null,
  icon text,
  sort_order int default 0
);

-- Products
create table products (
  id serial primary key,
  category_id int references categories(id),
  title text not null,
  description text,
  image_url text,
  product_url text,
  user_id text references auth.users(id),
  created_at timestamp default now(),
  avg_rating decimal(2,1) default 0,
  review_count int default 0
);

-- Reviews
create table reviews (
  id serial primary key,
  product_id int references products(id) on delete cascade,
  user_id text references auth.users(id),
  rating int check (rating >= 1 and rating <= 10),
  content text,
  created_at timestamp default now()
);

-- Profiles (extends auth.users)
create table profiles (
  id text references auth.users(id) primary key,
  username text unique not null,
  avatar_url text,
  bio text
);
```

**API Endpoints** (via Supabase client):
- `GET /categories` - 获取全部分类
- `GET /products?category_id=eq.X` - 按分类获取商品
- `POST /products` - 发布商品
- `GET /reviews?product_id=eq.X` - 获取商品点评
- `POST /reviews` - 提交点评
- `POST /auth/signup` - 注册
- `POST /auth/signin` - 登录