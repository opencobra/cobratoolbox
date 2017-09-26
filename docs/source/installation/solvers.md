Solver Installation Guide
---------------------------------
<!-- TOC -->
- [TOMLAB](#tomlab)
- [IBM ILOG CPLEX](#ibm-ilog-cplex)
- [GUROBI](#gurobi)
- [MOSEK](#mosek)
<!-- /TOC -->

<img src="https://prince.lcsb.uni.lu/jenkins/userContent/warning.png" height="20px" alt="warning"> Please make sure that you install a compatible solver. Check the compatibility [here](https://opencobra.github.io/cobratoolbox/docs/compatibility.html).

Platform-specific instructions are marked with
- **Windows** - <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px" alt="Windows">
- **macOS** - <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px" alt="macOS">
- **linux** - <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px" alt="Linux">

<img src="https://prince.lcsb.uni.lu/jenkins/userContent/warning.png" height="20px" alt="warning"> Most steps require superuser or administrator rights (`sudo`).

:pencil: Make sure that you replace `<ver>` with the respective `version` of the installed solver when setting the environment variables.

## TOMLAB

1) Download `TOMLAB/CPLEX` from [here](http://tomopt.com/scripts/register.php), where you can also download `TOMLAB/SNOPT`. You must purchase the `tomlab.lic` license separately.

2) <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px" alt="Linux"> In a terminal window, navigate to the download directory of `Tomlab` and do the following
    ````bash
    $ chmod +x <filename>.bin
    $ sudo ./<filename>.bin
    ````
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px" alt="Windows"> Run the `tomlab-win64-setup_<ver>.exe` as an administrator.
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px" alt="macOS"> Double-click on `tomlab-osx64-setup.app`.

3) Follow the installation instructions and install `tomlab` in:
    - <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px" alt="Linux">: `/opt` such that you will have a folder `/opt/tomlab`.
    - <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px" alt="Windows">: `C:\` such that you will have a folder `C:\tomlab`.
    - <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px" alt="macOS">:
    `/Applications` such that you will have a folder `/Applications/tomlab`

4) <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px" alt="Linux"> Copy the `tomlab.lic` license to the folder `/opt/tomlab` and change its permissions (you must have superuser or `sudo` rights)
    ````bash
    $ sudo chmod 644 tomlab.lic
    ````
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px" alt="Windows"> Copy the `tomlab.lic` license to the folder `C:\tomlab`.
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px" alt="macOS"> Copy the `tomlab.lic` license to the folder `/Applications/tomlab`.

5) <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px" alt="macOS">  <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px" alt="Linux"> Set the environment variable by editing your `~/.bashrc` file:
    ````bash
    $ nano ~/.bashrc
    ````
    Append the following lines, hit the `ESC` key, then save and exit by typing `CTRL-X` and hitting ENTER:
    ````
    export TOMLAB_PATH="/opt/tomlab"
    ````
    Reload your `~/.bashrc`:
    ````bash
    $ source ~/.bashrc
    ````
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px" alt="Windows"> In order to set the environment variables on Windows, please follow the instructions [here](https://www.computerhope.com/issues/ch000549.htm).

## IBM ILOG CPLEX

1) Download the `CPLEX` installation binary. The limited community edition is [here](https://www-01.ibm.com/software/websphere/products/optimization/cplex-studio-community-edition/). CPLEX is free for students (and academics) and further information how to register and download is [here](https://www.ibm.com/developerworks/community/blogs/jfp/entry/CPLEX_Is_Free_For_Students?lang=en).

2) <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px" alt="macOS">  <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px" alt="Linux"> Add `execute` permission to binary
    ````bash
    $ chmod +x <cplexbinary>.bin
    ````

3) <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px" alt="macOS">  <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px" alt="Linux"> Run the installer binary as superuser, follow the installation procedure, and accept the default installation path.
    ````bash
    $ sudo ./<cplexbinary>.bin
    ````
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px" alt="Windows"> Run `cplex_studio<ver>.win-x86-64.exe` as an administrator. Follow the installation instructions and install `CPLEX` in `C:\Program Files\IBM\ILOG\CPLEX_Studio<ver>`.

