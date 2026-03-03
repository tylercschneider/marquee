# SaasFront — Public Site Engine for Rails SaaS Apps

**Gem name:** `saas_front`
**Type:** Rails Engine (mountable)
**Purpose:** Drop a single gem into any Rails SaaS app and get a fully managed public site — pages, lead capture, analytics, versioning, and API — so you can launch fast and iterate without touching views every time.

**Tagline:** "Your SaaS public site, managed."

---

## Why This Gem

Every SaaS app needs the same public-facing pages: homepage, pricing, features, about, landing pages for campaigns. Every time you start a new app, you rebuild these from scratch. Then when marketing wants a copy change, it's a deploy. When you want to A/B test a headline, it's a code change.

SaasFront makes the public site a **managed system** — build with code or UI, track every change, measure what converts, and expose an API so a central command app can manage all your sites from one place.

**Already have a blog?** Good. SaasFront doesn't touch your blog. It manages everything else.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Your Rails App                        │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌────────────────┐  │
│  │  Your Blog  │  │ Your Auth   │  │  Your Product  │  │
│  │  (existing) │  │ (Jumpstart) │  │  (your SaaS)   │  │
│  └─────────────┘  └─────────────┘  └────────────────┘  │
│                                                         │
│  ┌─────────────────────────────────────────────────────┐│
│  │                  SaasFront Engine                   ││
│  │                                                     ││
│  │  Pages ─── Sections ─── Lead Forms ─── Analytics   ││
│  │    │          │            │              │         ││
│  │  Versions   Blocks      Submissions    Events      ││
│  │    │          │            │              │         ││
│  │  Change     DSL +       Email          Funnels     ││
│  │  History    UI Editor   Integration    Reports     ││
│  │                                                     ││
│  │  ┌──────────┐  ┌──────────────┐  ┌──────────────┐ ││
│  │  │ Admin UI │  │  Public      │  │  REST API    │ ││
│  │  │ /admin/  │  │  Renderer    │  │  /api/sf/    │ ││
│  │  │ site     │  │  (routes)    │  │  (3rd party) │ ││
│  │  └──────────┘  └──────────────┘  └──────────────┘ ││
│  └─────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘
         ▲                                    ▲
         │                                    │
    Your team edits                   3rd Party Command
    pages in admin UI                 Center manages via API
```

---

## Module Breakdown

### Module 1: Page Management

The core system. Pages are the top-level objects. Each page has a slug, status, and collection of sections.

**Models:**

```
SaasFront::Page
  - id
  - title                  # "Pricing"
  - slug                   # "pricing" (URL path)
  - page_type              # homepage, landing, feature, pricing, about, legal, custom
  - status                 # draft, published, archived
  - meta_title             # SEO title override
  - meta_description       # SEO description
  - og_image               # Social share image
  - schema_markup          # JSON-LD structured data
  - custom_css             # Page-specific CSS
  - custom_js              # Page-specific JS
  - template               # Which layout template to use
  - published_at
  - created_by_id          # Links to your User model
  - position               # Sort order for navigation
  - timestamps
```

**Page types and their default section templates:**

| Page Type | Default Sections | Notes |
|-----------|-----------------|-------|
| `homepage` | hero, features, social_proof, cta | Main site entry |
| `pricing` | hero, pricing_table, faq, cta | Conversion page |
| `features` | hero, feature_grid, cta | Product showcase |
| `about` | hero, team, story, cta | Trust builder |
| `landing` | hero, problem, solution, cta, form | Lead capture |
| `legal` | text_block | Privacy, terms |
| `custom` | (empty) | Build from scratch |

**Key behaviors:**
- Slugs are unique and URL-safe
- Publishing requires at least one section
- Homepage is a singleton (only one allowed)
- Pages render at `/<slug>` (or configurable prefix)
- 404 fallback page is configurable

---

### Module 2: Section/Block System

Sections are the building blocks of pages. Each section type has its own schema for content fields.

**Model:**

```
SaasFront::Section
  - id
  - page_id
  - section_type          # hero, features, pricing_table, testimonials, faq,
                          # cta, form, text_block, image_block, custom_html,
                          # announcement_bar, social_proof, team, stats,
                          # comparison, video, logo_cloud
  - content               # JSONB - structured content for this section type
  - settings              # JSONB - display settings (bg color, padding, width)
  - position              # Sort order within page
  - visible               # Toggle visibility without deleting
  - css_class             # Additional CSS classes
  - timestamps
