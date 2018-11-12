.. _testGuide:

Guide for writing a test
------------------------

Before starting to write a test on your own, it might be instructive to
follow common test practices in ``/test/verifiedTests``. A style guide
on how to write tests is given
`here <https://opencobra.github.io/cobratoolbox/docs/styleGuide.html>`__.

Prepare the test (define requirements)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There are functions that need a specific solver or that can only be run
if a certain toolbox is installed on a system. To address these, you
should specify the respective requirements by using

.. code-block:: matlab

    solvers = prepareTest(requirements)

If successfull and all requirements are fulfilled, ``prepareTest`` will
return a ``struct`` with one field for each problem type
(``solvers.LP``, ``solvers.MILP`` etc.). Each field will be a cell array
of solver names (if any are available). If the test does not ask for
multiple solvers (via the ``requiredSolvers`` or the
``useSolversIfAvailable`` arguments), the returned cell array will only
contain at most one solver.

Here are a few examples:

.. rubric:: Example A: Require Windows for the test

The same works with ``needsMac``, ``needsLinux`` and ``needsUnix``
instead of ``needsWindows``.

.. code-block:: matlab

    solvers = prepareTest('needsWindows', true);

.. rubric:: Example B: Require an LP solver (``needsLP``)

The same works with ``needsNLP``, ``needsMILP``, ``needsQP`` or
``needsMIQP``. ``solvers.LP``, ``solvers.MILP`` etc. will be cell arrays
of string with the respective available solver for the problem type. If
the ``'useSolversIfAvailable'`` parameter is non empty, all installed
solvers requested will be in the cell array. Otherwise, there will be at
most one solver (if no solver for the problem is installed, the cell
array is empty).

.. code-block:: matlab

    solvers = prepareTest('needsLP', true);

.. rubric:: Example C: Use multiple solvers if present

If multiple solvers are requested. ``solvers.LP``, ``solvers.MILP`` etc
will contain all those requested solvers that can solve the respective
problem type and that are installed.

.. code-block:: matlab

    solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'ibm_cplex', 'gurobi'});

.. rubric:: Example D: Require one of a set of solvers

Some functionalities do only work properly with a limited set of solvers.
with the keyword ``requireOneSolverOf`` you can specify a set of solvers
of which the test requires at least one to be present. This option, will
make the test never be run with any but the solvers specified in the
supplied list. E.g. if your test only works with ``gurobi`` or ``mosek``
you would call ``prepareTest`` as

.. code-block:: matlab

    solvers = prepareTest('requireOneSolverOf', {'ibm_cplex', 'gurobi'})

.. rubric:: Example E: Exclude a solver

If for some reason, a function is known not to work with a few specific
solvers (e.g. precision is insufficient) but works with all others, it
might be advantageous to explicitly exclude that one solver instead of
defining the list of possible solvers. This can be done with the
``excludeSolvers parameter``. Eg. to exclude ``matlab`` and ``lp_solve``
you would use the following command:

.. code-block:: matlab

    solvers = prepareTest('excludeSolvers', {'matlab', 'lp_solve'})

.. rubric:: Example F: Require multiple solvers

Some tests require more than one solver to be run, and otherwise fail. To
require multiple solvers for a test use the ``requiredSolvers`` parameters.
E.g. if your function requires ``ibm_cplex`` and ``gurobi`` use the following
call:

.. code-block:: matlab

    solvers = prepareTest('requiredSolvers', {'ibm_cplex', 'gurobi'})

.. rubric:: Example G: Require a specific MATLAB toolbox

The toolbox IDs are specified as those used in ``license('test',
'toolboxName')``.  The following example requires the statistics toolbox
to be present.

.. code-block:: matlab

    solvers = prepareTest('requiredToolboxes', {'statistics_toolbox'})

.. rubric:: Example H: Multiple requirements

If the test requires multiple different properties to be met, you should
test them all in the same call. To keep the code readable, first define
the requirements and then pass them in.

