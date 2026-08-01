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
  url:     "https://akqgioywwlbtzmkotsun.supabase.co/",
  anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFrcWdpb3l3d2xidHpta290c3VuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU1OTkzNzUsImV4cCI6MjEwMTE3NTM3NX0.bWyfuS9ukYGkENOk7z6SeZ0Kr1IJ8LT2yRlKORraS-k"
};
