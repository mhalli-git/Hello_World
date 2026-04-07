# Bootstrap A New Repo From This Template

## Goal

Use this template to create a new repository with a repeatable baseline:

- starter structure
- working `Validate` workflow
- GitHub Actions enabled
- auto-merge enabled
- `main` protected

## Create the repo from the template

Use GitHub UI or GitHub CLI.

Example with `gh`:

```powershell
& "C:\Program Files\GitHub CLI\gh.exe" repo create NEW_REPO_NAME --public --template mhalli-git/Hello_World
```

Then clone it:

```powershell
git clone git@github.com:mhalli-git/NEW_REPO_NAME.git
Set-Location .\NEW_REPO_NAME
```

## Bootstrap the repo settings

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap-github-repo.ps1 -Owner mhalli-git -Repo NEW_REPO_NAME
```

What the script configures:

- enables Actions
- sets workflow permissions to `write`
- allows workflows to create and approve pull requests
- enables auto-merge
- ensures `main` is the default branch
- protects `main`
- requires pull requests
- requires the `Validate` check
- blocks force pushes
- blocks deletion

## Required order

1. push `main`
2. run the bootstrap script
3. create a feature branch
4. open a PR
5. confirm `Validate` passes

## After bootstrap

- replace placeholder docs
- extend `scripts/validate-template.ps1`
- add app-specific CI steps
