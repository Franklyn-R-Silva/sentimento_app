-- Create table for gym exercises
CREATE TABLE IF NOT EXISTS public.gym_exercises (
    id uuid NOT NULL DEFAULT extensions.gen_random_uuid(),
    created_at timestamp with time zone DEFAULT now(),
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    name text NOT NULL,
    description text,
    exercise_qty integer,
    exercise_time text,
    stretching_name text,
    stretching_series integer,
    stretching_qty integer,
    stretching_time text,
    machine_photo_url text,
    stretching_photo_url text,
    day_of_week text, -- 'Segunda', 'Terça', etc.
    CONSTRAINT gym_exercises_pkey PRIMARY KEY (id)
);

-- Enable Row Level Security
ALTER TABLE public.gym_exercises ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view their own exercises" ON public.gym_exercises
    FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own exercises" ON public.gym_exercises
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own exercises" ON public.gym_exercises
    FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own exercises" ON public.gym_exercises
    FOR DELETE
    USING (auth.uid() = user_id);
