# Supabase Migrations

This folder contains SQL migration files for the Fortunia backend schema.
Each `.sql` file represents a specific versioned schema change.

## How to apply migrations

1. Install Supabase CLI if you haven't:
   ```bash
   brew install supabase/tap/supabase
   ```

2. Authenticate and link your project:
   ```bash
   supabase login
   supabase link --project-ref your-project-id
   ```

3. Apply all migrations:
   ```bash
   supabase db push
   ```

## Notes

- Never edit old migration files — always create a new one.
- Migrations are executed in filename order (chronologically).
- SQL files here are version-controlled and reflect backend evolution.
