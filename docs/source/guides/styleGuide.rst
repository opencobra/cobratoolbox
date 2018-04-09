Styleguide
==========

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

.. code:: matlab

    function [parameter1, parameter2, parameter3, parameter4] = functionManyParameters...
              (InputParameter1, InputParameter2, InputParameter3, InputParameter3,...
               InputParameter4, InputParameter5)

-  Divide the code in separate functional files whenever it is possible
   (and logical)

4. **Platform independent code**

-  Use ``pwd`` to get the current directory
-  Use ``filesep`` for paths (e.g., ``['myPath' filesep 'myFile.m']``)

Documentation and comments
~~~~~~~~~~~~~~~~~~~~~~~~~~

-  Make sure the code is fully documented and commented
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
-  When only changing documentation, include ``[CI skip]`` in the commit
   description
-  Consider starting the commit message (not the title of the PR) with
   an applicable emoji:

   -  :bug: ``:bug:`` when fixing a bug
   -  :art: ``:art:`` when improving the format/structure of the code
   -  :racehorse: ``:racehorse:`` when improving performance
   -  :memo: ``:memo:`` when writing docs
   -  :fire: ``:fire:`` when removing code or files
   -  :white_check_mark: ``:white_check_mark:`` when adding tests
   -  :penguin: ``:penguin:`` when fixing something on Linux
   -  :apple: ``:apple:`` when fixing something on macOS
   -  :computer: ``:computer:`` when fixing something on Windows
   -  :green_heart: ``:green_heart:`` when fixing the CI build
