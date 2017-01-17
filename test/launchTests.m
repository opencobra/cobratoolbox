% do not change the paths below
addpath(genpath('/var/lib/jenkins/MOcov'))
addpath(genpath('/var/lib/jenkins/jsonlab'))
addpath(genpath(pwd)) % include the root folder and all subfolders

% add GUROBI
addpath(genpath('/opt/gurobi650'))

% add CPLEX
addpath(genpath('/opt/ibm/ILOG/CPLEX_Studio1263'))

% add TOMLAB interface
addpath(genpath('/opt/tomlab'))

% run the official initialisation script
%initCobraToolbox
%{
% run the official testsuite
testAll
%}

exit_code = 0;

% enable profiler
profile on;

try

    result = runtests('./test/', 'Recursively', true, 'BaseFolder', '*verified*');

    % write coverage based on profile('info')
    mocov('-cover','src',...
          '-profile_info',...
          '-cover_json_file','coverage.json',...
          '-cover_method', 'profile');

    sumFailed = 0;
    sumIncomplete = 0;

    for i = 1:size(result,2)
        sumFailed = sumFailed + result(i).Failed;
        sumIncomplete = sumIncomplete + result(i).Incomplete;
    end

    data = loadjson('coverage.json', 'SimplifyCell', 1);

    sf = data.source_files;
    clFiles = [];
    tlFiles = [];

    for i = 1:length(sf)
        clFiles(i) = nnz(sf(i).coverage);
        tlFiles(i) = length(sf(i).coverage);
    end

    % average the values for each file
    cl = sum(clFiles);
    tl = sum(tlFiles);

    % print out a summary table
    rt = table(result)

    % print out the coverage as requested by gitlab
    fprintf('Covered Lines: %i, Total Lines: %i, Coverage: %f%%.\n', cl, tl, cl/tl * 100);

    if sumFailed > 0 || sumIncomplete > 0
        exit_code = 1
    end

    % ensure that we ALWAYS call exit
    exit(exit_code);

catch
  exit(1);
end
