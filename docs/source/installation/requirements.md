# Requirements

## Can I check if everything is properly set up before I start?

#### MATLAB

Please ensure that you have a working `MATLAB` [installation](https://nl.mathworks.com/help/install/).

#### git

You can check if you have a working installation of `git` by typing in the `Terminal` (on `linux` and `macOS`) or `cmd` (in `Windows`, not `Git Bash`):
```bash
$ git --version
```
If installed properly, this will return `git version 2.13.1 [...]` or similar with another version number.

#### curl

You can check if you have a working installation of `curl` by typing in the terminal (`cmd` on Windows, not `Git Bash`):
```bash
$ curl --version
```
which will return `curl 7.51.0 [...]` or similar with another version number if installed properly.

## What if my system is not properly configured?

**Linux (Ubuntu or Debian)**

```bash
$ sudo apt-get install git-all curl
```

**macOS**

In order to install `git`, install the [Xcode Command Line Tools](http://osxdaily.com/2014/02/12/install-command-line-tools-mac-os-x/). For `curl`, follow the instructions [here](http://macappstore.org/curl/).

**Windows**

Please download the `git` tools for Windows from [here](https://git-scm.com/download/win). During the installation process, please ensure that you select **Use Git Bash and optional Unix tools from the Windows Command prompt**. In addition, please make sure that you select **Checkout as-is, commit Unix-style line endings**.

<div align="center">
<img src="../_static/images/installation_git_windows_0.png" height="280px">&nbsp;&nbsp;&nbsp;<img src="../_static/images/installation_git_windows_1.png" height="280px">.
</div>

For installing `curl`, follow the instructions [here](https://stackoverflow.com/questions/9507353/how-do-i-install-set-up-and-use-curl-on-windows/16216825#16216825). 
