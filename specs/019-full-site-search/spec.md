# Feature Specification: Full-Site Documentation Search

**Feature Branch**: `019-full-site-search`

**Created**: 2026-08-17

**Status**: Draft

**Input**: User description: "look at the CI and how a change in the documentation that lives under master branch in rst files trigers the CI to generate the html format using sphinx and push it to the gh-pages. Currently on the cobra toolbox website the search bar only looks through the function names. I want to change this feature into a general search bar that searchs through all the documentations on the website"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Find any documentation topic, not just a function (Priority: P1)

A visitor to the COBRA Toolbox website types a word or phrase into the site's search bar looking for guidance on a topic — for example a tutorial name, an installation step, a modeling concept, or wording from the FAQ or contributing guide. Today the search bar only matches against the list of MATLAB function names, so a query like "flux balance analysis" or "install Gurobi" returns nothing useful even though pages covering that content exist on the site. The visitor needs the search bar to search across everything published on the site and take them straight to the right page.

**Why this priority**: This is the entire premise of the request — the current search bar's narrow scope is the reported problem. Without this, there is no feature.

**Independent Test**: On the published site, type a phrase that appears only in narrative documentation (e.g. a sentence from `installation.rst` or a tutorial page) into the search bar and confirm a result linking to the correct page is returned. This can be verified without touching function search behavior at all.

**Acceptance Scenarios**:

1. **Given** the search bar on any page of the published site, **When** a visitor types a phrase that appears in a non-function documentation page (installation guide, FAQ, contributing guide, citation guide, etc.), **Then** the search bar returns that page as a result and following it navigates to the matching content.
2. **Given** a query with no matches anywhere on the site, **When** the visitor submits it, **Then** the search bar clearly indicates no results were found rather than showing a blank or misleading state.

---

### User Story 2 - Keep finding functions by name (Priority: P2)

A returning visitor who already relies on the search bar to jump straight to a function's reference page (today's only supported use case) continues to get that same fast, accurate lookup after the change — searching for a function name still surfaces that function's page as a top result.

**Why this priority**: The existing function-name search is a validated, actively used capability. Broadening scope must not degrade it, but the site remains useful for function lookup even before broader content search is perfected, so this ranks below User Story 1.

**Independent Test**: Search for a known, unambiguous function name (e.g. one used in existing tutorials) and confirm its reference page is returned as a top result, matching today's experience.

**Acceptance Scenarios**:

1. **Given** the search bar, **When** a visitor types an exact function name, **Then** that function's reference page appears among the top results and can be opened directly.
2. **Given** the search bar, **When** a visitor types a partial function name, **Then** matching function pages still appear in the results alongside any other matching content.

---

### User Story 3 - Search results stay current with published documentation (Priority: P3)

A documentation maintainer edits or adds `.rst` files on the `master` branch. Once the existing documentation pipeline builds and publishes the site, the search bar picks up the new or changed content automatically — no separate manual step is needed to keep search results in sync with what is published.

**Why this priority**: Keeps the feature trustworthy over time, but the initial delivery of broad search (User Stories 1–2) already provides the core value; staleness would only surface after subsequent documentation changes.

**Independent Test**: Publish a documentation change containing a distinctive new phrase, wait for the existing publish pipeline to complete, then confirm the search bar returns the updated page for that phrase — and that content removed in the same change no longer appears in results.

**Acceptance Scenarios**:

1. **Given** a documentation change merged to `master` that adds a distinctive new phrase to a page, **When** the site finishes publishing, **Then** searching for that phrase returns the updated page.
2. **Given** a documentation change that removes a page or section, **When** the site finishes publishing, **Then** search no longer returns results pointing at the removed content.

---

### Edge Cases

