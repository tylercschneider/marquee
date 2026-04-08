# Add Social Meta Tags (Open Graph + Twitter Cards)

## Context

Marquee already renders partial OG tags (`og:title`, `og:description`, `og:type`) inline in the layout. The database has `og_image` and `schema_markup` columns that aren't used. This change completes social meta tag support so shared links preview properly on iMessage, Slack, LinkedIn, Twitter, etc.

## Changes

### 1. Configuration (`lib/marquee/configuration.rb`)
- Add `base_url` and `default_og_image` to `attr_accessor`
- Initialize both to `nil`

### 2. PageDefinition DSL (`lib/marquee/page_definition.rb`)
- Add `@_og_image = nil` in `initialize`
- Add `og_image` getter/setter method (same pattern as `meta_title`)
- Add `og_image: defn.og_image` to the `attrs` hash in `sync!`

### 3. Helper (`app/helpers/marquee/application_helper.rb`)
Add `marquee_social_meta_tags` method that renders:
- `<meta name="description">`, `og:title`, `og:description`, `og:type` ("website"), `og:site_name`, `og:url`, `og:image`
- `twitter:card` ("summary_large_image" if image present, else "summary"), `twitter:title`, `twitter:description`, `twitter:image`

Fallback logic:
- Title: `@page.meta_title || @page.title`
- Description: `@page.meta_description`
- Image: `@page.og_image || config.default_og_image` -- converted to absolute via `base_url` if relative
- URL: `base_url + slug` if configured, else `request.original_url`
- Site name: `config.site_name`

Add private `ensure_absolute_url` helper to prefix relative paths with `base_url`.

Also render `schema_markup` as `<script type="application/ld+json">` if present.

### 4. Layout (`app/views/layouts/marquee/application.html.erb`)
Replace inline meta tags (lines 5-11) with `<%= marquee_social_meta_tags %>`. Keep `<title>` tag.

### 5. Initializer template (`lib/generators/marquee/install/templates/initializer.rb`)
Add commented `config.base_url` and `config.default_og_image` examples.

### 6. README (`README.md`)
Add "Social Meta Tags" section documenting configuration and per-page `og_image` in DSL.

### 7. Tests
- `test/helpers/marquee/application_helper_test.rb` -- test all meta tag output, fallbacks, absolute URL conversion, twitter card type, nil @page, schema_markup
- Update or add page definition test for `og_image` DSL + sync

## Files to Modify
- `lib/marquee/configuration.rb`
- `lib/marquee/page_definition.rb`
- `app/helpers/marquee/application_helper.rb`
- `app/views/layouts/marquee/application.html.erb`
- `lib/generators/marquee/install/templates/initializer.rb`
- `README.md`

## Files to Create
- `test/helpers/marquee/application_helper_test.rb`

## Verification
1. Run existing tests: `bin/rails test` in test/dummy context
2. Run new helper tests
3. Verify meta tags render correctly by inspecting HTML output in integration test
