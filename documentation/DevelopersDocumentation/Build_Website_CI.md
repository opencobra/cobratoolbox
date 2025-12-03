# 🧩 Continuous Integration Guide:
# build-and-publish-site.yml

This document explains the structure and logic of the **Build and Publish Site (Ordered)** GitHub Actions workflow.
It is intended for developers maintaining the COBRA Toolbox documentation CI/CD pipeline.

---

## 📘 Overview

The workflow automates building the Sphinx-based documentation, preparing and updating static pages, and publishing the final website to the **`gh-pages`** branch under the `stable/` directory.

It performs the following major tasks in order:

1. Builds the core documentation (`make html`)
2. Removes and replaces dynamic parts (e.g. Contributors page)
3. Merges and updates external assets like tutorials, modules, citations
4. Regenerates the contributors list and HTML file
5. Updates navigation sidebars in static HTML pages
6. Updates static copyright text
7. Deploys all finalised files to `gh-pages`

---

## ⚙️ Trigger and Permissions

The workflow runs automatically **on every push to the `master` branch**:

```yaml
on:
  push:
    branches:
      - master
```

It has write permissions to repository contents, allowing deployment to the `gh-pages` branch.

```yaml
permissions:
  contents: write
```

---

## 🧱 Job Structure

All tasks are performed in a **single job** (`build-and-publish`) to preserve workspace state and order.

### ✅ 1. Checkout and Setup

* Checks out the current branch.
* Sets up **Python 3.10** with pip caching for faster runs.
* Installs dependencies listed in `documentation/requirements.txt`.

### ✅ 2. Core Documentation Build

* Runs `make html` in `documentation/` to build the Sphinx docs.
* Removes the `tutorials/` directory from the build, since tutorials are handled separately.
* Removes the auto-generated `contributors.html` to replace it later with a custom one.
* Copies all generated files to a temporary staging area `ghpages/stable`.

### ✅ 3. Preserve Existing Tutorials

Before overwriting the staging area, the workflow retrieves tutorials already deployed to `gh-pages`:

```yaml
- name: Checkout gh-pages into temp dir (read-only)
  uses: actions/checkout@v3
  with:
    ref: gh-pages
    path: ghpages-existing
```

If a `stable/tutorials/` directory exists in that branch, it is copied into the staging area.

This ensures tutorials are retained without being rebuilt every time.

---

## 🧠 Documentation Subsections

### 📖 Function Documentation

The workflow regenerates and stages documentation for the MATLAB function modules and citation pages:

* Runs scripts in `documentation/source/sphinxext/` and `documentation/source/modules/`
* Generates `.rst` files for modules
* Builds them with Sphinx (`make html`)
* Copies relevant HTML pages and static assets to:

  * `ghpages/stable/modules/`
  * `ghpages/stable/_static/`
  * `ghpages/stable/Citations/`

---

## 👥 Contributors Section

### Python Dependencies

Installed from:

```
documentation/source/Contributions/requirements.txt
```

This includes:

```
requests
pandas
numpy
datetime
python-dateutil
beautifulsoup4>=4.12
lxml>=5.1
```

### Updating the Sidebar (Navigation Menu)

The **UpdateSideBar.py** script copies the navigation sidebar from the built `index.html` and injects it into static pages, ensuring consistency with the rest of the site.

#### Contributors Template Sidebar Update

```yaml
python ./source/Contributions/UpdateSideBar.py \
  --source ./build/html/index.html \
  --input  ./source/Contributions/contributorsTemp.html \
  --output ./source/Contributions/contributorsTemp.html \
  --current-href contributors.html \
  --home-href index.html \
  --parser html5lib
```

* `--current-href` marks the active (“current”) page in the sidebar.
* `--home-href` ensures the first “Home” link points correctly.
* This produces the final sidebar for the contributors page.

#### Tutorials Sidebar Update

Since the tutorials live in a subfolder (`stable/tutorials/`), we also **rebase all relative links** using a prefix:

```yaml
python ./source/Contributions/UpdateSideBar.py \
  --source ./build/html/index.html \
  --input  ../ghpages/stable/tutorials/index.html \
  --output ../ghpages/stable/tutorials/index.html \
  --current-href tutorials/index.html \
  --home-href ../index.html \
  --href-prefix ../ \
  --parser html5lib
```

