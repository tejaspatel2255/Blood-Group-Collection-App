-- Supabase Schema for Family Registry App

-- 1. Table for Data Entry Operators
CREATE TABLE IF NOT EXISTS operators (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  role TEXT DEFAULT 'operator', -- 'admin' or 'operator'
  entries_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Table for Families (Heads of Family)
CREATE TABLE IF NOT EXISTS families (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  serial_number TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  
  -- HOF Details
  hof_name TEXT NOT NULL,
  father_husband_name TEXT,
  mother_name TEXT,
  dob DATE,
  age INTEGER NOT NULL,
  gender TEXT NOT NULL,
  blood_group TEXT NOT NULL,
  marital_status TEXT NOT NULL,
  education TEXT,
  education_other TEXT,
  occupation TEXT,
  occupation_other TEXT,
  annual_income TEXT,
  photo_url TEXT,
  
  -- Address & Contact
  current_address TEXT,
  native_place TEXT,
  city TEXT,
  state TEXT,
  pin_code TEXT,
  area TEXT,
  mobile TEXT NOT NULL,
  mobile_country_code TEXT DEFAULT '+91',
  whatsapp TEXT,
  whatsapp_country_code TEXT DEFAULT '+91',
  email TEXT,
  
  -- Login Credentials (for HOF login)
  login_username TEXT NOT NULL,
  login_password TEXT NOT NULL,

  -- Constraints
  CONSTRAINT check_india_mobile CHECK (mobile_country_code != '+91' OR (mobile ~ '^[0-9]{10}$')),
  CONSTRAINT check_india_whatsapp CHECK (whatsapp_country_code != '+91' OR (whatsapp IS NULL OR whatsapp = '' OR whatsapp ~ '^[0-9]{10}$'))
);

-- 3. Table for Family Members
CREATE TABLE IF NOT EXISTS family_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id UUID REFERENCES families(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  relationship TEXT NOT NULL,
  dob DATE,
  age INTEGER NOT NULL,
  gender TEXT NOT NULL,
  blood_group TEXT NOT NULL,
  marital_status TEXT NOT NULL,
  education TEXT,
  occupation TEXT,
  area TEXT,
  mobile TEXT,
  mobile_country_code TEXT DEFAULT '+91',
  photo_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),

  -- Constraints
  CONSTRAINT check_india_member_mobile CHECK (mobile_country_code != '+91' OR (mobile IS NULL OR mobile = '' OR mobile ~ '^[0-9]{10}$'))
);

-- 4. Storage Bucket
-- You must manually create a public bucket named 'photos' in the Supabase Dashboard.
-- Enable 'Public' access for the bucket.

-- 5. Row Level Security (RLS)
-- For development/testing, you can disable RLS or create permissive policies.
-- ALTER TABLE operators DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE families DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE family_members DISABLE ROW LEVEL SECURITY;

-- 6. HOW TO ADD AN ADMIN:
-- Step 1: Create a user in Supabase Dashboard -> Authentication -> Users.
-- Step 2: Note the User ID (UUID).
-- Step 3: Run the following SQL to make them an admin:
-- INSERT INTO operators (id, email, name, role) 
-- VALUES ('REPLACE-WITH-UUID', 'admin@example.com', 'Admin Name', 'admin');
