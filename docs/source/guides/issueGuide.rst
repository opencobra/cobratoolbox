Guide on reporting issues/enhancements
======================================

What should I do before opening an issue?
-----------------------------------------

Following these guidelines helps maintainers and the community
understand your report :pencil:, reproduce the behavior :computer:, and
fix it.

-  **Get the latest version** Check if you can reproduce the problem
   with the latest version, if the problem happens when you run your
   script/function with a different version of ``MATLAB`` or when using
   a different computer :computer: or different operating system (such
   as ``Linux``, ``Windows``, or ``macOS``).
-  **Check The COBRA Toolbox Forum on Google
   `here <https://groups.google.com/forum/#!forum/cobra-toolbox>`__**
   Has your question already been asked, or has your problem already
   been reported? If it has, add a comment to the existing issue instead
   of opening a new one.
-  **Check the list of currently reported issues
   `here <https://github.com/opencobra/cobratoolbox/issues>`__**. If you
   happen to find a related issue, please use that thread or refer in
   your new issue to an already existing one.
-  **Check the list of open pull requests
   `here <https://github.com/opencobra/cobratoolbox/pulls>`__**.

If you provide snippets in the issue/pull request, use `Markdown code
blocks <https://help.github.com/articles/markdown-basics/#multiple-lines>`__.

How can I report an issue (or enhancement)?
-------------------------------------------

Explain the problem and include **additional details** to help
maintainers reproduce the problem:

-  Use a clear and descriptive title.
-  Provide information when you last updated The COBRA Toolbox.
-  Describe the exact steps that reproduce the problem and that describe
   the proposed enhancement in as many details as possible. Start by
   explaining how you started and initialized The COBRA Toolbox.
-  Provide specific examples to demonstrate the steps.
-  Describe the current behavior you observed after following the steps
   and point out what exactly is the problem with that behavior.
-  Explain what behavior you expected to see instead and why.

Provide details on the **nature of the issue**:

-  If you’re reporting that ``MATLAB`` crashed, include a crash report.
   Indicate the line that you think that made ``MATLAB`` crash. As this
   is an operating system related issue, please make sure to test the
   same code on a different computer and/or operating system :computer:
   before reporting the issue.
-  If the problem is related to performance, include more details, such
   as CPU information, RAM, computer brand/model. Eventually, mention
   where you feel potential improvements could be made.
-  If the problem wasn’t triggered by a specific action, describe what
   you were doing before the problem happened.

Include details about your **configuration and environment**:

-  Provide details on your ``startup.m`` and your ``pathdef.m`` file.
-  Which version of MATLAB are you using?
-  What operating system are you using?
-  Which solvers do you have installed? You can get that table by
   running ``initCobraToolbox``.

Provide more context by answering these **questions**:

-  Might the problem be related to an external program?
-  Did the problem start happening recently?
-  If the problem started happening recently, can you reproduce the
   problem in an older version of The COBRA Toolbox?
-  Can you reliably reproduce the issue?
-  Does the problem happen for all COBRA models, or only some?
