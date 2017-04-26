% define global paths
global GUROBI_PATH
global ILOG_CPLEX_PATH
global TOMLAB_PATH

% include the root folder and all subfolders
addpath(genpath(pwd))

if length(which('initCobraToolbox.m')) == 0
    % define the path to The COBRA Toolbox
    pth = which('testAll.m');
    CBTDIR = pth(1:end-(length('testAll.m') + 1));

    % change the directory to the root
    cd([CBTDIR, filesep, '..', filesep]);

    % include the root folder and all subfolders
    addpath(genpath(pwd));
end

% run the official initialisation script
initCobraToolbox

if ~isempty(strfind(getenv('HOME'), 'jenkins'))
    WAITBAR_TYPE = 0;
else
    WAITBAR_TYPE = 1;
end

% define a success exit code
exit_code = 0;

try
    % retrieve the models first
    retrieveModels;

    % run an example of sparseLP
    changeCobraSolver('glpk')
    sparseLP_example;
    uniformSampling;

    % ensure that we ALWAYS call exit
    exit(exit_code);
catch
    exit(1);
end
