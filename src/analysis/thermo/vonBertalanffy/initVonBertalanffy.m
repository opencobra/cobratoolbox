% All the installation instructions are in a separate .md file named vonBertalanffy.md in docs/source/installation
% Setup the paths to the data, scripts and functions
% Check if this COBRA toolbox extension is in the Matlab path
stm_dir = which('setupThermoModel.m');
cc_dir = which('addThermoToModel.m');

% test if call to python2 works
[status,result] = system('python2 --version');
if status~=0
    disp(result)
    error('python2 should be installed')
end

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

%check if call to obabel works
[status,result] = system('ldd /usr/bin/obabel');
if ~isempty(strfind(result,'MATLAB'))
    disp(result)
    fprintf('%s\n','obabel must depend on the system libstdc++.so.6 not the one from MATLAB')
    fprintf('%s\n','Trying to edit the ''LD_LIBRARY_PATH'' to make sure that it has the correct system path before the Matlab path!')
    setenv('LD_LIBRARY_PATH',['/usr/lib/x86_64-linux-gnu:' getenv('LD_LIBRARY_PATH')]);
    fprintf('%s\n','The solution will be arch dependent');
end

[status,result] = system('obabel');
if status ~= 0
    setenv('LD_LIBRARY_PATH',['/usr/lib/x86_64-linux-gnu:' getenv('LD_LIBRARY_PATH')]);
end

[status,result] = system('obabel');
if status ~= 0
    error('Check that OpenBabel is installed and on the system path.')
end

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
