# Tasks: checkModelProperties

- [x] T001 Read the function; list the dense and quadratic operations (lines 275 and 301 are inside `if checkTrivial`, dead code)
- [x] T002 Write testCheckModelProperties.m (Tier 2/3, ecoli_core plus a 6 x 7 hand-built model) on the unmodified function; passes three times; 219 of 340 lines, exemptions and 3 defects in the header
- [x] T003 Measure the function's own code on the 30 665 x 38 841 model -> research.md
- [x] T004 Measure the whole function on a stored Recon4 feasible model (3 h limit reached in the solver stages) -> research.md
- [x] T005 Decide: measured, not worth changing (no source edit, Principle IV)
- [x] T006 Commit on the feature branch, push to the maintainer's fork only, no PR
