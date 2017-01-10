% These are the Von Bertylanffy DEPENDENCIES
% The COBRA toolbox: Freely available at
% https://github.com/opencobra/cobratoolbox
% which includes the component contribution method
% https://github.com/opencobra/cobratoolbox/thermo/
% 
% Python 2: Freely available at http://www.python.org/download/
% 
% Numpy: Freely available at
% http://sourceforge.net/projects/numpy/files/NumPy/
% 
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
%
% Open Babel and Python bindings: Freely available at
% http://openbabel.org/wiki/Get_Open_Babel
% In linux, these are the openbabel and python-openbabel packages

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
[status,groupsTemp] = system('python2 --version');
if status~=0
    error('python2 should be installed')
end

%setenv('PATH', [getenv('PATH') ':/opt/ChemAxon/MarvinBeans/bin/'])

%test if call to cxcalc works
[status,result] = system('cxcalc');
if status ~= 0
    setenv('PATH', [getenv('PATH') ':/opt/ChemAxon/MarvinBeans/bin/'])
    setenv('CHEMAXON_LICENSE_URL',[getenv('HOME') '/.chemaxon/license.cxl'])
    [status,result] = system('cxcalc');
    if status ~= 0
        error('Check that ChemAxon Marvin Beans is installed, licence is working and cxcalc is on the system path.')
    end
end

%check if call to babel works
[status,result] = system('babel');
if status ~= 0
    error('Check that OpenBabel is installed and on the system path.')
end

%Setup Babel
%libstdc++.so.6 must be the system one, not the one in Matlab's path, so we
%have to edit the 'LD_LIBRARY_PATH' to make sure that it has the correct
%system path before the Matlab path! The solution will be arch dependent

%This is what works on Ubuntu 15.10 - paste it into your startup file
%setenv('LD_LIBRARY_PATH',['/home/rfleming/work/ownCloud/code/Chemaxon/bin/bin/:/usr/lib/x86_64-linux-gnu:' getenv('LD_LIBRARY_PATH')])
