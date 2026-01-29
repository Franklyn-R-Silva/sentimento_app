-- ============================================
-- Create gym_logs table for workout history
-- ============================================

CREATE TABLE IF NOT EXISTS gym_logs (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    exercise_id UUID NOT NULL REFERENCES gym_exercises(id) ON DELETE CASCADE,
    exercise_name TEXT,
    weight DOUBLE PRECISION,
    reps INTEGER,
    series INTEGER,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Create indexes for faster queries
-- ============================================

CREATE INDEX IF NOT EXISTS idx_gym_logs_user_id ON gym_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_gym_logs_exercise_id ON gym_logs(exercise_id);
CREATE INDEX IF NOT EXISTS idx_gym_logs_created_at ON gym_logs(created_at DESC);

-- ============================================
-- Enable Row Level Security (RLS)
-- ============================================

ALTER TABLE gym_logs ENABLE ROW LEVEL SECURITY;

-- ============================================
-- RLS Policies
-- ============================================

-- Users can view their own logs
CREATE POLICY "Users can view their own logs"
    ON gym_logs FOR SELECT
    USING (auth.uid() = user_id);

-- Users can insert their own logs
CREATE POLICY "Users can insert their own logs"
    ON gym_logs FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own logs
CREATE POLICY "Users can update their own logs"
    ON gym_logs FOR UPDATE
    USING (auth.uid() = user_id);

-- Users can delete their own logs
CREATE POLICY "Users can delete their own logs"
    ON gym_logs FOR DELETE
    USING (auth.uid() = user_id);
