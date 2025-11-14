# Archon AI Coding Workflow Template

A simple yet reliable template for systematic AI-assisted development using **create-plan** and **execute-plan** workflows, powered by [Archon](https://github.com/coleam00/Archon) - the open-source AI coding command center. Build on top of this and create your own AI coding workflows!

## What is This?

This is a reusable workflow template that brings structure and reliability to AI coding assistants. Instead of ad-hoc prompting, you get:

- **Systematic planning** from requirements to implementation
- **Knowledge-augmented development** via Archon's RAG capabilities
- **Task management integration** for progress tracking
- **Specialized subagents** for analysis and validation
- **Codebase consistency** through pattern analysis

Works with **Claude Code**, **Cursor**, **Windsurf**, **Codex**, and any AI coding assistant that supports custom commands or prompt templates.

## Core Workflows

### 1. Create Plan (`/create-plan`)

Transform requirements into actionable implementation plans through systematic research and analysis.

**What it does:**
- Reads your requirements document
- Searches Archon's knowledge base for best practices and patterns
- Analyzes your codebase using the `codebase-analyst` subagent
- Produces a comprehensive implementation plan (PRP) with:
  - Task breakdown with dependencies and effort estimates
  - Technical architecture and integration points
  - Code references and patterns to follow
  - Testing strategy and success criteria

**Usage:**
```bash
/create-plan requirements/my-feature.md
```

### 2. Execute Plan (`/execute-plan`)

Execute implementation plans with integrated Archon task management and validation.

**What it does:**
- Reads your implementation plan
- Creates an Archon project and tasks automatically
- Implements each task systematically (`todo` → `doing` → `review` → `done`)
- Validates with the `validator` subagent to create unit tests
- Tracks progress throughout with full visibility

**Usage:**
```bash
/execute-plan PRPs/my-feature.md
```

## Why Archon?

[Archon](https://github.com/coleam00/Archon) is an open-source AI coding OS that provides:

- **Knowledge Base**: RAG-powered search across documentation, PDFs, and crawled websites
- **Task Management**: Hierarchical projects with AI-assisted task creation and tracking
- **Smart Search**: Hybrid search with contextual embeddings and reranking
- **Multi-Agent Support**: Connect multiple AI assistants to shared context
- **Model Context Protocol**: Standard MCP server for seamless integration

Think of it as the command center that keeps your AI coding assistant informed and organized.

## What's Included

```
.claude/
├── commands/
│   ├── create-plan.md      # Requirements → Implementation plan
│   ├── execute-plan.md     # Plan → Tracked implementation
│   └── primer.md           # Project context loader
├── agents/
│   ├── codebase-analyst.md # Pattern analysis specialist
│   └── validator.md        # Testing specialist
└── CLAUDE.md               # Archon-first workflow rules
```

## Setup Instructions

### For Claude Code

1. **Copy the template to your project:**
   ```bash
   cp -r use-cases/archon-example-workflow/.claude /path/to/your-project/
   ```

2. **Install Archon MCP server** (if not already installed):
   - Follow instructions at [github.com/coleam00/Archon](https://github.com/coleam00/Archon)
   - Configure in your Claude Code settings

3. **Start using workflows:**
   ```bash
   # In Claude Code
   /create-plan requirements/your-feature.md
   # Review the generated plan, then:
   /execute-plan PRPs/your-feature.md
   ```

### For Other AI Assistants

The workflows are just markdown prompt templates - adapt them to your tool - examples:

#### **Cursor / Windsurf**
- Copy files to `.cursor/` or `.windsurf/` directory
- Use as custom commands or rules files
- Manually invoke workflows by copying prompt content

#### **Cline / Aider / Continue.dev**
- Save workflows as prompt templates
- Reference them in your session context
- Adapt the MCP tool calls to your tool's API

#### **Generic Usage**
Even without tool-specific integrations:
1. Read `create-plan.md` and follow its steps manually
2. Use Archon's web UI for task management if MCP isn't available
3. Adapt the workflow structure to your assistant's capabilities

## Workflow in Action

### New Project Example

```bash
# 1. Write requirements
echo "Build a REST API for user authentication" > requirements/auth-api.md

# 2. Create plan
/create-plan requirements/auth-api.md
# → AI searches Archon knowledge base for JWT best practices
# → AI analyzes your codebase patterns
# → Generates PRPs/auth-api.md with 12 tasks

# 3. Execute plan
/execute-plan PRPs/auth-api.md
# → Creates Archon project "Authentication API"
# → Creates 12 tasks in Archon
# → Implements task-by-task with status tracking
# → Runs validator subagent for unit tests
# → Marks tasks done as they complete
```

### Existing Project Example

```bash
# 1. Create feature requirements
# 2. Run create-plan (it analyzes existing codebase)
/create-plan requirements/new-feature.md
# → Discovers existing patterns from your code
# → Suggests integration points
# → Follows your project's conventions

# 3. Execute with existing Archon project
# Edit execute-plan.md to reference project ID or let it create new one
/execute-plan PRPs/new-feature.md
```

## Key Benefits

### For New Projects
- **Pattern establishment**: AI learns and documents your conventions
- **Structured foundation**: Plans prevent scope creep and missed requirements
- **Knowledge integration**: Leverage best practices from day one

### For Existing Projects
- **Convention adherence**: Codebase analysis ensures consistency
- **Incremental enhancement**: Add features that fit naturally
- **Context retention**: Archon keeps project history and patterns

## Customization

### Adapt the Workflows

Edit the markdown files to match your needs - examples:

- **Change task granularity** in `create-plan.md` (Step 3.1)
- **Add custom validation** in `execute-plan.md` (Step 6)
- **Modify report format** in either workflow
- **Add your own subagents** for specialized tasks

### Extend with Subagents

Create new specialized agents in `.claude/agents/`:

```markdown
---
name: "security-auditor"
description: "Reviews code for security vulnerabilities"
tools: Read, Grep, Bash
---

You are a security specialist who reviews code for...
```

Then reference in your workflows.
 
 Execute Development Plan with Archon Task Management
You are about to execute a comprehensive development plan with integrated Archon task management. This workflow ensures systematic task tracking and implementation throughout the entire development process.
Critical Requirements
MANDATORY: Throughout the ENTIRE execution of this plan, you MUST maintain continuous usage of Archon for task management. DO NOT drop or skip Archon integration at any point. Every task from the plan must be tracked in Archon from creation to completion.
Step 1: Read and Parse the Plan
Read the plan file specified in: $ARGUMENTS
The plan file will contain:
* A list of tasks to implement
* References to existing codebase components and integration points
* Context about where to look in the codebase for implementation
Step 2: Project Setup in Archon
1. Check if a project ID is specified in CLAUDE.md for this feature
    * Look for any Archon project references in CLAUDE.md
    * If found, use that project ID
2. If no project exists:
    * Create a new project in Archon using mcp__archon__manage_project
    * Use a descriptive title based on the plan's objectives
    * Store the project ID for use throughout execution
Step 3: Create All Tasks in Archon
For EACH task identified in the plan:
1. Create a corresponding task in Archon using mcp__archon__manage_task("create", ...)
2. Set initial status as "todo"
3. Include detailed descriptions from the plan
4. Maintain the task order/priority from the plan
IMPORTANT: Create ALL tasks in Archon upfront before starting implementation. This ensures complete visibility of the work scope.
Step 4: Codebase Analysis
Before implementation begins:
1. Analyze ALL integration points mentioned in the plan
2. Use Grep and Glob tools to:
    * Understand existing code patterns
    * Identify where changes need to be made
    * Find similar implementations for reference
3. Read all referenced files and components
4. Build a comprehensive understanding of the codebase context
Step 5: Implementation Cycle
For EACH task in sequence:
5.1 Start Task
* Move the current task to "doing" status in Archon: mcp__archon__manage_task("update", task_id=..., status="doing")
* Use TodoWrite to track local subtasks if needed
5.2 Implement
* Execute the implementation based on:
    * The task requirements from the plan
    * Your codebase analysis findings
    * Best practices and existing patterns
* Make all necessary code changes
* Ensure code quality and consistency
5.3 Complete Task
* Once implementation is complete, move task to "review" status: mcp__archon__manage_task("update", task_id=..., status="review")
* DO NOT mark as "done" yet - this comes after validation
5.4 Proceed to Next
* Move to the next task in the list
* Repeat steps 5.1-5.3
CRITICAL: Only ONE task should be in "doing" status at any time. Complete each task before starting the next.
Step 6: Validation Phase
After ALL tasks are in "review" status:
IMPORTANT: Use the validator agent for comprehensive testing
1. Launch the validator agent using the Task tool
    * Provide the validator with a detailed description of what was built
    * Include the list of features implemented and files modified
    * The validator will create simple, effective unit tests
    * It will run tests and report results
The validator agent will:
* Create focused unit tests for the main functionality
* Test critical edge cases and error handling
* Run the tests using the project's test framework
* Report what was tested and any issues found
Additional validation you should perform:
* Check for integration issues between components
* Ensure all acceptance criteria from the plan are met
Step 7: Finalize Tasks in Archon
After successful validation:
1. For each task that has corresponding unit test coverage:
    * Move from "review" to "done" status: mcp__archon__manage_task("update", task_id=..., status="done")
2. For any tasks without test coverage:
    * Leave in "review" status for future attention
    * Document why they remain in review (e.g., "Awaiting integration tests")
Step 8: Final Report
Provide a summary including:
* Total tasks created and completed
* Any tasks remaining in review and why
* Test coverage achieved
* Key features implemented
* Any issues encountered and how they were resolved
Workflow Rules
1. NEVER skip Archon task management at any point
2. ALWAYS create all tasks in Archon before starting implementation
3. MAINTAIN one task in "doing" status at a time
4. VALIDATE all work before marking tasks as "done"
5. TRACK progress continuously through Archon status updates
6. ANALYZE the codebase thoroughly before implementation
7. TEST everything before final completion
Error Handling
If at any point Archon operations fail:
1. Retry the operation
2. If persistent failures, document the issue but continue tracking locally
3. Never abandon the Archon integration - find workarounds if needed
Remember: The success of this execution depends on maintaining systematic task management through Archon throughout the entire process. This ensures accountability, progress tracking, and quality delivery.

Execute Development Plan with Archon Task Management
You are about to execute a comprehensive development plan with integrated Archon task management. This workflow ensures systematic task tracking and implementation throughout the entire development process.
Critical Requirements
MANDATORY: Throughout the ENTIRE execution of this plan, you MUST maintain continuous usage of Archon for task management. DO NOT drop or skip Archon integration at any point. Every task from the plan must be tracked in Archon from creation to completion.
Step 1: Read and Parse the Plan
Read the plan file specified in: $ARGUMENTS
The plan file will contain:
* A list of tasks to implement
* References to existing codebase components and integration points
* Context about where to look in the codebase for implementation
Step 2: Project Setup in Archon
1. Check if a project ID is specified in CLAUDE.md for this feature
    * Look for any Archon project references in CLAUDE.md
    * If found, use that project ID
2. If no project exists:
    * Create a new project in Archon using mcp__archon__manage_project
    * Use a descriptive title based on the plan's objectives
    * Store the project ID for use throughout execution
Step 3: Create All Tasks in Archon
For EACH task identified in the plan:
1. Create a corresponding task in Archon using mcp__archon__manage_task("create", ...)
2. Set initial status as "todo"
3. Include detailed descriptions from the plan
4. Maintain the task order/priority from the plan
IMPORTANT: Create ALL tasks in Archon upfront before starting implementation. This ensures complete visibility of the work scope.
Step 4: Codebase Analysis
Before implementation begins:
1. Analyze ALL integration points mentioned in the plan
2. Use Grep and Glob tools to:
    * Understand existing code patterns
    * Identify where changes need to be made
    * Find similar implementations for reference
3. Read all referenced files and components
4. Build a comprehensive understanding of the codebase context
Step 5: Implementation Cycle
For EACH task in sequence:
5.1 Start Task
* Move the current task to "doing" status in Archon: mcp__archon__manage_task("update", task_id=..., status="doing")
* Use TodoWrite to track local subtasks if needed
5.2 Implement
* Execute the implementation based on:
    * The task requirements from the plan
    * Your codebase analysis findings
    * Best practices and existing patterns
* Make all necessary code changes
* Ensure code quality and consistency
5.3 Complete Task
* Once implementation is complete, move task to "review" status: mcp__archon__manage_task("update", task_id=..., status="review")
* DO NOT mark as "done" yet - this comes after validation
5.4 Proceed to Next
* Move to the next task in the list
* Repeat steps 5.1-5.3
CRITICAL: Only ONE task should be in "doing" status at any time. Complete each task before starting the next.
Step 6: Validation Phase
After ALL tasks are in "review" status:
IMPORTANT: Use the validator agent for comprehensive testing
1. Launch the validator agent using the Task tool
    * Provide the validator with a detailed description of what was built
    * Include the list of features implemented and files modified
    * The validator will create simple, effective unit tests
    * It will run tests and report results
The validator agent will:
* Create focused unit tests for the main functionality
* Test critical edge cases and error handling
* Run the tests using the project's test framework
* Report what was tested and any issues found
Additional validation you should perform:
* Check for integration issues between components
* Ensure all acceptance criteria from the plan are met
Step 7: Finalize Tasks in Archon
After successful validation:
1. For each task that has corresponding unit test coverage:
    * Move from "review" to "done" status: mcp__archon__manage_task("update", task_id=..., status="done")
2. For any tasks without test coverage:
    * Leave in "review" status for future attention
    * Document why they remain in review (e.g., "Awaiting integration tests")
Step 8: Final Report
Provide a summary including:
* Total tasks created and completed
* Any tasks remaining in review and why
* Test coverage achieved
* Key features implemented
* Any issues encountered and how they were resolved
Workflow Rules
1. NEVER skip Archon task management at any point
2. ALWAYS create all tasks in Archon before starting implementation
3. MAINTAIN one task in "doing" status at a time
4. VALIDATE all work before marking tasks as "done"
5. TRACK progress continuously through Archon status updates
6. ANALYZE the codebase thoroughly before implementation
7. TEST everything before final completion
Error Handling
If at any point Archon operations fail:
1. Retry the operation
2. If persistent failures, document the issue but continue tracking locally
3. Never abandon the Archon integration - find workarounds if needed
Remember: The success of this execution depends on maintaining systematic task management through Archon throughout the entire process. This ensures accountability, progress tracking, and quality delivery.