```

**Section type content schemas:**

```ruby
# Hero section
{
  headline: "Stop wasting food and money",
  subheadline: "Smart inventory tracking for your kitchen",
  cta_text: "Start Free",
  cta_url: "/signup",
  secondary_cta_text: "See how it works",
  secondary_cta_url: "#how-it-works",
  image_url: "/hero.png",
  background_style: "gradient"  # solid, gradient, image, video
}

# Pricing table
{
  headline: "Simple, transparent pricing",
  plans: [
    {
      name: "Free",
      price: 0,
      interval: "month",
      features: ["Up to 100 items", "Basic reports"],
      cta_text: "Get Started",
      cta_url: "/signup",
      highlighted: false
    },
    {
      name: "Pro",
      price: 12,
      interval: "month",
      features: ["Unlimited items", "Advanced reports", "API access"],
      cta_text: "Start Free Trial",
      cta_url: "/signup?plan=pro",
      highlighted: true
    }
  ]
}

# FAQ
{
  headline: "Frequently Asked Questions",
  items: [
    { question: "Can I cancel anytime?", answer: "Yes, cancel with one click." },
    { question: "Is there a free tier?", answer: "Yes, free forever for basic use." }
  ]
}

# Testimonials / Social Proof
{
  headline: "What people are saying",
  style: "cards",  # cards, carousel, quotes
  items: [
    {
      quote: "Saved me $200/month on groceries",
      author: "Sarah M.",
      role: "Mom of 3",
      image_url: "/testimonials/sarah.jpg",
      rating: 5
    }
  ]
}

# Lead capture form
{
  headline: "Join the waitlist",
  subheadline: "Be the first to know when we launch",
  fields: [
    { name: "email", type: "email", required: true, placeholder: "you@example.com" },
    { name: "name", type: "text", required: false, placeholder: "Your name" }
  ],
  submit_text: "Join Waitlist",
  success_message: "You're on the list!",
  redirect_url: "/thank-you",
  tag: "waitlist"  # For segmenting leads
}

# Stats / Numbers
{
  items: [
    { value: "10,000+", label: "Items tracked" },
    { value: "$907", label: "Avg savings per year" },
    { value: "4.8★", label: "App Store rating" }
  ]
}

# Logo cloud (as seen in / integrations)
{
  headline: "Integrates with",
  logos: [
    { name: "Stripe", image_url: "/logos/stripe.svg", url: "https://stripe.com" }
  ]
}

# Comparison table
{
  headline: "How we compare",
  us_label: "WYN",
  competitors: ["Spreadsheet", "Other App"],
  rows: [
    { feature: "AI-powered", us: true, competitors: [false, false] },
    { feature: "Auto-tracking", us: true, competitors: [false, true] }
  ]
}
```

**Section settings (shared across all types):**

```ruby
{
  background_color: "#ffffff",
  text_color: "#1a1a1a",
  padding_top: "lg",        # none, sm, md, lg, xl
  padding_bottom: "lg",
  max_width: "container",   # full, container, narrow
  anchor_id: "features",    # For #anchor links
  animate: false             # Scroll animation
}
```

---

### Module 3: Code-First DSL

Everything you can do in the UI, you can do in code. Seed pages from a DSL file, or define pages entirely in code and skip the database.

**Page definition DSL:**

```ruby
# config/saas_front/pages/pricing.rb
SaasFront.define_page :pricing do
  title "Pricing"
  page_type :pricing
  meta_title "Pricing - YourApp"
  meta_description "Simple, transparent pricing. Start free."

  hero do
    headline "Simple, transparent pricing"
    subheadline "No hidden fees. Cancel anytime."
  end

  pricing_table do
    plan :free do
      price 0
      features [
        "Up to 100 items",
        "Basic reports",
        "Email support"
      ]
      cta "Get Started", "/signup"
    end

    plan :pro, highlighted: true do
      price 12, :month
      features [
        "Unlimited items",
        "Advanced reports",
        "API access",
        "Priority support"
      ]
      cta "Start Free Trial", "/signup?plan=pro"
    end
  end

  faq do
    question "Can I cancel anytime?" do
      "Yes. Cancel from your account settings with one click. No questions asked."
    end

    question "Is there a free trial?" do
      "Yes — 14-day free trial on Pro. No credit card required."
    end
  end

  cta do
    headline "Ready to get started?"
    button "Sign Up Free", "/signup"
  end
