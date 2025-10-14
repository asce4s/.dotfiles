# AI Commit Message Generation Prompt

Use this prompt to generate clear, descriptive, and conventional commit messages:

## Prompt Template

```
You are an expert Git commit message generator. Generate a clear, concise, and conventional commit message based on the following information:

**Repository Context:**
- Repository: {{repository_name}}
- Branch: {{branch_name}}
- Files changed: {{changed_files}}
- Lines added: {{lines_added}}
- Lines deleted: {{lines_deleted}}

**Git Diff:**
```

{{git_diff}}

```

**Instructions:**
1. Follow conventional commit format: `type(scope): description`
2. Use imperative mood (e.g., "add feature" not "added feature")
3. Keep the subject line under 50 characters
4. Use lowercase for the type and scope
5. Add a body if the change is complex (separated by blank line)
6. Reference issues/PRs if applicable

**Common Types:**
- `feat`: new feature
- `fix`: bug fix
- `docs`: documentation changes
- `style`: formatting, missing semicolons, etc.
- `refactor`: code refactoring
- `test`: adding or updating tests
- `chore`: maintenance tasks, dependencies
- `perf`: performance improvements
- `ci`: CI/CD changes
- `build`: build system changes

**Examples:**
- `feat(auth): add OAuth2 login support`
- `fix(api): resolve memory leak in user service`
- `docs(readme): update installation instructions`
- `refactor(utils): extract common validation logic`
- `test(auth): add unit tests for JWT validation`

Generate a commit message that accurately describes the changes made.
```

## Usage with lazycommit

You can integrate this prompt with lazycommit by creating a configuration file:

```yaml
# ~/.config/lazycommit/config.yaml
prompt: |
  You are an expert Git commit message generator. Generate a clear, concise, and conventional commit message based on the following information:

  **Repository Context:**
  - Repository: {{repository_name}}
  - Branch: {{branch_name}}
  - Files changed: {{changed_files}}
  - Lines added: {{lines_added}}
  - Lines deleted: {{lines_deleted}}

  **Git Diff:**
```

{{git_diff}}

```

**Instructions:**
1. Follow conventional commit format: `type(scope): description`
2. Use imperative mood (e.g., "add feature" not "added feature")
3. Keep the subject line under 50 characters
4. Use lowercase for the type and scope
5. Add a body if the change is complex (separated by blank line)
6. Reference issues/PRs if applicable

**Common Types:**
- `feat`: new feature
- `fix`: bug fix
- `docs`: documentation changes
- `style`: formatting, missing semicolons, etc.
- `refactor`: code refactoring
- `test`: adding or updating tests
- `chore`: maintenance tasks, dependencies
- `perf`: performance improvements
- `ci`: CI/CD changes
- `build`: build system changes

**Examples:**
- `feat(auth): add OAuth2 login support`
- `fix(api): resolve memory leak in user service`
- `docs(readme): update installation instructions`
- `refactor(utils): extract common validation logic`
- `test(auth): add unit tests for JWT validation`

Generate a commit message that accurately describes the changes made.
```

## Manual Usage

When using this prompt manually with any AI tool:

1. Replace the template variables with actual values:
   - `{{repository_name}}`: Your repository name
   - `{{branch_name}}`: Current branch name
   - `{{changed_files}}`: List of modified files
   - `{{lines_added}}`: Number of lines added
   - `{{lines_deleted}}`: Number of lines deleted
   - `{{git_diff}}`: The actual git diff output

2. Provide the git diff using: `git diff --cached` (for staged changes) or `git diff` (for unstaged changes)

3. The AI will generate a properly formatted commit message following conventional commit standards.

## Tips for Better Commit Messages

- **Be specific**: Instead of "fix bug", write "fix: resolve null pointer exception in user validation"
- **Use present tense**: "add feature" not "added feature"
- **Keep it concise**: The subject line should be under 50 characters
- **Add context**: Use the body to explain why the change was made, not what was changed
- **Reference issues**: Include issue numbers when relevant (e.g., "fix: resolve #123")
- **Group related changes**: Make separate commits for logically separate changes

