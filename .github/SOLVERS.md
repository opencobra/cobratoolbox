Solver Installation Guide
---------------------------------
<!-- TOC -->

- [TOMLAB](#tomlab)
- [IBM ILOG CPLEX](#ibm-ilog-cplex)
- [GUROBI](#gurobi)
- [MOSEK](#mosek)
<!-- /TOC -->
Platform-specific instructions are marked with
- **Windows** - <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px">
- **macOS** - <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px">
- **linux** - <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px">

*Note: Most steps require superuser or administrator rights (`sudo`).*

## TOMLAB

1) Download `TOMLAB/CPLEX` from [here](http://tomopt.com/scripts/register.php), where you can also download `TOMLAB/SNOPT`.

2)  <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px">  <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px"> In a terminal window, navigate to the download directory of tomlab and do the following
    ````bash
    $ chmod +x <filename>.bin
    $ sudo ./<filename>.bin
    ````
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px"> Run the `tomlab-win64-setup_<ver>.exe` as an administrator.

3) Follow the installation instructions and install `tomlab` in:
    - <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px">  <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px">: `/opt` such that you will have a folder `/opt/tomlab`.
    - <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px"> : `C:\` such that you will have a folder `C:\tomlab`

4) <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px">  <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px"> Copy the `tomlab.lic` license to the folder `/opt/tomlab` and change its permissions
    ````bash
    $ sudo chmod 644 tomlab.lic
    ````
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px"> Copy the `tomlab.lic` license to the folder `C:\tomlab`.

5) <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px">  <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px"> Set the environment variable by editing your '~/.bashrc' file:
    ````bash
    $ nano ~/.bashrc
    ````
    Append the following lines (type `i` to insert text), hit the `ESC` key, then save and exit by typing `wq` and hitting ENTER:
    ````
    export TOMLAB_PATH="/opt/tomlab"
    ````
    Reload your `~/.bashrc`:
    ````bash
    $ source ~/.bashrc
    ````

## IBM ILOG CPLEX

1) Download the `CPLEX` installation binary from [here](https://www-01.ibm.com/software/websphere/products/optimization/cplex-studio-community-edition/)

2) <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px">  <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px"> Add `execute` permission to binary
    ````bash
    $ chmod +x <cplexbinary>.bin
    ````

3) <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px">  <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px"> Run the installer binary as superuser, follow the installation procedure, and accept the default installation path.
    ````bash
    $ sudo ./<cplexbinary>.bin
    ````
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px"> Run `cplex_studio<ver>.win-x86-64.exe` as an administrator. Follow the installation instructions and install `CPLEX` in `C:\Program Files\IBM\ILOG\CPLEX_Studio<ver>`.

4) <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px">  <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px"> Set the environment variable by editing your `~/.bashrc` file:
    ````bash
    $ nano ~/.bashrc
    ````
    Append the following lines (type `i` to insert text), hit the `ESC` key, then save and exit by typing `wq` and hitting ENTER:
    ````
    export ILOG_CPLEX_PATH="/opt/ibm/ILOG/CPLEX_Studio<ver>"
    ````
    Reload your `~/.bashrc`:
    ````bash
    $ source ~/.bashrc
    ````
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px"> ![#ff0000](https://placehold.it/15/ff0000/000000?text=+) Make sure that you select `Yes, update the PATH variable.`. You can also follow the instructions [here](https://www.ibm.com/support/knowledgecenter/SSSA5P_12.6.1/ilog.odms.cplex.help/CPLEX/GettingStarted/topics/set_up/Windows.html).

## GUROBI

1) Register and log in [here](http://www.gurobi.com/)

2) Request license from the [download center](http://www.gurobi.com/downloads/download-center) and retrieve `YOUR-LICENSE-KEY-FROM-SITE`

3) Download the `Gurobi` optimizer from [here](http://www.gurobi.com/downloads/gurobi-optimizer)

4) <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px">  <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px"> Navigate to the directory where `Gurobi` was downloaded and enter
    ````bash
    $ tar xvzf <archive>.tar.gz
    $ sudo mv gurobi<ver> /opt/.
    $ cd /opt/gurobi<ver>/linux64/bin/
    ````
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px"> Run `Gurobi-<ver>-win64.msi` and follow the installation instructions. Accept the default path `C:\gurobi<ver>\`.

5) <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px">  <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px"> Edit the `bash` settings to include paths
    ````bash
    $ nano ~/.bashrc
    ````
    Append the following lines (type `i` to insert text), hit the `ESC` key, then save and exit by typing `wq` and hitting ENTER:
    ````
    export GUROBI_HOME="/opt/gurobi<ver>/linux64"
    export PATH="${PATH}:${GUROBI_HOME}/bin"
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib"
    ````
    Reload your `~/.bashrc`:
    ````bash
    $ source ~/.bashrc
    ````

6)  <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px">  <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px"> Activate your license by running:
    ````
    $ grbgetkey YOUR-LICENSE-KEY-FROM-SITE
    ````
    You will be prompted
    ````
    In which directory would you like to store the Gurobi license key file?
    [hit Enter to store it in /home/<userid>]:
    ````
    Hit `ENTER`.

    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px"> Browse to `Start > All Programs > Gurobi < VER> > Gurobi Interactive Shell (<ver>)`. This should prompt to enter the license key `YOUR-LICENSE-KEY-FROM-SITE`. Enter this key and hiter `ENTER`.

7)  <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px">  <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px"> Verify that `Gurobi` is successfully installed by launching the `Gurobi` prompt:
    ````bash
    $ gurobi.sh
    ````
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px"> Browse to `Start > All Programs > Gurobi < VER> > Gurobi Interactive Shell (<ver>)`.

    This command should give you the prompt for `Gurobi`. Exit by entering `exit()` or hitting `CTRL-D` on your keyboard.

## MOSEK

1) Download `MOSEK` as an archive [here](https://mosek.com/resources/downloads)

2) Apply for a license [here](https://mosek.com/resources/trial-license). A free academic license is [here](https://license.mosek.com/academic/). You will receive an email with your `mosek.lic` file.

3) <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px">  <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px"> Save (or move) the downloaded archive `tar.bz2` to `/opt/.`

4) <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px">  <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px"> Navigate to `/opt` and extract the archive
    ````bash
    $ cd /opt
    $ tar xvjf <filename>.tar.bz2
    ````
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px"> Run `moseksetupwin64x86.msi` and select `Typical` installation. This will install `mosek` in `C:\Program Files\Mosek`.

5) Configure the `PATH` and `MOSEKLM_LICENSE_FILE` environment variables in `~/.bashrc` by editing your `bashrc` file
    ````bash
    $ nano ~/.bashrc
    ````
    Append the following lines (type `i` to insert text), hit the `ESC` key, then save and exit by typing `wq` and hitting ENTER:
    ````
    export PATH="/opt/mosek/<ver>/":${PATH}
    export MOSEKLM_LICENSE_FILE="/opt/mosek/"
    ````
    Reload your `~/.bashrc`:
    ````bash
    $ source ~/.bashrc
    ````

6) <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px">  <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px"> Copy the license file `mosek.lic` to `/opt/mosek/`.
   <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px"> Copy the license file `mosek.lic` to `C:\Users\<yourUsername>\mosek\`.

7) <img src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" height="20px">  <img src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" height="20px"> Verify that `MOSEK` is correctly installed by using the following command in your terminal
    ````sh
    $ msktestlic
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
    <img src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" height="20px"> By browsing to `Start > All Programs > Mosek Optimization Tools`, you can run `Test license system`. This should open a window and display the output as shown above.
