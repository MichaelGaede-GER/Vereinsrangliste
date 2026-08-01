// =====================================================================
//  config.js — Supabase-Zugangsdaten
//
//  Beide Werte findest du in deinem Supabase-Projekt unter:
//     Project Settings → Data API   (URL)
//     Project Settings → API Keys   (anon / public key)
//
//  Hinweis: Der "anon public"-Key darf öffentlich im Browser stehen –
//  dafür ist er gedacht. Deine Daten schützt die Row Level Security
//  aus der schema.sql (nur eingeloggte Turnierleiter haben Zugriff).
// =====================================================================

window.SUPABASE_CONFIG = {
  url:     "https://akqgioywwlbtzmkotsun.supabase.co/rest/v1/",
  anonKey: "sb_publishable_pjO63JCk2AQlCWPjFWuWxg_NZ5McXb_"
};