end
```

**Landing page DSL:**

```ruby
# config/saas_front/pages/grocery-waste-lp.rb
SaasFront.define_page :grocery_waste do
  title "Stop Wasting Food"
  page_type :landing
  slug "stop-wasting-food"

  hero do
    headline "The average family wastes $907/year on groceries"
    subheadline "WYN tracks what you have so you stop buying duplicates"
    cta "Join the Waitlist", "#signup"
    image "/images/hero-kitchen.jpg"
  end

  problem do
    points [
      "You buy something you already have — again",
      "Food expires before you use it",
      "You have no idea what's actually in your pantry"
    ]
  end

  solution do
    steps [
      { title: "Tell WYN what you bought", description: "Snap a receipt or just tell it in chat" },
      { title: "WYN tracks everything", description: "Knows what you have, what's expiring, what's running low" },
      { title: "Stop wasting money", description: "Smart suggestions based on what's actually in your kitchen" }
    ]
  end

  form :waitlist do
    headline "Join the Waitlist"
    field :email, required: true
    field :name
    submit "Count Me In"
    tag "grocery-waste-lp"
  end
end
```

**Sync behavior:**
- `rails saas_front:pages:sync` — Loads DSL definitions, creates/updates database records
- DSL pages can be locked (not editable in UI) or unlocked (DSL is seed, UI edits override)
- `lock: true` on DSL definition means "this page is code-managed only"
- Changes in UI to unlocked DSL pages get versioned like any other change

---

### Module 4: Lead Capture & Tracking

Track visitors, captures, and conversions across the entire funnel.

**Models:**

```
SaasFront::Lead
  - id
  - email
  - name
  - data                  # JSONB - any custom fields from form
  - source_page_id        # Which page they converted on
  - tags                  # Array - for segmenting ("waitlist", "pricing-page", etc.)
  - status                # new, contacted, converted, unsubscribed
  - utm_source
  - utm_medium
  - utm_campaign
  - utm_term
  - utm_content
  - referrer              # HTTP referrer
  - ip_address            # Hashed for privacy
  - user_agent
  - converted_at          # When they became a paying customer
  - timestamps

SaasFront::PageView
  - id
  - page_id
  - visitor_id            # Anonymous cookie-based ID
  - session_id            # Groups pageviews in a session
  - path                  # URL path
  - referrer
  - utm_source
  - utm_medium
  - utm_campaign
  - device_type           # desktop, mobile, tablet
  - country               # From IP (optional)
  - duration_seconds      # Time on page
  - timestamps

SaasFront::Event
  - id
  - visitor_id
  - session_id
  - lead_id               # If identified
  - event_type            # page_view, form_submit, cta_click, purchase, custom
  - event_name            # "waitlist_signup", "pricing_click", "purchase_pro"
  - page_id
  - section_id            # Which section triggered it
  - properties            # JSONB - event-specific data
  - timestamps
```

**Tracking features:**
- **Automatic page view tracking** — middleware or JS snippet, configurable
- **Form submission tracking** — every form submit creates a Lead + Event
- **CTA click tracking** — data attributes on CTA buttons fire events
- **Purchase/conversion tracking** — hook into your payment system via callback
- **UTM parameter capture** — persisted on first visit, carried through session
- **Session management** — 30-min inactivity timeout, cookie-based
- **Privacy-first** — no 3rd party scripts, IP hashing, configurable data retention

**Conversion hooks:**

```ruby
# In your app — tell SaasFront when a purchase happens
SaasFront::Tracker.record_conversion(
  email: current_user.email,
  event_name: "purchase_pro",
  value: 12.00,
  properties: { plan: "pro", interval: "monthly" }
)
```

**Analytics aggregations (pre-computed daily):**

```
SaasFront::DailyStat
  - date
  - page_id               # null = site-wide
  - views
  - unique_visitors
  - form_submissions
  - cta_clicks
  - conversions
  - conversion_value
  - avg_time_on_page
  - bounce_rate
  - top_referrers          # JSONB
  - device_breakdown       # JSONB { desktop: 60, mobile: 35, tablet: 5 }
