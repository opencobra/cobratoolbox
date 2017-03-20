Solver Installation Guide (Linux)
---------------------------------

Tomlab
------
1) Download `TOMLAB /SNOPT` and `TOMLAB /CPLEX` from [here](http://tomopt.com/scripts/register.php)
2) In a terminal window, navigate to the download directory of tomlab and 
do the following:
````sh
$ chmod +x <filename>.bin
$ sudo ./<filename>.bin
````
3) Follow the installation instructions
4) Copy the tomlab.lic license to the folder /opt/tomlab and change its permissions:
````sh
$ sudo chmod 755 tomlab.lic
````
If you want to confirm the correct permissions:
````sh
$ stat --format '%a' <file>
````
5) In the MATLAB command window, enter: 
````matlab
>> pathtool
````
6) Click "Add with Subfolders..." and select the directory where the 
solvers were installed (/opt/tomlab).

IBM ILOG CPLEX
---------------
1) Acquire `CPLEX` installation binary from [here](https://www-01.ibm.com/software/websphere/products/optimization/cplex-studio-community-edition/)
2) Add execute permission to binary:
````sh 
$ chmod +x <cplexbinary>.bin
````
3) Execute the installer binary as superuser:
````sh
$ sudo ./<cplexbinary>.bin
````
4) Follow the installation procedure. Accept the default installation path.
5) In the MATLAB command window, enter: 
````matlab
>> pathtool
````
6) Click "Add with Subfolders..." and select 
/opt/ibm/ILOG/CPLEX_Studio<ver>/cplex/matlab.

GLPK
----
In Bash, enter:
````sh
$ sudo apt-get install python-glpk
$ sudo apt-get install glpk-utils
````

MOSEK
-----
1) Download `MOSEK` as an archive [here](https://mosek.com/resources/downloads) and save to /opt/. 
2) Apply for a licence [here](https://mosek.com/resources/trial-license)
3) You will receive an email containing your "mosek.lic" file. 
Copy the license file mosek.lic to /opt/mosek. 
Then, configure the path in ~/.bashrc:
````
export PATH=/opt/mosek/<ver>/tools/platform/linux64x86/bin/:$PATH
````
4) Navigate to the directory where the tar.bz2 was downloaded (/opt/) and 
enter in a shell to extract the archive: 
````sh
$ tar xvjf <filename>.tar.bz2
````
5) In the MATLAB command window, enter: 
````matlab
>> pathtool
````
6) Click "Add with Subfolders..." and select the directory where Mosek was 
extracted.


Gurobi
------
1) Register and log in [here](http://www.gurobi.com/)
2) Request licence from the [download center](http://www.gurobi.com/downloads/download-center) 
and retrieve YOUR-LICENCE-KEY-FROM-SITE
3) Download Gurobi optimizer from [here](http://www.gurobi.com/downloads/gurobi-optimizer)
4) In a shell, navigate to the directory where Gurobi was downloaded and 
enter:
````sh
$ tar xvzf <archive>.tar.gz
$ sudo mv gurobi<ver> /opt/.
$ cd /opt/gurobi<ver>/linux64/bin/
$ ./grbgetkey YOUR-LICENCE-KEY-FROM-SITE
````
5) You will be prompted:
````sh
In which directory would you like to store the Gurobi license key file?
[hit Enter to store it in /home/<userid>]:
````
Hit enter.

6) Install the `Gurobi` solver:
````sh
cd /opt/gurobi<ver>/linux64
sudo ./setup.py install
````

7) Edit the bash settings to include paths:
````sh
$ sudo nano ~/.bashrc
````

8) Append these lines, save and exit:
````
export GUROBI_HOME="/opt/gurobi<ver>/linux64"
export PATH="${PATH}:${GUROBI_HOME}/bin"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib"
````

9) Reboot your system and verify that `Gurobi` successfully installed:
````sh
$ cd $GUROBI_HOME/bin
$ ./gurobi.sh
````
Should give you the prompt for `Gurobi`.
Exit by entering 
````sh
$ exit()
````

One more test that can be done to ensure it's properly installed is:
````sh
$ cd $GUROBI_HOME/bin
$ ./grbprobe
````

should give something similar to:
````
HOSTNAME=...
HOSTID=...
PLATFORM=linux64
USERNAME=...
SOCKETS=...
CPU=...
````
