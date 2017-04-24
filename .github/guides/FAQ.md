Frequently Asked Questions (FAQ)
--------------------------------

## Github

**What do all these labels mean?**

A comprehensive list of labels and their description for the issues and pull requests is given [here](https://github.com/opencobra/cobratoolbox/blob/master/.github/guides/LABELS.md).

## Reconstruction

What does `DM_reaction` stand for after running `biomassPrecursorCheck(model)`?

**Answer**: `DM_ reactions` are commonly demand reactions.

## Submodules

When running `git submodule update`, the following error message appears:

```bash
No submodule mapping found in .gitmodules for path 'external/lusolMex64bit'
```

**Solution**: remove the cached version of the respective submodule
```bash
git rm --cached external/lusolMex64bit
```

**Note**: The submodule throwing an error might be different than `external/lusolMex64bit`, but the command should work with any submodule.
