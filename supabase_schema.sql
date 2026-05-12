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
  mobile TEXT NOT NULL,
  whatsapp TEXT,
  email TEXT,
  
  -- Login Credentials (for HOF login)
  login_username TEXT NOT NULL,
  login_password TEXT NOT NULL
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
  mobile TEXT,
  photo_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
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
