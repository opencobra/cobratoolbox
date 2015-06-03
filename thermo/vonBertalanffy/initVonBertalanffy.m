% Setup the paths to the data, scripts and functions

% Clear workspace
clear

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

