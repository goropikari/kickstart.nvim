# Repository instructions

## Commit hooks

- Keep `.githooks/pre-commit` in the repository and keep it executable.
- Keep `core.hooksPath` configured as `.githooks` for local development.
- Run `make install-hooks` when setting up a new checkout.
- Do not remove, disable, or bypass the pre-commit hook with `--no-verify`.
- Commits must not be created when `make check` fails.
