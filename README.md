# Marquee

A page framework engine for Rails SaaS apps. Marquee provides page registration, routing, versioning, A/B testing, funnel tracking, lead capture, and an admin UI.

Pages are code — ERB templates in your host app — and Marquee provides the infrastructure around them.

## Installation

Add to your Gemfile:

```ruby
gem "marquee"
```

Run the install generator:

```bash
$ bin/rails generate marquee:install
$ bin/rails db:migrate
```

Mount the engine in `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount Marquee::Engine => "/"
end
```

## Configuration

Edit `config/initializers/marquee.rb`:

```ruby
Marquee.configure do |config|
  config.site_name = "My App"
  config.site_tagline = "Your tagline here"

  # Protect the admin UI
  config.admin_auth = ->(controller) {
    controller.redirect_to("/login") unless controller.current_user&.admin?
  }

  # Event adapter (default: LogAdapter)
  # config.event_adapter = Marquee::Events::AhoyAdapter.new
end
```

## Defining Pages

Register pages in your initializer. Each page maps to an ERB template in your host app:

```ruby
Marquee.define_page(:pricing) do
  title "Pricing"
  page_type "landing"
  meta_title "Plans & Pricing"
  meta_description "Find the right plan for your team."
  template_path "marquee_pages/pricing"
end
```

Create the corresponding template in your host app at `app/views/marquee_pages/pricing.html.erb`.

Sync page definitions to the database (e.g., in a deploy task or initializer):

```ruby
Marquee::PageDefinition.sync!(version: "v1.2.0")
```

## A/B Testing

Define experiments inline with page definitions:

```ruby
Marquee.define_page(:pricing) do
  title "Pricing"
  template_path "marquee_pages/pricing"

  experiment "Hero Copy Test" do
    metric "lead_capture"
    variant "Control", template_path: "marquee_pages/pricing", control: true
    variant "New Hero", template_path: "marquee_pages/pricing_v2", weight: 1
  end
end
```

Marquee automatically assigns visitors to variants and tracks assignments. Manage experiment lifecycle (start, pause, resume, complete) from the admin UI.

## Funnel Tracking

Define funnels to track visitor progression across pages:

```ruby
Marquee.define_funnel(:signup) do
  name "Signup Flow"
  step :landing, label: "Landing Page", position: 1
  step :pricing, label: "Pricing Page", position: 2
  step :checkout, label: "Checkout", position: 3
end
```

Funnel progress is recorded automatically when visitors view pages. View step-by-step visitor counts and drop-off rates in the admin UI.

## Lead Capture

Capture leads from any page with a form that posts to the leads endpoint:

```erb
<%= form_with model: Marquee::Lead.new, url: marquee.leads_path do |f| %>
  <%= f.hidden_field :source_page_id, value: @page.id %>
  <%= f.email_field :email, placeholder: "you@example.com" %>
  <%= f.text_field :name, placeholder: "Your name" %>
  <%= f.submit "Get Started" %>
<% end %>
```

Leads are automatically tied to A/B test variants for conversion tracking.

## Event Instrumentation

Marquee instruments events through a pluggable adapter system:

```ruby
# Built-in adapters
Marquee::Events::LogAdapter.new   # Logs to Rails.logger (default)
Marquee::Events::NullAdapter.new  # No-op
Marquee::Events::AhoyAdapter.new  # Forwards to Ahoy

# Manual instrumentation
Marquee.instrument("custom.event", user_id: 123, action: "clicked_cta")
```

Events tracked automatically:
- `page.viewed` — page ID, slug, experiment/variant IDs
- `lead.created` — email, source page ID

## Admin UI

Marquee includes an admin interface at `/admin/` with:

- **Pages** — list of all registered pages
- **Experiments** — status, variant performance, start/pause/resume/complete controls
- **Funnels** — step-by-step visitor counts and drop-off rates
- **Leads** — captured leads with conversion data

Protect it with the `admin_auth` configuration option (see Configuration above).

## Routes

Marquee provides these routes:

| Method | Path | Description |
|--------|------|-------------|
| GET | `/:slug` | Render a published page |
| POST | `/leads` | Create a lead |
| GET | `/admin/pages` | List pages |
| GET | `/admin/experiments` | List experiments |
| GET | `/admin/experiments/:id` | Experiment detail + results |
| POST | `/admin/experiments/:id/start` | Start an experiment |
| POST | `/admin/experiments/:id/pause` | Pause an experiment |
| POST | `/admin/experiments/:id/resume` | Resume an experiment |
| POST | `/admin/experiments/:id/complete` | Complete an experiment |
| GET | `/admin/funnels` | List funnels |
| GET | `/admin/funnels/:id` | Funnel detail + results |
| GET | `/admin/leads` | List leads |

## Requirements

- Ruby 3.1+
- Rails 8.1+

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