```

---

### Module 5: Version History & Change Tracking

Every change is tracked. Full audit trail. Rollback anything.

**Models:**

```
SaasFront::Version
  - id
  - versionable_type      # "SaasFront::Page" or "SaasFront::Section"
  - versionable_id
  - user_id               # Who made the change (your app's User model)
  - action                # created, updated, published, unpublished, archived, rolled_back
  - changeset             # JSONB - what changed { field: [old, new] }
  - snapshot              # JSONB - full state at this version (for rollback)
  - metadata              # JSONB - extra context (IP, user agent, API key used)
  - timestamps

SaasFront::ChangeSet
  - id
  - user_id
  - description           # "Updated hero headline and CTA"
  - versions              # has_many :versions
  - status                # draft, applied, rolled_back
  - timestamps
```

**Version features:**
- Every save creates a new version automatically
- Changeset groups related changes (e.g., "updated pricing page" touches hero + pricing_table + CTA)
- Full page snapshot stored for rollback
- Diff viewer in admin UI shows what changed
- Rollback to any version with one click
- Versions are immutable — rollback creates a new version that restores old state
- API-triggered changes are versioned too (with API key in metadata)

**Change tracking DSL in admin UI:**

```
Page: Pricing
Version #14 — Published by Tyler, 2 hours ago
  Changes:
    ✏️  Hero headline: "Simple pricing" → "Simple, transparent pricing"
    ✏️  Pro plan price: $9/mo → $12/mo
    ➕  Added FAQ: "Is there a free trial?"

  [Rollback to v13] [View full diff]
```

---

### Module 6: Admin UI

A mountable admin interface for managing everything. Ships as part of the engine.

**Routes:**

```
# config/routes.rb
mount SaasFront::Engine, at: "/admin/site"
```

**Admin screens:**

| Screen | Purpose |
|--------|---------|
| **Dashboard** | Site-wide stats (views, leads, conversions), recent changes, quick actions |
| **Pages** | List all pages, status, last edited, quick publish/unpublish |
| **Page Editor** | Section list with inline editing, preview, SEO settings, publish controls |
| **Section Editor** | Structured form for section content (not freeform WYSIWYG — intentionally) |
| **Leads** | List/search/filter leads, export CSV, status management |
| **Analytics** | Page-level and site-level charts — views, conversions, funnels |
| **Change History** | Timeline of all changes, filter by page/user, rollback controls |
| **Settings** | Site name, branding, navigation, SEO defaults, API keys, integrations |
| **Onboarding** | Setup wizard (first-time only) |

**UI approach:**
- Server-rendered with Turbo Frames/Streams (no SPA, no heavy JS)
- Tailwind CSS for styling (or standalone CSS if consumer doesn't use Tailwind)
- Stimulus controllers for interactive bits (drag reorder, inline edit, charts)
- Hotwire-native — feels fast without complexity
- Mobile-responsive admin
- Auth delegated to host app via configuration block

**Page editor interaction:**

```
┌──────────────────────────────────────────────┐
│ Page: Pricing                    [Draft ▾]   │
│                                  [Preview]   │
│                                  [Publish]   │
├──────────────────────────────────────────────┤
│                                              │
│  ┌─ Hero ──────────────────────────── [⋮] ─┐│
│  │ Headline: Simple, transparent pricing    ││
│  │ Subheadline: No hidden fees...           ││
│  │ CTA: [Get Started] → /signup             ││
│  └──────────────────────────────────────────┘│
│                                              │
│  ┌─ Pricing Table ─────────────────── [⋮] ─┐│
│  │ Free: $0/mo  |  Pro: $12/mo (★)         ││
│  │ [Edit plans...]                          ││
│  └──────────────────────────────────────────┘│
│                                              │
│  ┌─ FAQ ───────────────────────────── [⋮] ─┐│
│  │ 3 questions                              ││
│  │ [Edit questions...]                      ││
│  └──────────────────────────────────────────┘│
│                                              │
│  [+ Add Section]                             │
│                                              │
├──────────────────────────────────────────────┤
│ SEO  │  Settings  │  History (14 versions)   │
└──────────────────────────────────────────────┘
```

---

### Module 7: REST API (3rd Party Integration)

Full API so an external command center app can manage pages, leads, and analytics across multiple SaaS apps.

**Authentication:** API key per app, passed as Bearer token.

**Endpoints:**

```
# Pages
GET    /api/sf/v1/pages                    # List all pages
GET    /api/sf/v1/pages/:slug              # Get page with sections
POST   /api/sf/v1/pages                    # Create page
PATCH  /api/sf/v1/pages/:slug              # Update page
DELETE /api/sf/v1/pages/:slug              # Archive page
POST   /api/sf/v1/pages/:slug/publish      # Publish
POST   /api/sf/v1/pages/:slug/unpublish    # Unpublish
POST   /api/sf/v1/pages/:slug/duplicate    # Clone a page

