# Installation instructions - vonBertalanffy
(Suitable for UNIX-based computers)

First, begin by installing all the necessary dependencies. At the time of writing this, the following were used:

 * Ubuntu 16.04 LTS (or newer)

 * Python 2.7

 * NumPy 1.11.1

 * ChemAxon MarvinBeans 17.28.0

 * OpenBabel 2.3

The following commands are entered in a *terminal window (bash or similar  shell)*.

### Python 2
OpenBabel only works with Python 2. Most distributions should already have
this installed, but if this is not the case, please refer to the installation specific for your system.

### NumPy
NumPy can be installed using the following commands:
```
 pip install NumPy --user
```
In case it is not enough this is an alternative way:
```
 sudo apt-get install python-dev
 sudo apt-get install python-setuptool
 sudo wget http://downloads.sourceforge.net/project/numpy/NumPy/1.11.1/numpy-1.11.1.tar.gz  
 sudo tar -xzvf numpy-1.11.1.tar.gz
 cd numpy-1.11.1  
 sudo python setup.py build -j 4 install
```
Alternatively, Numpy is freely available at
http://sourceforge.net/projects/numpy/files/NumPy/

### Sun Java
In order not to get issues with the add-apt-repository command, install the following package if Java 8 is not already installed on your machine:
```
 sudo apt-get install software-properties-common
```
Add the PPA:
```
 sudo add-apt-repository ppa:webupd8team/java
```
 Update the repo index:
```
 sudo apt-get update
```
 Install Java 8:
```
 sudo apt-get install oracle-java8-installer
```
Alternatively, https://java.com/en/download/

### ChemAxon Calculator Plugin
ChemAxon calculator plugin requires a license. Apply for an academic license.

After your license has been made available, you can download from the “My
Licenses” tab on the ChemAxon website.

Download the license and place it under (replace <user> by your actual user account):
```
 /home/<user>/.chemaxon
```
Download Marvin for Linux fromn https://www.chemaxon.com/products/marvin/download, avigate to the directory where it was
saved and make it executable (here, we downloaded version 17.28.0 - use the
appropriate filename for your version):  
```
 sudo chmod +x Marvin_linux_17.28.0.deb
```
Execute the installer (again, use the same filename as above):
```
 sudo dpkg -i for Marvin_linux_17.28.0.deb
```
It will install automatically to this directory:  
```
 /opt/chemaxon/
```
This is important, since this is the path used by COBRA Toolbox.

Finally, add the installation path to the PATH environment variable:
```
 export PATH=$PATH:/opt/chemaxon/marvinsuite/bin/
 source ~/.profile
```
Test the installation by trying to at a system terminal: cxcalc
Then you should get something like the following output:
Calculator, (C) 1998-2017 ChemAxon Ltd.
version 17.28.0
Licenses of additionally used third party programs can be found in license.html
Online version: http://www.chemaxon.com/marvin/license.html
Runs various molecule calculations: charge, pKa, logP, etc.

For more info, see:
ChemAxon's cxcalc, with licence, which is part of Marvin Beans

ChemAxon Marvin Beans download
https://www.chemaxon.com/download/marvin-suite/#mbeans

ChemAxon Marvin Beans installation - all platforms
https://docs.chemaxon.com/display/docs/Installation+MS#InstallationMS-MarvinBeansforJava

ChemAxon Marvin Beans installation - linux
https://docs.chemaxon.com/display/docs/Installation+MS#InstallationMS-Linux/SolarisLinux/Solaris

ChemAxon Marvin Beans cxcalc - about
https://docs.chemaxon.com/display/CALCPLUGS/cxcalc+command+line+tool

ChemAxon Free academic license - available from
http://www.chemaxon.com/my-chemaxon/my-academic-license/

ChemAxon Free academic license - installation
https://marvin-demo.chemaxon.com/marvin/help/licensedoc/installToDesktop.html#gui

 ### OpenBabel and Python bindings  
Install the OpenBabel and Python 2 bindings by entering the following:
```
 sudo apt-get install openbabel  
 sudo apt-get install python-openbabel
```
Alternatively, Open Babel and Python bindings: http://openbabel.org/wiki/Get_Open_Babel
