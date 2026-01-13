# Generalized rules for development

## Overview
These are rules for development. 

Given the programming language you are working with, ignore any rules that make no logical sense for that language. 

## Seperation of concerns
- Split logic into individual files / components / and modules. This helps in maintaining a clear structure and makes it easier to understand and modify the code and reduces LLM context overflow. 
- Follow the Single Responsibility Principle (SRP): Ensure each class or module has only one reason to change.
- Layer your architecture: Separate concerns into distinct layers, such as Presentation, Business Logic, and Data Access.
- Keep business logic out of the UI: Do not put core business rules in controllers or views; delegate to services or use cases.
- Use services or domain models for business rules: Encapsulate logic in dedicated classes, such as UserService or OrderValidator.
- Avoid god classes: Break down large classes that handle multiple concerns into smaller, focused classes.
- Apply Dependency Inversion: Depend on abstractions, not concrete implementations; use interfaces for loose coupling.
- Isolate data access: Let Repositories or DAOs handle persistence; business logic must not reference databases directly.
- Externalize configuration: Never hardcode values; use config files or environment variables for app settings.
- Separate validation: Perform input validation in controllers and business validation in domain services.
- Design for testing: Structure code so business logic can be unit-tested without UI or database dependencies.
- Use events for decoupling: Apply event-driven patterns for communication across concerns instead of direct calls.

## Task management
These are instructions on how you should manage tasks with the help of Taskmaster MCP. 
If you change the state of a main task to done without all subtasks being done, you will not be able to change the state of a subtask. 

### Basic Taskmaster Cycle
1. **List Tasks**
   `task-master list` or `get_tasks` → View current tasks, status, and IDs
2. **Select Next**
   `task-master next` or `next_task` → Get the recommended next task
3. **View Details**
   `task-master show <id>` or `get_task` → Read full task description
4. **Break Down**
   `task-master expand <id>` → Create subtasks for complex work
5. **Implement**
   Write code, tests, documentation, etc.
6. **Log Progress**
   `task-master update-subtask` → Record findings, decisions, blockers
7. **Mark Complete**
   `task-master set-status <id> done` → Only when truly finished & verified
8. **Repeat**

### Adding new tasks
- If you are asked to add an individual task then you just add a regular task. 
- If you are asked to add a product requirements document, make sure you follow the correct procedure and remember to give it a meaningful tag name. 

### Task Complexity Analysis
- Run `analyze_project_complexity` / `task-master analyze-complexity --research` for analysis
- Review complexity report via `complexity_report` / `task-master complexity-report`
- Focus on high-complexity tasks (8-10) for detailed breakdown
- Use analysis results for appropriate subtask allocation

### Task Breakdown Process
- Use `expand_task` / `task-master expand --id=<id>` with complexity report
- Use `--num=<number>` to specify explicit subtask count
- Add `--research` flag for research-backed expansion
- Add `--force` flag to replace existing subtasks
- Use `--prompt="<context>"` for additional context
- Use `expand_all` for multiple pending tasks

### Implementation Drift Handling
- When implementation differs from plan, use `update` / `task-master update --from=<id> --prompt="..." --research`
- Use `update_task` / `task-master update-task --id=<id> --prompt="..." --research` for single tasks

### Iterative Subtask Implementation
1. **Preparation**: Use `get_task` to understand subtask goals
2. **Exploration**: Identify files, functions, and code changes needed
3. **Log Plan**: Use `update_subtask` to document detailed implementation plan
4. **Verify Plan**: Confirm logged details with `get_task`
5. **Begin Implementation**: Set status to `in-progress`
6. **Refine Progress**: Regularly log findings with `update_subtask`
7. **Review & Update Rules**: Create/modify rules for new patterns
8. **Mark Complete**: Set status to `done`
9. **Commit Changes**: Use descriptive commit messages
10. **Proceed**: Identify next task with `next_task`

### Task Status Management
- Use 'pending' for ready tasks
- Use 'in-progress' for active work
- Use 'done' for completed and verified tasks
- Use 'deferred' for postponed tasks

### Dependency Management
- Use `add_dependency` / `task-master add-dependency` to add prerequisites
- Use `remove_dependency` / `task-master remove-dependency` to remove dependencies
- System prevents circular dependencies
- Dependencies shown with status indicators

### Task Reorganization
- Use `move_task` / `task-master move --from=<id> --to=<id>` for restructuring
- Supports moving tasks to subtasks, subtasks to tasks, reordering within parents
- Validates moves to prevent data loss
- Maintains dependency integrity

### Tagged Task Contexts
- Default to `master` context for most work
- Create feature-specific tags for major initiatives (e.g., `feature-steam-integration`)
- Use branch-based tags when working on git branches
- Create experiment tags for risky changes
- Isolate team member work to prevent conflicts
- Parse PRDs into dedicated tags for complex features

### When to Introduce Tags
- **Git Feature Branches**: Create tag when user branches (e.g., `git checkout -b feature-x`)
- **Team Collaboration**: Separate contexts for multi-developer work
- **Experiments**: Sandbox risky changes in dedicated tags
- **Large Features**: PRD-driven development in feature-specific tags
- **Version-Based**: Different approaches for prototype vs. production work

### Product Requirements Document-Driven Feature Development
1. **Create Tag**: `add_tag feature-[name] --description="[description]"`
2. **Draft PRD**: Collaborate on comprehensive requirements document
3. **Parse PRD**: `parse_prd prd-file.txt --tag=feature-[name]`
4. **Analyze & Expand**: Run complexity analysis and task expansion
5. **Add Master Reference**: Create high-level task in master tag

### Configuration Management
- Use `.taskmaster/config.json` for model selections and parameters
- Set API keys in `.env` (CLI) or MCP configuration files
- Use `task-master models --setup` for configuration
- Tagged system settings in config file
