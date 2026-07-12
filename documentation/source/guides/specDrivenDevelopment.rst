Spec-driven development with an LLM
-----------------------------------

The COBRA Toolbox is developed with the help of AI coding agents (for example
Claude and Codex) under a **spec-driven** workflow managed by
`Spec Kit <https://github.com/github/spec-kit>`__. This page explains, for human
contributors, how that process works and how to instruct an LLM to develop a new
feature. It is a companion to the traditional *How to contribute* workflow above, not a
replacement: code still lands via a pull request to ``develop`` with tests.

Why spec-driven
~~~~~~~~~~~~~~~~

An LLM can change a lot of code very quickly. In a widely-used scientific library
that is a risk: a silent change to stoichiometry, a solver status, or a public
function signature is a defect even if the code still runs. Spec-driven development
puts a reviewable **specification, plan, and task list** in front of every
non-trivial change, so the intent is agreed before any code is written and every edit
is auditable back to a requirement.

The source of truth is the repository, not the website. The rules the agents follow
live in ``.specify/memory/constitution.md`` (the project *constitution*), and this
documentation site is generated from ``documentation/source/`` — so what you read here
is always a rendered view of what is in the repo.

The constitution
~~~~~~~~~~~~~~~~~

The constitution is the single, agent-neutral source of truth for how to work in the
repository. It binds AI agents and human contributors to the same openCOBRA
conventions (the :ref:`styleGuide`, the documentation guide, the :ref:`testGuide`, and
the model-field specification) and adds the discipline needed for LLM-assisted work:
scientific and numerical correctness, backward compatibility of public interfaces and
model fields, solver abstraction, testing via ``prepareTest`` and
``test/verifiedTests``, polyglot (MATLAB + Python + Julia) fidelity, file placement,
and single-sourced documentation.

Read it before instructing an agent: ``.specify/memory/constitution.md``.

The workflow
~~~~~~~~~~~~~

Any non-trivial change proceeds through an explicit sequence of phases. Each phase
produces an artefact under ``specs/<NNN-feature-name>/`` that you can read and approve
before the next phase begins:

.. code-block:: text

    constitution   the rules (already ratified; amended only deliberately)
    specify        spec.md   — what and why, with measurable success criteria
    clarify        resolve ambiguities in the spec (if needed)
    plan           plan.md   — how, checked against the constitution
    tasks          tasks.md  — an ordered, independently testable task list
    analyze        cross-check spec/plan/tasks for consistency (if available)
    implement      edit code — only now, and only after the above are approved

The human stays in the loop: you review and approve the spec, the plan, and the task
list before implementation, and you review the resulting pull request as usual.

The implementation gate
~~~~~~~~~~~~~~~~~~~~~~~~~

The most important rule (constitution Principle VI) is that **an ordinary request does
not authorise code changes**. Asking an agent to "fix this" or "add that" is treated
as a request to *enter* the workflow — to draft or update a spec — not as permission to
edit source, tests, or build files. Implementation happens only after ``spec.md``,
``plan.md``, and ``tasks.md`` exist and are approved, and you explicitly invoke the
implementation phase.

There is a single, deliberate escape hatch for a genuinely trivial fix, which you type
verbatim:

.. code-block:: text

    DIRECT IMPLEMENTATION OVERRIDE: bypass Spec Kit for this change.

Without that exact phrase, the agent will stop and tell you which phase to run next.

How to instruct an LLM to develop a feature
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Describe the feature in plain language — the scientific goal, the functions or
   models involved, and how you would know it works (the success criteria matter most).
2. Ask the agent to run the specification phase (``/speckit-specify`` in Claude; the
   equivalent ``speckit-specify`` surface in Codex). Review the generated ``spec.md``
   and answer any clarification questions.
3. Ask for the plan (``/speckit-plan``) and then the tasks (``/speckit-tasks``). Read
   them. This is where you catch a wrong assumption cheaply, before any code exists.
4. When you are satisfied, invoke implementation (``/speckit-implement``). The agent
   edits code, runs tests, and records an implementation receipt under
   ``specs/<feature>/agent-runs/``.
5. Review the pull request against ``develop`` as you would any contribution: tests,
   backward compatibility, solver independence, and numerical correctness.

A good instinct is to spend your effort on the spec and the plan. A clear specification
is a better lever on the outcome than detailed instructions during implementation.

Agent-agnostic
~~~~~~~~~~~~~~~

The workflow does not depend on any single AI product. The constitution and the
``specs/`` artefacts are agent-neutral; each agent has its own command surface
(``.claude/`` for Claude, ``.agents/`` for Codex and others) that maps to the same
phases. A contributor may use whichever agent they prefer, and the resulting specs,
plans, tasks, and receipts read the same way.

Where the artefacts live
~~~~~~~~~~~~~~~~~~~~~~~~~~

* ``.specify/memory/constitution.md`` — the rules (source of truth).
* ``.specify/`` — Spec Kit templates, scripts, and the ``git``, ``agent-context``, and
  ``human-loop`` extensions.
* ``.claude/`` and ``.agents/`` — the per-agent command and skill surfaces.
* ``specs/<NNN-feature-name>/`` — the spec, plan, tasks, analysis, and implementation
  receipts for each feature.
* ``CLAUDE.md`` and ``AGENTS.md`` — thin pointers that direct an agent to the
  constitution.
