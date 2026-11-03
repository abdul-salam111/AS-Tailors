# Supabase schema

SQL migrations for the AS Tailors Supabase project live in
`supabase/migrations/`, numbered in apply order. They're the source of
truth for the database schema — don't hand-edit tables/policies in the
dashboard without also committing the equivalent SQL here, or the next
migration (and the next developer) will be working from a stale picture.

## Applying a migration

No Supabase CLI project is linked yet, so for now apply migrations by
pasting them into the Supabase dashboard's **SQL Editor** for your project,
in filename order (`0001_...`, `0002_...`, ...). Each file is idempotent
*in the sense that it only runs once* — re-running one that's already been
applied will fail on the `create table`/`create type` statements, which is
the intended guard rail against accidental double-apply.

Once the project is linked with the Supabase CLI, the normal flow is:

```bash
supabase login
supabase link --project-ref <your-project-ref>
supabase db push
```

## What's in 0001

The identity/shop/RLS foundation every other feature depends on:
`profiles`, `shops`, `shop_members`, `audit_logs`, the `shop_role` enum,
RLS policies for owner/admin/tailor/staff (customer-role RLS is
deliberately deferred — see CLAUDE.md §1a item 8), and the
`bootstrap_shop()` RPC that provisions the first owner/shop (SRS §3's
"controlled setup process").

Feature tables (customers, measurement templates, orders, payments, ...)
belong in their own numbered migrations as those features get built — see
SRS §9.2 for the full table inventory this will eventually grow into.
