Frequently Asked Questions (FAQ)
================================

.. begin-faq-marker

.. contents:: Table of contents

.. |ImageLink| image:: https://img.shields.io/badge/COBRA-forum-blue.svg
.. _ImageLink: https://groups.google.com/forum/#!forum/cobra-toolbox

If you need support, please feel free to post your question in our |ImageLink|_.

Installation
------------

How may I remove a legacy installation?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you have an existing installation of a legacy COBRA Toolbox on your system,
please remove the installation directory from your MATLAB path.

|warning| The following commands will delete your ``cobratoolbox`` directory and all of its contents

.. code-block:: matlab

    >> CBTDIR = fileparts(which('initCobraToolbox.m')); % get the directory of the COBRA Toolbox
    >> rmpath(genpath(CBTDIR)); % remove the directory from the path
    >> savepath % save the new path
    >> delete(CBTDIR,'s') % delete the installation directory


I cannot update the COBRA Toolbox using ``updateCobraToolbox()``. Why?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Whenever the update of the COBRA Toolbox fails when running ``updateCobraToolbox()``,
there is a chance that major restructurations happened recently. For instance, new submodules
might have been added.

Another reason for a failing update might be when the local version of the COBRA Toolbox is too old.
In that case, the easiest is to reinstall (reclone) the COBRA Toolbox or the fork after
having backed up the current version.

In case the update fails because of changes in the COBRA Toolbox, please
contribute your changes first by following the instructions `here <https://opencobra.github.io/cobratoolbox/stable/contributing.html>`.

In case you do not want to contribute your changes and are familiar with ``git``, you may also type (beware, your changes will be lost!):

.. code:: console

    $ git stash # stash all potential changes
    $ git add --all  # add all files first to stage
    $ git reset --hard HEAD  # hard reset the repository


When running ``git submodule update``, the following error message appears. What should I do?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: console

    No submodule mapping found in .gitmodules for path 'external/lusolMex64bit'

remove the cached version of the respective submodule by typing:

.. code:: console

    $ git rm --cached external/lusolMex64bit

Note: The submodule throwing an error might be different than
``external/lusolMex64bit``, but the command should work with any submodule.


On Windows, MATLAB R2016b crashes with CPLEX 12.7.1. Why?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When you experience an unexpected crash of MATLAB ``R2016b`` when running:

.. code-block:: matlab

    >> changeCobraSolver('ibm_cplex')

or

.. code-block:: matlab

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

On Linux, MATLAB Suddenly crashes without any error
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This can happen due to some MATLAB versions shipping broken libraries, in particular ``libssl.so.1.0.0``.
To fix this, you will have to replace the matlab library by the system library as follows:

.. code-block:: console

    $ sudo mv <MATLAB_ROOT>/bin/glnxa64/libssl.so.1.0.0 <MATLAB_ROOT>/bin/glnxa64/libssl.so.1.0.0.old
    $ sudo cp /lib/x86_64-linux-gnu/libssl.so.1.0.0 <MATLAB_ROOT>/bin/glnxa64/libssl.so.1.0.0

where ``<MATLAB_ROOT>`` is the directory of your MATLAB installation.


Parallel programming
--------------------

When running code in a parfor loop, solvers (and other global variables) are not properly set.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is an issue with global variables and the matlab
parallel computing toolbox. Global variables are not passed on to the
workers of a parallel pool. To change cobra global settings for a parfor loop, it is necessary to
reinitialize the global variables on each worker. The toolbox offers
two helper functions for this purpose, which also take care of pathes,
``getEnvironment()`` and ``restoreEnvironment()``, which can be used
as in the below example.

.. code-block:: matlab

    environment = getEnvironment();
    parfor i = 1:2
        restoreEnvironment(environment);
        changeCobraSolver(solver, 'LP', 0, -1); %third argument is printLevel, fourth argument is validation Level.
        % additional code in the parfor loop will now use the currently set solver
        optimizeCbModel(model);
    end

By requesting the current environment (global variables and path) before the parfor loop and
assigning it to a local variable, that variable is passed on to the
workers, which can then use it to set up the environment. ``dqqMinos`` and ``quadMinos`` use the file system to input and output solutions.
Therefore, they can currently not be used in any function that uses ``parfor``, as this would
cause concurrency issues between different workers.

Reconstruction
--------------

What does ``DM_reaction`` stand for after running ``biomassPrecursorCheck(model)``?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``DM_ reactions`` are commonly demand reactions.

Github & Contributing
---------------------

How may I update a submodule?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When updating a submodule, please consider updating the submodule itself
in the ``opencobra/cobratoolbox`` repository. Below is an example of how to update
the ``tutorials`` submodule:

.. code:: console

    $ cd fork-cobratoolbox # directory of your cloned fork
    $ git checkout develop
    $ git fetch upstream # upstream must be configured to point to opencobra/cobratoolbox
    $ git merge upstream/develop
    $ git checkout -b update-submodule
    $ cd tutorials
    $ git pull origin master # pull the latest changes from the master branch of COBRA.tutorials
    $ cd .. # change back to the root
    $ git add tutorials
    $ git commit -m "Updating the tutorials submodule"
    $ git push origin update-submodule

Then, proceed to open the PR to the ``opencobra/cobratoolbox`` repository.

What do all these labels on issues and PRs mean?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A comprehensive list of labels and their description for the issues and
pull requests is given
`here <https://opencobra.github.io/cobratoolbox/docs/labels.html>`__.

General
-------

After loading a model, I get errors when using it with toolbox functions. What can I do?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you used ``load('filename.mat')`` to load your model, you may encounter
unexpected errors.  Please only use ``readCbModel('filename.mat')``.  Many
models stored in a MATLAB format (.mat) contain outdated data structures, which
are no longer compatible with the COBRA Toolbox. The ``readCbModel()`` function
tries to convert these models to the current format and will inform you whether
this was successful or not.

If the ``readCbModel()`` call was unsuccessful, please use ``load`` again to
load your model struct and run ``verifyModel(model)`` to determine which fields
in the model are problematic.  You can then either try to correct the fields,
or remove them, if they are not necessary for your analysis.

If this does not solve your problem, feel free to report an issue as described
`here <https://opencobra.github.io/cobratoolbox/docs/issueGuide.html>`__.

.. end-faq-marker
