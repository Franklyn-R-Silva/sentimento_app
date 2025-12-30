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

-- Criação da tabela de perfis de usuário (app_profiles)
create table public.app_profiles (
  id uuid references auth.users not null primary key,
  updated_at timestamptz,
  username text unique,
  full_name text,
  avatar_url text,
  website text,
  matricula int4,
  tipo_permissao text
);

-- Habilitar Row Level Security (RLS)
alter table public.app_profiles enable row level security;

-- Políticas de Segurança para app_profiles
create policy "Perfis são visíveis publicamente"
  on public.app_profiles for select
  using (true);

create policy "Usuários podem inserir seu próprio perfil"
  on public.app_profiles for insert
  with check (auth.uid() = id);

create policy "Usuários podem atualizar seu próprio perfil"
  on public.app_profiles for update
  using (auth.uid() = id);

-- Função e Trigger para criar perfil automaticamente ao cadastrar usuário (Opcional, mas recomendado)
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.app_profiles (id, username, full_name, avatar_url)
  values (
    new.id,
    new.raw_user_meta_data->>'username',
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'avatar_url'
  );
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Criação da tabela de metas
create table public.metas (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null default auth.uid(),
  titulo text not null,
  descricao text,
  categoria text not null default 'geral',
  tipo text not null default 'streak', -- streak, contador, habito
  meta_valor int default 1,
  valor_atual int default 0,
  icone text default '🎯',
  cor text default '#7C4DFF',
  frequencia text default 'diaria', -- diaria, semanal, mensal
  ativo boolean default true,
  concluido boolean default false,
  data_inicio timestamptz default now(),
  data_fim timestamptz,
  criado_em timestamptz default now() not null
);

-- Habilitar Row Level Security (RLS) para metas
alter table public.metas enable row level security;

-- Políticas de Segurança para metas
create policy "Usuários podem ver suas próprias metas"
  on public.metas for select
  using (auth.uid() = user_id);

create policy "Usuários podem inserir suas próprias metas"
  on public.metas for insert
  with check (auth.uid() = user_id);

create policy "Usuários podem atualizar suas próprias metas"
  on public.metas for update
  using (auth.uid() = user_id);

create policy "Usuários podem deletar suas próprias metas"
  on public.metas for delete
  using (auth.uid() = user_id);

-- Criação da tabela de fotos anuais (Projeto 365 dias)
create table public.fotos_anuais (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null default auth.uid(),
  image_url text not null,
  frase text,
  mood_level int2 check (mood_level >= 1 and mood_level <= 5),
  tags text[],
  lat float8,
  lng float8,
  data_foto timestamptz default now() not null,
  criado_em timestamptz default now() not null
);

-- Habilitar Row Level Security (RLS) para fotos_anuais
alter table public.fotos_anuais enable row level security;

-- Políticas de Segurança para fotos_anuais
create policy "Usuários podem ver suas próprias fotos"
  on public.fotos_anuais for select
  using (auth.uid() = user_id);

create policy "Usuários podem inserir suas próprias fotos"
  on public.fotos_anuais for insert
  with check (auth.uid() = user_id);

create policy "Usuários podem atualizar suas próprias fotos"
  on public.fotos_anuais for update
  using (auth.uid() = user_id);

create policy "Usuários podem deletar suas próprias fotos"
  on public.fotos_anuais for delete
  using (auth.uid() = user_id);

-- Recomendações de Índices para Performance
create index if not exists idx_entradas_humor_user_id on public.entradas_humor(user_id);
create index if not exists idx_metas_user_id on public.metas(user_id);
create index if not exists idx_fotos_anuais_user_id on public.fotos_anuais(user_id);
create index if not exists idx_fotos_anuais_data_foto on public.fotos_anuais(data_foto);

-- Configuração de Segurança para o Bucket de Storage (fotos_anuais)
-- Nota: O bucket deve ser criado manualmente no painel como 'fotos_anuais'

-- Permite que usuários autenticados vejam qualquer foto (Bucket Público)
create policy "Fotos são visíveis publicamente"
on storage.objects for select
to authenticated
using (bucket_id = 'fotos_anuais');

-- Permite que usuários façam upload apenas para sua própria pasta
create policy "Usuários podem fazer upload de suas próprias fotos"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'fotos_anuais' AND
  (storage.foldername(name))[1] = 'users' AND
  (storage.foldername(name))[2] = auth.uid()::text
);

-- Permite que usuários deletem suas próprias fotos
create policy "Usuários podem deletar suas próprias fotos"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'fotos_anuais' AND
  (storage.foldername(name))[1] = 'users' AND
  (storage.foldername(name))[2] = auth.uid()::text
);

-- Configuração de Segurança para o Bucket de Storage (avatars)
-- Nota: O bucket deve ser criado manualmente no painel como 'avatars'

-- Permite que qualquer pessoa veja os avatares (Público)
create policy "Avatares são visíveis publicamente"
on storage.objects for select
to public
using (bucket_id = 'avatars');

-- Permite que usuários autenticados façam upload apenas de seu próprio avatar
create policy "Usuários podem fazer upload de seu próprio avatar"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Permite que usuários atualizem seu próprio avatar
create policy "Usuários podem atualizar seu próprio avatar"
on storage.objects for update
to authenticated
using (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Permite que usuários deletem seu próprio avatar
create policy "Usuários podem deletar seu próprio avatar"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

