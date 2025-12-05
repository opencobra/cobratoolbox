# COBRA Toolbox Documentation CI/CD Workflow Guide

This document explains how the **Build and Publish Site** GitHub Actions workflow operates. It is designed for future developers maintaining or extending the documentation pipeline.

---

## Overview

The workflow automatically:

1. Builds the Sphinx documentation
2. Updates dynamic citation data
3. Preserves previously deployed tutorials
4. Rebuilds function documentation
5. Regenerates the contributors page
6. Updates navigation sidebars in static HTML
7. Applies copyright updates
8. Deploys the final `stable/` site to the `gh-pages` branch

It runs **every time the `master` branch is pushed**.

---

## Workflow Trigger and Permissions

```yaml
on:
  push:
    branches:
      - master
```

The workflow uses:

```yaml
permissions:
  contents: write
```

This allows publishing to the `gh-pages` branch.

Concurrency ensures that only one workflow runs at a time:

```yaml
concurrency:
  group: gh-pages-deploy
  cancel-in-progress: false
```

---

## Job Structure

Everything runs inside a **single job** named `build-and-publish` so that intermediate files remain available across steps.

---

## Core Documentation Build

### 1. Checkout and Python Setup

The repository is checked out, Python 3.10 is installed, and documentation dependencies are installed from:

```
documentation/requirements.txt
```

### 2. Citation Database Update

Before building the docs, the workflow updates the COBRA citation database:

* Dependencies loaded from `documentation/source/Citations/requirements.txt`
* The file `COBRA.bib` is updated using `updateCitationsBib.py`

The workflow prints the number of citations collected for visibility.

### 3. Sphinx Build

The documentation is built using:

```
make html
```

The tutorials directory is then removed because tutorials are maintained only on the deployed site:

```
rm -rf ./documentation/build/html/tutorials
```

### 4. Stage Output

All generated HTML is staged into a temporary directory:

```
ghpages/stable/
```

The auto-generated contributors page is also removed so a custom one can be inserted later.

---

## Bringing Forward Existing Tutorials

Tutorials are not rebuilt each run. Instead, the workflow retrieves any existing tutorials from the previously deployed `gh-pages` branch:

1. The `gh-pages` branch is checked out into `ghpages-existing/`
2. If tutorials exist, they are copied into the staging area

This ensures tutorials persist unless intentionally deleted or replaced.

---

## Function Documentation

Function pages and citation `.rst` files are regenerated:

* `GenerateCitationsRST.py` produces formatted citation pages
* `copy_files.py` moves images and resources
* `GetRSTfiles.py` rebuilds module-level documentation
* `make html` regenerates the documentation

The results are staged under:

```
ghpages/stable/modules/
ghpages/stable/_static/
ghpages/stable/Citations/
```

---

## Contributors Page Generation

### 1. Install Contributor Dependencies

Dependencies are installed from:

```
documentation/source/Contributions/requirements.txt
```

### 2. Sidebar Updates

The custom static pages must have a sidebar matching the current Sphinx build.

The script `UpdateSideBar.py`:

* Copies sidebar HTML from `build/html/index.html`
* Inserts it into a static page
* Marks the correct navigation entry as active
* Adjusts links when pages live in subfolders

It is applied to:

#### Contributors template

```
source/Contributions/contributorsTemp.html
```

#### Tutorials index

```
ghpages/stable/tutorials/index.html
```

Uses prefix rebasing (`../`) because the tutorials folder is one level deeper.

#### HOLDER_TEMPLATE

If `HOLDER_TEMPLATE.html` exists inside tutorials, the same update is applied.

---

## Contributors Content Generation

Two scripts generate the final contributors page:

1. `UpdateContributorsList.py` rebuilds the structured contributor list
2. `GenerateContributorsHTML.py` outputs the finished HTML file into:

```
source/Contributions/contributors/
```

This is then staged to:

```
ghpages/stable/
```

---

## Static HTML Copyright Updates

The script `UpdateCopyright.py` updates copyright strings in:

* contributors.html
* tutorials/index.html

This resolves outdated year or version strings.

---

## Deployment

Deployment uses the JamesIves GitHub Pages action:

```yaml
uses: JamesIves/github-pages-deploy-action@v4
with:
  folder: ghpages
  branch: gh-pages
  clean: false
```

Key notes:

* `clean: false` preserves existing files such as old versions
* Only the staged site (`ghpages/`) is pushed

---

## Maintenance Guidelines

### Updating Build Dependencies

Ensure both files are kept in sync:

* `documentation/requirements.txt`
* `documentation/source/Contributions/requirements.txt`

### Updating SideBar Script

If Sphinx changes its HTML structure, you may need to modify:

```
get_menu_div() selector
```

### Adding New Static Pages

Use UpdateSideBar.py with appropriate flags:

* `--current-href`
* `--home-href`
* `--href-prefix`

### Debugging

Common checks:

* Confirm file paths exist before sidebar update
* Inspect build output in `documentation/build/html/`
* Check logs in the Actions tab for missing selectors or paths

---

## Local Testing

You can test the sidebar pipeline locally:

```bash
cd documentation
make html

python ./source/Contributions/UpdateSideBar.py \
  --source ./build/html/index.html \
  --input ./source/Contributions/contributorsTemp.html \
  --output ./source/Contributions/contributorsTemp.html \
  --current-href contributors.html \
  --home-href index.html
```

Then regenerate the contributors:

```bash
python ./source/Contributions/GenerateContributorsHTML.py
```

---

## Summary of Helper Scripts

| Script                        | Purpose                                |
| ----------------------------- | -------------------------------------- |
| `UpdateSideBar.py`            | Inject sidebar and adjust navigation   |
| `UpdateContributorsList.py`   | Regenerate structured contributor list |
| `GenerateContributorsHTML.py` | Produce final contributors HTML page   |
| `UpdateCopyright.py`          | Adjust copyright metadata              |
| `GetRSTfiles.py`              | Auto-generate module rst files         |
| `GenerateCitationsRST.py`     | Build citation documentation           |
| `copy_files.py`               | Copy assets used by documentation      |
| `updateCitationsBib.py`       | Update citation database (COBRA.bib)   |

---

## Last Updated

2025 · COBRA Toolbox Documentation Team
