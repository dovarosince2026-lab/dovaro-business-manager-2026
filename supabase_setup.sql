-- DOVARO Business Manager - Supabase SQL setup
-- Supabase Dashboard > SQL Editor > New query > paste and Run.
-- Use a long, unique Business ID known only to you and your partner.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  business_id text,
  display_name text,
  email text,
  created_at timestamptz not null default now()
);

create table if not exists public.products (
 id uuid primary key default gen_random_uuid(), business_id text not null,
 created_by uuid not null references auth.users(id), name text not null,
 size text, color text, qty integer not null default 0 check(qty >= 0),
 cost numeric(12,2) not null default 0, price numeric(12,2) not null default 0,
 created_at timestamptz not null default now()
);
create table if not exists public.sales (
 id uuid primary key default gen_random_uuid(), business_id text not null,
 created_by uuid not null references auth.users(id), date date not null default current_date,
 product_id uuid, product_name text, size text, color text, qty integer not null default 1,
 price numeric(12,2) not null default 0, amount numeric(12,2) not null default 0,
 person text, payment text not null default 'paid', note text, created_at timestamptz not null default now()
);
create table if not exists public.purchases (
 id uuid primary key default gen_random_uuid(), business_id text not null,
 created_by uuid not null references auth.users(id), date date not null default current_date,
 product text not null, qty integer not null default 1, price numeric(12,2) not null default 0,
 amount numeric(12,2) not null default 0, person text, note text, created_at timestamptz not null default now()
);
create table if not exists public.expenses (
 id uuid primary key default gen_random_uuid(), business_id text not null,
 created_by uuid not null references auth.users(id), date date not null default current_date,
 category text not null, amount numeric(12,2) not null default 0, person text, note text,
 created_at timestamptz not null default now()
);
create table if not exists public.dues (
 id uuid primary key default gen_random_uuid(), business_id text not null,
 created_by uuid not null references auth.users(id), date date not null default current_date,
 person text not null, phone text, amount numeric(12,2) not null default 0,
 paid numeric(12,2) not null default 0, note text, created_at timestamptz not null default now()
);
create table if not exists public.partner_entries (
 id uuid primary key default gen_random_uuid(), business_id text not null,
 created_by uuid not null references auth.users(id), date date not null default current_date,
 kind text not null check(kind in ('capital','withdrawal')), person text not null,
 amount numeric(12,2) not null default 0, note text, created_at timestamptz not null default now()
);

-- Helper: users can only read/write rows in their assigned business.
create or replace function public.my_business_id()
returns text language sql stable security definer set search_path = public
as $$ select business_id from public.profiles where id = auth.uid() $$;

alter table public.profiles enable row level security;
drop policy if exists "profile self read" on public.profiles;
create policy "profile self read" on public.profiles for select to authenticated using (id = auth.uid());
drop policy if exists "profile self insert" on public.profiles;
create policy "profile self insert" on public.profiles for insert to authenticated with check (id = auth.uid());
drop policy if exists "profile self update" on public.profiles;
create policy "profile self update" on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

do $$ declare t text; begin
 foreach t in array array['products','sales','purchases','expenses','dues','partner_entries'] loop
   execute format('alter table public.%I enable row level security', t);
   execute format('drop policy if exists "shared business access" on public.%I', t);
   execute format(
    'create policy "shared business access" on public.%I for all to authenticated using (business_id = public.my_business_id()) with check (business_id = public.my_business_id())', t
   );
 end loop;
end $$;

grant usage on schema public to authenticated;
grant select, insert, update, delete on public.profiles, public.products, public.sales,
 public.purchases, public.expenses, public.dues, public.partner_entries to authenticated;
grant execute on function public.my_business_id() to authenticated;
