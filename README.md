# Ask Uganda — Mobile

A patient, multilingual, AI-powered citizen-service assistant for the Republic of Uganda. Any Ugandan can ask a plain-language question about a government service — in their own language, by text or voice — and receive an accurate, personalised answer.

Ask Uganda is built on top of the **Government Unified Verification API (GUVA)**. Every claim it makes about a specific citizen, business, license, parcel of land, or tax position is grounded in a live, consented verification call to GUVA — never invented by the language model. Procedural answers come from a curated government knowledge base, not from the model's parametric memory. This grounding discipline is what separates Ask Uganda from generic government chatbots.

## What the app does

| Capability | What the citizen experiences |
|---|---|
| Conversational service guidance | Ask in any supported language, by text or voice, and receive procedural guidance grounded in a curated knowledge base. |
| Personalised verified answers | With explicit consent, the assistant checks the citizen's specific situation against the authoritative register through GUVA, and renders the result as a clearly distinct verified-fact card. |
| Inline consent moments | Before every verification, the assistant shows exactly what will be checked, against which authority, for what purpose, and proceeds only on the citizen's "Allow". |
| Form assistance | Field-by-field walkthrough of government forms, with GUVA-backed pre-fill for fields that can be verified. |
| Service recommendation for life events | Life events ("start a business", "have a child", "buy land", "lose ID", "travel", "retire") expand into a guided sequence of every government interaction they trigger. |
| Document guidance & capture | Camera capture with overlay; the assistant indicates whether a document looks like the right type and is legible. |
| Ministry routing & human handoff | When a query falls outside the assistant's scope, it routes the citizen to the right office with the conversation context attached. |
| Activity hub | Every conversation, consent, and verified result remains visible to the citizen for review or revocation. |

## Languages

English, Luganda, Runyankole–Rukiga, Acholi, Ateso, Lugbara, and Swahili. Voice input/output is available in the languages where the sovereign speech stack is ready; the others are text-first until voice support matures.

## Architecture

Feature-first, clean-architecture Flutter codebase targeting Android and iOS from a single Dart source.

```
lib/
├── app/
│   ├── router/app_router.dart        # go_router config (shell + full-screen routes)
│   └── shell/app_shell.dart          # bottom-nav scaffold
├── core/
│   ├── constants/                    # strings, languages
│   ├── responsive/                   # breakpoint helpers
│   ├── state/preferences_controller  # Riverpod StateNotifier
│   ├── theme/                        # MD3 light/dark, Uganda palette
│   └── widgets/                      # shared brand mark, coat of arms
└── features/
    ├── assistant/                    # the hero conversational surface
    │   ├── domain/models/            # chat, consent, verified fact, life event
    │   └── presentation/             # controller, screens, widgets
    ├── services_directory/           # catalogue + service detail
    ├── life_events/                  # event-driven guided plans
    ├── forms/                        # field-by-field assistance + review
    ├── documents/                    # capture + guidance
    ├── handoff/                      # human escalation card
    ├── activity/                     # conversations / verifications / consents tabs
    ├── settings/                     # language, voice, accessibility, offline, about
    ├── auth/                         # welcome, sign in, create access
    └── splash/                       # entry point + onboarding gate
```

**State management:** `flutter_riverpod` (`StateNotifier` for the assistant and preferences). **Routing:** `go_router` with a `ShellRoute` for tabbed surfaces and root-level routes for full-screen flows. **Theming:** Material 3 with the Uganda palette (forest green, gold, flag accents) and light/dark themes.

### Grounding discipline in code

The [AssistantController](lib/features/assistant/presentation/controllers/assistant_controller.dart) structurally separates conversational guidance (produced by the model) from authoritative facts (returned only after an explicit `ConsentProposal` is accepted). There is no code path where the model can emit a `VerifiedFact` — the type only exists as the response to a consented GUVA call. This makes the grounding promise enforced by structure, not by model behaviour.

## Getting started

```bash
flutter pub get
flutter run               # autodetects connected device or simulator
```

Common targets:

```bash
flutter run -d "iPhone 17 Pro Max"   # iOS Simulator
flutter run -d chrome                # web (basic functionality only)
flutter build apk --debug            # Android debug APK
flutter build ios --simulator --debug
```

## Conventions

- `flutter analyze` must be clean before merge.
- Routes are declared in [app/router/app_router.dart](lib/app/router/app_router.dart); navigation goes through `context.push` / `context.go`, never raw `Navigator.push` (mixing the two causes page-key collisions).
- Brand placements use the shared [AskUgandaBrandMark](lib/core/widgets/ask_uganda_brand_mark.dart) widget — `variant: mark` on light surfaces, `variant: squircleIcon` on dark.
- New features follow the `features/<name>/{domain,presentation}` layout.

## Related

- **GUVA platform docs:** [`../guva-docs/`](../guva-docs/) — the interoperability and verification API this app consumes.
- **Ask Uganda product docs:** [`../askUganda/ask-uganda-docs/`](../askUganda/ask-uganda-docs/) — full product, AI, UX, security, and governance specifications.
- **Logo pack:** [`../askUganda/logos/ask-uganda-app-icon/`](../askUganda/logos/ask-uganda-app-icon/) — source of all app icons and the in-app brand mark.

## Status

Prototype for the Government Systems Prototype Showcase and National Innovator Registry. The mobile client implements the channel-tier UX from the architecture documentation. The orchestration, retrieval, sovereign language model, and GUVA integration described in the product docs are server-side and stubbed in the client through realistic mock flows — every consent moment, verified-fact card, and handoff in the app mirrors the contract the live backend will fulfil.
