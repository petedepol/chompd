# Chompd — AI Subscription Defence

> Bite back at subscriptions.

Chompd is a freemium subscription tracking & defence app built in Flutter. Its core differentiator is AI-powered screenshot scanning — users share a screenshot of a confirmation email, bank statement, or app store receipt, and Claude Haiku extracts the subscription details automatically.

Its headline feature is the **Trap Scanner** — pre-purchase dark pattern detection that warns users BEFORE they get charged.

## Getting Started

This is a Flutter project targeting iOS and Android.

```bash
flutter pub get
flutter run
```

For AI scan functionality, pass your Anthropic API key at build time:

```bash
flutter run --dart-define=ANTHROPIC_API_KEY=your_key_here
```

## Tech Stack

| Layer | Choice |
|---|---|
| Framework | Flutter 3.x |
| State management | Riverpod (StateNotifier) |
| Local database | Isar |
| AI backend | Claude Haiku 4.5 via Anthropic API |
| Theme | Dark-only (v1) |

## Resources

- See `CLAUDE.md` for full project context, design system, and architecture
- See `docs/` for feature specs and build docs
