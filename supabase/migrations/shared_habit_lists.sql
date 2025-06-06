-- Create shared habits lists table
CREATE TABLE IF NOT EXISTS public.shared_habit_lists (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  habits JSONB NOT NULL,
  is_public BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  
  -- Add indexes for faster queries
  CONSTRAINT valid_title CHECK (char_length(title) <= 31),
  CONSTRAINT valid_description CHECK (char_length(description) <= 68)
);

-- Set up RLS (Row Level Security) policies
ALTER TABLE public.shared_habit_lists ENABLE ROW LEVEL SECURITY;

-- Policy for viewing public shared habit lists or your own lists
CREATE POLICY "View public or own shared habit lists" ON public.shared_habit_lists
  FOR SELECT USING (is_public OR auth.uid() = user_id);

-- Policy for inserting your own shared habit list
CREATE POLICY "Insert own shared habit lists" ON public.shared_habit_lists
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Policy for updating only your own shared habit lists
CREATE POLICY "Update own shared habit lists" ON public.shared_habit_lists
  FOR UPDATE USING (auth.uid() = user_id);

-- Policy for deleting only your own shared habit lists
CREATE POLICY "Delete own shared habit lists" ON public.shared_habit_lists
  FOR DELETE USING (auth.uid() = user_id);
