% First, begin by installing all the necessary dependencies. At the time 
% of writing this, the following were used:
% 
% *Ubuntu 16.04 LTS*
% 
% *Python 2.7*
% 
% *NumPy 1.11.1*
% 
% *ChemAxon MarvinBeans 16.9.5.0*
% 
% *OpenBabel 2.3*
% 
% The following commands are entered in a *terminal window (bash or similar  shell)*.

%% Python 2 
% OpenBabel only works with Python 2. Most distributions should already have 
% this installed, but if this is not the case, the following lines will do it: 
% 
% sudo add-apt-repository ppa:fkrull/deadsnakes  
% 
% sudo apt-get update  
% 
% sudo apt-get install python2.7
%
% Alternatively, Python 2 is freely available at http://www.python.org/download/

%% NumPy 
% NumPy can be installed using the following commands: 
% 
% sudo apt-get install python-dev 
% 
% sudo apt-get install python-setuptools 
% 
% sudo wget http://downloads.sourceforge.net/project/numpy/NumPy/1.11.1/numpy-1.11.1.tar.gz  
% 
% sudo tar -xzvf numpy-1.11.1.tar.gz 
% 
% cd numpy-1.11.1  
% 
% sudo python setup.py build -j 4 install 
%
% Alternatively, Numpy is freely available at 
% http://sourceforge.net/projects/numpy/files/NumPy/

%% Sun Java
% In order not to get issues with the add-apt-repository command, install the following package:
% 
% $ sudo apt-get install software-properties-common
% 
% Add the PPA:
% 
% $ sudo add-apt-repository ppa:webupd8team/java
% 
% Update the repo index:
% 
% $ sudo apt-get update
% 
% Install Java 8:
% 
% $ sudo apt-get install oracle-java8-installer
% 
% Alternatively, https://java.com/en/download/

%% ChemAxon Calculator Plugin 
% ChemAxon calculator plugin requires a license. Apply for an academic license 
% at the following link: http://www.chemaxon.com/my-chemaxon/my-academic-license/ 
% 
% After your license has been made available, you can download from the “My 
% Licenses” tab on the ChemAxon website. 
% 
% Download the license and place it under (replace USER by your actual user 
% account): 
% 
% /home/USER/.chemaxon 
% 
% Download MarvinBeans for Linux, navigate to the directory where it was 
% saved and make it executable (here, we downloaded version 16.9.5.0 - use the 
% appropriate filename for your version):  
% 
% sudo chmod +x marvinbeans-16.9.5.0-linux_with_jre64.sh  
% 
% Execute the installer (again, use the same filename as above): 
% 
% sudo ./marvinbeans-16.9.5.0-linux_with_jre64.sh 
% 
% When asked for an installation directory, make it:  
% 
% /opt/ChemAxon/MarvinBeans 
% 
% This is important, since this is the path used by COBRA Toolbox. 
% 
% Finally, add the installation path to the PATH environment variable: 
% 
% PATH=$PATH:/opt/ChemAxon/MarvinBeans/bin 
% 
% sudo export PATH
%
% Test the installation by trying to at a system terminal: cxcalc
% Then you should get something like the following output:
% Calculator, (C) 1998-2016 ChemAxon Ltd.
% version 16.5.23.0
% Licenses of additionally used third party programs can be found in license.html
% Online version: http://www.chemaxon.com/marvin/license.html
% Runs various molecule calculations: charge, pKa, logP, etc.
% 
% For more info, see:
% ChemAxon's cxcalc, with licence, which is part of Marvin Beans
% ChemAxon Marvin Beans download
% https://www.chemaxon.com/download/marvin-suite/#mbeans
% ChemAxon Marvin Beans installation - all platforms
% https://docs.chemaxon.com/display/docs/Installation+MS#InstallationMS-MarvinBeansforJava
% ChemAxon Marvin Beans installation - linux
% https://docs.chemaxon.com/display/docs/Installation+MS#InstallationMS-Linux/SolarisLinux/Solaris
% ChemAxon Marvin Beans cxcalc - about
% https://docs.chemaxon.com/display/CALCPLUGS/cxcalc+command+line+tool
% ChemAxon Marvin Beans cxcalc - installation
% ChemAxon Free academic license - available from 
% http://www.chemaxon.com/my-chemaxon/my-academic-license/
% ChemAxon Free academic license - installation
% https://marvin-demo.chemaxon.com/marvin/help/licensedoc/installToDesktop.html#gui
 
%% OpenBabel and Python bindings  
% Install the OpenBabel and Python 2 bindings by entering the following: 
% 
% sudo apt-get install openbabel  
% 
% sudo apt-get install python-openbabel
%
% Alternatively, Open Babel and Python bindings: http://openbabel.org/wiki/Get_Open_Babel

%% With all dependencies installed correctly, we configure our environment.

% Setup the paths to the data, scripts and functions
% Check if this COBRA toolbox extension is in the Matlab path
stm_dir = which('setupThermoModel.m');
cc_dir = which('addThermoToModel.m');

% Add extension to path if it is not already there
if isempty(stm_dir) || isempty(cc_dir)
    vonB_dir = pwd;
    
    c = {'ComponentContribution'; 'SetupThermoModel'; 'testing'}; % Check that current directory contains all necessary subdirectories
    d = dir;
    c_test = {d.name}';
    
    if all(ismember(c,c_test))
        addpath(genpath(vonB_dir)); % Add to path
        savepath; % Save new path
    else
        error(['Current directory must be */vonBertalanffy, which should contain the following files and directories:\n' sprintf('%s\n',c{:})]);
    end
end

% test if call to python2 works
[status,result] = system('python2 --version');
if status~=0
    disp(result)
    error('python2 should be installed')
end

%setenv('PATH', [getenv('PATH') ':/opt/ChemAxon/MarvinBeans/bin/'])

%test if call to cxcalc works
[status,result] = system('cxcalc');
if status ~= 0
    if status==127
        disp(result)
        error('Check that ChemAxon Marvin Beans is working licence is working and cxcalc is on the system path.')
    else
        disp(result)
        setenv('PATH', [getenv('PATH') ':/usr/local/bin/chemaxon/bin'])%RF
        setenv('PATH', [getenv('PATH') ':/opt/ChemAxon/MarvinBeans/bin/'])
        setenv('CHEMAXON_LICENSE_URL',[getenv('HOME') '/.chemaxon/license.cxl'])
        [status,result] = system('cxcalc');
        if status ~= 0
            disp(result)
            error('Check that ChemAxon Marvin Beans is installed, licence is working and cxcalc is on the system path.')
        end
    end
end

%check if call to babel works
[status,result] = system('babel');
if status ~= 0
    error('Check that OpenBabel is installed and on the system path.')
end

[status,result] = system('ldd /usr/bin/babel');
if ~isempty(strfind(result,'MATLAB'))
    disp(result)
    fprintf('%s\n','babel must depend on the system libstdc++.so.6 not the one from MATLAB')
    fprintf('%s\n','Trying to edit the ''LD_LIBRARY_PATH'' to make sure that it has the correct system path before the Matlab path!')
    setenv('LD_LIBRARY_PATH',['/usr/lib/x86_64-linux-gnu:' getenv('LD_LIBRARY_PATH')]);
    fprintf('%s\n','The solution will be arch dependent');
end

