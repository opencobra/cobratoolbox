% define global paths
global CBTDIR
global GUROBI_PATH
global ILOG_CPLEX_PATH
global TOMLAB_PATH

fprintf('The COBRAToolbox testing suite\n')
fprintf('------------------------------\n')
setenv('MOCOV_PATH','/home/thomas/cobra_devel/MOcov');
setenv('JSONLAB_PATH','/home/thomas/cobra_devel/jsonlab-1.5');
if ~isempty(getenv('MOCOV_PATH')) && ~isempty(getenv('JSONLAB_PATH'))
    addpath(genpath(getenv('MOCOV_PATH')))
    addpath(genpath(getenv('JSONLAB_PATH')))
    COVERAGE = true;
    fprintf('MoCov and JsonLab are on path, coverage will be computed.\n')
else
    COVERAGE = false;
end

% Save the folder we were in.
origDir = pwd;

% if the location of initCobraToolbox is not yet known
if length(which('initCobraToolbox.m')) == 0
    % define the path to The COBRA Toolbox
    pth = fileparts(which('testAll.m'));
    % Now, we are in the test folder
    cd(pth)
    % Switch to the base folder
    cd ..
    % And assign the CBTDIR variable
    CBTDIR = pwd;
else
    CBTDIR = fileparts(which('initCobraToolbox.m'));
    cd(CBTDIR);
end

% include the root folder and all subfolders.
addpath(genpath([pwd filesep 'test']));

% change to the root folder of The COBRA TOolbox
cd(CBTDIR);

% run the official initialisation script
initCobraToolbox;

%Init the cleanup:
currentDir = cd('test');
testDirContent = getFilesInDir('type','all'); %Get all currently present files in the folder.
testDirPath = pwd;
cd(currentDir);


if ~isempty(strfind(getenv('HOME'), 'jenkins')) || ~isempty(strfind(getenv('USERPROFILE'), 'jenkins'))
    WAITBAR_TYPE = 0;

    % add CellNetAnalyzer for testing purposes
    addpath(genpath(getenv('CNA_PATH')));

    % check the CNA installation
    checkCNAinstallation(0);
else
    WAITBAR_TYPE = 1;
end

if verLessThan('matlab', '8.2')
    error('The testsuite of The COBRA Toolbox can only be run with MATLAB R2014b+.')
end

% define a success exit code
exit_code = 0;

% enable profiler
profile on;

if COVERAGE
    % Get the ignored Files from gitIgnore
    % only retain the lines that end with .txt and .m and 
    %are not comments and point to files in the /src folder
    ignoredPatterns = {'^.{0,3}$',... % Is smaller than four.
                       ['^[^s][^r][^c][^' regexptranslate('escape',filesep) ']']}; % does not start with src/
    filterPatterns = {'\.txt$','\.m$'}; % Is either a .m file or a .txt file.
    ignoreFiles = getIgnoredFiles(ignoredPatterns,filterPatterns);
    
    
    % check the code quality    
    listFiles = getFilesInDir('gitFileType','tracked','restrictToPattern','*.m$');

    % count the number of failed code quality checks per file
    nMsgs = 0;
    nCodeLines = 0;
    nEmptyLines = 0;
    nCommentLines = 0;

    for i = 1:length(listFiles)
        nMsgs = nMsgs + length(checkcode(listFiles(i)));

        fid = fopen(listFiles(i));

        % check if the file is on the ignored list
        countFlag = true;
        while ~feof(fid) && countFlag
            lineOfFile = strtrim(char(fgetl(fid)));
            if length(lineOfFile) > 0 && length(strfind(lineOfFile(1), '%')) ~= 1  ...
                && length(strfind(lineOfFile, 'end')) ~= 1 && length(strfind(lineOfFile, 'otherwise')) ~= 1 ...
                && length(strfind(lineOfFile, 'switch')) ~= 1 && length(strfind(lineOfFile, 'else')) ~= 1  ...
                && length(strfind(lineOfFile, 'case')) ~= 1 && length(strfind(lineOfFile, 'function')) ~= 1
                    nCodeLines = nCodeLines + 1;

            elseif length(lineOfFile) == 0
                nEmptyLines = nEmptyLines + 1;

            elseif length(strfind(lineOfFile(1), '%')) == 1
                nCommentLines = nCommentLines + 1;
            end
        end
        fclose(fid);
    end

    % average number of messages per codeLines
    avMsgsPerc = floor(nMsgs / nCodeLines * 100);

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

    fprintf('\n\n -> The code grade is %s (%1.2f%%).\n\n', grade, avMsgsPerc);

    if ~isempty(strfind(getenv('HOME'), 'jenkins'))
        % set the new badge
        system(['cp /mnt/prince-data/jenkins/userContent/codegrade-', grade, '.svg /mnt/prince-data/jenkins/userContent/codegrade.svg']);

        % secure copy the badge from the slave
        system('scp -P 8022 /mnt/prince-data/jenkins/userContent/codegrade.svg jenkins@prince-server.lcsb.uni.lux:/var/lib/jenkins/userContent');
    end
end

try

    % save the userpath
    originalUserPath = path;

    % run the tests in the subfolder verifiedTests/ recursively
    [result,resultTable] = runCOBRATestSuite();

    sumSkipped = sum(resultTable.Skipped);    
    sumFailed = sum(resultTable.Failed) - sumSkipped;    
    
    fprintf(['\n > ', num2str(sumFailed), ' tests failed. ', num2str(sumSkipped), ' tests were skipped due to missing requirements.\n\n']);

    % count the number of covered lines of code
    if COVERAGE
        % write coverage based on profile('info')
        fprintf('Running MoCov ... \n')
        mocov('-cover', 'src', ...
              '-profile_info', ...
              '-cover_json_file', 'coverage.json', ...
              '-cover_html_dir', 'coverage_html', ...
              '-cover_method', 'profile', ...
              '-verbose');

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
        fprintf('Covered Lines: %i, Total Lines: %i, Coverage: %f%%.\n', cl, tl, cl / tl * 100);
    end

    % print out a summary table
    resultTable

    % restore the original path
    restoredefaultpath;
    addpath(originalUserPath);

    if sumFailed > 0 
        exit_code = 1;
    end

    fprintf(['\n > The exit code is ', num2str(exit_code), '.\n\n']);
    
    %clean up temporary files.
    removeTempFiles(testDirPath,testDirContent);

    % ensure that we ALWAYS call exit
    if ~isempty(strfind(getenv('HOME'), 'jenkins')) || ~isempty(strfind(getenv('USERPROFILE'), 'jenkins'))
        exit(exit_code);
    end
catch ME
    %Also clean up temporary files in case of an error.
    removeTempFiles(testDirPath,testDirContent);
    if ~isempty(strfind(getenv('HOME'), 'jenkins')) || ~isempty(strfind(getenv('USERPROFILE'), 'jenkins'))
        % only exit on jenkins.
        exit(1);
    else
        % switch back to the folder we were in and rethrow the error
        cd(origDir);
        rethrow(ME);
    end
end


% switch back to the original directory
cd(origDir)
