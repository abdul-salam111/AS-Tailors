-- ============================================================================
-- 0008_avatars_bucket.sql
--
-- Public Storage bucket for profile pictures (EditProfileView's avatar
-- picker). Public, unlike measurement-references (private + signed URL) —
-- a staff photo isn't sensitive, and a stable public URL is what gets
-- stored in auth.users.user_metadata.avatar_url (see
-- AuthRepositoryImpl.updateAvatar), avoiding the need to re-sign/refresh
-- a URL every time the app displays it.
--
-- Path convention: {user_id}/avatar.jpg — always the same path per user,
-- uploaded with upsert so a re-upload overwrites in place rather than
-- accumulating orphaned files.
--
-- Apply after 0001-0007. See supabase/README.md.
-- ============================================================================

insert into storage.buckets (id, name, public, file_size_limit)
values ('avatars', 'avatars', true, 5242880)
on conflict (id) do nothing;

create policy avatars_select on storage.objects for select
  using (bucket_id = 'avatars');

create policy avatars_insert on storage.objects for insert
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy avatars_update on storage.objects for update
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