# Sections
GET    /api/sf/v1/pages/:slug/sections     # List sections for page
POST   /api/sf/v1/pages/:slug/sections     # Add section
PATCH  /api/sf/v1/sections/:id             # Update section
DELETE /api/sf/v1/sections/:id             # Remove section
POST   /api/sf/v1/pages/:slug/sections/reorder  # Reorder sections

# Leads
GET    /api/sf/v1/leads                    # List/search/filter leads
GET    /api/sf/v1/leads/:id                # Get lead details
PATCH  /api/sf/v1/leads/:id                # Update lead status/tags
DELETE /api/sf/v1/leads/:id                # Delete lead
GET    /api/sf/v1/leads/export             # CSV export

# Analytics
GET    /api/sf/v1/analytics/overview       # Site-wide stats
GET    /api/sf/v1/analytics/pages/:slug    # Page-level stats
GET    /api/sf/v1/analytics/funnel         # Conversion funnel data
GET    /api/sf/v1/analytics/leads          # Lead acquisition over time

# Versions
GET    /api/sf/v1/pages/:slug/versions     # Version history
POST   /api/sf/v1/pages/:slug/rollback     # Rollback to version

# Config
GET    /api/sf/v1/config                   # Current site config
PATCH  /api/sf/v1/config                   # Update site config

# Webhooks (3rd party receives events)
POST   /api/sf/v1/webhooks                 # Register webhook
GET    /api/sf/v1/webhooks                 # List webhooks
DELETE /api/sf/v1/webhooks/:id             # Remove webhook
```

**Webhook events pushed to 3rd party:**

```
page.published
page.updated
lead.created
lead.converted
analytics.daily_summary
version.created
```

**API response format:**

```json
{
  "data": {
    "id": "pricing",
    "type": "page",
    "attributes": {
      "title": "Pricing",
      "slug": "pricing",
      "status": "published",
      "sections_count": 4,
      "published_at": "2026-02-28T10:00:00Z"
    },
    "relationships": {
      "sections": [...],
      "versions": { "count": 14 }
    }
  },
  "meta": {
    "app_name": "WYN",
    "generated_at": "2026-02-28T12:00:00Z"
  }
}
```

---

### Module 8: Onboarding Wizard

First-time setup flow when the gem is installed. Runs in the admin UI.

**Steps:**

```
Step 1: Site Basics
  - Site name
  - Site tagline
  - Primary color
  - Logo upload

Step 2: Navigation
  - Choose which pages to create (checkboxes)
  - [ ] Homepage (recommended)
  - [ ] Pricing
  - [ ] Features
  - [ ] About
  - [ ] Contact

Step 3: Homepage Setup
  - Hero headline
  - Hero subheadline
  - Primary CTA text + URL
  - Choose a template style

Step 4: Lead Capture
  - Enable/disable lead capture
  - Default form fields (email, name, etc.)
  - Notification email for new leads

Step 5: Analytics
  - Enable/disable page view tracking
  - JS snippet vs server-side tracking
  - Data retention period (30/90/365 days)

Step 6: API Access
  - Generate API key
  - Set webhook URL (optional)
  - Copy integration snippet

Step 7: Review & Launch
  - Preview your site
  - Checklist of what's configured
  - [Publish Site] button
