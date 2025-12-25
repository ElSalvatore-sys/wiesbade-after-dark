-- Auth Settings for WiesbadenAfterDark
-- Run in Supabase Dashboard > SQL Editor

-- Note: Email templates must be configured in Dashboard UI
-- Go to: Authentication > Email Templates

-- These are the redirect URLs to configure:
-- Site URL: https://owner-6xdb541ae-l3lim3d-2348s-projects.vercel.app
-- Redirect URLs:
--   https://owner-6xdb541ae-l3lim3d-2348s-projects.vercel.app/*
--   http://localhost:5173/*

-- Verify auth settings
SELECT 
  'Check Authentication > URL Configuration in Dashboard' as action,
  'Add the redirect URLs listed above' as note;