.. code-block:: matlab

    % define required toolboxes
    requiredToolboxes = {'bioinformatics_toolbox', 'optimization_toolbox'};

    % define the required solvers (in this case matlab and dqqMinos)
    requiredSolvers = {'dqqMinos', 'matlab'};

    % check if the specified requirements are fullfilled (toolboxes, solvers in thhis example, a unix OS).
    solversPkgs = prepareTest('requiredSolvers', requiredSolvers, 'requiredToolboxes', requiredToolboxes, 'needsUnix', true);

Test if an output is correct
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you want to test if the output of a function
``[output1, output2] = function1(input1, input2)`` is correct, you
should call this function at least 4 times in your test. The argument
``ìnput2`` might be an optional input argument.

.. code-block:: matlab

    % Case 1: test with 1 input and 1 output argument
    output1 = function1(input1)

    % Case 2: test with 1 input and 2 output arguments
    [output1, output2] = function1(input1)

    % Case 3: test with 1 output and 2 input arguments
    output1 = function1(input1, input2)

    % Case 4: test with 2 input and 2 output arguments
    [output1, output2] = function1(input1, input2)

Each of the 4 test scenarios should be followed by a test on ``output1``
and ``output2``. For instance, for ``Case 4``:

.. code-block:: matlab

    % Case 4: test with 2 input and 2 output arguments
    [output1, output2] = function1(input1, input2)

    % test on output1
    assert(output1 < tol); % tol must be defined previously, e.g. tol = 1e-6;

    % test on output2
    assert(abs(output2 - refData_output2) < tol); % refData_output2 can be loaded from a file

The test succeeds if the argument of ``assert()`` yields a ``true``
logical condition.

Test if a function throws an error or warning message
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you want to test whether your ``function1`` correctly throws an
**error** message, you can test as follows:

