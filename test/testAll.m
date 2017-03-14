% define global paths
global path_GUROBI
global path_ILOG_CPLEX
global path_TOMLAB

% do not change the paths below
if ~isempty(strfind(getenv('HOME'), 'jenkins'))
    addpath(genpath('/var/lib/jenkins/MOcov'));
    addpath(genpath('/var/lib/jenkins/jsonlab'));
end

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

% enable profiler
profile on;

try
    % retrieve the models first
    retrieveModels;

    % run the tests in the subfolder verifiedTests/ recursively
    result = runtests('./test/', 'Recursively', true, 'BaseFolder', '*verified*');

    sumFailed = 0;
    sumIncomplete = 0;

    if ~isempty(strfind(getenv('HOME'), 'jenkins'))
        % write coverage based on profile('info')
        mocov('-cover','src',...
              '-profile_info',...
              '-cover_json_file','coverage.json',...
              '-cover_method', 'profile');

        for i = 1:size(result,2)
            sumFailed = sumFailed + result(i).Failed;
            sumIncomplete = sumIncomplete + result(i).Incomplete;
        end

        % load the coverage file
        data = loadjson('coverage.json', 'SimplifyCell', 1);

        sf = data.source_files;
        clFiles = zeros(length(sf), 1);
        tlFiles = zeros(length(sf), 1);

        for i = 1:length(sf)
            clFiles(i) = nnz(sf(i).coverage);
            tlFiles(i) = length(sf(i).coverage);
        end

        % average the values for each file
        cl = sum(clFiles);
        tl = sum(tlFiles);

        % print out the coverage
        fprintf('Covered Lines: %i, Total Lines: %i, Coverage: %f%%.\n', cl, tl, cl/tl * 100);
    end

    % print out a summary table
    table(result)

    if sumFailed > 0 || sumIncomplete > 0
        exit_code = 1;
    end

    % ensure that we ALWAYS call exit
    exit(exit_code);
catch
    exit(1);
end
