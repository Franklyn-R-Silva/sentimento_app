-- Create the storage bucket for gym photos
INSERT INTO storage.buckets (id, name, public)
VALUES ('gym_photos', 'gym_photos', false)
ON CONFLICT (id) DO NOTHING;

-- Set up RLS policies for the bucket

-- Policy to allow authenticated users to upload files
-- We use a comprehensive policy for simplicity in this context,
-- but typically you'd restrict path to auth.uid()
CREATE POLICY "Authenticated users can upload gym photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'gym_photos');

-- Policy to allow authenticated users to view files
CREATE POLICY "Authenticated users can view gym photos"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'gym_photos');

-- Policy to allow authenticated users to delete files
CREATE POLICY "Authenticated users can delete gym photos"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'gym_photos');

-- Policy to allow authenticated users to update files
CREATE POLICY "Authenticated users can update gym photos"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'gym_photos');
