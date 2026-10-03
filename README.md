# Bee Hive Lodge No. 66: Meeting Sign-In

Members scan a QR code (or open the link) and sign in with their name, lodge and title.
Sign-ins are stored in Supabase. Officers view and download them as Excel from the admin page.

| Page | Who uses it |
|---|---|
| `index.html` | Members: the sign-in form |
| `qr.html` | Printable QR code poster for the lodge door |
| `admin.html` | Officers: view a day's attendance, remove mistakes, download Excel |

## Setup
1. Run `supabase/schema.sql` on the Supabase project (already done if Claude set this up).
2. Put the project URL and publishable key in `config.js`.
3. Add each officer's email to the `admins` table:
   `insert into public.admins (email) values ('secretary@example.com');`
4. In Supabase, go to **Authentication → URL Configuration**. Set the Site URL to this site's GitHub Pages address
   and add `<site>/admin.html` to the Redirect URLs.
5. Turn on GitHub Pages for this repo (Settings → Pages → deploy from `main`, root).

## Privacy
This repo is public so GitHub Pages can host it for free. It contains no attendance data.
The public can only add sign-ins; reading them requires an officer login.
Daily Excel copies are saved to the private `beehive-records` repo.
