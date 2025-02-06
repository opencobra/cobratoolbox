COBRA Tutorials
===============

Tutorials are here to get you started with using `The COBRA
Toolbox <https://opencobra.github.io/cobratoolbox>`__. The
tutorials are grouped according to the ``src/`` folder structure:

- |icon_analysis| `analysis <https://github.com/opencobra/COBRA.tutorials/tree/master/analysis>`__
- |icon_base| `base <https://github.com/opencobra/COBRA.tutorials/tree/master/base>`__
- |icon_dataIntegration| `dataIntegration <https://github.com/opencobra/COBRA.tutorials/tree/master/dataIntegration>`__
- |icon_design| `design <https://github.com/opencobra/COBRA.tutorials/tree/master/design>`__
- |icon_reconstruction| `reconstruction <https://github.com/opencobra/COBRA.tutorials/tree/master/reconstruction>`__
- |icon_visualization| `visualization <https://github.com/opencobra/COBRA.tutorials/tree/master/visualization>`__

All tutorials are provided in 4 formats: ``.mlx``, ``.m``, ``.pdf``, and ``.html``.

- The interactive version ``.mlx`` is a MATLAB Live-script format and can be run using `the MATLAB Live-script editor <https://nl.mathworks.com/help/matlab/matlab_prog/what-is-a-live-script.html>`__.
- The static version ``.html`` can be visualized on the `tutorial section of the COBRA Toolbox documentation <https://opencobra.github.io/COBRA.tutorials>`__.
- For your reference, the ``.pdf`` version can be downloaded from the `tutorial section <https://opencobra.github.io/COBRA.tutorials>`__. The `.m` version of the tutorial can be opened and run directly in MATLAB. This is particularly useful to build new analysis scripts based on an existing tutorial.

Contribute a new tutorial or modify an existing tutorial
========================================================

A template for generating a new tutorial is provided `here
<https://github.com/opencobra/COBRA.tutorials/tree/master/.template/tutorial_template.mlx>`__.

There are two ways to contribute to the tutorials:

A) Contribute using the ``MATLAB.devTools``
----------------------------------------

You can use the `MATLAB.devTools <https://github.com/opencobra/MATLAB.devTools>`__ to submit your tutorial.

B) Contribute using ``git`` (via command line)
-------------------------------------------

Fork and checkout your branch
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Fork the `COBRA.tutorials repository <https://www.github.com/opencobra/COBRA.tutorials>`__ on Github.

2. Clone the forked repository to a directory of your choice:

   .. code-block:: console

      $ git clone git@github.com:<userName>/COBRA.tutorials.git fork-COBRA.tutorials.git

3. Change to the directory:

   .. code-block:: console

      $ cd fork-COBRA.tutorials.git/

4. Set the upstream to the ``opencobra/COBRA.tutorials`` repository:

   .. code-block:: console

      $ git remote add upstream git@github.com:opencobra/COBRA.tutorials.git

5. Fetch from the upstream repository

   .. code-block:: console

      $ git fetch upstream

6. Checkout a new branch from ``develop``:

   .. code-block:: console

      $ git checkout -b <yourBranch> upstream/develop

7. Now, make your changes in the tutorial in MATLAB.


Submit your changes and open a pull request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

8. Once you are done making changes, add the files to your branch, where ``tutorial_<yourFile>`` is the name of the tutorial.    Make sure to add the ``.m`` and the ``.mlx`` files.

   .. code-block:: console

      $ git add tutorial_<yourFile>.m
      $ git add tutorial_<yourFile>.mlx
      $ git commit -m "Changes to tutorial_<yourFile>"

9. Push your commits on ``<yourBranch>`` to your fork:

   .. code-block:: console

      $ git push origin <yourBranch>

10. Browse to your fork on ``https://www.github.com/<yourUserName>/COBRA.tutorials``, where ``<yourUserName>`` is your Github username.

11. Click on ``Compare & Pull Request``.

12. Change the target branch ``develop``.

13. Submit your pull request.

14. Wait until your pull request is accepted.


.. |icon_analysis| raw:: html

   <img src="http://gibbs.unal.edu.co/cobradoc/cobratoolbox/img/icon_analysis.png" height="14px">

.. |icon_base| raw:: html

   <img src="http://gibbs.unal.edu.co/cobradoc/cobratoolbox/img/icon_base.png" height="14px">

.. |icon_dataIntegration| raw:: html

   <img src="http://gibbs.unal.edu.co/cobradoc/cobratoolbox/img/icon_di.png" height="14px">

.. |icon_design| raw:: html

   <img src="http://gibbs.unal.edu.co/cobradoc/cobratoolbox/img/icon_design.png" height="14px">

.. |icon_reconstruction| raw:: html

   <img src="http://gibbs.unal.edu.co/cobradoc/cobratoolbox/img/icon_reconstruction.png" height="14px">

.. |icon_visualization| raw:: html

   <img src="http://gibbs.unal.edu.co/cobradoc/cobratoolbox/img/icon_visualization.png" height="14px">