4) <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px" alt="macOS"> <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px" alt="Linux"> Set the environment variable by editing your `~/.bashrc` file:
    ````bash
    $ nano ~/.bashrc
    ````
    Append the following lines, hit the `ESC` key, then save and exit by typing `CTRL-X` and hitting ENTER:
    On <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px" alt="Linux">:
    ````
    export ILOG_CPLEX_PATH="/opt/ibm/ILOG/CPLEX_Studio<ver>"
    ````
    On <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px" alt="macOS">
    ````
    export ILOG_CPLEX_PATH="/Applications/IBM/ILOG/CPLEX_Studio<ver>"
    ````
    Reload your `~/.bashrc`:
    ````bash
    $ source ~/.bashrc
    ````
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px" alt="Windows"> ![#ff0000](https://placehold.it/15/ff0000/000000?text=+) Make sure that you select `Yes, update the PATH variable.`. You can also follow the instructions [here](https://www.ibm.com/support/knowledgecenter/SSSA5P_12.6.1/ilog.odms.cplex.help/CPLEX/GettingStarted/topics/set_up/Windows.html).

## GUROBI

1) Register and log in [here](http://www.gurobi.com/)

2) Request license from the [download center](http://www.gurobi.com/downloads/download-center) and retrieve `YOUR-LICENSE-KEY-FROM-SITE`

3) Download the `Gurobi` optimizer from [here](http://www.gurobi.com/downloads/gurobi-optimizer)

4) <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px" alt="Linux"> Navigate to the directory where `Gurobi` was downloaded and enter
    ````bash
    $ tar -xvzf <archive>.tar.gz
    $ sudo mv gurobi<ver> /opt/.
    $ cd /opt/gurobi<ver>/linux64/bin/
    ````
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px" alt="Windows"> Run `Gurobi-<ver>-win64.msi` and follow the installation instructions. Accept the default path `C:\gurobi<ver>\`.
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px" alt="macOS"> Run `gurobi<ver>_mac64.pkg` and follow the installation instructions. Accept the default path `/Applications/gurobi<ver>/`.

5) <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px" alt="Linux"> Edit the `bash` settings to include paths
    ````bash
    $ nano ~/.bashrc
    ````
    Append the following lines, hit the `ESC` key, then save and exit by typing `CTRL-X` and hitting ENTER:
    ````
    export GUROBI_HOME="/opt/gurobi<ver>/linux64"
    export PATH="${PATH}:${GUROBI_HOME}/bin"
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib"
    export GUROBI_PATH="${GUROBI_HOME}"
    ````
    Reload your `~/.bashrc`:
    ````bash
    $ source ~/.bashrc
    ````
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px" alt="Windows"> In order to set the environment variables on Windows, please follow the instructions [here](https://www.computerhope.com/issues/ch000549.htm).

6)  <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px" alt="macOS">  <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px" alt="Linux"> Activate your license by running:
    ````
    $ grbgetkey YOUR-LICENSE-KEY-FROM-SITE
    ````
    You will be prompted
    ````
    In which directory would you like to store the Gurobi license key file?
    [hit Enter to store it in /home/<userid>]:
    ````
    Hit `ENTER`.

    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px" alt="Windows"> Browse to `Start > All Programs > Gurobi < VER> > Gurobi Interactive Shell (<ver>)`. This should prompt to enter the license key `YOUR-LICENSE-KEY-FROM-SITE`. Enter this key and hiter `ENTER`.

7)  <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px" alt="Linux"> Verify that `Gurobi` is successfully installed by launching the `Gurobi` prompt:
    ````bash
    $ gurobi.sh
    ````
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px" alt="Windows"> Browse to `Start > All Programs > Gurobi < VER> > Gurobi Interactive Shell (<ver>)`.
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px" alt="macOS">
    Browse to `/Applications`and double-click on `Gurobi<ver>` to start the Gurobi shell.

    This command should give you the prompt for `Gurobi`. Exit by entering `exit()` or hitting `CTRL-D` on your keyboard.

## MOSEK

