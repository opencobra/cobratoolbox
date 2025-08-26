Software Lifecycle
==============================================================

Introduction
----------------

The COBRA Toolbox is an open-source MATLAB platform for constraint-based
modelling of biological networks. It supports optimization methods such
as Flux Balance Analysis (FBA), gene deletion analysis, thermodynamic
feasibility studies, and multi-scale modelling. To ensure quality,
reproducibility, and long-term maintainability, we follow a structured
Software Development Lifecycle (SDLC).

Development Model
------------------------

We use an **iterative and incremental model** focused on reproducibility
and scientific validation. Each cycle covers planning, design,
implementation, testing, release, and maintenance. This allows us to
integrate new methods, optimise existing functionality, and fix issues
while keeping the software stable.

Phases
--------

* **Planning** \- Development goals are identified from community feedback, GitHub issues, and the project roadmap.
* **Requirements & Design** \- New features are defined with clear acceptance criteria and designed for compatibility with MATLAB and supported solvers.
* **Implementation** \- Code is developed in feature branches, documented, and accompanied by tutorials.
* **Testing** \- Every contribution is validated by automated tests through our continuous integration (CI) system, with peer review before merging.
* **Release** \- Stable versions are periodically published on GitHub. The main branch holds stable releases, while the develop branch contains the latest development work.
* **Maintenance** \- Bug fixes, solver updates, and compatibility improvements are applied regularly, with minor releases issued as needed.

Roles and Responsibilities
--------------------------------

* **Maintainers** oversee quality control and approve merges.
* **Contributors** add features, fix bugs, and provide documentation.
* **Community** members submit issues, feature requests, and pull requests.

Tools and Infrastructure
--------------------------------

* **Version control**: GitHub (main and develop branches).
* **Continuous Integration**: Automated test suite (`testAll <https://github.com/opencobra/cobratoolbox/blob/develop/test/testAll.m>`__) run on pull requests.
* **Documentation**: MATLAB function help text and tutorials, with HTML tutorials generated automatically.
* **Supported solvers**: GLPK, Gurobi, MOSEK, TOMLAB, with CPLEX support limited to older MATLAB versions.

Quality Assurance
------------------------

* All contributions undergo automated testing and code review.
* Test results are posted on pull requests before merging.
* Performance profiling and reproducibility checks are part of the validation process.

Releases
--------

* Versions follow **Semantic Versioning** (MAJOR.MINOR.PATCH).
* Each release includes detailed release notes and updated tutorials.
