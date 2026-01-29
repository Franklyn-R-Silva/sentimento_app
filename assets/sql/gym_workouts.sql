-- gym_workouts.sql
-- 1. Criar a tabela de grupos de treino (Gym Workouts)
CREATE TABLE IF NOT EXISTS gym_workouts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),
  user_id UUID REFERENCES auth.users NOT NULL,
  name TEXT NOT NULL,
  muscle_group TEXT,
  description TEXT,
  day_of_week TEXT,
  order_index INTEGER
);

-- Habilitar RLS para gym_workouts
ALTER TABLE gym_workouts ENABLE ROW LEVEL SECURITY;

-- Política de segurança para gym_workouts
DROP POLICY IF EXISTS "Users can manage their own workouts" ON gym_workouts;
CREATE POLICY "Users can manage their own workouts" ON gym_workouts
  FOR ALL TO authenticated USING (auth.uid() = user_id);

-- 2. Atualizar a tabela gym_exercises com os novos campos
DO $$
BEGIN
    -- Campo para o grupo de treino
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='gym_exercises' AND column_name='workout_id') THEN
        ALTER TABLE gym_exercises ADD COLUMN workout_id UUID REFERENCES gym_workouts(id) ON DELETE SET NULL;
    END IF;

    -- Campos de suporte (categoria, grupo muscular, etc)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='gym_exercises' AND column_name='category') THEN
        ALTER TABLE gym_exercises ADD COLUMN category TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='gym_exercises' AND column_name='muscle_group') THEN
        ALTER TABLE gym_exercises ADD COLUMN muscle_group TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='gym_exercises' AND column_name='sets') THEN
        ALTER TABLE gym_exercises ADD COLUMN sets INTEGER;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='gym_exercises' AND column_name='reps') THEN
        ALTER TABLE gym_exercises ADD COLUMN reps TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='gym_exercises' AND column_name='weight') THEN
        ALTER TABLE gym_exercises ADD COLUMN weight NUMERIC;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='gym_exercises' AND column_name='rest_time') THEN
        ALTER TABLE gym_exercises ADD COLUMN rest_time INTEGER;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='gym_exercises' AND column_name='is_completed') THEN
        ALTER TABLE gym_exercises ADD COLUMN is_completed BOOLEAN DEFAULT false;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='gym_exercises' AND column_name='order_index') THEN
        ALTER TABLE gym_exercises ADD COLUMN order_index INTEGER;
    END IF;

    -- Tempo de execução (para pranchas, cardio, etc)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='gym_exercises' AND column_name='exercise_time') THEN
        ALTER TABLE gym_exercises ADD COLUMN exercise_time TEXT;
    END IF;
END $$;
