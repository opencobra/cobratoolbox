function generateSystemConfigReport()
% Generates a configuration report of the sytem and saves it as COBRAconfigReport.log
%
% USAGE:
%
%     generateSystemConfigReport()


    global CBTDIR;
    global CBT_LP_SOLVER;
    global CBT_MILP_SOLVER;
    global CBT_QP_SOLVER;
    global CBT_MIQP_SOLVER;
    global CBT_NLP_SOLVER;
    global GUROBI_PATH;
    global ILOG_CPLEX_PATH;
    global TOMLAB_PATH;
    global MOSEK_PATH;

    reportFile = 'COBRAconfigReport.log';

    currentDir = pwd;

    % find the current directory
    fileDir = fileparts(which('generateSystemConfigReport'));

    % change to the root of The COBRA toolbox
    cd([fileDir filesep '..' filesep '..']);

    % define the root path of The COBRA Toolbox
    CBTDIR = fileparts(which('initCobraToolbox'));

    if ~isempty(CBTDIR)
        tmpRootDir = CBTDIR;
    else
        tmpRootDir = pwd;
    end

    % define the full path to the log file
    fullPathReportFile = [tmpRootDir filesep reportFile];

    % turn on logging
    if exist(fullPathReportFile, 'file') == 2
        delete(fullPathReportFile);
    end

    % turn on output logging
    diary(fullPathReportFile);

    fprintf('\n > ---------------------------------- SYSTEM CONFIGURATION REPORT ----------------------------------\n');

    % retrieve the version of git
    try
        [~, result_gitVersion] = system('git --version');
        result_gitVersion = strtrim(result_gitVersion);
    catch
        warning(' > git is not installed.\n');
    end

    % retrieve the version of curl
    try
        [~, tmp_result_curlVersion] = system('curl --version');
        tmp_result_curlVersion = strsplit(tmp_result_curlVersion);
        result_curlVersion = [tmp_result_curlVersion{1}, ' ', tmp_result_curlVersion{2}, ' ', tmp_result_curlVersion{3}];
    catch
        warning(' > curl is not installed.\n');
    end

    % launch the initialisation script
    try
        tic;
        initCobraToolbox;
        toc;
    end

    % print a summary of the MATLAB installation
    fprintf('\n');
    ver
    fprintf('\n');

    % retrieve the version of bash
    try
        shell = getenv('SHELL');
        fprintf(' > %-20s:        %s\n', 'Default shell', shell);
        [~, tmp_result_shellVersion] = system([shell ' --version']);
        result_shellVersion = strtrim(tmp_result_shellVersion);
        fprintf(' > %-20s:        %s\n', 'Version of shell', result_shellVersion);
    end

    % output the architecture information
    fprintf(' > %-20s:        %s\n', 'Architecture', computer);
    fprintf(' > %-20s:        %s\n', 'MATLAB folder', matlabroot);
    fprintf(' > %-20s:        %s\n', 'COBRA Toolbox root', tmpRootDir);
    fprintf(' > %-20s:        %s\n', 'git version', result_gitVersion);
    fprintf(' > %-20s:        %s\n', 'curl version', result_curlVersion);

    % solver paths
    globalVars = {'CBT_LP_SOLVER', 'CBT_MILP_SOLVER', 'CBT_QP_SOLVER', 'CBT_MIQP_SOLVER', ...
                  'CBT_NLP_SOLVER', 'GUROBI_PATH', 'ILOG_CPLEX_PATH', 'TOMLAB_PATH', 'MOSEK_PATH'};

    for i = 1:length(globalVars)
        try
            fprintf(' > %-20s:        %s\n', globalVars{i}, eval(globalVars{i}));
        catch
            warning([globalVars{i}, ' could not be retrieved.\n']);
        end
    end

    % open the file with a handle to append text
    fileID = fopen(fullPathReportFile, 'a+');

    % retrieve the system PATH
    try
        fprintf(fileID, '\n > System PATH:\n%s\n\n', getenv('PATH'));
    end

    % print out the MATLAB path to the log file
    fprintf(fileID, ' > MATLAB path:\n%s\n', path);

    fclose(fileID);

    fprintf('\n > ----------------------------------- END OF CONFIGURATION REPORT -----------------------------------\n');

    % turn off logging
    diary off;

    fprintf('\n >  Please send the report located in\n    %s\n', [CBTDIR, filesep, reportFile]);
    fprintf('    to the developers or post it in the %s:\n', hyperlink('https://groups.google.com/forum/#!forum/cobra-toolbox', 'forum', 'forum: '));

    % change back to the original directory
    cd(currentDir);
end
