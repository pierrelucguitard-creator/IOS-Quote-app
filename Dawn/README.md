# Dawn

A quiet daily quote app for iOS — Apple-inspired UI with curated wisdom and optional [Gemini](https://aistudio.google.com/apikey)-crafted originals.

## Requirements

- macOS with **Xcode 15+** (iOS 17 SDK)
- iPhone or Simulator
- Optional: Gemini API key for AI-generated quotes

## Open & run

1. Open `Dawn/Dawn.xcodeproj` in Xcode
2. Select your Team under **Signing & Capabilities**
3. Choose an iPhone simulator or device
4. Press **⌘R** to build and run

## Gemini setup (optional)

1. Create a free API key at [Google AI Studio](https://aistudio.google.com/apikey)
2. In the app, open **Settings**
3. Paste the key and tap **Save API Key** (stored in the Keychain)
4. On **Today**, tap **Gemini** to generate an original quote

Without a key, Dawn still works with a curated daily rotation of 65+ quotes.

## Features

- **Today** — one quote per day, ambient colors that shift with morning / afternoon / evening / night
- **Gemini** — generate fresh quotes by theme (quiet, courage, creativity)
- **Favorites** — save quotes you want to revisit
- **Share** — system share sheet
- **Appearance** — System / Light / Dark

## Project layout

```
Dawn/
├── Dawn.xcodeproj
└── Dawn/
    ├── DawnApp.swift
    ├── Models/
    ├── Services/          # QuoteStore, Gemini, Keychain
    ├── Views/             # Today, Favorites, Settings
    ├── Resources/Quotes.json
    └── Assets.xcassets
```
