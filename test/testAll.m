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
    % change the directory to the root
    cd([fileparts(which(mfilename)), filesep, '..', filesep]);

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

if ~isempty(strfind(getenv('HOME'), 'jenkins'))
    % check the code quality
    listFiles = rdir(['./src', '/**/*.m']);

    % count the number of failed code quality checks per file
    nMsgs = 0;
    nCodeLines = 0;
    nEmptyLines = 0;
    nCommentLines = 0;

    for i = 1:length(listFiles)
        nMsgs = nMsgs + length(checkcode(listFiles(i).name));

        fid = fopen(listFiles(i).name);
        res = {};
        while ~feof(fid)
            lineOfFile = strtrim(fgetl(fid));
            if length(lineOfFile) > 0 && length(strfind(lineOfFile(1), '%')) ~= 1  ...
               && length(strfind(lineOfFile, 'end')) ~= 1 && length(strfind(lineOfFile, 'otherwise')) ~= 1 ...
               && length(strfind(lineOfFile, 'switch')) ~= 1 && length(strfind(lineOfFile, 'else')) ~= 1  ...
               && length(strfind(lineOfFile, 'case')) ~= 1 && length(strfind(lineOfFile, 'function')) ~= 1

                res{end+1, 1} = lineOfFile;

            elseif length(lineOfFile) == 0
                nEmptyLines = nEmptyLines + 1;

            elseif length(strfind(lineOfFile(1), '%')) == 1
                nCommentLines = nCommentLines + 1;
            end
        end
        fclose(fid);
        nCodeLines = nCodeLines + numel(res);
    end

    % average number of messages per codeLines
    avMsgsPerc = floor(nMsgs / nCodeLines * 100 );

    grades = {'A', 'B', 'C', 'D', 'E', 'F'};
    intervals = [0, 3;
                 3, 6;
                 6, 9;
                 9, 12;
                 12, 15;
                 15, 100];

    grade = 'F';
    for i = 1:length(intervals)
        if avMsgsPerc >= intervals(i, 1) && avMsgsPerc < intervals(i, 2)
            grade = grades{i};
        end
    end

    % remove the old badge
    system('rm /var/lib/jenkins/userContent/codegrade.svg');

    % set the new badge
    system(['cp /var/lib/jenkins/userContent/codegrade-', grade, '.svg /var/lib/jenkins/userContent/codegrade.svg']);
end

try
    % retrieve the models first
    retrieveModels;

    % run the tests in the subfolder serialTests/ recursively and in parallel
    if verLessThan('matlab', '8.5') % < 2015
        resultSerial = runtests('./test/', 'Recursively', true, 'BaseFolder', '*serial*');
    else
        resultSerial = runtests('./test/', 'Recursively', true, 'BaseFolder', '*serial*', 'UseParallel', true);
    end

    % run the tests in the subfolder parallelTests/ recursively and in series
    resultParallel = runtests('./test/', 'Recursively', true, 'BaseFolder', '*parallel*');

    % close all open figures
    close all

    sumFailed = 0;
    sumIncomplete = 0;

    if ~isempty(strfind(getenv('HOME'), 'jenkins'))
        % write coverage based on profile('info')
        mocov('-cover','src',...
              '-profile_info',...
              '-cover_json_file','coverage.json',...
              '-cover_method', 'profile');

        for i = 1:size(resultSerial,2)
            sumFailed = sumFailed + resultSerial(i).Failed;
            sumIncomplete = sumIncomplete + resultSerial(i).Incomplete;
        end

        for i = 1:size(resultParallel,2)
            sumFailed = sumFailed + resultParallel(i).Failed;
            sumIncomplete = sumIncomplete + resultParallel(i).Incomplete;
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

    % print out a summary table (serial)
    fprintf('Summary table of tests run sequentially.\n')
    table(resultSerial)

    % print out a summary table (parallel)
    fprintf('Summary table of tests run in parallel.\n')
    table(resultParallel)

    if sumFailed > 0 || sumIncomplete > 0
        exit_code = 1;
    end

    % ensure that we ALWAYS call exit
    exit(exit_code);
catch
    exit(1);
end
