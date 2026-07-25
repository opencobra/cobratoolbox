# Contract: Header-Compliance Rule Catalog

This is the authoritative rule set the checker (`checkFunctionHeaders.m`) implements and
the remediation agents satisfy. Every rule is derived from
`documentation/source/guides/documentationGuide.rst` and `.../styleGuide.rst`
(Constitution Principle VII-E, X). The **header** is the block of comment lines between a
function's signature line and its first executable line.

`error` = blocks the CI gate (SC-007): either the generator would error, or documented
content would be silently dropped, or a declared argument/used field is undocumented.
`warning` = reported, does not block the gate.

## Applicability

- **function file** (first non-comment line is `function …`): all rules apply.
- **script file** (no `function` signature): only H-DESC and H-PCT apply (FR-010).
- **excluded-vendored** (research R2): no rules; reported as excluded, never edited.
- Only the **primary** (first) function's header is evaluated; sub/local functions are
  out of scope for the gate (spec Edge Cases, Assumptions).

## Rules

### H-EMPTY — non-empty header *(error, function)*
A function file MUST have at least one header comment line (a description) between the
signature and the first code line.
- FAIL: signature immediately followed by code (85 files at baseline).
- PASS: `function y = f(x)` then `% Computes y from x`.

### H-DESC — description present *(error, both)*
The header MUST open with ≥1 description line before the first keyword block.
- PASS: `% Adds a reaction to the model or modifies an existing reaction`.

### H-PCT — one space after `%` *(error, both)*
Every header content line MUST have exactly one space after `%` (`% text`, not `%text`).
Lines the generator deliberately ignores are exempt: `%%` section headers and
`% ..`-prefixed lines.
- FAIL: `%INPUTS:` or `%    model:  ...` written as `%model: ...`.
- PASS: `% INPUTS:`.

### H-USAGE — USAGE block with signature *(error, function)*
A `USAGE:` block MUST be present and contain the function's call signature, with one
blank comment line before the keyword, after the keyword, and after the signature.
- PASS:
  ```matlab
  % USAGE:
  %
  %    [model, rxnIDexists] = addReaction(model, rxnID, varargin)
  %
  ```

### H-OUT — every declared output documented *(error, function)*
Every output variable in the signature MUST appear on its own line inside an
`OUTPUT:`/`OUTPUTS:` block, with a colon after the name and ≥4 spaces before the
description.
- FAIL: signature `[model, rxnIDexists] = …` but header documents only `model`.
- PASS: both `model:` and `rxnIDexists:` present in `OUTPUTS:`.

### H-IN — every declared input documented *(error, function)*
Every input in the signature that is not pure `varargin` MUST appear on its own line
inside an `INPUT:`/`INPUTS:` or `OPTIONAL INPUTS:` block, with a colon after the name and
≥4 spaces before the description.
- FAIL: signature `f(model, rxnID, varargin)` documents `model` only.
- PASS: `model:` and `rxnID:` present; `varargin` handled by H-NV.

### H-NV — consumed name-value / varargin parameters documented *(error where detectable, function)*
Where the body extracts named parameters from `varargin` via a detectable pattern
(`inputParser` `addRequired`/`addOptional`/`addParameter`; `struct(varargin{:})` field
reads; documented COBRA parsers), every parameter the code reads MUST be documented in an
`OPTIONAL INPUTS:` (or `INPUTS:`) block, typically as `* name - description` sub-bullets
under `varargin`. Parameters the code never reads MUST NOT be added.
- Detectable-and-missing → `error`. Pattern not statically detectable → not flagged
  (avoid false positives; the agent still documents it manually).

### H-ARGFMT — argument line format *(error, function)*
Argument lines MUST be indented 4 spaces after `%`, have a colon after the argument name,
and ≥4 spaces between the colon and the description. Mis-indentation is a generator error.
- FAIL: `% input3: desc` (no 4-space indent) or `%    input2  desc` (no colon).
- PASS: `%    input2:     Description of input2`.

### H-FIELD — struct field sub-bullet format *(error, function)*
When a struct argument lists fields, each field MUST use the `* .field - description`
form: a blank comment line after the struct argument, then sub-bullets indented 2 spaces
beyond the struct description, with a space between `*` and `.`, and multi-line field
descriptions aligned to the first description character.
- FAIL: `%   * .field` (wrong indent) or `%    *.field` (no space after `*`).
- PASS:
  ```matlab
  %    model:    COBRA model structure with fields:
  %
  %                * .S - `m x n` stoichiometric matrix
  %                * .lb - `n x 1` lower flux bounds
  ```

### H-FIELDUSE — used struct fields documented *(error where detectable, function)*
For a struct-typed argument `a`, every field the body **reads** (`a.field`,
`isfield(a,'field')`) for an input, or **writes** (`a.field = …`) for an output, MUST be
listed as an H-FIELD sub-bullet under `a`. Only fields the function uses are required
(Clarifications); the full struct schema is NOT required. Undocumented used field →
`error`. Field meanings come from `COBRAModelFields.rst` / `solveCobraLP.m` /
`optimizeCbModel.m`, else are inferred from usage without fabrication (FR-006).

### H-BODYGAP — one blank line before body *(warning, function)*
The header SHOULD end with one empty line before the first executable line, and there
MUST NOT be a lone comment line immediately above the first code line (that comment would
be pulled into the generated doc). Provenance `% .. Author:` lines followed by a blank
line are the correct terminator.

### H-SIG — canonical signature spacing *(error, function)*
The `function` signature MUST have a space after each comma, a space before and after
`=`, and no padding inside `[...]`/`(...)`. A malformed signature errors the generator.
- FAIL: `function [ a,b ]=f( x,y )`.
- PASS: `function [a, b] = f(x, y)`.

### H-AUTHOR — provenance lines ignored by generator *(warning, function)*
`Author`/`Authors` provenance lines SHOULD be prefixed `% ..` so the generator ignores
them (they are not shown in docs). Existing correct `% .. Author:` lines MUST be
preserved, not "fixed" into rendered content.

## Gate semantics (SC-007)

- The CI gate (`testHeaderCompliance.m`) FAILS iff any in-scope file has ≥1
  `error`-severity violation.
- `warning`-severity violations are printed in the report but do not fail the gate.
- The checker MUST run headless with no solver/internet/GUI and finish scanning all
  in-scope `src/*.m` in the same MATLAB process well under a minute.

## Behaviour-preservation contract (FR-008, SC-005)

Independent of the rules above, remediation MUST NOT change any executable line. The
verifier compares, per changed file, the sequence of non-comment / non-blank lines
(trailing whitespace stripped) before vs after; any difference is a hard failure. The
only permitted non-comment change is signature whitespace that leaves the tokenised
signature identical (H-SIG).
