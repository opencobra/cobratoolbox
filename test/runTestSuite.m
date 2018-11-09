function [results, resultTable] = runTestSuite(testNames)
% This function runs all tests (i.e. files starting with 'test' in the
% CBTDIR/test/ folder and returns the status.
% It can distinguish between skipped and Failed tests. A test is considered
% to be skipped if it throws a COBRA:RequirementsNotMet error.
%
% INPUTS:
%
%    testNames:     only run tests matching the regexp given in testNames.
%
% OUTPUTS:
%
%    results:       A structure array with one entry per test and the following fields:
%
%                    - `.passed`: true if the test passed otherwise false
%                    - `.skipped`: true if the test was skipped otherwise false
%                    - `.failed`: true if the test failed, or was skipped, otherwise false
%                    - `.status`: a string representing the status of the test ('failed','skipped' or'passed')
%                    - `.fileName`: the fileName of the test
%                    - `.time`: the duration of the test (if passed otherwise NaN)
%                    - `.statusMessage`: Informative string about potential problems
%                    - `.Error`: Error message received from a failed or skipped test
%    resultTable:   A Table with details of the results.
%
% Author:
%    - Thomas Pfau Jan 2018.

global CBTDIR

if ~exist('testNames','var')
    testNames = '.*';
end

% go to the test directory.
testDir = [CBTDIR filesep 'test'];
currentDir = cd(testDir);

% get all names of test files
testFiles = rdir(['verifiedTests' filesep '**' filesep 'test*.m']);
testFileNames = {testFiles.name};
testFileNames = testFileNames(~cellfun(@(x) isempty(regexp(x,testNames,'ONCE')),testFileNames));

% save the current globals (all tests should have the same environment when
% starting) and path 
environment = getEnvironment();

% save the current warning state
warnstate = warning();

% run the tests and show outputs.
for i = 1:numel(testFileNames)
    % shut down any existing parpool.
    try
        % test if there is a parpool that we should shut down before the next test.
        p = gcp('nocreate');
        delete(p);
    catch
        % do nothing
    end

    % reset the globals
    restoreEnvironment(environment)

    % reset the warning state
    warning(warnstate);

    [~,file,ext] = fileparts(testFileNames{i});
    testName = file;
    fprintf('****************************************************\n\n');
    fprintf('Running %s\n\n',testName);
    results(i) = runScriptFile([file ext]);
    fprintf('\n\n%s %s!\n',testName,results(i).status);
    if ~results(i).passed
        if results(i).skipped
            fprintf('Reason:\n%s\n',results(i).statusMessage);
        else
            trace = results(i).Error.getReport();
            tracePerLine = strsplit(trace,'\n');
            testSuitePosition = find(cellfun(@(x) ~isempty(strfind(x, 'runTestSuite')),tracePerLine));
            trace = sprintf(strjoin(tracePerLine(1:(testSuitePosition-7)),'\n')); % Remove the testSuiteTrace.
            fprintf('Reason:\n%s\n',trace);
        end
    end
    fprintf('\n\n****************************************************\n');
end

% create a table from the fields
resultTable= table({results.fileName}',{results.status}',[results.passed]',[results.skipped]',...
                            [results.failed]',[results.time]',{results.statusMessage}',...
                            'VariableNames',{'TestName','Status','Passed','Skipped','Failed','Time','Details'});

% change back to the original directory.
cd(currentDir)
end


function globals = getGlobals()
% Get all values of current globals in a struct.
% USAGE:
%    globals = getGlobals()
%
% OUTPUT:
%
%    globals:   a struct of all global variables

    globals = struct();
    globalvars = who('global');
    for i = 1:numel(globalvars)
        globals.(globalvars{i}) = getGlobalValue(globalvars{i});
    end
end

function resetGlobals(globals)
% Reset all global variables to a value stored in the input struct (all
% variables not present will be deleted.
% USAGE:
%    resetGlobals(globals)
%
% INPUT:
%    globals:   A struct with 1 field per global variable.

    globalvars = who('global');
    globalsToDelete = setdiff(globalvars,fieldnames(globals));

    for i = 1:numel(globalsToDelete)
        clearGlobal(globalsToDelete{i});
    end

    % Note: we cannot clean functions as this would remove profiling information

    % for everything else, check, if it changed
    globalNames = fieldnames(globals);
    for i = 1:numel(globalNames)
        % set the global to the old value.
        setGlobal(globalNames{i},globals.(globalNames{i}));
    end
end


function setGlobal(globalName,globalValue)
% Safely set a global Variable to a specific value.
%
% USAGE:
%    setGlobal(globalName,globalValue)
%
% INPUTS:
%    globalName:    A string representing the name of the global variable
%    globalValue:   The value to set the global variable to

    eval([ globalName '_val = globalValue;']);
    eval(['global ' globalName]);
    eval([globalName ' = ' globalName '_val;']);
end

function clearGlobal(globalName)
% Safely clear a global variable.
%
% USAGE:
%    clearGlobal(globalName)
%
% INPUTS:
%    globalName:    The name of the global variable to clear.

    clearvars('-global',globalName);
end

function value = getGlobalValue(globalName)
% Safely get the Value of a global variable.
%
% USAGE:
%    getGlobalValue(globalName)
%
% INPUTS:
%    globalName:    The name of the global variable to get the value for

    eval(['global ' globalName]);
    eval(['value = ' globalName ';']);
end
