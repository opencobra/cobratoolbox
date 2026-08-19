# Data Model: Full-Site Documentation Search

This feature has no MATLAB/COBRA model data (no stoichiometric matrix, reaction, or
metabolite fields). Its "data" is the site's search index and the query/result shapes that
flow through the browser widget. Entities below correspond directly to the Key Entities
already named in `spec.md`.

## Documentation Page

A single published page on the website.

| Field | Meaning | Source |
|-------|---------|--------|
| `title` | Page or section title shown to the visitor | Sphinx doctitle (rst-generated pages) or the tutorial HTML's `<title>`/`<h1>` (tutorial pages) |
| `url` | Path to the page, relative to the published site root | Sphinx-assigned path (rst-generated) or the tutorial's staged path under `stable/tutorials/` |
| `body_text` | Extracted plain text used for matching | Sphinx's own text extraction (rst-generated, already inside `searchindex.js`) or stripped-tag text pulled from the staged tutorial HTML (new step, Decision 2 in `research.md`) |
| `kind` | Which source produced this page — `"rst"` or `"tutorial"` | Set by whichever generation step emitted the entry |

Not a new persisted structure for `rst`-sourced pages — this row describes what already
exists inside Sphinx's `searchindex.js`. It is a genuinely new, small structure for
`tutorial`-sourced pages, emitted by the new supplemental-index step.

## Search Index Entry

The searchable, matchable unit derived from one Documentation Page (or a meaningful section
within it, matching Sphinx's own existing granularity for `rst` pages).

| Field | Meaning |
|-------|---------|
| `title` | Display title for a result |
| `url` | Link target, including any in-page anchor Sphinx already generates for sub-sections |
| `snippet_source` | The text used to compute relevance and to derive a shown excerpt |
| `kind` | `"function"` (a function reference page — a `rst`-kind page under `modules/`), `"doc"` (any other `rst`-kind page), or `"tutorial"` |

`kind` is what lets the rendered result be distinguishable per the Edge Cases in `spec.md`
("query matches both a function name and unrelated narrative content ... must be
distinguishable"), and lets FR-003's parity requirement be checked directly: a result with
`kind = "function"` is present and ranked appropriately for a function-name query.

No entry is persisted to a database — the full set of entries for a given publish is exactly
the union of what Sphinx's `searchindex.js` already contains (for `function`/`doc` kinds)
plus the new supplemental JSON emitted by the tutorial-indexing step (for the `tutorial`
kind). Both are static files shipped alongside the rest of the published site, refreshed
every time `build-and-publish-docs.yml` runs (satisfying FR-006/FR-007: content and only
content that is actually published is reflected, automatically, every publish).

## Search Query

The text a visitor types into the search bar. No new shape beyond a plain string — validated
client-side only for a minimum length before triggering matching (Edge Case: very short
queries must not return an unhelpfully large/noisy set).

## Search Result

A ranked match between a Search Query and one Search Index Entry, as rendered to the
visitor.

| Field | Meaning |
|-------|---------|
| `title` | From the matched entry |
| `url` | From the matched entry (visitor navigates here on selection) |
| `excerpt` | Short, query-relevant snippet derived from `snippet_source`, giving the visitor context to judge relevance (FR-002) |
| `kind` | Carried through from the entry, used to visually distinguish function results from narrative/tutorial results |
| `rank` | Position in the relevance-ordered list (FR-004) |

## Flow

```
visitor keystroke
      │
      ▼
Search Query (debounced client-side)
      │
      ├──► match against Sphinx searchindex.js  ──► candidate Search Index Entries (kind: function | doc)
      │
      └──► match against tutorials-supplement.json ──► candidate Search Index Entries (kind: tutorial)
      │
      ▼
merge + rank candidates ──► top-N Search Results ──► rendered inline under the search box
```

No entity here has a state machine or lifecycle beyond "present in the current publish's
index, or not" — an entry's presence is fully determined by whether its source page is part
of the current publish, which is exactly the mechanism that satisfies SC-005 (removed
content stops appearing after the next successful publish): the next `make html` /
tutorial-index run simply does not emit an entry for content that no longer exists.
