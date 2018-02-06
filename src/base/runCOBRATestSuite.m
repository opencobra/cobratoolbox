function [results, resultTable] = runCOBRATestSuite(testNames)
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
%                   .passed - true if the test passed otherwise false
%                   .skipped - true if the test was skipped otherwise false
%                   .failed - true if the test failed, or was skipped,
%                             otherwise false
%                   .status - a string representing the status of the test
%                             ('failed','skipped' or'passed')
%                   .fileName - the fileName of the test 
%                   .time - the duration of the test (if passed otherwise NaN)
%                   .statusMessage - Informative string about potential
%                                    problems.
%                   .Error - The Error message received from a failed or skipped test 
%    resultTable:   A Table with details of the results. 
%
% Author:
%    - Thomas Pfau Jan 2018.


global CBTDIR

if ~exist('testNames','var')
    testNames = '.*';
end

%Go to the test directory.
testDir = [CBTDIR filesep 'test'];
currentDir = cd(testDir);

%Get all names of test files
testFiles = rdir(['verifiedTests' filesep '**' filesep 'test*.m']);
testFileNames = {testFiles.name};
testFileNames = testFileNames(~cellfun(@(x) isempty(regexp(x,testNames,'ONCE')),testFileNames));

%Run the tests and show outputs.
for i = 1:numel(testFileNames)
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
            testSuitePosition = find(cellfun(@(x) ~isempty(strfind(x,'runCOBRATestSuite')),tracePerLine));
            trace = sprintf(strjoin(tracePerLine(1:(testSuitePosition-7)),'\n')); % Remove the testSuiteTrace.
            fprintf('Reason:\n%s\n',trace);        
        end
    end
    fprintf('\n\n****************************************************\n');
end

%Now, create a table from the fields

resultTable= table({results.fileName}',{results.status}',[results.passed]',[results.skipped]',...
                            [results.failed]',[results.time]',{results.statusMessage}',...
                            'VariableNames',{'TestName','Status','Passed','Skipped','Failed','Time','Details'});
                        

%Change back to the original directory.
cd(currentDir)