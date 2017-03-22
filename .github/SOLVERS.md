Solver Installation Guide (Linux)
---------------------------------

Most steps require superuser rights (`sudo`).


Tomlab
------

1) Download `TOMLAB/SNOPT` and `TOMLAB/CPLEX` from [here](http://tomopt.com/scripts/register.php)

2) In a terminal window, navigate to the download directory of tomlab and 
do the following

    ````sh
    $ chmod +x <filename>.bin
    $ sudo ./<filename>.bin
    ````

3) Follow the installation instructions

4) Copy the `tomlab.lic` license to the folder `/opt/tomlab` and change its permissions

    ````sh
    $ sudo chmod 644 tomlab.lic
    ````

    If you want to confirm the correct permissions
    ````
    $ stat --format '%a' <file>
    ````


IBM ILOG CPLEX
---------------

1) Acquire `CPLEX` installation binary from [here](https://www-01.ibm.com/software/websphere/products/optimization/cplex-studio-community-edition/)

2) Add execute permission to binary

    ````sh
    $ chmod +x <cplexbinary>.bin
    ````

3) Execute the installer binary as superuser

    ````sh
    $ sudo ./<cplexbinary>.bin
    ````

4) Follow the installation procedure. Accept the default installation path.



GLPK
----

In the terminal, enter
````sh
$ sudo apt-get install python-glpk
$ sudo apt-get install glpk-utils
````


MOSEK
-----
1) Download `MOSEK` as an archive [here](https://mosek.com/resources/downloads) and save to `/opt/.`

2) Apply for a licence [here](https://mosek.com/resources/trial-license)

3) You will receive an email containing your `mosek.lic` file

4) Copy the license file `mosek.lic` to `/opt/mosek`

5) Configure the `PATH` environment variable in `~/.bashrc` by editing your `bashrc` file

    ````sh
    $ nano ~/.bashrc
    ````
    Append the following lines, save and exit

    ````
    export PATH="/opt/mosek/<ver>/tools/platform/linux64x86/bin/:{$PATH}"
    ````

4) Navigate to the directory where the `tar.bz2` was downloaded (`/opt/`) and enter in a shell to extract the archive

    ````sh
    $ tar xvjf <filename>.tar.bz2
    ````

5) Verify that `MOSEK` is correctly installed by using the following command in Matlab:
````matlab
>> mosekdiag
````

It should give an output similar to this:
````matlab
Matlab version: 9.2.0.538062 (R2017a)
Architecture  : GLNXA64
Warning: The mosek optimizer could not be invoked from the command line. Most likely the path has not been configured
correctly. The mosek optimizer can still be invoked from the MATLAB environment. 
> In mosekdiag (line 23) 
mosekopt: /opt/mosek/8/toolbox/r2014a/mosekopt.mexa64

MOSEK Version 8.0.0.57 (Build date: 2017-2-20 11:19:46)
Copyright (c) MOSEK ApS, Denmark. WWW: mosek.com
Platform: Linux/64-X86

mosekopt is working correctly.
Warning: MOSEK Fusion is not configured correctly; check that mosek.jar is added to the javaclasspath. 
> In mosekdiag (line 72) 
````


Gurobi
------
1) Register and log in [here](http://www.gurobi.com/)

2) Request licence from the [download center](http://www.gurobi.com/downloads/download-center) and retrieve `YOUR-LICENCE-KEY-FROM-SITE`

3) Download `Gurobi` optimizer from [here](http://www.gurobi.com/downloads/gurobi-optimizer)

4) In a shell, navigate to the directory where `Gurobi` was downloaded and enter

    ````sh
    $ tar xvzf <archive>.tar.gz
    $ sudo mv gurobi<ver> /opt/.
    $ cd /opt/gurobi<ver>/linux64/bin/
    ````

5) Edit the `bash` settings to include paths

    ````sh
    $ nano ~/.bashrc
    ````

6) Append these lines, save and exit

    ````
    export GUROBI_HOME="/opt/gurobi<ver>/linux64"
    export PATH="${PATH}:${GUROBI_HOME}/bin"
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib"
    ````

7) Reload your `bashrc`

    ````sh
    $ source ~/.bashrc
    ````

8) Verify that `Gurobi` is successfully installed by activating your licence

    ````
    $ grbgetkey YOUR-LICENCE-KEY-FROM-SITE
    ````

    You will be prompted
    ````
    In which directory would you like to store the Gurobi license key file?
    [hit Enter to store it in /home/<userid>]:
    ````
    Hit enter.

9)  Verify that `Gurobi` is successfully installed by launching the `Gurobi` prompt

    ````sh
    $ gurobi.sh
    ````
    This command should give you the prompt for `Gurobi`.
    Exit by entering `exit()`.

    One more test that can be done to ensure it's properly installed is
    ````sh
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