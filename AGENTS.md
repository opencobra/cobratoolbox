# AGENTS.md

Guidelines for automated code review agents (Codex, AI reviewers, and bots) contributing to the COBRA Toolbox repository.

## Repository Overview

The COBRA Toolbox is a MATLAB-based software package for constraint-based modelling of biological networks.
It supports genome-scale metabolic modelling, flux balance analysis, and related optimisation methods.

Primary languages:

* MATLAB (main codebase)
* Shell scripts (CI and utilities)
* Docker (CI environment)

Key components:

* `/src/` – core COBRA Toolbox functionality
* `/test/` – unit and integration tests
* `/external/` – external solver and toolbox integrations
* `/docs/` – documentation
* `/tutorials/` – example workflows

CI runs MATLAB tests using Docker and a self-hosted GitHub runner.

---

## Coding Standards

### MATLAB

Follow MATLAB best practices:

* Functions should be **modular and well documented**
* Include **help blocks at the beginning of each function**
* Avoid unnecessary global variables
* Avoid modifying MATLAB path permanently
* Prefer vectorised operations over loops when possible

Function header format:

```
% functionName
%
% Description of function.
%
% USAGE:
%    output = functionName(input)
%
% INPUTS:
%    input: description
%
% OPTIONAL INPUTS:(If applicable)
%
% OUTPUTS:
%    output: description
%
% Authors:
%    Name
% NOTE: (If applicable)
```

---

## Solver Integration

The toolbox supports multiple solvers.

Preferred solver order:

1. gurobi
2. glpk
3. mosek

When reviewing code:

* ensure solver independence where possible
* avoid solver-specific assumptions
* verify compatibility with `changeCobraSolver`

Example expected pattern:

```
changeCobraSolver('gurobi','all',0)
```

---

## Testing Requirements

All new functionality must include tests.

Tests should:

* reside in `/test`
* be runnable via:

```
run('test/testAll.m')
```

Avoid tests that:

* require internet access
* rely on random results without fixed seeds
* require GUI interaction
* should be skipped if dependencies are not installed using prepareTest

CI runs MATLAB in headless mode.

---

## CI Environment

CI runs inside a Docker container with:

* MATLAB
* Gurobi
* Xvfb (headless display)
* Linux environment

MATLAB is executed using:

```
matlab -batch
```

Agents should ensure code is compatible with:

* headless execution
* Linux filesystem
* Docker environments

Avoid:

* GUI-only MATLAB functions
* OS-specific paths

---

## Performance Considerations

Genome-scale models can contain thousands of reactions and metabolites.

Reviewers should watch for:

* unnecessary nested loops
* inefficient matrix operations
* repeated solver calls inside loops
* large memory allocations

Prefer sparse matrices where appropriate.

---

## Documentation Expectations

Public functions must include:

* clear help text
* usage examples when applicable

Major features should also update:

* documentation
* tutorials

---

## Review Focus Areas

Automated reviewers should prioritise:

1. MATLAB correctness
2. solver compatibility
3. test coverage
4. numerical stability
5. performance for large models

Lower priority:

* stylistic MATLAB issues
* whitespace changes

---

## Security

The toolbox does not process user authentication data.
However, reviewers should flag:

* execution of arbitrary shell commands
* unsafe file operations
* unvalidated external inputs

---

## Contribution Expectations

Pull requests should:

* pass all tests
* maintain backwards compatibility
* include appropriate documentation

Breaking API changes should be clearly documented.

---

## Notes for AI Reviewers

When reviewing MATLAB code in this repository:

* prioritise numerical correctness
* avoid suggesting Python-style refactors
* assume MATLAB R2024b+ compatibility
* respect existing COBRA Toolbox conventions
* Make the notes and your suggestions short but meaningful

Focus feedback on **scientific correctness and algorithmic robustness**, not stylistic preferences.
