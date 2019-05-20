.. _styleGuide:

Style guide
-----------

A comprehensive MATLAB style guide written by Richard Jonson can be
found [here](http://www.datatool.com/downloads/MatlabStyle2%20book.pdf).

Code
~~~~

1. **Spacing**

-  Write ``if singleCondition``, and not ``if (singleCondition)``. Use
   brackets only for multiple conditions.
-  Use spaces around operators, e.g., ``i + 1`` instead of ``i+1``
-  Use spaces after commas (unless separated by newlines)
-  Avoid spaces inside the curly-braces of cells: ``{a, b}`` instead of
   ``{ a, b }``
-  Use spaces after commas in lists, after operands, after names, etc.
   This also improves readability. e.g. ``a = [1, 2, 3; 4, 5, 6];``
   instead of ``a=[1,2,3;4,5,6]``;
-  Include a single line of whitespace between blocks of code
-  Include a whitespace after a comment sign ``%``

2. **Variable names**

-  When using mixed words, separate with capital letters (with no
   intervening spaces or punctuation), e.g. ``calculateKineticFlux``
-  Avoid ambiguity when naming variables: be as specific as possible
-  All variable names must be written in English
-  Use verb-noun structure for functions: allows to explain the
   operations performed
-  Append meaningful prefixes when possible, e.g. ``Av``, ``Sum``,
   ``Min``, ``Max``, etc
-  Boolean type variables, i.e. with only ``true/false`` values, with
   ``Is`` or ``is`` to stress this fact, e.g. ``if dataIsLoaded``
-  Reuse names for short-life and variables with local scope, such as
   indexes of loops
-  Only use ``i``, ``j``, etc., as indexes for very short loops

3. **Miscellaneous**

-  Add sanity checks to the code, e.g., if something does not work as
   expected, there should be code to check for this and either issue a
   ``warning`` or an ``error`` if there is a problem.
-  Do not encode the absolute position of any files within any function:
   use relative paths, where possible
-  Indent the code: really improves readability.
-  Fix a maximum line length: break large ones if needed. Ensure that it
   is clear that the sentence is separated through different lines,
   e.g.:

.. code-block:: matlab

    function [parameter1, parameter2, parameter3, parameter4] = functionManyParameters...
              (InputParameter1, InputParameter2, InputParameter3, InputParameter3, ...
               InputParameter4, InputParameter5)

-  Divide the code in separate functional files whenever it is possible
   (and logical)

4. **Platform independent code**

-  Use ``pwd`` to get the current directory
-  Use ``filesep`` for paths (e.g., ``['myPath' filesep 'myFile.m']``)

Documentation and comments
~~~~~~~~~~~~~~~~~~~~~~~~~~

-  Make sure the code is fully documented and commented, especially parts of
   the code that might be difficult to understand for beginner users.
-  Header for each file with the following elements:

   -  Brief description (easy and short functions) or more detailed
      explanations (more complicated functions).
   -  Description of ``INPUT`` and ``OUTPUT`` variables
   -  Authors, co-authors, contributors (and the contribution of each of
      them)
   -  Date of first fully operative version, and dates of consequent
      modifications with the corresponding number of version, e.g.
      ``v1 - 11/06/2014 / v2 - 12/08/2014``
   -  Description of modifications in later versions, e.g.
      ``v2: the efficiency has been improved by substituting the loops with matrices operations``

-  Throughout the file:

   -  Comment smartly. Not every line, but enough to allow tracking the
      execution
   -  Try to use brief comments.
   -  In case you believe a more complicated part requires a more
      comprehensive explanation, describe ``What are you doing`` and
      ``How it is done through a more detailed paragraph``.
   -  If the code is divided in blocks, you can also introduce briefly
      what is the function of each block beforehand.
   -  Format the comments with a whitespace after the ``%`` sign. Try to use lowercase letters for comments.

.. raw:: html

   <!-- elaborate guidelines to automatically generate the documentation //-->

Tests
~~~~~

-  Annotate the individual tests extensively for review
-  Use ``assert(computedResult == expectedResult)`` to logically test
   the ``computedResult`` and the ``expectedResult`` (you may also use
   ``<`` or ``>``)
-  For testing all entries of a vector, use
   ``assert(all(vector1 == vector2))``
-  Only use equality ``assert`` tests for integer values
-  Make sure that equality ``assert`` tests within a given tolerance,
   e.g., ``tol = 1e-9; assert(condition < tol);``
-  Write loops for testing multiple models and/or solvers
-  Try to make your tests compatible with as many solvers as possible
-  Test, if possible, your contribution on ``Linux``
-  Make sure to limit the output of the function to a minimum - only
   print the necessary information
-  Use ``verbose`` or ``printLevel`` to switch the verbose mode
-  Ensure that the solution of optimization problems is actually a
   solution (test that the solution vector satisfies the imposed
   constraints)

Git commit messages
~~~~~~~~~~~~~~~~~~~

-  Use the present tense (“Add feature” not “Added feature”)
-  Limit the first line to 72 characters or less
-  Reference issues and pull requests liberally
-  When only changing documentation, include ``[documentation]`` in the commit
   description
-  Consider starting the commit message (not the title of the PR) with
   an applicable emoji:

   -  |bug| ``:bug:`` when fixing a bug
   -  |art| ``:art:`` when improving the format/structure of the code
   -  |racehorse| ``:racehorse:`` when improving performance
   -  |memo| ``:memo:`` when writing docs
   -  |fire| ``:fire:`` when removing code or files
   -  |white_check_mark| ``:white_check_mark:`` when adding tests
   -  |penguin| ``:penguin:`` when fixing something on Linux
   -  |apple| ``:apple:`` when fixing something on macOS
   -  |computer| ``:computer:`` when fixing something on Windows
   -  |green_heart| ``:green_heart:`` when fixing the CI build


.. |macos| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/apple.png" height="20px" width="20px" alt="macOS">


.. |linux| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/linux.png" height="20px" width="20px" alt="linux">


.. |windows| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/windows.png" height="20px" width="20px" alt="windows">


.. |warning| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/warning.png" height="20px" width="20px" alt="warning">


.. |matlab| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/matlab.png" height="20px" width="20px" alt="matlab">


.. |tada| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/tada.png" height="20px" width="20px" alt="tada">


.. |thumbsup| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/thumbsUP.png" height="20px" width="20px" alt="thumbsup">


.. |bulb| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/bulb.png" height="20px" width="20px" alt="bulb">


.. |pencil| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/pencil.png" height="20px" width="20px" alt="pencil">


.. |computer| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/computer.png" height="20px" width="20px" alt="computer">


.. |bug| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/bug.png" height="20px" width="20px" alt="bug">


.. |apple| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/apple.png" height="20px" width="20px" alt="apple">


.. |art| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/art.png" height="20px" width="20px" alt="art">


.. |fire| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/fire.png" height="20px" width="20px" alt="fire">


.. |green_heart| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/green_heart.png" height="20px" width="20px" alt="green_heart">


.. |memo| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/memo.png" height="20px" width="20px" alt="memo">


.. |penguin| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/penguin.png" height="20px" width="20px" alt="penguin">


.. |racehorse| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/racehorse.png" height="20px" width="20px" alt="racehorse">


.. |white_check_mark| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/white_check_mark.png" height="20px" width="20px" alt="white_check_mark">


.. |tutorials| raw:: html

   <a href="https://opencobra.github.io/cobratoolbox/latest/tutorials/index.html"><img src="https://img.shields.io/badge/COBRA-tutorials-blue.svg?maxAge=0"></a>


.. |latest| raw:: html

   <a href="https://opencobra.github.io/cobratoolbox/latest"><img src="https://img.shields.io/badge/COBRA-docs-blue.svg?maxAge=0"></a>


.. |forum| raw:: html

   <a href="https://groups.google.com/forum/#!forum/cobra-toolbox"><img src="https://img.shields.io/badge/COBRA-forum-blue.svg"></a>


.. |br| raw:: html

   <br>

