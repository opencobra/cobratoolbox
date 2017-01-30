Frequently Asked Questions (FAQ)
--------------------------------

## Submodules

When running `git submodule update`, the following error message appears:

```bash
No submodule mapping found in .gitmodules for path 'external/lusolMex64bit'`
```

**Solution**: remove the cached version of the respective submodule
```bash
git rm --cached external/lusolMex64bit
```

**Note**: The submodule throwing an error might be different than `external/lusolMex64bit`, but the command should work with any submodule.
