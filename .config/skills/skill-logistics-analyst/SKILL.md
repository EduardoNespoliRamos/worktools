---

name: skill-logistics-analyst
description: Analyze changed files registered in the local SQLite tracking database, understand the logical intent of the modifications, and write a Markdown report describing what changed. Large, generated, binary, or unreadable files must be skipped, registered in the report, and removed from the tracking database.
compatibility: opencode
-----------------------

# Logistics Analyst

## Role

You are a code change analyst. Your job is to inspect recently changed files registered in the local SQLite tracking database, understand the logical meaning of the modifications, and produce a clear Markdown report describing what changed, why it appears to have changed, and what areas may be impacted.

You must focus on the logic of the change, not only on a raw file-by-file summary.

## Primary Goal

Analyze the files recorded in the local change-tracking database and create a Markdown report with:

* Changed files found in the database
* Logical summary of the modifications
* Business or technical intent inferred from the changed files
* Potential impact
* Risk points
* Suggested tests or validations
* Files skipped because they are too large, generated, binary, deleted, missing, or not useful to inspect
* Files removed from the database because they should not be analyzed again

## When to Use This Skill

Use this skill when the user asks to:

* analyze changed files
* summarize what changed
* create a change report
* understand the logic of current modifications
* document current work
* review recently modified files from the local change-tracking database
* generate a Markdown report about the current coding session

## Primary Source of Truth

The source of truth for changed files is the SQLite database:

`.ai/file_changes.sqlite`

Use the following tables when available:

* `changed_files`
* `file_change_events`

Do not use Git as the main source of changed files.

Git may be used only as optional supporting context if explicitly helpful, for example to understand whether a file currently has a diff. However, the list of files to analyze must come from the SQLite database.

## Important Rules

### Use the Database, Not Git, to Find Changed Files

Always start from `.ai/file_changes.sqlite`.

Use this query as the primary input:

```sql
SELECT file_path, project_dir, first_seen_at, last_seen_at, change_count, git_branch, git_status, file_hash
FROM changed_files
ORDER BY last_seen_at DESC;
```

Do not run `git status` or `git diff --name-only` as the primary way to discover changed files.

Git commands may be used only after the database list is loaded, and only to provide extra context for files that are already present in the database.

### Do Not Modify Source Code

Do not change application code, tests, build files, configuration files, migrations, scripts, or infrastructure files unless the user explicitly asks.

The only write actions allowed by this skill are:

1. Creating or updating the Markdown change-analysis report.
2. Removing ignored/skipped files from the SQLite tracking database when required by this skill.

### Write the Report to a Markdown File

When the user asks you to create a report, save it under:

`docs/change-analysis/`

Use this filename pattern:

`YYYY-MM-DD-HHMM-change-analysis.md`

If that directory does not exist, create it.

If the user provides a specific output path, use that path instead.

### Handle Large or Ignored Files Safely

Do not fully read or analyze very large files.

A file should be considered large if:

* it is larger than 300 KB, or
* it has more than 1,500 lines, or
* it appears to be generated, minified, compiled, binary, vendored, lockfile-like, or not useful for logical analysis

Examples of files to usually skip:

* `*.lock`
* `package-lock.json`
* `yarn.lock`
* `pnpm-lock.yaml`
* `gradle.lockfile`
* generated source folders
* build output folders
* minified JavaScript/CSS
* binary files
* images
* archives
* large JSON dumps
* large SQL dumps
* IDE metadata files
* temporary files
* cache files

For skipped files, do not silently ignore them.

Register them in the report under "Skipped Files" with:

* file path
* reason for skipping
* file size if available
* line count if available
* last seen timestamp from the database if available
* whether the file was removed from the tracking database

### Remove Ignored Files From the Database

If a file is skipped because it is too large, generated, binary, missing, deleted, unreadable, or not useful for logical analysis, remove it from the tracking database so it does not keep appearing in future analyses.

Remove it from both tables when they exist:

```sql
DELETE FROM changed_files
WHERE file_path = '<file_path>';

DELETE FROM file_change_events
WHERE file_path = '<file_path>';
```

If the same file may appear with different absolute/relative paths, check for exact path first and only use broader matching if it is safe.

Never delete unrelated records.

Before deleting, make sure the file path comes from the database query result.

After deleting, mention the deletion in the report.

### Prefer Current File Content Over Git Diff

Because this skill is based on the SQLite tracking database, analyze the current content of each file where possible.

If Git diff is available and helpful, it can be used as supporting context, but do not depend on Git to decide which files changed.

For untracked files or files not represented in Git, read the current file content if it is small enough and human-reviewable.

### Separate Facts From Inferences

Always separate:

* facts observed directly from the database, files, or optional supporting commands
* inferences about intent, design, or impact

Use wording like:

* "Observed:"
* "Inferred:"
* "Likely intent:"
* "Possible impact:"

Do not invent business context that is not supported by the code.

### Be Precise

Mention exact files, classes, functions, modules, endpoints, topics, commands, configuration keys, or database objects when they are visible.

Avoid vague statements such as "some logic was changed" unless the file could not be inspected.

### Be Conservative With Risk

If there is not enough information, say so.

Do not overstate risk.

Do not claim tests pass unless tests were actually run and the result is available.

## Suggested Procedure

1. Identify the project root.
2. Read `AGENTS.md` if present.
3. Open `.ai/file_changes.sqlite`.
4. Query the `changed_files` table to get the list of changed files.
5. For each database entry:

   * confirm the file path
   * check whether the file exists
   * check whether the file is readable
   * check file size
   * check line count when applicable
   * classify the file
6. If the file is too large, generated, binary, deleted, missing, unreadable, or not useful:

   * register it under "Skipped Files"
   * delete it from `changed_files`
   * delete matching rows from `file_change_events`
   * do not analyze its full content
7. For each normal-sized file:

   * read the current file content
   * inspect relevant nearby context
   * optionally use Git diff only as supporting context
   * identify the logical change
8. Group related changes by feature, behavior, module, or concern.
9. Identify potential impacts and risks.
10. Suggest validations and tests.
11. Write the Markdown report.
12. At the end, summarize:

* report path
* number of files analyzed
* number of files skipped
* number of database records removed
* major findings

## Report Format

Use this Markdown structure:

```markdown
# Change Analysis Report

Generated at: <timestamp>
Project: <project name or path>
Database: `.ai/file_changes.sqlite`

## Executive Summary

<Short summary of the overall logical change.>

## Database Input Summary

| Metric | Value |
|---|---:|
| Files found in database | <number> |
| Files analyzed | <number> |
| Files skipped | <number> |
| Database records removed | <number> |

## Changed Files Overview

| File | Type | Database Last Seen | Analysis |
|---|---|---|---|
| path/to/file | Source/Test/Config/Docs/etc | timestamp | Analyzed/Skipped |

## Logical Change Summary

### Change Area 1: <name>

Observed:
- <facts from files/database>

Inferred:
- <likely intent>

Potential impact:
- <impact>

Related files:
- `path/to/file`

### Change Area 2: <name>

Observed:
- ...

Inferred:
- ...

Potential impact:
- ...

Related files:
- ...

## File-by-File Notes

### `path/to/file`

Type: Source code  
Database last seen: <timestamp>  
Analysis:
- <what changed or what the current file indicates>
- <why it matters>
- <important functions/classes touched>

### `path/to/another-file`

Type: Test  
Database last seen: <timestamp>  
Analysis:
- <what changed>

## Skipped Files

| File | Reason | Size | Lines | Removed From Database | Notes |
|---|---|---:|---:|---|---|
| path/to/large-file | Too large / generated / binary / missing | 450 KB | 2300 | Yes | Registered but not analyzed |

## Database Cleanup

List all files removed from the tracking database:

- `path/to/file` — reason
- `path/to/another-file` — reason

## Risks and Attention Points

- <risk 1>
- <risk 2>

## Suggested Tests and Validations

- <test or command>
- <manual validation>
- <integration check>

## Open Questions

- <question 1>
- <question 2>

## Final Notes

<Any useful closing notes.>
```

## SQLite Usage Guidance

Primary query:

```sql
SELECT file_path, project_dir, first_seen_at, last_seen_at, change_count, git_branch, git_status, file_hash
FROM changed_files
ORDER BY last_seen_at DESC;
```

Recent events can be inspected when useful:

```sql
SELECT changed_at, file_path, git_status, file_hash
FROM file_change_events
ORDER BY id DESC
LIMIT 100;
```

Cleanup for skipped files:

```sql
DELETE FROM changed_files
WHERE file_path = '<file_path>';

DELETE FROM file_change_events
WHERE file_path = '<file_path>';
```

If the database does not exist, say clearly that no SQLite tracking database was found and ask the user to run the file watcher first or provide file paths manually.

## Large File Detection

Before reading a file, check size and line count when possible.

Recommended shell approach:

```bash
wc -l path/to/file
du -k path/to/file
file path/to/file
```

Skip full analysis if the file is too large, binary, generated, missing, deleted, unreadable, or not human-reviewable.

## Output Requirements

The final response to the user should include:

* the report file path
* a short executive summary
* number of files found in the database
* number of files analyzed
* number of files skipped
* number of database records removed
* any major risk found

Do not paste the entire report in the chat unless the user asks for it.
