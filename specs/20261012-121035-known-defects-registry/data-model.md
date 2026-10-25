# Data Model: Known-defects registry

- **DefectEntry**: `function_path` (from "Function under test:"), `title`, `severity`,
  `trigger`, `observed`, `expected`, `lines` (list of ranges), `test_file`, `header_line`
  (line of the entry's `- DEFECT:` line, for error messages).
- **Registry**: DefectEntry list grouped by `function_path`, ordered by function path then
  title; rendered to Markdown.
- **Parse errors**: `(file, line, message)` triples; any error means no registry is written.

Registry layout (rendered): title and a "generated, do not edit" notice with the
regeneration command; a count line; the summary table (Function, Severity, Problem, Test
file); then per function a section with its defects (Severity, Trigger, Observed, Expected,
Source lines). Function names are shown as the repository-relative source path.