```

**Post-onboarding:** Creates all selected pages with template content, configures tracking, and sets the site to "published" state.

---

### Module 9: SEO & Meta Management

Built-in SEO that works out of the box.

**Automatic:**
- `<title>` tags from page title (with site name suffix)
- `<meta description>` from page meta or auto-generated from hero
- OpenGraph tags (title, description, image, type)
- Twitter Card tags
- Canonical URLs
- Schema.org JSON-LD (WebPage, FAQPage, Product for pricing)
- Sitemap.xml auto-generated from published pages
- robots.txt management
- Clean URL structure (`/pricing` not `/pages/pricing`)

**Configurable per page:**
- Meta title override
- Meta description override
- OG image override
- noindex/nofollow flags
- Custom canonical URL
- Schema.org type override

**Site-wide SEO settings:**
- Default OG image
- Site name for title suffix
- Google Search Console verification
- Social profiles for Schema.org Organization

---

### Module 10: Navigation & Site Structure

**Model:**

```
SaasFront::NavItem
  - id
  - label                 # "Pricing"
  - url                   # "/pricing" or external URL
  - page_id               # Link to internal page (optional)
  - position
  - nav_group             # "header", "footer", "sidebar"
  - parent_id             # For dropdowns
  - visible
  - new_tab               # Open in new tab
  - timestamps
```

**Features:**
- Header and footer navigation managed separately
- Drag-and-drop reorder in admin
- Dropdown menus (one level deep)
- Auto-sync: when a page is published, option to auto-add to nav
- Badge support (e.g., "New" next to a nav item)
- CTA button style for primary nav items (e.g., "Sign Up" button in header)

---

### Module 11: Asset Management

**Model:**

```
SaasFront::Asset
  - id
  - filename
  - content_type
  - byte_size
  - url                   # Storage URL (Active Storage or direct)
  - alt_text
  - folder                # Organize: "heroes", "logos", "testimonials"
  - timestamps
```

**Features:**
- Upload images through admin UI
- Organize into folders
- Alt text management (accessibility + SEO)
- Image optimization on upload (resize, compress)
- Uses Active Storage under the hood
- Referenced by sections via URL

---

## Additional Features (Recommended)

### Announcement Bar

A dismissible bar at the top of the site for promotions, announcements, product launches.

```ruby
SaasFront::Announcement
  - message               # "We just launched Pro! Get 20% off"
  - link_text             # "Learn more"
  - link_url              # "/pricing"
  - background_color
  - text_color
  - active                # Toggle on/off
  - starts_at             # Schedule
  - ends_at
  - dismissible           # Can visitors close it?
```

### Redirect Manager

Manage URL redirects without touching routes.

```ruby
SaasFront::Redirect
  - from_path             # "/old-pricing"
  - to_path               # "/pricing"
  - redirect_type         # 301, 302
  - hits                  # Track how many times it's used
  - active
```

### Social Proof Widget

Real-time notification popups: "Sarah from Austin just signed up!"

```ruby
SaasFront::SocialProofConfig
  - enabled
  - message_template      # "{name} from {location} just {action}"
  - display_duration      # Seconds to show
  - delay_between         # Seconds between popups
  - source                # "leads" or "custom"
  - position              # bottom-left, bottom-right
```

### A/B Testing (Future — Phase 2)

Test section variants against each other.

```ruby
SaasFront::Experiment
  - name                  # "Hero headline test"
  - page_id
  - section_id
  - status                # running, paused, completed
  - variants              # JSONB array of content variants
  - traffic_split         # [50, 50] or [33, 33, 34]
  - winning_variant       # Set when completed
  - metric                # "form_submissions" or "cta_clicks"
```

### Email Integration

Connect form submissions to your email system.

```ruby
# config/initializers/saas_front.rb
SaasFront.configure do |config|
  config.on_lead_created do |lead|
    # Send to your email system
    MailchimpService.add_subscriber(lead.email, tags: lead.tags)

    # Or send a notification
    AdminMailer.new_lead(lead).deliver_later

    # Or trigger a webhook
    # (handled automatically if webhooks are configured)
  end
