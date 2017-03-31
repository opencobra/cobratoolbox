Solver Installation Guide
---------------------------------
<!-- TOC -->

- [Tomlab](#tomlab)
- [IBM ILOG CPLEX](#ibm-ilog-cplex)
- [MOSEK](#mosek)
- [Gurobi](#gurobi)

<!-- /TOC -->
Platform-specific instructions are marked with
- **Windows** - <img src="https://winblogs.azureedge.net/win/2016/12/cropped-cropped-Windows-logo1-192x192.png" height="20px">
- **macOS** - <img src="http://geeknrush.fr/wp-content/uploads/2015/10/Apple-Logo-Black.png" height="20px">
- **linux** - <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/35/Tux.svg/652px-Tux.svg.png" height="20px">

*Note: Most steps require superuser or administrator rights (`sudo`).*

## Tomlab

1) Download `TOMLAB/CPLEX` from [here](http://tomopt.com/scripts/register.php), where you can also download `TOMLAB/SNOPT`.

2)  <img src="http://geeknrush.fr/wp-content/uploads/2015/10/Apple-Logo-Black.png" height="20px">  <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/35/Tux.svg/652px-Tux.svg.png" height="20px"> In a terminal window, navigate to the download directory of tomlab and do the following
    ````bash
    $ chmod +x <filename>.bin
    $ sudo ./<filename>.bin
    ````
    <img src="https://winblogs.azureedge.net/win/2016/12/cropped-cropped-Windows-logo1-192x192.png" height="20px"> Run the `tomlab-win64-setup_<ver>.exe` as an administrator.

3) Follow the installation instructions and install `tomlab` in:
    - <img src="http://geeknrush.fr/wp-content/uploads/2015/10/Apple-Logo-Black.png" height="20px">  <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/35/Tux.svg/652px-Tux.svg.png" height="20px">: `/opt` such that you will have a folder `/opt/tomlab`.
    - <img src="https://winblogs.azureedge.net/win/2016/12/cropped-cropped-Windows-logo1-192x192.png" height="20px"> : `C:\` such that you will have a folder `C:\tomlab`


4) <img src="http://geeknrush.fr/wp-content/uploads/2015/10/Apple-Logo-Black.png" height="20px">  <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/35/Tux.svg/652px-Tux.svg.png" height="20px"> Copy the `tomlab.lic` license to the folder `/opt/tomlab` and change its permissions

    ````bash
    $ sudo chmod 644 tomlab.lic
    ````

    If you want to confirm the correct permissions
    ````bash
    $ stat --format '%a' <file>
    ````
    <img src="https://winblogs.azureedge.net/win/2016/12/cropped-cropped-Windows-logo1-192x192.png" height="20px"> Copy the `tomlab.lic` license to the folder `C:\tomlab`.

## IBM ILOG CPLEX

1) Download the `CPLEX` installation binary from [here](https://www-01.ibm.com/software/websphere/products/optimization/cplex-studio-community-edition/)

2) <img src="http://geeknrush.fr/wp-content/uploads/2015/10/Apple-Logo-Black.png" height="20px">  <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/35/Tux.svg/652px-Tux.svg.png" height="20px"> Add `execute` permission to binary

    ````bash
    $ chmod +x <cplexbinary>.bin
    ````

3) <img src="http://geeknrush.fr/wp-content/uploads/2015/10/Apple-Logo-Black.png" height="20px">  <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/35/Tux.svg/652px-Tux.svg.png" height="20px"> Run the installer binary as superuser, follow the installation procedure, and accept the default installation path.

    ````bash
    $ sudo ./<cplexbinary>.bin
    ````

    <img src="https://winblogs.azureedge.net/win/2016/12/cropped-cropped-Windows-logo1-192x192.png" height="20px"> Run `cplex_studio<ver>.win-x86-64.exe` as an administrator. Follow the installation instructions and install `CPLEX` in `C:\Program Files\IBM\ILOG\CPLEX_Studio<ver>`.

    ![#ff0000](https://placehold.it/15/ff0000/000000?text=+) Make sure that you select `Yes, update the PATH variable.`. You can also follow the instructions [here](https://www.ibm.com/support/knowledgecenter/SSSA5P_12.6.1/ilog.odms.cplex.help/CPLEX/GettingStarted/topics/set_up/Windows.html).


## MOSEK

1) Download `MOSEK` as an archive [here](https://mosek.com/resources/downloads) and save to `/opt/.`

2) Apply for a license [here](https://mosek.com/resources/trial-license). A free academic license is [here](https://license.mosek.com/academic/).

3) You will receive an email with your `mosek.lic` file.

4) Copy the license file `mosek.lic` to `/opt/mosek/`

5) Navigate to the directory where the `tar.bz2` was downloaded (`/opt/`) and enter in a shell to extract the archive

    ````bash
    $ tar xvjf <filename>.tar.bz2
    ````

6) Configure the `PATH` and `MOSEKLM_LICENSE_FILE` environment variables in `~/.bashrc` by editing your `bashrc` file

    ````bash
    $ nano ~/.bashrc
    ````
    Append the following lines (type `i` to insert text), hit the `ESC` key, then save and exit by typing `wq` and hitting ENTER:

    ````
    export PATH="/opt/mosek/<ver>/":${PATH}
    export MOSEKLM_LICENSE_FILE="/opt/mosek/"
    ````

7) Reload your `bashrc`

    ````bash
    $ source ~/.bashrc
    ````

8) Verify that `MOSEK` is correctly installed by using the following command in your terminal

    ````sh
    $ msktestlic
    ````

    It should give an output similar to this:
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


## Gurobi

1) Register and log in [here](http://www.gurobi.com/)

2) Request license from the [download center](http://www.gurobi.com/downloads/download-center) and retrieve `YOUR-LICENSE-KEY-FROM-SITE`

3) Download `Gurobi` optimizer from [here](http://www.gurobi.com/downloads/gurobi-optimizer)

4) In a shell, navigate to the directory where `Gurobi` was downloaded and enter

    ````bash
    $ tar xvzf <archive>.tar.gz
    $ sudo mv gurobi<ver> /opt/.
    $ cd /opt/gurobi<ver>/linux64/bin/
    ````

5) Edit the `bash` settings to include paths

    ````bash
    $ nano ~/.bashrc
    ````

6) Append the following lines (type `i` to insert text), hit the `ESC` key, then save and exit by typing `wq` and hitting ENTER:

    ````
    export GUROBI_HOME="/opt/gurobi<ver>/linux64"
    export PATH="${PATH}:${GUROBI_HOME}/bin"
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib"
    ````

7) Reload your `bashrc`

    ````bash
    $ source ~/.bashrc
    ````

8) Verify that `Gurobi` is successfully installed by activating your license

    ````
    $ grbgetkey YOUR-LICENSE-KEY-FROM-SITE
    ````

    You will be prompted
    ````
    In which directory would you like to store the Gurobi license key file?
    [hit Enter to store it in /home/<userid>]:
    ````
    Hit enter.

9) Verify that `Gurobi` is successfully installed by launching the `Gurobi` prompt

    ````bash
    $ gurobi.sh
    ````
    This command should give you the prompt for `Gurobi`. Exit by entering `exit()` or hitting `CTRL-D` on your keyboard.

    One more test that can be done to ensure it's properly installed is
    ````bash
    $ grbprobe
    ````

    should give something similar to
    ````
    HOSTNAME=...
    HOSTID=...
    PLATFORM=linux64
    USERNAME=...
    SOCKETS=...
    CPU=...
    ````
