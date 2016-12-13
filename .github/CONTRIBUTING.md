# Contributing to the COBRA Toolbox

:+1::tada: First off, thanks for taking the time to contribute to the [COBRA Toolbox](https://github.com/opencobra/cobratoolbox)! :tada::+1:

<!-- MDTOC maxdepth:6 firsth1:0 numbering:1 flatten:0 bullets:0 updateOnSave:1 -->

1. [How can I contribute?](#how-can-i-contribute)   
&emsp;1.1. [Reporting an issue or enhancement](#reporting-an-issue-or-enhancement)   
&emsp;1.2. [Submitting a pull request (PR)](#submitting-a-pull-request-pr)   
2. [Styleguides](#styleguides)   
&emsp;2.1. [Git commit messages](#git-commit-messages)   
&emsp;2.2. [Code styleguide](#code-styleguide)   
&emsp;2.3. [Documentation and comments styleguide](#documentation-and-comments-styleguide)   
&emsp;2.4. [Test styleguide](#test-styleguide)   
3. [Labels](#labels)   

<!-- /MDTOC -->

## How can I contribute?

### Reporting an issue or enhancement

This section guides you through submitting an issue for the COBRA Toolbox. You may use a [template](https://github.com/opencobra/cobratoolbox/blob/documentation/.github/ISSUE_TEMPLATE.md) for submitting an issue or enhancement. Following these guidelines helps maintainers and the community understand your report :pencil:, reproduce the behavior :computer:, and fix it.

* **Pull the latest version of the COBRA Toolbox** You might be able to find the cause of the problem yourself. Most importantly, check if you can reproduce the problem with the latest version, if the problem happens when you run your script/function using the COBRAToolbox with a different version of `MATLAB` or when using a different computer :computer: or different operating system (such as `Linux`, `Windows`, or `macOS`).
* **Check the list of currently reported issues [here](https://github.com/opencobra/cobratoolbox/issues)**. If you happen to find a related issue, please use that thread or refer in your new issue to an already existing one.
* **Check the COBRA Toolbox Forum on Google [here](https://groups.google.com/forum/#!forum/cobra-toolbox)** Has your question already been asked, or has your problem already been reported. If it has, add a comment to the existing issue instead of opening a new one.

After you've determined that you discovered a bug and need to open a new issue, you may want to follow these guidelines in order to have your issue resolved quickly. Explain the problem and include additional details to help maintainers reproduce the problem:

* **Use a clear and descriptive title** for the issue to identify the problem.
* **Provide information when you last updated the COBRA Toolbox or which tagged version you are using**. It is important to know which version you are using in order to reproduce the error.
* **Describe the exact steps which reproduce the problem and that describe the proposed enhancement** in as many details as possible. For example, start by explaining how you started and initialized the COBRA Toolbox.
* **Provide specific examples to demonstrate the steps**. Include links to files or GitHub projects, or copy/pasteable snippets, which you use in those examples. If you're providing snippets in the issue, use [Markdown code blocks](https://help.github.com/articles/markdown-basics/#multiple-lines).
* **Describe the current behavior you observed after following the steps** and point out what exactly is the problem with that behavior.
* **Explain which behavior you expected to see instead and why**

Provide details on the nature of the issue:

* **If you're reporting that `MATLAB` crashed**, include a crash report. Importantly, include the script that ran before the crash occurred, and indicate the line that you think that made `MATLAB` crash. As this is an operating system related issue, please make sure to test the same code on a different computer and/or operating system :computer: before reporting the issue.
* **If the problem is related to performance**, include more details, such as CPU information, RAM, computer brand/model. Eventually, mention where you feel potential improvements could be made.
* **If the problem wasn't triggered by a specific action**, describe what you were doing before the problem happened and share more information using the guidelines below.

Include details about your configuration and environment:

* **Provide details on your `startup.m` and your `pathdef.m` file.** If you have pre-configured your system to load the files of the COBRA Toolbox, please give more details about which solver directories, COBRA
* **Which version of MATLAB are you using?**
* **What's the name and version of the OS you're using?**
* **Which solvers do you have installed?** You can get that list by running `initCobraToolbox`.

Provide more context by answering these questions:

* **Might the problem be related to an external program?** If you are using a specific `MATLAB` function or a pre-compiled binary and the problem occurs with that function call, please mention it here.
* **Did the problem start happening recently** (e.g. after updating to a new version of Atom) or was this always a problem?
* If the problem started happening recently, **can you reproduce the problem in an older version of the COBRA Toolbox?** What's the most recent version in which the problem doesn't happen? You can checkout older versions of the COBRA Toolbox using `git checkout <tag or commit-ID>`.
* **Can you reliably reproduce the issue?** If not, provide details about how often the problem happens and under which conditions it normally happens.
* If the problem is related to working with models, **does the problem happen for all COBRA models, or only some?**

### Submitting a pull request (PR)

If this is your first time submitting a PR, or would need to have more information on how to do it, this [guide](https://www.digitalocean.com/community/tutorials/how-to-create-a-pull-request-on-github) might come in handy. The official [GitHub guide](https://help.github.com/articles/creating-a-pull-request/) may also help you in the submission process.

There is no particular template for submitting a PR, but do not submit a PR with too many files being changed at once. Please make sure that you document exactly what errors/issues that this PR addresses. When fixing an issue or error, you shall document the current output and the new output that is expected with the fix.

Before submitting the PR, please make sure that you followed the template for submitting a pull request [here](https://github.com/opencobra/cobratoolbox/blob/documentation/.github/PULL_REQUEST_TEMPLATE.md).

## Styleguides

### Git commit messages

* Use the present tense ("Add feature" not "Added feature")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally
* When only changing documentation, include `[ci skip]` in the commit description
* Consider starting the commit message with an applicable emoji:
    * :bug: `:bug:` when fixing a bug
    * :art: `:art:` when improving the format/structure of the code
    * :racehorse: `:racehorse:` when improving performance
    * :memo: `:memo:` when writing docs
    * :fire: `:fire:` when removing code or files
    * :white_check_mark: `:white_check_mark:` when adding tests
    * :penguin: `:penguin:` when fixing something on Linux
    * :apple: `:apple:` when fixing something on macOS
    * :computer: `:computer:` when fixing something on Windows
    * :green_heart: `:green_heart:` when fixing the CI build

### Code styleguide

1. **Spacing**
  * Write `if singleCondition`, and not `if (singleCondition)`. Use brackets only for multiple conditions.
  * Use spaces around operators, e.g., `i + 1` instead of `i+1`
  * Use spaces after commas (unless separated by newlines)
  * Avoid spaces inside the curly-braces of cells: `{a, b}` instead of `{ a, b }`
  * Use spaces after commas in lists, after operands, after names, etc. This also improves readability. e.g. `a = [ 1, 2, 3; 4, 5, 6 ];` instead of `a=[1,2,3;4,5,6]`;
  * Include a single line of whitespace between blocks of code

2. **Variable names**
  * Avoid ambiguity when naming variables: be as specific as possible
  * When using mixed words, separate with capital letters, e.g. `calculateKineticFlux`
  * All variable names must be written in English
  * Use verb-noun structure for functions: allows to explain the operations performed
  * Append meaningful prefixes when possible, e.g. `Av`, `Sum`, `Min`, `Max`, etc
  * Boolean type variables, i.e. with only True/False values, with `Is` or `is` to stress this fact, e.g. `if dataIsLoaded`
  * Reuse names for short-life and variables with local scope, such as indexes of loops
  * Only use `i`, `j`, etc., as indexes for very short loops

3. **Miscellaneous**
  * Add sanity checks to the code, e.g., if something does not work as expected, there should be code to check for this and either issue a warning or an error if there is a problem.
  * Do not encode the absolute position of any files within any function: use relative paths, where possible
  * Indent the code: really improves readability.
  * Fix a maximum line length: break large ones if needed. Ensure that it is clear that the sentence is separated through different lines, e.g.:
  ```
  function [ parameter1, parameter2, parameter3, parameter4 ] = FunctionManyParameters…
      …( InputParameter1, InputParameter2, InputParameter3, InputParameter3,...
  ...InputParameter4, InputParameter5 )
  ```
  * Divide the code in separate functional files whenever it is possible (and logical)

<!-- find some style guidelines online from MATLAB and compare with Julia -->

### Documentation and comments styleguide

* Make sure the code is fully documented and commented
* Header for each file with the following elements:
    * Brief description (easy and short functions) or more detailed explanations (more complicated functions).
    * Description of `Input` and `Output` variables
    * Authors, co-authors, contributors (and the contribution of each of them)
    * Date of first fully operative version, and dates of consequent modifications with the corresponding number of version, e.g. `v1 - 11/06/2014 / v2 - 12/08/2014`
    * Description of modifications in later versions, e.g. `v2: the efficiency has been improved by substituting the loops with matrices operations`
* Throughout the file:
    * Comment smartly. Not every line, but enough to allow tracking the execution
    * Try to use brief comments.
    * In case you believe a more complicated part requires a more comprehensive explanation, describe `What are you doing` and `How it is done through a more detailed paragraph`.
    * If the code is divided in blocks, you can also introduce briefly what is the function of each block beforehand.

### Test styleguide

* Make sure not to include `%%` in your test file to separate code blocks
* Annotate the individual tests extensively for review
* Use `assert(computedResult == expectedResult)` to logically test the `computedResult` and the `expectedResult` (you may also use `<` or `>`)
* Write loops for testing multiple models and/or solvers
* Try to make your tests compatible with as many solvers as possible
* Make sure to limit the output of the function to a minimum - only print the necessary information
* Use `verbose` to switch the verbose mode
* Ensure that the solution of optimization problems is actually a solution (test that the solution vector satisfies the imposed constraints)
* Make sure that equality `assert` tests within a given tolerance, e.g., `tol = 1e-9; assert(condition < tol);`
* Only use equality `assert` tests for integer values

## Labels

This section lists the labels we use to help us track and manage issues and pull requests. The labels are loosely grouped by their purpose, but it's not required that every issue have a label from every group or that an issue can't have more than one label from the same group.

| Label name | Description |
| -----------| --- |
| `beginner` | Less complex issues that would be good first issues to work on for users who want to contribute to Atom. |
| `bug` | Confirmed bugs or reports that are very likely to be bugs. |
| `crash` | Reports of Atom completely crashing. |
| `documentation` | Related to any type of documentation |
| `duplicate` | Pull requests/issues that are duplicates of other issues, i.e. they have been reported before. |
| `enhancement` | Feature requests. |
| `help wanted` | The Atom core team would appreciate help from the community in resolving these issues. |
| `in progress` | Pull requests/issues that are still being worked on, more changes will follow. |
| `invalid` | Issues that aren't valid (e.g. user errors). |
| `linux` | Related to the COBRA Toolbox running on Linux. |
| `mac` | Related to the COBRA Toolbox running on macOS. |
| `needs more information` | More information needs to be collected about these problems or feature requests (e.g. steps to reproduce). |
| `needs reproduction` | Likely bugs, but haven't been reliably reproduced. |
| `needs response` | A response is needed from the author of the PR. Issue will likely be closed unless a response is provided. |
| `needs review` | Pull requests/issues that need code review, and approval from maintainers or the COBRA Toolbox core team. |
| `needs testing` | Pull requests/issues that need manual testing. |
| `parallel` | Related to parallel computing |
| `performance` | Related to performance. |
| `question` | Questions more than bug reports or feature requests (e.g. how do I do X). |
| `requires changes` | Pull requests/issues that need to be updated based on review comments and then reviewed again. |
| `under review` | Pull requests/issues being reviewed by maintainers or the COBRA Toolbox core team. |
| `windows` | Related to the COBRA Toolbox running on Windows. |
| `wontfix`  | The COBRA Toolbox core team has decided not to fix these issues for now, either because they're working as intended or for some other reason. |

*This guide is inspired by [ATOM's contributing guide](https://github.com/atom/atom/blob/master/CONTRIBUTING.md). Feel free to propose changes to this document in a pull request.*
