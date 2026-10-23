# DOVARO Business Manager — Source Package

- Brand: DOVARO
- Design: Premium black, gold and white
- Partners: Siam and Nayeem
- Target: Android + desktop web app with shared online data

## Included files
- `index.html` — responsive app frontend (HTML/CSS/JavaScript)
- `supabase_setup.sql` — database schema and row-level security policies
- `manifest.json` — basic installable web app metadata
- `README_BN.md` — setup guide

## Important status
This is a source package, **not yet a deployed live app**. To share live data between both partners' devices, create a Supabase project, run the SQL, configure the public/publishable key in the app, and host the frontend over HTTPS (for example with GitHub Pages).

## Setup summary
1. Create a project at https://supabase.com/
2. Open SQL Editor and run all of `supabase_setup.sql`.
3. In Project Settings → API, copy the Project URL and publishable/anon key.
4. Host `index.html` and `manifest.json` on a static HTTPS host.
5. Open the hosted app, enter the Supabase URL and publishable/anon key.
6. Siam creates an account and sets a long private Business ID. Nayeem creates a separate account and uses that exact same ID.
7. Test with fake transactions before entering real business data.

## Security
- Never share passwords, OTPs, or the Supabase service-role/secret key.
- Only use the public/publishable/anon key in the browser.
- The current shared Business ID approach is an MVP, not a full invitation system. Anyone who learns the ID may attempt to join; keep it private and do not publish it.
- Before using this for important accounting, verify backups and test the flows carefully.

## Current limitations
- This is an MVP source, not audited accounting software.
- Profit calculation is approximate (sales minus total purchases minus expenses), not proper cost-of-goods-sold accounting.
- Stock is checked during sale entry but automatic stock decrement/returns and concurrent-sale protection need additional database-side implementation before relying on it for live inventory.
- Due collection workflow, audit history, invitation approval, and JSON restore are not complete production features.
- A responsive web app can be installed on Android via the browser, but a Play Store APK/AAB is a separate build and publishing process.