* The `--href-prefix ../` argument ensures links like `modules/index.html` become `../modules/index.html`, maintaining correct navigation from within the subfolder.

---

## 🧬 Contributor Page Regeneration

After updating the sidebar, two scripts regenerate the content:

1. `UpdateContributorsList.py`
   Parses `AllContributors.csv` to update metadata.

2. `GenerateContributorsHTML.py`
   Creates the final `contributors.html` using updated contributor data and the refreshed sidebar template.

The generated file is then staged under `ghpages/stable/`.

---

## © Copyright Updates

An optional step, **UpdateCopyright.py**, is executed to refresh copyright
footers in contributors and tutorials pages before deployment:

```yaml
python ./source/Contributions/UpdateCopyright.py \
  ../ghpages/stable/contributors.html \
  ../ghpages/stable/tutorials/index.html
```

This ensures the copyright date or version
matches the latest release.

---

## 🚀 Deployment

Finally, the pipeline deploys everything under `ghpages/` to the remote `gh-pages` branch:

```yaml
uses: JamesIves/github-pages-deploy-action@v4
with:
  folder: ghpages
  branch: gh-pages
  clean: false
  commit-message: "Publish site (single deploy, ordered build)"
```

The deployment **preserves existing content** (`clean: false`) while replacing any changed files in `stable/`.

---

## 🧩 Maintenance Tips

### 1. When to Rebuild

* Any change in documentation source files (`.rst`, `.py`, templates)
* Updated `AllContributors.csv`
* Modified sidebar structure or styling
* Sphinx theme updates

### 2. Updating Dependencies

If you update documentation dependencies, also update:

```
documentation/requirements.txt
documentation/source/Contributions/requirements.txt
```

### 3. Sidebar Adjustments

If Sphinx output structure changes (e.g. new `ul` nesting or sidebar div name),
edit the selector in `UpdateSideBar.py`:

```python
def get_menu_div(soup):
    return soup.select_one("div.wy-menu.wy-menu-vertical")
```

### 4. Tutorials Path Fixes

If tutorials move, update:

* The path in the “Update Tutorials sidebar” step
* The `--href-prefix` argument (e.g. `../../` for deeper nesting)

### 5. Debugging

To inspect failures:

* View workflow logs under “Actions → Build and publish site (ordered)”
* Re-run with “Enable debug logging” to print out file paths
* Check if the input and output HTML paths exist before sidebar injection

---

## ✅ Summary of Key Python Tools

| Script                          | Purpose                                               |
| ------------------------------- | ----------------------------------------------------- |
| **UpdateSideBar.py**            | Copies and updates sidebar navigation from built HTML |
| **UpdateContributorsList.py**   | Updates contributor data from CSV                     |
| **GenerateContributorsHTML.py** | Generates final contributors.html                     |
| **UpdateCopyright.py**          | Refreshes copyright metadata                          |
| **GetRSTfiles.py**              | Auto-generates `.rst` files for module docs           |
| **GenerateCitationsRST.py**     | Regenerates citations                                 |
| **copy_files.py**               | Synchronises static resources                         |

---

## 💡 Example: Local Testing

You can simulate the CI steps locally:

```bash
cd documentation
make html

python ./source/Contributions/UpdateSideBar.py \
  --source ./build/html/index.html \
  --input  ./source/Contributions/contributorsTemp.html \
  --output ./source/Contributions/contributorsTemp.html \
  --current-href contributors.html \
  --home-href index.html

python ./source/Contributions/GenerateContributorsHTML.py
```

Then open the generated HTML files under:

```
documentation/source/Contributions/contributors/
```

---

### Maintainers

If you introduce new static pages under `stable/`, you can reuse **UpdateSideBar.py**
to inject a consistent sidebar:

```bash
python UpdateSideBar.py \
  --source ./build/html/index.html \
  --input ./path/to/newpage.html \
  --output ./path/to/newpage.html \
  --current-href newpage.html \
  --home-href ../index.html \
  --href-prefix ../
```

---

**Last updated:** November 2025
**Maintainer:** COBRA Toolbox Documentation Team
