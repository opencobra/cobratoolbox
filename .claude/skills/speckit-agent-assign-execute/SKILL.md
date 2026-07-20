---
name: speckit-agent-assign-execute
description: Execute tasks by spawning the assigned agent for each task
compatibility: Requires spec-kit project structure with .specify/ directory
metadata:
  author: github-spec-kit
  source: agent-assign:commands/execute.md
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

1. **Setup**: Run `.specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. **Check Assignment File Exists**: Verify `agent-assignments.yml` exists in FEATURE_DIR.
   - If missing, **STOP** and report: "No agent-assignments.yml found. Run `/speckit.agent-assign.assign` first, then `/speckit.agent-assign.validate` to verify."

3. **Load Implementation Context**:
   - **REQUIRED**: Read `tasks.md` for the complete task list and execution plan
   - **REQUIRED**: Read `agent-assignments.yml` for agent-to-task mapping
   - **REQUIRED**: Read `plan.md` for tech stack, architecture, and file structure
   - **IF EXISTS**: Read `spec.md` for feature requirements and user stories
   - **IF EXISTS**: Read `data-model.md` for entities and relationships
   - **IF EXISTS**: Read contracts/ for API specifications and test requirements
   - **IF EXISTS**: Read `research.md` for technical decisions and constraints
   - **IF EXISTS**: Read `quickstart.md` for integration scenarios

4. **Project Setup Verification** (same as `/speckit.implement`):
   - **REQUIRED**: Create/verify ignore files based on actual project setup:

   **Detection & Creation Logic**:
   - Check if the following command succeeds to determine if the repository is a git repo (create/verify .gitignore if so):

     ```sh
     git rev-parse --git-dir 2>/dev/null
     ```

   - Check if Dockerfile* exists or Docker in plan.md → create/verify .dockerignore
   - Check if .eslintrc* exists → create/verify .eslintignore
   - Check if eslint.config.* exists → ensure the config's `ignores` entries cover required patterns
   - Check if .prettierrc* exists → create/verify .prettierignore
   - Check if .npmrc or package.json exists → create/verify .npmignore (if publishing)
   - Check if terraform files (*.tf) exist → create/verify .terraformignore
   - Check if .helmignore needed (helm charts present) → create/verify .helmignore

   **If ignore file already exists**: Verify it contains essential patterns, append missing critical patterns only
   **If ignore file missing**: Create with full pattern set for detected technology

5. **Parse Execution Plan**: Parse tasks.md structure and extract:
   - **Task phases**: Setup, Foundational, User Stories, Polish
   - **Task dependencies**: Sequential vs parallel execution rules
   - **Task details**: ID, description, file paths, parallel markers [P], story labels
   - **Agent assignments**: Look up each task ID in `agent-assignments.yml` to get assigned agent name

6. **Execute Tasks Phase by Phase**: For each phase in tasks.md, process tasks in order:

   **For each task**:
   - Look up the agent assignment from `agent-assignments.yml`
   - Determine execution mode:

   **Mode A — Default (no specialized agent)**:
   If the task is assigned to `default`, execute the task directly in the current context, following the same implementation rules as `/speckit.implement`:
   - Read relevant context files
   - Implement the task according to its description
   - Validate the result

   **Mode B — Specialized Agent**:
   If the task is assigned to a named agent (not `default`), launch the assigned agent to handle the task:
   - Use the assigned agent (by name) to execute this task
   - Provide the agent with a clear prompt containing:
     - The task ID and full description from tasks.md
     - Relevant context: tech stack from plan.md, related entities from data-model.md, API contracts if applicable
     - The specific file paths the task should create or modify
     - Any dependency context from previously completed tasks in this phase
   - Wait for the agent to complete its work
   - Verify the agent's output (files created/modified as expected)

   **Dependency and ordering rules**:
   - Complete each phase before moving to the next
   - Within a phase, run sequential tasks in order
   - Tasks marked [P] that are assigned to different agents can be spawned in parallel
   - Tasks affecting the same files must run sequentially regardless of [P] marker
   - If a task fails, halt execution for that phase and report the error

7. **Progress Tracking**:
   - After each completed task, mark it as `[X]` in tasks.md
   - Report progress after each task:
     ```
     ✓ T001 (default) — Created project structure
     ✓ T002 (backend-dev) — Implemented User model
     ✗ T003 (frontend-dev) — FAILED: Component creation error
     ```
   - After each phase, display a phase summary:
     ```
     ## Phase 1: Setup — Complete (3/3 tasks)
     ## Phase 2: Foundational — Complete (5/5 tasks)
     ## Phase 3: User Story 1 — In Progress (2/4 tasks)
     ```

8. **Error Handling**:
   - If a spawned agent fails or produces unexpected results, report the error with context
   - For non-parallel tasks, halt execution on failure and suggest next steps
   - For parallel tasks [P], continue with other tasks, collect and report all failures at phase end
   - If the agent definition file is missing at execution time, fall back to `default` mode and warn the user

9. **Completion Validation**:
   - Verify all tasks across all phases are marked as completed
   - Check that implemented features match the original specification
   - Validate that tests pass (if test tasks were included)
   - Confirm the implementation follows the technical plan
   - Report final status:
     ```
     ## Execution Summary

     | Phase   | Total | Completed | Failed | Skipped |
     |---------|-------|-----------|--------|---------|
     | Setup   | 3     | 3         | 0      | 0       |
     | Found.  | 5     | 5         | 0      | 0       |
     | US1     | 4     | 4         | 0      | 0       |
     | US2     | 3     | 3         | 0      | 0       |
     | Polish  | 2     | 2         | 0      | 0       |
     | **Total** | **17** | **17** | **0** | **0** |

     Agents used: backend-dev (6 tasks), frontend-dev (4 tasks), test-writer (3 tasks), default (4 tasks)
     ```

Note: This command requires both `tasks.md` and `agent-assignments.yml` to exist. If tasks.md is missing, suggest running `/speckit.tasks` first. If agent-assignments.yml is missing, suggest running `/speckit.agent-assign.assign` first.