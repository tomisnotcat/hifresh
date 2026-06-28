-- Hifresh 数据库 schema
-- 运行这个 SQL 来创建所有表

-- 1. 分类表
create table if not exists categories (
  id serial primary key,
  name text not null,
  slug text unique not null,
  icon text,
  sort_order int default 0
);

-- 2. 用户资料表（扩展 auth.users）
create table if not exists profiles (
  id text references auth.users(id) on delete cascade primary key,
  username text unique not null,
  avatar_url text,
  bio text,
  created_at timestamp default now()
);

-- 3. 商品表
create table if not exists products (
  id serial primary key,
  category_id int references categories(id) on delete set null,
  title text not null,
  description text,
  image_url text,
  product_url text,
  user_id text references auth.users(id) on delete set null,
  created_at timestamp default now(),
  avg_rating decimal(3,1) default 0,
  review_count int default 0
);

-- 4. 点评表
create table if not exists reviews (
  id serial primary key,
  product_id int references products(id) on delete cascade,
  user_id text references auth.users(id) on delete set null,
  rating int check (rating >= 1 and rating <= 10),
  content text,
  created_at timestamp default now()
);

-- 触发器：新增点评时自动更新商品评分
create or replace function update_product_rating()
returns trigger as $$
begin
  update products set
    avg_rating = (select avg(rating) from reviews where product_id = NEW.product_id),
    review_count = (select count(*) from reviews where product_id = NEW.product_id)
  where id = NEW.product_id;
  return NEW;
end;
$$ language plpgsql;

create trigger on_review_insert
  after insert on reviews
  for each row execute function update_product_rating();

-- 触发器：删除点评时自动更新商品评分
create or replace function update_product_rating_on_delete()
returns trigger as $$
begin
  update products set
    avg_rating = coalesce((select avg(rating) from reviews where product_id = OLD.product_id), 0),
    review_count = (select count(*) from reviews where product_id = OLD.product_id)
  where id = OLD.product_id;
  return OLD;
end;
$$ language plpgsql;

create trigger on_review_delete
  after delete on reviews
  for each row execute function update_product_rating_on_delete();

-- 触发器：创建用户时自动创建 profile
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into profiles (id, username)
  values (NEW.id, NEW.raw_user_meta_data->>'username');
  return NEW;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- 5. RLS 策略（行级安全）
alter table profiles enable row level security;
alter table products enable row level security;
alter table reviews enable row level security;

-- profiles: 所有人可读，自己可写
create policy "Profiles are viewable by everyone" on profiles for select using (true);
create policy "Users can update own profile" on profiles for update using (auth.uid() = id);

-- products: 所有人可读，登录用户可创建
create policy "Products are viewable by everyone" on products for select using (true);
create policy "Authenticated users can insert products" on products for insert with check (auth.role() = 'authenticated');

-- reviews: 所有人可读，登录用户可创建，不可删除他人点评
create policy "Reviews are viewable by everyone" on reviews for select using (true);
create policy "Authenticated users can insert reviews" on reviews for insert with check (auth.role() = 'authenticated');

-- 6. 初始化分类数据
insert into categories (name, slug, icon, sort_order) values
  ('手机数码', 'phones', '📱', 1),
  ('电脑办公', 'computers', '💻', 2),
  ('数码配件', 'accessories', '🎧', 3),
  ('服装内衣', 'clothing', '👕', 4),
  ('鞋靴箱包', 'shoes-bags', '👜', 5),
  ('美妆护肤', 'beauty', '💄', 6),
  ('食品生鲜', 'food', '🍎', 7),
  ('饮料酒水', 'drinks', '🥤', 8),
  ('母婴玩具', 'baby-toys', '🧸', 9),
  ('图书音像', 'books', '📚', 10),
  ('家用电器', 'appliances', '🏠', 11),
  ('家居日用', 'home', '🛋️', 12),
  ('家纺厨具', 'bedding', '🛏️', 13),
  ('运动户外', 'sports', '⚽', 14),
  ('汽车用品', 'auto', '🚗', 15),
  ('珠宝手表', 'jewelry', '⌚', 16),
  ('宠物生活', 'pets', '🐶', 17),
  ('农资绿植', 'garden', '🌿', 18),
  ('医药保健', 'health', '💊', 19),
  ('钟表眼镜', 'glasses', '👓', 20)
on conflict (slug) do nothing;