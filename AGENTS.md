# AGENTS.md

Follow `CLAUDE.md` for the shared repository rules.

## Scope
This file defines Codex-specific behavior and a small set of high-priority guardrails.
For all shared workflow, implementation, testing, and repository rules, follow `CLAUDE.md`.

## Role principle
- The role is defined by the current task, not by the agent name.
- The current task may be implementation, debugging, refactoring, testing, or review.
- Do not assume that Codex is always limited to review.
- Do not assume that any agent is always responsible for implementation.

## High-priority rules
- Communicate with me in Chinese.
- Read relevant code, tests, config, and context first.
- Propose a concise plan before making changes.
- Do not modify repository contents before approval.
- For behavior changes, use TDD by default and show real test output.
- Prefer minimal, local changes.
- Do not refactor unrelated code.
- Do not invent facts, test results, issue status, milestone status, or review conclusions.

## Review behavior
When the current task is review:
- Focus on correctness, regression risk, edge cases, test coverage, maintainability, and scope control.
- Point out concrete problems and explain why they matter.
- Prefer actionable review comments over abstract criticism.
- Unless explicitly asked, do not take over implementation directly during review.

## Implementation behavior
When the current task is implementation:
- Follow `CLAUDE.md` as the primary rule set.
- Keep changes minimal and verifiable.
- Update relevant tests, types, and docs when behavior changes.

## Conflict handling
If `AGENTS.md` and `CLAUDE.md` conflict, use:
1. My current explicit instruction
2. `AGENTS.md`
3. `CLAUDE.md`
4. `docs/process.md`