.. code-block:: matlab

    % Case 5: test with 2 input and 1 output arguments (2nd input argument is of wrong dimension)
    % There are two options. If a particular error message is to be tested (here, 'Input2 has the wrong dimension'):
    assert(verifyCobraFunctionError('function1', 'inputs', {input1, input2'}, 'testMessage', 'Input2 has the wrong dimension'));

    % If the aim is to test, that the function throws an error at all
    assert(verifyCobraFunctionError('function1', 'inputs', {input1, input2'}));

If you want to test whether your ``function1`` correctly throws a
**warning** message, you can test as follows:

.. code-block:: matlab

    warning('off', 'all')
        output1 = function1(input1, input2');
        assert(length(lastwarn()) > 0)
    warning('on', 'all')

Note that this allows the error message to be thrown without failing the
test.

Test template
~~~~~~~~~~~~~

A test template is readily available
`here <https://opencobra.github.io/cobratoolbox/docs/testTemplate.html>`__.
The following sections shall be included in a test file:

.. rubric:: 1. Header

.. code-block:: matlab

    % The COBRAToolbox: <testNameOfSrcFile>.m
    %
    % Purpose:
    %     - <provide a short description of the purpose of the test
    %
    % Authors:
    %     - <major change>: <your name> <date>
    %

.. rubric:: 2. Test initialization

.. code-block:: matlab

    global CBTDIR
    
    % save the current path and switch to the test path
    currentDir = cd(fileparts(which('fileName'))); 

    % get the path of the test folder	    
    testPath = pwd;

.. rubric:: 3. Define the solver packages to be tested and the tolerance

.. code-block:: matlab

    % set the tolerance
    tol = 1e-8;

    % define the solver packages to be used to run this test
    solvers = prepareTest('needsLP',true);

.. rubric:: 4. Load a model and/or reference data

.. code-block:: matlab

    % load a model distributed by the toolbox
    getDistributedModel('testModel.mat');
    % load a particular model for this test:
    readCbModel([testPath filesep 'SpecificModel.mat'])
    % load reference data
    load([testPath filesep 'testData_functionToBeTested.mat']);

Please only load *small* models, i.e. less than ``100`` reactions. If
you want to use a non-standard test model that is already available
online, please make a pull request with the URL entry to the
`COBRA.models repository <https://github.com/cobrabot/COBRA.models>`__.

:warning: In order to guarantee compatibility across platforms, please use the full path to the model. For instance:

.. rubric:: 5. Create a parallel pool

This is only necessary for tests that test a function that runs in
parallel.

.. code-block:: matlab

    % create a parallel pool
    poolobj = gcp('nocreate'); % if no pool, do not create new one.
    if isempty(poolobj)
        parpool(2); % launch 2 workers
    end

:warning: Please only launch a pool of ``2`` workers - more workers
should not be needed to test a parallel function efficiently.

.. rubric:: 6. Body of test


The test itself. If the solvers are essential for the functionality tested in this test use:

.. code-block:: matlab

    for k = 1:length(solvers.LP)
        fprintf(' -- Running <testFile> using the solver interface: %s ... ', solvers.LP{k});

        solverLPOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
        % <your test goes here>

        % output a success message
        fprintf('Done.\n');
    end

This is important, as the continuous integration system will run other solvers on the test in its nightly build. That way, 
we can determine solvers that work with a specific method, and those that do not (potentially due to precision problems or other issues).
If the solvers are only used to test the outputs of a function for correctness, use:

.. code-block:: matlab

    solverLPOK = changeCobraSolver(solvers.LP{1}, 'LP', 0);
    % <your test goes here>

    % output a success message
    fprintf('Done.\n');

.. rubric:: 7. Return to the original directory

.. code-block:: matlab

    % change the directory
    cd(currentDir)

Run the test locally on your machine
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Please make sure that your test runs individually by typing after a
fresh start:

.. code-block:: matlab

    >> initCobraToolbox
    >> <testName>

Please then verify that the test runs in the test suite by running:

.. code-block:: matlab

    >> testAll

Alternatively, you can run the test suite in the background by typing:

.. code:: sh

    $ matlab -nodesktop -nosplash < test/testAll.m

Verify that your test passed
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Once your pull request (PR) has been submitted, you will notice an
orange mark next to your latest commit. Once the continuous integration
(CI) server succeeded, you will see a green check mark. If the CI
failed, you will see a red cross.

What should I do in case my PR failed?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can check why your PR failed by clicking on the mark and following
the respective links. Alternatively, you can see the output of the CI
for your PR
`here <https://prince.lcsb.uni.lu/jenkins/job/COBRAToolbox-pr-auto/>`__.
You can then click on the build number. Under ``Console Output``, you
can see the output of ``test/testAll.m`` with your integrated PR.

Once you understood why the build for your proposed PR failed, you can
add more commits that aim at fixing the error, and the CI will be
re-triggered.

Common errors include:

-  Double percentage sign ``%%`` in your test file to separate code
   blocks. Replace ``%%`` with ``%``.
-  Compatibility issues (``ILOG Cplex`` is not compatible with
   ``R2015b+``). Add an additional test on the version of matlab using
   ``verLessThan('matlab', '<version>')``.

Can I find out how many tests have failed?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The logical conditions, when tested using ``assert()``, will throw an
error when not satisfied. It is bad practice to test the sum of tests
passed and failed. Please only test using ``assert(logicalCondition)``.
Even though a test may fail using ``assert()``, a summary table with
comprehensive information is provided at the end of the test run.

For instance, the following test script **do not do this - bad
practice!**:

.. code-block:: matlab

    % do not do this: bad practice!
    testPassed = 0;
    testFailed = 0;

    % test on logical condition 1 - do not do this: bad practice!
    if logicalCondition1
        testPassed = testPassed + 1;
    else
        testFailed = testFailed + 1;
    end

    % test on logical condition 2 - do not do this: bad practice!
    if logicalCondition2
        testPassed = testPassed + 1;
    else
        testFailed = testFailed + 1;
    end

    assert(testPassed == 2 && testFailed == 0); % do not do this: bad practice!

shall be rewritten as follows:

.. code-block:: matlab

    % good practice
    assert(logicalCondition1);
    assert(logicalCondition2);
