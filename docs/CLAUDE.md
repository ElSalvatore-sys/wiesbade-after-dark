- # Project-Specific Tool Usage Patterns

## This Project's Stack
[Edit based on project]
- Frontend: [React/Vue/etc]
- Backend: [Express/FastAPI/etc]
- Database: [PostgreSQL/MySQL/etc]
- Deployment: [Vercel/Railway/etc]

## Tool Usage Priorities for This Project

### High Priority (Use Often)
- **prisma**: [Database name] schema management
- **playwright**: Testing [specific features]
- **feature-dev**: New [type of features]

### Medium Priority (Use Sometimes)
- **perplexity**: Research [specific topics]
- **github**: [Specific repo] management

### Auto-Running
- **security-guidance**: Watching for [specific concerns]

## Project-Specific Patterns

### Database Operations
- Primary models: [list main models]
- Common queries: [list frequent queries]
- Migration pattern: [describe approach]

**Remind me to:**
- Use Prisma for all database queries
- Check schema before adding fields
- Test migrations in development first

### Testing Patterns
- Test files location: [path]
- Critical user flows: [list flows]
- Browser: [Chrome/Firefox/Safari]

**Remind me to:**
- Use Playwright for E2E tests
- Screenshot failing tests
- Test in [specific browser]

### Git Workflow
- Branch naming: [convention]
- Commit message format: [format]
- PR requirements: [requirements]

**Remind me to:**
- Run /pr-review before pushing
- Use /commit-push for atomic commits
- Link issues in PR descriptions

### Security Considerations
- Auth pattern: [JWT/Session/etc]
- Data validation: [approach]
- GDPR compliance: [requirements]

**Remind me to:**
- Check security-guidance warnings
- Validate all user inputs
- Test authentication flows

## Common Task → Tool Mapping

"Add new [feature]" → Use: feature-dev, prisma (if DB), playwright (test)
"Fix bug in [component]" → Use: playwright (reproduce), pr-review (check fix)
"Deploy to [environment]" → Use: pr-review, commit-commands, github
"Research [topic]" → Use: perplexity first
"Database [operation]" → Use: prisma exclusively