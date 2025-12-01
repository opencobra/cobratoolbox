How to contribute to the COBRA Toolbox
--------------------------------------

This guide explains, step by step, how to contribute code to the COBRA Toolbox:
how to fork the repository, work on your changes locally, place your code in the
correct folder inside ``src``, add tests, and open a pull request (PR).

1. Overview of the contribution workflow
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The typical workflow for contributing is:

1. Fork the COBRA Toolbox repository on GitHub.
2. Clone your fork to your local machine.
3. Add your code to the appropriate subfolder of ``src``.
4. Add tests for your new code (see :ref:`testGuide`).
5. Commit your changes locally.
6. Push your changes to your fork on GitHub.
7. Open a pull request to the ``develop`` branch of the COBRA Toolbox repository.
8. Address any review comments from the maintainers.

The following sections describe each step in more detail.

2. Fork the COBRA Toolbox repository
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Go to the main COBRA Toolbox repository on GitHub:

   * https://github.com/opencobra/cobratoolbox

2. In the top right corner, click the **Fork** button.
3. Choose your GitHub account as the destination.
4. GitHub will create a copy of the COBRA Toolbox under your account, for example:

   * ``https://github.com/<your-username>/cobratoolbox``

All your changes will be pushed to this fork.

3. Clone your fork locally
~~~~~~~~~~~~~~~~~~~~~~~~~~

To work on the code, clone your fork to your local machine.

1. Open a terminal.
2. Run:

   .. code-block:: bash

      git clone https://github.com/<your-username>/cobratoolbox.git
      cd cobratoolbox

3. Add the original repository as an ``upstream`` remote so that you can pull in future updates:

   .. code-block:: bash

      git remote add upstream https://github.com/opencobra/cobratoolbox.git
      git fetch upstream

4. Add your code to the correct folder in ``src``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

All new COBRA Toolbox code should be added under the ``src`` folder. The main
subfolders under ``src`` are:

* ``analysis``
* ``base``
* ``dataIntegration``
* ``design``
* ``reconstruction``
* ``visualization``

It is recommended to create a **new subfolder** inside the most appropriate
parent folder for your project. This keeps the toolbox organised and makes it
easier for others to navigate the code.

Below is guidance on when to use each folder.

**4.1. src/analysis**

Use ``analysis`` for methods that analyse existing metabolic models. Examples:

* Flux balance analysis, flux variability analysis, phenotype simulations.
* Comparison pipelines, performance profiling.
* Statistical or diagnostic analyses.

Suggested structure:  
``src/analysis/myNewAnalysisTool/``

**4.2. src/base**

Use ``base`` for shared utilities and core methods needed across the toolbox.
Examples include:

* General-purpose helper functions.
* IO utilities used by multiple modules.
* Shared mathematical or solver-related helper functions.

Suggested structure:  
``src/base/myUtilityFunctions/``

**4.3. src/dataIntegration**

Use ``dataIntegration`` for code that integrates omics or experimental data with
a model. Examples:

* Transcriptomics-, proteomics-, or metabolomics-based integration.
* Condition-specific model building.
* Data-driven constraint generation.

Suggested structure:  
``src/dataIntegration/myIntegrationPipeline/``

**4.4. src/design**

Use ``design`` for algorithms that propose modifications or interventions.
Examples:

* Strain design algorithms.
* Knockout or overexpression strategies.
* Intervention ranking, phenotype optimisation.

Suggested structure:  
``src/design/myDesignAlgorithm/``

**4.5. src/reconstruction**

Use ``reconstruction`` for tools that construct, curate or update metabolic
models. Examples:

* Model reconstruction pipelines.
* Gap filling algorithms.
* Model merging and quality control tools.

Suggested structure:  
``src/reconstruction/myReconstructionPipeline/``

**4.6. src/visualization**

Use ``visualization`` for tools that generate plots, diagrams or graphical
summaries. Examples:

* Flux distribution plots.
* Network diagrams.
* Pathway visualisation tools.

Suggested structure:  
``src/visualization/myVisualisationTools/``

5. Add a test for every new code module
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Every contribution must include a corresponding **test**. This ensures that new
code is validated and remains stable.

Your test should:

* Cover the main functions of your addition.
* Run without errors in a clean installation.
* Include checks for both expected behaviour and edge-case failures when possible.

For more information on writing tests, refer to:

* :ref:`testGuide`

6. Commit and push your changes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Once your code and tests are ready, commit your work.

1. Check which files have changed:

   .. code-block:: bash

      git status

2. Stage your new code and tests:

   .. code-block:: bash

      git add src/ path/to/your/files
      git add test/ path/to/your/tests

3. Commit your changes:

   .. code-block:: bash

      git commit -m "Add new analysis tool for XYZ with tests"

4. Push your changes to your fork:

   .. code-block:: bash

      git push origin develop

7. Open a pull request
~~~~~~~~~~~~~~~~~~~~~~

Once your changes are pushed, open a pull request on GitHub.

1. Visit your fork:

   * ``https://github.com/<your-username>/cobratoolbox``

2. Click **Compare & pull request**.
3. Ensure the PR target is:

   * Base repository: ``opencobra/cobratoolbox``
   * Base branch: ``develop``  
   * Head repository: your fork  
   * Head branch: ``develop`` (or whichever branch you pushed to)

4. Describe:

   * What your contribution does.
   * Where the code lives in ``src``.
   * What tests were added.
   * Any notes for reviewers.

5. Submit the pull request.

8. Address review comments
~~~~~~~~~~~~~~~~~~~~~~~~~~

Maintainers may request revisions. This is normal.

1. Make the changes locally.
2. Commit and push them again:

   .. code-block:: bash

      git commit -am "Address review comments"
      git push origin develop

Your pull request will update automatically.

Once approved, it will be merged into the ``develop`` branch of the COBRA Toolbox.