- What happens when a query matches a very large number of pages (e.g. a common word)? Results must be ranked so the most relevant pages appear first, and the list must not overwhelm the visitor.
- How does the search bar behave for very short queries (e.g. a single character)? It should avoid returning an unhelpfully large or noisy result set.
- What happens when a query matches both a function name and unrelated narrative content? Both should appear, distinguishable enough that the visitor can tell which is which (e.g. by result type or page context).
- What happens when a documentation page is deleted or renamed on `master`? After the next publish, search must not link to a broken or stale URL.
- What happens when a visitor searches while the site is mid-publish? The visitor should see either the previous or the new consistent state, never a partially updated or broken index.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The search bar MUST return matches drawn from the full text of all documentation pages published on the website, not only the list of function names.
- **FR-002**: Each search result MUST show the visitor enough context to judge relevance (at minimum a page/section title) and MUST link directly to the matching page.
- **FR-003**: The search bar MUST continue to support finding a function by its exact or partial name, with that function's reference page returned as a result, matching today's capability (no regression to the existing, validated behavior).
- **FR-004**: Results MUST be ordered so that the content most relevant to the query appears first, rather than in an arbitrary or purely alphabetical order.
- **FR-005**: The search bar MUST return results directly from the search input, consistent with the site's current instant-lookup interaction, rather than requiring a full separate page load to see whether any match exists.
- **FR-006**: The searchable content MUST be regenerated automatically as part of the existing documentation build-and-publish pipeline (triggered by changes to `.rst` files on `master`), so results reflect the latest published content without requiring maintainers to perform a separate manual indexing step.
- **FR-007**: The search bar MUST NOT surface content that is not part of the published website (no draft, unpublished, or internal-only content may appear in results).
- **FR-008**: Search MUST include tutorial pages in addition to the content freshly generated from `.rst` sources each publish. Because tutorial HTML is carried over from the previously published site rather than rebuilt from source on every run (see `build-and-publish-docs.yml`), the search-content generation step MUST scan the carried-over tutorial HTML currently staged for publish, not only the freshly-built Sphinx output, so tutorials are searchable on the same terms as the rest of the site.
- **FR-009**: The documentation build MUST remain reliable: if generating the broader search content fails, the existing build-and-publish pipeline MUST fail visibly (not silently publish a site with a broken or missing search bar).
- **FR-010**: Search response to a typed query MUST feel instant to the visitor (perceived latency low enough to support type-as-you-go use, consistent with the current function-name search bar), even as the amount of indexed documentation grows.

### Key Entities

- **Documentation Page**: A single published page on the website (e.g. a guide, tutorial, FAQ entry, or function reference page) — has a title, body content, and a URL. The unit that a search result points to.
- **Search Index Entry**: The searchable representation of one documentation page (or a meaningful section within it) — derived from the page's title and text content, used to match visitor queries and rank results.
- **Search Query**: The text a visitor types into the search bar.
- **Search Result**: A ranked match between a query and one search index entry, shown to the visitor with enough context to decide whether to follow it.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A visitor searching for a phrase found only in non-function documentation (tutorials, guides, FAQ, installation, contributing) is shown the correct page as a result, for at least 95% of phrases sampled across the site's documentation sections.
- **SC-002**: Searching for a known function name continues to return that function's page among the top results, with no measurable regression versus current behavior.
- **SC-003**: Search results appear to the visitor within 1 second of typing a query, on a standard broadband connection.
- **SC-004**: After a documentation change is published, a distinctive new phrase from that change is findable via search within one publish cycle, with no manual maintainer action beyond the normal `.rst` edit and merge.
- **SC-005**: Content removed from the documentation source no longer appears in search results after the next successful publish.
- **SC-006**: The existing documentation build-and-publish pipeline (`build-and-publish-docs.yml`) continues to complete successfully with the added search-content generation step, and fails clearly (rather than partially publishing) if that step cannot complete.

## Assumptions

- The "search bar" referenced by the user is the site-wide quick-search box present in the page sidebar/header on every published page (currently backed by a function-name-only list), as opposed to introducing a brand-new UI element.
- The site remains a static, CI-published artifact (no application server); any broader search capability must work within that static-hosting constraint, consistent with Constitution Principle on the website being a generated artifact of `documentation/source/` via Sphinx.
- "All the documentation on the website" includes: function reference pages, installation instructions, FAQ, contributing/guides content, citation pages, and tutorials — i.e., everything on the published site, whether freshly generated from `documentation/source/*.rst` during the build or carried over as pre-built tutorial HTML from the previous deploy (per FR-008).
- Existing deep links into search (e.g. bookmarked function-page URLs) continue to resolve; this feature adds breadth to what can be found, it does not change how existing pages are addressed.
- No authentication or personalization is involved — search results are the same for all visitors, matching the site's current fully public, static nature.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001, FR-002, FR-004 | manual verification: query a phrase unique to a non-function doc page on the published site and confirm the correct page is returned and ranked first — (no source function) | — (no source function) |
| US2 / FR-003 | manual verification: query a known function name on the published site and confirm its reference page is returned among top results — (no source function) | — (no source function) |
| US3 / FR-006, SC-004, SC-005 | CI verification: publish a docs change with a distinctive phrase, confirm it is searchable after the next `build-and-publish-docs.yml` run, and confirm removed content drops out — (no source function) | — (no source function) |
| SC-006 / FR-009 | CI verification: `build-and-publish-docs.yml` run completes (or fails visibly) with the search-content generation step included — (no source function) | — (no source function) |
