-- Storage Buckets Migration
-- Applied: 2025-12-24 19:08:21 UTC
-- Creates photo and document storage buckets with proper RLS policies

-- Create photos bucket (public, 5MB limit, image types only)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'photos',
  'photos',
  true,
  5242880,  -- 5MB
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif'];

-- Create documents bucket (private, 10MB limit, document types)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'documents',
  'documents',
  false,
  10485760,  -- 10MB
  ARRAY['application/pdf', 'text/csv', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']
)
ON CONFLICT (id) DO UPDATE SET
  public = false,
  file_size_limit = 10485760;

-- Storage RLS Policies for photos
DROP POLICY IF EXISTS "Public photos are viewable by everyone" ON storage.objects;
CREATE POLICY "Public photos are viewable by everyone"
ON storage.objects FOR SELECT
USING (bucket_id = 'photos');

DROP POLICY IF EXISTS "Authenticated users can upload photos" ON storage.objects;
CREATE POLICY "Authenticated users can upload photos"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'photos' AND auth.role() = 'authenticated');

-- Storage RLS Policies for documents
DROP POLICY IF EXISTS "Authenticated access to documents" ON storage.objects;
CREATE POLICY "Authenticated access to documents"
ON storage.objects FOR ALL
USING (bucket_id = 'documents' AND auth.role() = 'authenticated');

SELECT 'Storage buckets created!' as status;
