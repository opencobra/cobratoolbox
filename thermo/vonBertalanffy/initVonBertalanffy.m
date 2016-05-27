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



%Setup Babel
%libstdc++.so.6 must be the system one, not the one in Matlab's path, so we
%have to edit the 'LD_LIBRARY_PATH' to make sure that it has the correct
%system path before the Matlab path! The solution will be arch dependent

%This is what works on Ubuntu 15.10 - paste it into your startup file
setenv('LD_LIBRARY_PATH',['/home/rfleming/work/ownCloud/code/Chemaxon/bin/bin/:/usr/lib/x86_64-linux-gnu:' getenv('LD_LIBRARY_PATH')])

