-- VaultAI Database Schema
-- Run these migrations in order in your Supabase project

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For full-text search
CREATE EXTENSION IF NOT EXISTS "vector";  -- For AI embeddings (pgvector)

-- ============================================================
-- PROFILES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  display_name TEXT,
  avatar_url TEXT,
  phone TEXT,
  subscription_tier TEXT DEFAULT 'free' CHECK (subscription_tier IN ('free', 'pro', 'family', 'enterprise')),
  storage_used BIGINT DEFAULT 0,
  document_count INTEGER DEFAULT 0,
  language TEXT DEFAULT 'en',
  notification_preferences JSONB DEFAULT '{"expiry_90d": true, "expiry_30d": true, "expiry_7d": true, "expiry_1d": true}'::jsonb,
  emergency_mode_enabled BOOLEAN DEFAULT false,
  blood_group TEXT,
  emergency_contacts JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS for profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- ============================================================
-- CATEGORIES TABLE (custom categories)
-- ============================================================
CREATE TABLE IF NOT EXISTS categories (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  emoji TEXT DEFAULT '📄',
  color TEXT DEFAULT '#4F46E5',
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own categories" ON categories
  FOR ALL USING (auth.uid() = user_id);

-- ============================================================
-- FOLDERS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS folders (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  parent_id UUID REFERENCES folders(id) ON DELETE CASCADE,
  color TEXT,
  emoji TEXT DEFAULT '📁',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE folders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own folders" ON folders
  FOR ALL USING (auth.uid() = user_id);

-- ============================================================
-- DOCUMENTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS documents (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  folder_id UUID REFERENCES folders(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  file_name TEXT NOT NULL,
  file_url TEXT NOT NULL,
  file_type TEXT NOT NULL,
  file_size BIGINT DEFAULT 0,
  thumbnail_url TEXT,
  category TEXT DEFAULT 'other',
  tags TEXT[] DEFAULT '{}',
  notes TEXT,
  ocr_text TEXT,
  ai_summary TEXT,
  ai_keywords TEXT[] DEFAULT '{}',
  ai_confidence_score FLOAT,
  document_number TEXT,
  holder_name TEXT,
  issuer_name TEXT,
  issue_date DATE,
  expiry_date DATE,
  metadata JSONB DEFAULT '{}'::jsonb,
  is_favorite BOOLEAN DEFAULT false,
  is_archived BOOLEAN DEFAULT false,
  is_shared BOOLEAN DEFAULT false,
  is_encrypted BOOLEAN DEFAULT true,
  version INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_documents_user_id ON documents(user_id);
CREATE INDEX idx_documents_category ON documents(category);
CREATE INDEX idx_documents_expiry_date ON documents(expiry_date);
CREATE INDEX idx_documents_is_favorite ON documents(is_favorite);
CREATE INDEX idx_documents_is_archived ON documents(is_archived);
CREATE INDEX idx_documents_title_trgm ON documents USING gin(title gin_trgm_ops);
CREATE INDEX idx_documents_ocr_text_trgm ON documents USING gin(ocr_text gin_trgm_ops);

ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own documents" ON documents
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own documents" ON documents
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own documents" ON documents
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own documents" ON documents
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================================
-- TAGS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS tags (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  color TEXT DEFAULT '#4F46E5',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, name)
);

ALTER TABLE tags ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own tags" ON tags
  FOR ALL USING (auth.uid() = user_id);

-- ============================================================
-- DOCUMENT TAGS JUNCTION TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS document_tags (
  document_id UUID REFERENCES documents(id) ON DELETE CASCADE,
  tag_id UUID REFERENCES tags(id) ON DELETE CASCADE,
  PRIMARY KEY (document_id, tag_id)
);

ALTER TABLE document_tags ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own document tags" ON document_tags
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM documents d WHERE d.id = document_id AND d.user_id = auth.uid()
    )
  );

-- ============================================================
-- REMINDERS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS reminders (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  document_id UUID REFERENCES documents(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  reminder_date TIMESTAMPTZ NOT NULL,
  type TEXT DEFAULT 'document_expiry',
  is_completed BOOLEAN DEFAULT false,
  is_recurring BOOLEAN DEFAULT false,
  recurring_days INTEGER,
  notification_sent BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_reminders_user_id ON reminders(user_id);
CREATE INDEX idx_reminders_reminder_date ON reminders(reminder_date);

ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own reminders" ON reminders
  FOR ALL USING (auth.uid() = user_id);

-- ============================================================
-- AI METADATA TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS ai_metadata (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  document_id UUID REFERENCES documents(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  embedding VECTOR(1536), -- For AI similarity search (requires pgvector)
  extracted_fields JSONB DEFAULT '{}'::jsonb,
  detected_language TEXT,
  confidence_score FLOAT,
  processing_status TEXT DEFAULT 'pending',
  processed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE ai_metadata ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own ai metadata" ON ai_metadata
  FOR SELECT USING (auth.uid() = user_id);

-- ============================================================
-- SUBSCRIPTIONS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS subscriptions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  tier TEXT DEFAULT 'free' CHECK (tier IN ('free', 'pro', 'family', 'enterprise')),
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'cancelled', 'expired', 'trial')),
  started_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ,
  payment_provider TEXT,
  payment_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own subscription" ON subscriptions
  FOR SELECT USING (auth.uid() = user_id);

-- ============================================================
-- ACTIVITY LOGS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS activity_logs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  action TEXT NOT NULL,
  entity_type TEXT,
  entity_id UUID,
  metadata JSONB DEFAULT '{}'::jsonb,
  ip_address TEXT,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_activity_logs_user_id ON activity_logs(user_id);
CREATE INDEX idx_activity_logs_created_at ON activity_logs(created_at DESC);

ALTER TABLE activity_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own activity logs" ON activity_logs
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "System can insert activity logs" ON activity_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- SHARED DOCUMENTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS shared_documents (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  document_id UUID REFERENCES documents(id) ON DELETE CASCADE NOT NULL,
  owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  shared_with_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  share_link TEXT UNIQUE,
  permission TEXT DEFAULT 'view' CHECK (permission IN ('view', 'edit')),
  expires_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE shared_documents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Owners can manage shared documents" ON shared_documents
  FOR ALL USING (auth.uid() = owner_id);

CREATE POLICY "Recipients can view shared documents" ON shared_documents
  FOR SELECT USING (auth.uid() = shared_with_id);

-- ============================================================
-- FAMILY GROUPS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS family_groups (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  max_members INTEGER DEFAULT 6,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS family_group_members (
  group_id UUID REFERENCES family_groups(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member')),
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'removed')),
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (group_id, user_id)
);

ALTER TABLE family_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE family_group_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Group members can view group" ON family_groups
  FOR SELECT USING (
    auth.uid() = owner_id OR
    EXISTS (
      SELECT 1 FROM family_group_members m
      WHERE m.group_id = id AND m.user_id = auth.uid() AND m.status = 'active'
    )
  );

CREATE POLICY "Owners can manage groups" ON family_groups
  FOR ALL USING (auth.uid() = owner_id);

-- ============================================================
-- NOTIFICATIONS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT DEFAULT 'info',
  data JSONB DEFAULT '{}'::jsonb,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own notifications" ON notifications
  FOR ALL USING (auth.uid() = user_id);

-- ============================================================
-- DEVICES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS devices (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  device_name TEXT,
  platform TEXT,
  os_version TEXT,
  app_version TEXT,
  fcm_token TEXT,
  is_active BOOLEAN DEFAULT true,
  last_seen TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE devices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own devices" ON devices
  FOR ALL USING (auth.uid() = user_id);

-- ============================================================
-- STORAGE BUCKETS
-- ============================================================
-- Run in Supabase Storage settings:
-- 1. Create "documents" bucket (private)
-- 2. Create "profiles" bucket (public)
-- 3. Create "thumbnails" bucket (public)

-- Storage policies for documents bucket
INSERT INTO storage.buckets (id, name, public) VALUES ('documents', 'documents', false)
  ON CONFLICT DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('profiles', 'profiles', true)
  ON CONFLICT DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('thumbnails', 'thumbnails', true)
  ON CONFLICT DO NOTHING;

-- RLS for storage.objects
CREATE POLICY "Users can upload own documents" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'documents' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can read own documents" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'documents' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can delete own documents" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'documents' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- ============================================================
-- FUNCTIONS & TRIGGERS
-- ============================================================

-- Auto-create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'avatar_url'
  )
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.subscriptions (user_id, tier, status)
  VALUES (NEW.id, 'free', 'active')
  ON CONFLICT (user_id) DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Auto-update document count on profile
CREATE OR REPLACE FUNCTION update_document_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE profiles SET document_count = document_count + 1,
      storage_used = storage_used + COALESCE(NEW.file_size, 0)
    WHERE id = NEW.user_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE profiles SET document_count = GREATEST(document_count - 1, 0),
      storage_used = GREATEST(storage_used - COALESCE(OLD.file_size, 0), 0)
    WHERE id = OLD.user_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_document_count_change
  AFTER INSERT OR DELETE ON documents
  FOR EACH ROW EXECUTE FUNCTION update_document_count();

-- Auto-create document expiry reminders
CREATE OR REPLACE FUNCTION create_expiry_reminders()
RETURNS TRIGGER AS $$
DECLARE
  intervals INTEGER[] := ARRAY[90, 30, 7, 1];
  i INTEGER;
BEGIN
  IF NEW.expiry_date IS NOT NULL THEN
    FOREACH i IN ARRAY intervals LOOP
      INSERT INTO reminders (user_id, document_id, title, description, reminder_date, type)
      VALUES (
        NEW.user_id,
        NEW.id,
        'Document expiring in ' || i || ' days: ' || NEW.title,
        NEW.title || ' expires on ' || TO_CHAR(NEW.expiry_date, 'DD Mon YYYY'),
        (NEW.expiry_date - i * INTERVAL '1 day')::TIMESTAMPTZ,
        'document_expiry'
      )
      ON CONFLICT DO NOTHING;
    END LOOP;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_document_expiry_set
  AFTER INSERT OR UPDATE OF expiry_date ON documents
  FOR EACH ROW EXECUTE FUNCTION create_expiry_reminders();

-- Updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_documents_updated_at
  BEFORE UPDATE ON documents
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_reminders_updated_at
  BEFORE UPDATE ON reminders
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
