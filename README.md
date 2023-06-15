# Cobratoolbox Website Documentation

This website is built and hosted using GitHub pages, please read the documentation for more information: https://docs.github.com/en/pages


## Continuous Integration of Tutorials:

Here are the following steps taken in the tutorial CI pipeline:
1. Contributor posts .m and .mlx tutorial to the [Tutorials Repository](https://github.com/opencobra/COBRA.tutorials)
2. This triggers the [GitHub action workflow](https://github.com/opencobra/COBRA.tutorials/blob/master/.github/workflows/main.yml) which is hosted on a local computer (self-hosted runner). Here the .mlx file is converted to a .html file and pushed to the gh-pages branch of the cobratoolbox repository
3. This then triggers a [seperate Github actions workflow](https://github.com/opencobra/cobratoolbox/blob/gh-pages/.github/workflows/main.yml) on the cobratoolbox gh-pages branch. This workflow reconfigures the various files and directories so that the html tutorial can be integrated into the website 
