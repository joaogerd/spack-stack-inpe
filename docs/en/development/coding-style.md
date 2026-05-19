# Coding style

## Shell scripts

- Use `bash` explicitly when Bash features are required.
- Use clear function names.
- Print operational messages with consistent prefixes such as `[INFO]`, `[WARN]` and `[ERROR]`.
- Fail early when a required variable, command or path is missing.
- Keep machine-specific values in configuration files, not hardcoded deep inside generic logic.

## Documentation

- Prefer concrete commands over generic descriptions.
- Separate confirmed facts from hypotheses.
- Record validation evidence.
- Avoid copying values from another machine without verification.

## YAML files

- Keep site configuration focused on infrastructure.
- Keep application dependencies in environment definitions.
- Use comments when a value is site-specific or provisional.