end
```

### Custom Domain Routing (Future — Phase 2)

For running the public site on a different domain than the app.

```ruby
config.custom_domain = "www.yourproduct.com"
config.app_domain = "app.yourproduct.com"
```

---

## Configuration

```ruby
# config/initializers/saas_front.rb
SaasFront.configure do |config|
  # Basics
  config.site_name = "YourApp"
  config.site_tagline = "Your tagline here"

  # Auth — protect the admin UI
  config.admin_auth = ->(controller) { controller.current_user&.admin? }

  # User model — for change tracking
  config.current_user_method = :current_user

  # Routing
  config.admin_path = "/admin/site"       # Admin UI mount point
  config.public_path = "/"                # Public pages mount point (or "/pages")
  config.api_path = "/api/sf"             # API mount point

  # Features
  config.enable_tracking = true           # Page view tracking
  config.enable_lead_capture = true       # Lead forms
  config.enable_api = true                # REST API
  config.enable_webhooks = true           # Outbound webhooks
  config.enable_social_proof = false      # Social proof popups
  config.enable_announcements = true      # Announcement bar

  # Tracking
  config.tracking_method = :js            # :js or :server_side
  config.session_timeout = 30.minutes
  config.data_retention = 365.days        # How long to keep analytics data
  config.hash_ip_addresses = true         # Privacy

  # Blog integration — tell SaasFront where your blog lives
  config.blog_path = "/blog"              # SaasFront won't claim this route
  config.excluded_paths = ["/blog", "/app", "/admin"]

  # Assets
  config.asset_storage = :active_storage  # or :direct (URL-based)
  config.max_upload_size = 5.megabytes

  # API
  config.api_rate_limit = 100             # Requests per minute

  # Callbacks
  config.on_lead_created = ->(lead) { }
  config.on_page_published = ->(page) { }
  config.on_conversion = ->(event) { }
end
```

---

## Installation & Setup

```bash
# Add to Gemfile
gem 'saas_front'

# Install
bundle install
rails saas_front:install

# This generates:
#   - config/initializers/saas_front.rb (configuration)
#   - db/migrate/*_create_saas_front_tables.rb (all tables)
#   - config/saas_front/pages/ (directory for DSL page definitions)

# Run migrations
rails db:migrate

# Mount the engine (added automatically by installer)
# config/routes.rb
mount SaasFront::Engine => "/admin/site", as: "saas_front_admin"

# Seed default pages (optional)
rails saas_front:seed

# Launch onboarding
# Visit /admin/site → onboarding wizard runs automatically on first visit
```

---

## Database Tables

The install migration creates these tables:

```
saas_front_pages
saas_front_sections
saas_front_leads
saas_front_page_views
saas_front_events
saas_front_daily_stats
saas_front_versions
saas_front_change_sets
saas_front_nav_items
saas_front_assets
saas_front_announcements
saas_front_redirects
saas_front_api_keys
saas_front_webhooks
saas_front_settings          # Key-value store for site settings
```

All tables are prefixed with `saas_front_` to avoid collisions with host app.

---

## Rendering Pipeline

How public pages get rendered:

```
Request: GET /pricing
    │
    ▼
SaasFront::PublicController#show
    │
    ├── Find page by slug
    ├── Check page is published
    ├── Record page view (async)
    ├── Capture UTM params to session
    │
    ▼
SaasFront::PageRenderer
    │
    ├── Load page layout template
    ├── For each section (ordered by position):
    │     ├── Load section partial: sections/_hero.html.erb
    │     ├── Pass section.content as local variables
    │     └── Apply section.settings (CSS classes, styles)
    │
    ├── Inject SEO meta tags into <head>
    ├── Inject tracking JS (if enabled)
    ├── Inject announcement bar (if active)
    │
    ▼
Rendered HTML (inside your app's layout or SaasFront's layout)
```

**Layout options:**
1. Use your app's application layout (default — integrates seamlessly)
2. Use SaasFront's built-in layout (standalone — includes nav, footer)
3. Use a custom layout: `config.public_layout = "marketing"`

---

## Rake Tasks

```bash
# Page management
rails saas_front:pages:sync         # Sync DSL definitions to database
rails saas_front:pages:list         # List all pages and their status
rails saas_front:seed               # Create default pages from templates

