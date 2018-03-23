function result = runScriptFile(fileName)
% This function runs the test in fileName 
% It can distinguish between skipped and Failed tests. A test is considered
% to be skipped if it throws a COBRA:RequirementsNotMet error.
%
% OUTPUTS:
%
%    result:    A structure array with the following fields:
%               .passed - true if the test passed otherwise false
%               .skipped - true if the test was skipped otherwise false
%               .failed - true if the test failed, or was skipped,
%                         otherwise false
%               .status - a string representing the status of the test
%                         ('failed','skipped' or'passed')
%               .fileName - the fileName of the test 
%               .time - the duration of the test (if passed otherwise NaN)
%               .statusMessage - Informative string about potential
%                                problems.
%               .Error - The Error message received from a failed or skipped test 
%
% Author:
%    - Thomas Pfau Jan 2018.

global CBT_MISSING_REQUIREMENTS_ERROR_ID;

COBRA_TESTSUITE_TESTFILE = fileName;

%Get the timinig (and hope these values are not overwritten.
COBRA_TESTSUITE_STARTTIME = clock();
try
    %Run the file
    executefile(fileName);
catch ME
    %Catch errors and interpret them
    clearvars -except ME COBRA_TESTSUITE_STARTTIME COBRA_TESTSUITE_TESTFILE CBT_MISSING_REQUIREMENTS_ERROR_ID
    result = struct('status','failed','failed',true,'passed',false,'skipped',false,'fileName',...
        COBRA_TESTSUITE_TESTFILE,'time',NaN, 'statusMessage', 'fail', 'Error',ME);    
    if strcmp(ME.identifier,CBT_MISSING_REQUIREMENTS_ERROR_ID)
        %Requirement missing, so the test was skipped.
        result.status = 'skipped';  
        result.skipped = true;
        result.statusMessage = ME.message;
    else
        %Actual error in the test.
        result.skipped = false;
        result.status = 'failed';
        result.statusMessage = ME.message;
    end    
    return
end
%Get the timinig.
scriptTime = etime(clock(),COBRA_TESTSUITE_STARTTIME);

result = struct('status','passed','failed',false,'passed',true,'skipped',false,'fileName',...
    COBRA_TESTSUITE_TESTFILE, 'time', scriptTime,'statusMessage','success', 'Error',MException('',''));

end

function executefile(fileName)
%Runs a script file (used to separate workspaces)
run(fileName)
end
