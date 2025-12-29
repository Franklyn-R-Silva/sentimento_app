-- Criação da tabela de entradas de humor
create table public.entradas_humor (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null default auth.uid(),
  nota int2 not null check (nota >= 1 and nota <= 5),
  nota_texto text,
  tags text[],
  criado_em timestamptz default now() not null
);

-- Habilitar Row Level Security (RLS)
alter table public.entradas_humor enable row level security;

-- Política para permitir que usuários vejam apenas suas próprias entradas
create policy "Usuários podem ver suas próprias entradas"
on public.entradas_humor
for select using (auth.uid() = user_id);

-- Política para permitir que usuários insiram suas próprias entradas
create policy "Usuários podem inserir suas próprias entradas"
on public.entradas_humor
for insert with check (auth.uid() = user_id);

-- Política para permitir que usuários atualizem suas próprias entradas
create policy "Usuários podem atualizar suas próprias entradas"
on public.entradas_humor
for update using (auth.uid() = user_id);

-- Política para permitir que usuários deletem suas próprias entradas
create policy "Usuários podem deletar suas próprias entradas"
on public.entradas_humor
for delete using (auth.uid() = user_id);
