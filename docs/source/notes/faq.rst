Frequently Asked Questions (FAQ)
================================

.. begin-faq-marker

Github
------

**What do all these labels mean?**

A comprehensive list of labels and their description for the issues and
pull requests is given
`here <https://opencobra.github.io/cobratoolbox/docs/labels.html>`__.

Reconstruction
--------------

What does ``DM_reaction`` stand for after running
``biomassPrecursorCheck(model)``?

**Answer**: ``DM_ reactions`` are commonly demand reactions.

Submodules
----------

When running ``git submodule update``, the following error message
appears:

.. code::

    No submodule mapping found in .gitmodules for path 'external/lusolMex64bit'

**Solution**: remove the cached version of the respective submodule

.. code::

    git rm --cached external/lusolMex64bit

**Note**: The submodule throwing an error might be different than
``external/lusolMex64bit``, but the command should work with any
submodule.

Parallel programming
--------------------

When running cobra code in a parfor loop, solvers (and other global
variables) are not properly set.

| **Answer**: This is an issue with global variables and the matlab
  parallel computing toolbox. Global variables are not passed on to the
  workers of a parallel pool.
| To change cobra global settings for a parfor loop, it is necessary to
  reinitialize the global variables on each worker. The easiest way to
  do this is as follows:

.. code::

    global CBT_SOLVER_LP
    solver = CBT_SOLVER_LP
    parfor 1:2
        changeCobraSolver(solver,'LP');
        %additional code in the parfor loop will now use the currently set solver
        optimizeCbModel(model);
    end

By requesting the current global variable before the parfor loop and
assigning it to a local variable, that variable is passed on to the
workers, which can then use it to set up the correct solver (or other
variable).

(Windows) MATLAB R2016b crashes with CPLEX 12.7.1
-------------------------------------------------

When you experience an unexpected crash of MATLAB ``R2016b`` when
running:

.. code::

    >> changeCobraSolver('ibm_cplex')

or

.. code::

    >> initCobraToolbox

after having installed ``CPLEX 12.7.1``, the solver might not be
correctly installed (see `this
issue <https://github.com/opencobra/cobratoolbox/issues/802>`__).

In order to fix this issue, follow these steps:

-  Uninstall all older versions of CPLEX (e.g., ``12.6.3``)
-  Uninstall CPLEX ``12.7.1``
-  Restart your computer
-  Install CPLEX ``12.7.1``. You will be prompted to install
   ``Microsoft Visual C++ 2013``
-  Download `this software
   package <https://www.microsoft.com/en-us/download/details.aspx?id=40784>`__
   and install ``Microsoft Visual C++ 2013 (x64)``
-  Finish the installation of CPLEX ``12.7.1``
-  Restart your computer
-  Start MATLAB and the above commands again

.. end-faq-marker
