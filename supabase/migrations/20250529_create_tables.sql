-- Create profiles table for user information
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users PRIMARY KEY,
  nickname TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create sleep_sessions table with user_id reference
CREATE TABLE IF NOT EXISTS sleep_sessions (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE NOT NULL,
  session_directory TEXT,
  sleep_score INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Index on user_id for faster queries
  CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);
CREATE INDEX idx_sleep_sessions_user_id ON sleep_sessions(user_id);

-- Create snoring_events table
CREATE TABLE IF NOT EXISTS snoring_events (
  id UUID PRIMARY KEY,
  session_id UUID NOT NULL,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE NOT NULL,
  duration_seconds INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  CONSTRAINT fk_session FOREIGN KEY (session_id) REFERENCES sleep_sessions(id) ON DELETE CASCADE
);
CREATE INDEX idx_snoring_events_session_id ON snoring_events(session_id);

-- Create sleep_talking_events table
CREATE TABLE IF NOT EXISTS sleep_talking_events (
  id UUID PRIMARY KEY,
  session_id UUID NOT NULL,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE NOT NULL,
  duration_seconds INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  CONSTRAINT fk_session FOREIGN KEY (session_id) REFERENCES sleep_sessions(id) ON DELETE CASCADE
);
CREATE INDEX idx_sleep_talking_events_session_id ON sleep_talking_events(session_id);

-- Create RLS (Row Level Security) policies
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE sleep_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE snoring_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE sleep_talking_events ENABLE ROW LEVEL SECURITY;

-- Create policy to allow users to only access their own data
CREATE POLICY "Users can only access their own profile"
  ON profiles FOR ALL
  USING (auth.uid() = id);

CREATE POLICY "Users can only access their own sleep sessions"
  ON sleep_sessions FOR ALL
  USING (auth.uid() = user_id);

CREATE POLICY "Users can only access their own snoring events (via session)"
  ON snoring_events FOR ALL
  USING (
    session_id IN (
      SELECT id FROM sleep_sessions WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can only access their own sleep talking events (via session)"
  ON sleep_talking_events FOR ALL
  USING (
    session_id IN (
      SELECT id FROM sleep_sessions WHERE user_id = auth.uid()
    )
  );
