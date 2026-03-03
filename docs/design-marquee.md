# Marquee (formerly SaasFront)

**Type:** Planned Ruby Gem (Rails Engine)
**Repo:** ~/projects/marquee (empty — just README)
**Spec:** infrastructure-ideas/saas-front-gem-spec.md (1,100+ lines, very detailed)
**RubyGems name:** `marquee` (available, confirmed 2026-03-02)
**Status:** Fully specced, zero code

## What It Does (planned)

Drop-in public site engine for Rails SaaS apps. Managed pages, sections, lead capture, analytics, versioning, SEO, admin UI, REST API, and code-first DSL. "Your SaaS public site, managed."

## Full Spec

See saas-front-gem-spec.md for complete details including:
- 11 modules, 15 database tables
- Section content schemas (hero, pricing, FAQ, testimonials, etc.)
- Complete REST API with response formats
- Rendering pipeline, configuration, rake tasks
- 5 build phases

## Strategic Role

- **SaaS infrastructure gem** — every SaaS app needs public pages, this makes it a one-liner
- **Command Center integration** — Marquee::Client for managing pages across apps
- **Replaces custom work** — dyb_site, tyler_jumper, sota all have hand-built public pages that Marquee would replace
- **Pairs with Herald** — Marquee = pages, Herald = blog
- **High value if built** — solves a real, recurring problem across every Rails SaaS

## Build Priority

Phase 1 (pages + sections + admin UI + public rendering + DSL) would be immediately usable. But EventEngine should ship first — it's closer to done.
