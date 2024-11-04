
# Converting `gh-pages` Branch to `docs` Folder

This document outlines the necessary steps to convert the `gh-pages` branch to use the `docs` folder as the root for GitHub Pages hosting. This process includes renaming directories, updating workflows, and adjusting links to ensure seamless website functionality.

## How GitHub Hosts the Website

GitHub Pages allows repositories to be hosted as static websites. By default, GitHub Pages can use the `/docs` folder in the main branch to serve the website. Currently, this repository uses the `gh-pages` branch, which contains multiple folders and structures for different versions (e.g., `stable`, `latest`). Transitioning to a `docs` folder structure simplifies hosting and aligns with GitHub Pages' conventional setup.

## Steps for Conversion

### 1. Rename `docs` Folder to `documentation`

The current `docs` folder needs to be renamed to something like `documentation` to avoid conflicts with the new GitHub Pages hosting setup. This requires:
- Renaming the folder to `documentation`.
- Updating any workflows in `.github/workflows` that reference the `docs` folder to use the new `documentation` name.

### 2. Remove `/stable` and `/latest` Directories

The `/stable` and `/latest` directories contain duplicate files that should be consolidated into the root directory of the `docs` folder. This requires:
- Moving all files from `/stable` to the root of the new `docs` folder.
- Removing both `/stable` and `/latest` directories from the repository.
  
### 3. Update All Links

Many links across the website use absolute paths, referencing specific directories like `/stable`:
- Replace all absolute URLs (e.g., `https://opencobra.github.io/cobratoolbox/stable/...`) with relative URLs.
- Ensure that links are consistent with the new root structure. For example:
  - Before: `https://opencobra.github.io/cobratoolbox/stable/tutorials/tutorialHostMicrobeInteractions.html`
  - After: `tutorials/tutorialHostMicrobeInteractions.html`

### 4. Workflow and Automation Adjustments

Since the structure and location of the hosted site files will change:
- Modify any CI/CD or GitHub Action workflows that build or deploy to `gh-pages`. These should now target the `/docs` folder in the main branch.
- Verify that the new `documentation` folder works with the CI/CD pipeline, including any build steps needed for static assets.

### 5. Clean Up `.gitmodules` (If Necessary)

If `.gitmodules` includes submodules in the old `docs` folder or references the `stable` or `latest` directories, update these paths to reflect the new structure.

### 6. Test for Broken Links and References

After updating all links:
- Run a broken link checker across the repository to catch any missed or incorrect links.
- Test all major pages to ensure they load correctly without `stable` or `latest` paths.

### 7. Validate GitHub Pages Settings

After these changes, ensure that:
- GitHub Pages is configured to serve from the `/docs` folder in the repository settings.
- Verify that the new site renders correctly on GitHub Pages after pushing the changes.

---

Following these steps will transition the `gh-pages` setup to use the new `docs` structure, streamlining the repository and aligning with GitHub’s hosting conventions.
