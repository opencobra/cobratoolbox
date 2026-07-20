---
name: speckit-agent-assign-validate
description: Validate that all agent assignments are correct and agents exist
compatibility: Requires spec-kit project structure with .specify/ directory
metadata:
  author: github-spec-kit
  source: agent-assign:commands/validate.md
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Verify that agent assignments in `agent-assignments.yml` are complete, consistent, and reference agents that actually exist. This command is **READ-ONLY** — it does not modify any files. If issues are found, it suggests remediation actions.

## Outline

1. **Setup**: Run `.specify/scripts/bash/check-prerequisites.sh --json --require-tasks` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. **Check Assignment File Exists**: Verify `agent-assignments.yml` exists in FEATURE_DIR.
   - If missing, **STOP** and report: "No agent-assignments.yml found. Run `/speckit.agent-assign.assign` first to generate agent assignments."

3. **Load Inputs**: Read the following files from FEATURE_DIR:
   - **REQUIRED**: `agent-assignments.yml` — the agent assignment mapping
   - **REQUIRED**: `tasks.md` — the task list to validate against
   - Parse `agent-assignments.yml` to extract the `agents_scanned` list and `assignments` mapping
   - Parse `tasks.md` to extract all task IDs

4. **Rescan Agent Definitions**: Discover currently available agent definition files following the same hierarchy as the assign command:

   **Scanning priority order** (highest to lowest):
   1. **Project-level**: `.claude/agents/*.md` in the repository root
   2. **User-level**: `~/.claude/agents/*.md` in the user's home directory

   For each agent file:
   - Parse YAML frontmatter to extract name and description
   - Record source level
   - Deduplicate by name (highest priority wins)

   Build a **Current Agent Registry** for comparison against `agents_scanned` in the assignment file.

5. **Run Validation Checks**: Perform the following checks and record results:

   **Check 1 — Coverage**: Every task ID in tasks.md has a corresponding entry in `assignments`.
   - Status per task: `OK` (has assignment) or `UNASSIGNED` (missing from assignments)

   **Check 2 — Agent Existence**: Every agent name referenced in `assignments` (except `default`) exists in the current agent registry.
   - Status per assignment: `OK` (agent exists) or `MISSING` (agent file not found)

   **Check 3 — Agent Conflicts**: No agent name appears at multiple hierarchy levels with different definitions.
   - Status: `OK` (no conflicts) or `CONFLICT` (same name, different levels — list which levels)

   **Check 4 — Agent Drift**: Compare `agents_scanned` from the assignment file against the current agent registry.
   - Report any agents that were available during assignment but are now missing
   - Report any new agents that were not available during assignment

   **Check 5 — Frontmatter Validity**: Each agent file referenced in assignments has valid YAML frontmatter with at minimum a `description` field.
   - Status: `OK` (valid) or `INVALID` (missing or malformed frontmatter)

6. **Generate Validation Report**: Output a structured report:

   ```text
   ## Agent Assignment Validation Report

   **Feature**: <feature-name>
   **Assignment file**: <path to agent-assignments.yml>
   **Validation time**: <timestamp>

   ### Summary

   | Metric               | Value |
   |----------------------|-------|
   | Total tasks          | 15    |
   | Assigned tasks       | 15    |
   | Unassigned tasks     | 0     |
   | Valid agents         | 12    |
   | Missing agents       | 0     |
   | Conflicts            | 0     |
   | Agent drift detected | No    |

   ### Overall Status: ✓ PASS / ✗ FAIL

   ### Task Assignment Details

   | Task ID | Assigned Agent  | Status     |
   |---------|-----------------|------------|
   | T001    | default         | ✓ OK       |
   | T002    | backend-dev     | ✓ OK       |
   | T003    | unknown-agent   | ✗ MISSING  |
   | T004    | frontend-dev    | ✓ OK       |

   ### Issues Found (if any)

   1. **MISSING**: Task T003 assigned to agent `unknown-agent` which does not exist at any hierarchy level
   2. **UNASSIGNED**: Task T010 has no entry in agent-assignments.yml
   3. **CONFLICT**: Agent `helper` found at both project and user level with different descriptions
   4. **DRIFT**: Agent `api-dev` was available during assignment but has since been removed

   ### Recommended Actions

   - Run `/speckit.agent-assign.assign` to reassign tasks with missing or conflicting agents
   - Or manually edit `agent-assignments.yml` to fix specific entries
   ```

7. **Final Verdict**:
   - **PASS**: All checks pass — safe to run `/speckit.agent-assign.execute`
   - **FAIL**: Issues found — list actionable remediation steps

   If PASS, suggest proceeding with `/speckit.agent-assign.execute`.
   If FAIL, suggest running `/speckit.agent-assign.assign` to fix issues.

Note: This command is strictly read-only. It does not modify `agent-assignments.yml`, `tasks.md`, or any agent files.