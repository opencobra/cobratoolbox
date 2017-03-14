# Contributing to The COBRA Toolbox

:+1::tada: First off, thanks for taking the time to contribute to [The COBRA Toolbox](https://github.com/opencobra/cobratoolbox)! :tada::+1:

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

This section guides you through submitting an issue for The COBRA Toolbox. You may use a [template](https://github.com/opencobra/cobratoolbox/blob/documentation/.github/ISSUE_TEMPLATE.md) for submitting an issue or enhancement. Following these guidelines helps maintainers and the community understand your report :pencil:, reproduce the behavior :computer:, and fix it.

* **Pull the latest version of The COBRA Toolbox** You might be able to find the cause of the problem yourself. Most importantly, check if you can reproduce the problem with the latest version, if the problem happens when you run your script/function using the COBRA Toolbox with a different version of `MATLAB` or when using a different computer :computer: or different operating system (such as `Linux`, `Windows`, or `macOS`).
* **Check the list of currently reported issues [here](https://github.com/opencobra/cobratoolbox/issues)**. If you happen to find a related issue, please use that thread or refer in your new issue to an already existing one.
* **Check The COBRA Toolbox Forum on Google [here](https://groups.google.com/forum/#!forum/cobra-toolbox)** Has your question already been asked, or has your problem already been reported. If it has, add a comment to the existing issue instead of opening a new one.

After you've determined that you discovered a bug and need to open a new issue, you may want to follow these guidelines in order to have your issue resolved quickly. Explain the problem and include additional details to help maintainers reproduce the problem:

* **Use a clear and descriptive title** for the issue to identify the problem.
* **Provide information when you last updated The COBRA Toolbox or which tagged version you are using**. It is important to know which version you are using in order to reproduce the error.
* **Describe the exact steps which reproduce the problem and that describe the proposed enhancement** in as many details as possible. For example, start by explaining how you started and initialized The COBRA Toolbox.
* **Provide specific examples to demonstrate the steps**. Include links to files or GitHub projects, or copy/pasteable snippets, which you use in those examples. If you're providing snippets in the issue, use [Markdown code blocks](https://help.github.com/articles/markdown-basics/#multiple-lines).
* **Describe the current behavior you observed after following the steps** and point out what exactly is the problem with that behavior.
* **Explain which behavior you expected to see instead and why**

Provide details on the nature of the issue:

* **If you're reporting that `MATLAB` crashed**, include a crash report. Importantly, include the script that ran before the crash occurred, and indicate the line that you think that made `MATLAB` crash. As this is an operating system related issue, please make sure to test the same code on a different computer and/or operating system :computer: before reporting the issue.
* **If the problem is related to performance**, include more details, such as CPU information, RAM, computer brand/model. Eventually, mention where you feel potential improvements could be made.
* **If the problem wasn't triggered by a specific action**, describe what you were doing before the problem happened and share more information using the guidelines below.

Include details about your configuration and environment:

* **Provide details on your `startup.m` and your `pathdef.m` file.** If you have pre-configured your system to load the files of The COBRA Toolbox, please give more details about which solver directories, COBRA
* **Which version of MATLAB are you using?**
* **What's the name and version of the OS you're using?**
* **Which solvers do you have installed?** You can get that list by running `initCobraToolbox`.

Provide more context by answering these questions:

* **Might the problem be related to an external program?** If you are using a specific `MATLAB` function or a pre-compiled binary and the problem occurs with that function call, please mention it here.
* **Did the problem start happening recently** (e.g. after updating to a new version of Atom) or was this always a problem?
* If the problem started happening recently, **can you reproduce the problem in an older version of The COBRA Toolbox?** What's the most recent version in which the problem doesn't happen? You can checkout older versions of The COBRA Toolbox using `git checkout <tag or commit-ID>`.
* **Can you reliably reproduce the issue?** If not, provide details about how often the problem happens and under which conditions it normally happens.
* If the problem is related to working with models, **does the problem happen for all COBRA models, or only some?**

### Submitting a pull request (PR)

If this is your first time submitting a PR, or would need to have more information on how to do it, this [guide](https://www.digitalocean.com/community/tutorials/how-to-create-a-pull-request-on-github) might come in handy. The official [GitHub guide](https://help.github.com/articles/creating-a-pull-request/) may also help you in the submission process.

There is no particular template for submitting a PR, but do not submit a PR with too many files being changed at once. Please make sure that you document exactly what errors/issues that this PR addresses. When fixing an issue or error, you shall document the current output and the new output that is expected with the fix.

Before submitting the PR, please make sure that you followed the template for submitting a pull request [here](https://github.com/opencobra/cobratoolbox/blob/documentation/.github/PULL_REQUEST_TEMPLATE.md) and that you checked that there aren't any other open [Pull Requests](https://github.com/opencobra/cobratoolbox/pulls) for the same update/change.

## Styleguides

A style guide for the `The COBRA Toolbox` is given [here](https://github.com/opencobra/cobratoolbox/blob/documentation/.github/STYLE_GUIDE.md).

## Labels

A full list of labels for the issues and pull requests is given [here](https://github.com/opencobra/cobratoolbox/blob/documentation/.github/LABELS_LIST.md).

*This guide is inspired by [ATOM's contributing guide](https://github.com/atom/atom/blob/master/CONTRIBUTING.md). Feel free to propose changes to this document in a pull request.*
