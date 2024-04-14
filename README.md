# devops.jesuislibre.org

<!--toc:start-->

- [devops.jesuislibre.org](#repository)
  - [TODO devops.jesuislibre.org project initialisation](#todo-repository-project-initialisation)
  - [Included with this project](#included-with-this-project)
  - [Git workflow](#git-workflow)
  - [Commans](#commans)

<!--toc:end-->

## TODO devops.jesuislibre.org project initialisation

Enable **Read and write permissions** on the
[Github action workflow permission](https://github.com/badele/devops.jesuislibre.org/settings/actions)
(for pushing the release and changelog)

## Included with this project

- nix/flake - reproducible, declarative and reliable developpement systems
- just - Onboarding project commands
- pre-commit - Verify commits before push
- cocogitto - Conventional commits and auto versioning

## Git workflow

- `nix develop` or automatically loaded with `direnv` tool
- Conventional commits - `cog feat "message" scope`
  - pre-commit hook
    - markdownlint - markdown linter
    - nixpkgs-fmt - nix linter
- github
  - CI
    - conventional commits
    - lint
    - test
    - coverage
  - Manually releasing a new version
    [release action](https://github.com/badele/devops.jesuislibre.org/actions/workflows/Release.yml)

## Project commands

<!-- COMMANDS -->

```text
Available recipes:
    help                       Help it showed if just is called without arguments
    precommit-install          Setup pre-commit
    precommit-update           Update pre-commit
    precommit-check            precommit check
    hugo-init                  Init hugo documentation site
    hugo-serve
    doc-update FAKEFILENAME    Update documentation
    lint                       Lint the project
    repl                       Repl the project
    packages                   Show installed packages
```

<!-- /COMMANDS -->
