# Data Model: function-name conflicts

- **Conflict**: `name` (lower-case key), `kind` (`duplicate` | `shadows-matlab`), `files`
  (repository-relative paths), `matlabFile` (path, for `shadows-matlab`).
- **Known entry**: `name`, `kind`, `reason` (text). File format, one per line:
  `name | kind | reason`; blank lines and lines starting with `#` ignored.
- **Detector** (local function of the test): input a list of folders to scan (the repository
  `src/` and `external/`, or the temporary tree) and the MATLAB root; output Conflict array.
- **Message formatter**: Conflict array and the MATLAB release -> text with the five items.