1) Download `MOSEK` as an archive [here](https://mosek.com/resources/downloads)

2) Apply for a license [here](https://mosek.com/resources/trial-license). A free academic license is [here](https://license.mosek.com/academic/). You will receive an email with your `mosek.lic` file.

3) <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px" alt="Linux"> Save (or move) the downloaded archive `tar.bz2` to `/opt/.` (you must have superuser or `sudo` rights).
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px" alt="macOS">  Save (or move) the downloaded archive `tar.bz2` to `/Applications/.` (you must have superuser or `sudo` rights).

4) <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px" alt="macOS"> Navigate to `/opt` and extract the archive
    ````bash
    $ cd /opt
    $ tar xvjf <filename>.tar.bz2
    ````
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px" alt="Windows"> Run `moseksetupwin64x86.msi` and select `Typical` installation. This will install `mosek` in `C:\Program Files\Mosek`.
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px" alt="Linux"> Browse to `/Applications` and double-click the archive to uncompress.
    :warning: It is important to run the script `python /Applications/mosek/<ver>/tools/platform/osx64x86/bin/install.py`, which makes important updates to the installation.

5) <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px" alt="macOS"> <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px" alt="Linux"> Configure the `PATH` and `MOSEKLM_LICENSE_FILE` environment variables in `~/.bashrc` by editing your `bashrc` file
    ````bash
    $ nano ~/.bashrc
    ````
    Append the following lines, hit the `ESC` key, then save and exit by typing `CTRL-X` and hitting ENTER:
    On <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px" alt="Linux">
    ````
    export PATH=/opt/mosek/<ver>/:$PATH
    export MOSEKLM_LICENSE_FILE=/opt/mosek/
    ````
    On <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px" alt="macOS">
    ````
    export MOSEK_PATH=/Applications/mosek/<ver>
    export PATH=$MOSEK_PATH:$PATH
    export MOSEKLM_LICENSE_FILE=/Applications/mosek/
    ````
    Reload your `~/.bashrc`:
    ````bash
    $ source ~/.bashrc
    ````
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px" alt="Windows"> In order to set the environment variables on Windows, please follow the instructions [here](https://www.computerhope.com/issues/ch000549.htm).

6) <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px" alt="Linux"> Copy the license file `mosek.lic` to `/opt/mosek/`.
   <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px" alt="Windows"> Copy the license file `mosek.lic` to `C:\Users\<yourUsername>\mosek\`.
   <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px" alt="macOS">  Copy the license file `mosek.lic` to `/Applications/mosek/`.

7) <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px" alt="Linux"> Verify that `MOSEK` is correctly installed by using the following command in your terminal
    ````bash
    $ /opt/mosek/<ver>/tools/platform/linux64x86/bin/./msktestlic
    ````
    This command should give an output similar to this:
    ````
    Problem
      Name                   :
      Objective sense        : min
      Type                   : LO (linear optimization problem)
      Constraints            : 1
      Cones                  : 0
      Scalar variables       : 5000
      Matrix variables       : 0
      Integer variables      : 0

    Optimizer started.
    Mosek license manager: License path: /opt/mosek/mosek.lic
    Mosek license manager:  Checkout license feature 'PTS' from flexlm.
    Mosek license manager:  Checkout time 0.01. r: 0 status: 0
    Interior-point optimizer started.
    Presolve started.
    Eliminator started.
    Freed constraints in eliminator : 0
    Eliminator terminated.
    Eliminator - tries                  : 1                 time                   : 0.00
    Lin. dep.  - tries                  : 0                 time                   : 0.00
    Lin. dep.  - number                 : 0
    Presolve terminated. Time: 0.00
    Interior-point optimizer terminated. Time: 0.00.

    Optimizer terminated. Time: 0.02
    ************************************
    A license was checked out correctly.
    ************************************
    ````
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px" alt="Windows"> By browsing to `Start > All Programs > Mosek Optimization Tools`, you can run `Test license system`. This should open a window and display the output as shown above.
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px" alt="macOS"> In a terminal, run:
    ````bash
    $ /Applications/mosek/<ver>/tools/platform/osx64x86/bin/./msktestlic
    ````
    This should produce an output as shown above.