# Analytics
rails saas_front:analytics:rollup   # Aggregate daily stats (run via cron)
rails saas_front:analytics:cleanup  # Remove data older than retention period

# Maintenance
rails saas_front:install            # Run installer
rails saas_front:api_key:generate   # Generate new API key
rails saas_front:export             # Export all pages as JSON
rails saas_front:import FILE=x.json # Import pages from JSON
```

---

## Build Phases

### Phase 1: Core (MVP — build this first)
- [ ] Page model with CRUD
- [ ] Section model with content schemas (hero, features, pricing, faq, cta, text_block)
- [ ] Basic admin UI (page list, page editor with section forms)
- [ ] Public rendering (pages render at `/<slug>`)
- [ ] Version tracking on pages/sections
- [ ] SEO meta tags (title, description, OG)
- [ ] Install generator
- [ ] Configuration system
- [ ] DSL for defining pages in code

**Ship when:** You can create a page in admin, add sections, publish it, and see it at `/<slug>`.

### Phase 2: Lead Capture & Analytics
- [ ] Lead model + form sections
- [ ] Page view tracking (JS snippet)
- [ ] Event tracking (form submits, CTA clicks)
- [ ] Analytics dashboard in admin
- [ ] Daily stats aggregation
- [ ] UTM parameter capture
- [ ] Lead list + export in admin
- [ ] Email notification callback on new lead

**Ship when:** You can build a landing page, capture leads, and see conversion stats.

### Phase 3: Change Management & Polish
- [ ] Full version history UI with diffs
- [ ] Rollback functionality
- [ ] Change sets (group related changes)
- [ ] Navigation manager
- [ ] Announcement bar
- [ ] Redirect manager
- [ ] Asset upload + management
- [ ] Onboarding wizard
- [ ] Additional section types (testimonials, stats, comparison, logo cloud)

**Ship when:** Non-technical team members can manage the site confidently.

### Phase 4: API & 3rd Party Integration
- [ ] REST API (full CRUD)
- [ ] API key management
- [ ] Webhooks (outbound events)
- [ ] Rate limiting
- [ ] API documentation
- [ ] Multi-app identifier in API responses

**Ship when:** Your command center app can manage pages and read analytics across apps.

### Phase 5: Advanced (Future)
- [ ] A/B testing
- [ ] Social proof widget
- [ ] Custom domain routing
- [ ] Page templates marketplace
- [ ] Drag-and-drop section reordering (Sortable.js)
- [ ] Live preview while editing
- [ ] Scheduled publishing (publish at future date)
- [ ] Page-level access controls (password-protected pages)
- [ ] Multi-language support

---

## Gem Dependencies

```ruby
# saas_front.gemspec
spec.add_dependency "rails", ">= 7.1"
spec.add_dependency "turbo-rails"          # Hotwire for admin UI
spec.add_dependency "stimulus-rails"       # JS controllers
spec.add_dependency "pagy"                 # Pagination
spec.add_dependency "jbuilder"             # JSON API responses

# Optional / recommended
spec.add_development_dependency "rspec-rails"
spec.add_development_dependency "factory_bot_rails"
spec.add_development_dependency "capybara"
```

Tailwind CSS is expected in the host app (or SaasFront ships minimal standalone CSS).

---

## How This Fits Your Workflow

1. **New SaaS app:** `gem 'saas_front'` → `rails saas_front:install` → onboarding wizard → public site live in under an hour
2. **Iterate on copy:** Open admin UI → edit headline → publish → change tracked automatically
3. **Launch campaign:** Create landing page in admin or DSL → set up lead form → share link → watch analytics
4. **Command center:** Your 3rd party app hits the API → manages pages/leads across WYN, EventEngine site, future apps
5. **Code-first launch:** Define pages in `config/saas_front/pages/*.rb` → `rails saas_front:pages:sync` → deployed with code, editable in UI

---

## Name Alternatives

If `saas_front` doesn't feel right:

| Name | Vibe |
|------|------|
| `saas_front` | Descriptive, clear |
| `frontdoor` | The entry to your app |
| `launchsite` | Speed-focused |
| `pagesmith` | Crafted pages |
| `storefront` | E-commerce feel (maybe too specific) |
| `sitecraft` | Building craft |
