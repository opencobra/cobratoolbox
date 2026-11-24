% The COBRAToolbox: testSetCplexParametersForProblem.m
%
% Purpose:
%     - setCplexParametersForProblem(cplexProblem, problemTypeParams, solverParams,
%       problemType) resets a Cplex object to its defaults and sets display, logging,
%       tolerance, MIP, algorithm, scaling, time-limit, numerical-emphasis, Markowitz and
%       advanced-start parameters from the COBRA problem-type parameters and the
%       solver-specific parameters, and returns the log destination. The function only calls
%       setDefault and reads and writes the properties Param, DisplayFunc and Start, so a
%       hand-built structure with these fields stands in for the Cplex object (as in
%       testSetCplexParam), and every parameter set is checked against the value or code
%       written in the help and the source (CPLEX algorithm codes 0-6, the legacy MIQP method
%       codes), for each problem type. CPLEX itself is not called.
%
% Function under test:
%     src/base/solvers/cplex/setCplexParametersForProblem.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a hand-built structure (fields setDefault, Param,
%     DisplayFunc) in place of the Cplex object, and a tempname folder for the log file.
%
% Coverage exemptions:
%     Lines 320, 329: unreachable, the condition of line 313 ends in "&& 0" (multiscale is
%         read but never applied, as the help says).
%     Lines 371, 372, 375, 376, 379, 380, 384: unreachable, inside "if 0" (line 369).
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found. (The defect recorded on 2026-11-15, text values of problemTypeParams.method
%     overwritten by the barrier default for MIQP, was fixed by feature
%     20261120-161825-core-blocker-fixes and is tested below.)
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Full test after the fix (feature 20261120-161825-core-blocker-fixes), 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSetCplexParametersForProblem'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the stand-in for the Cplex object, and the COBRA parameters of a problem type
cplexProblem = struct('setDefault', [], 'Param', struct(), 'DisplayFunc', @disp);
ptp = struct('printLevel', 0, 'logFile', 0, 'feasTol', 1e-7, 'optTol', 1e-8, ...
    'relMipGapTol', 1e-4, 'intTol', 1e-5, 'absMipGapTol', 1e-3, 'timeLimit', 100);

% the log file is written in a temporary folder
logFolder = tempname;
mkdir(logFolder);

%% LP, printLevel 0, no logging: display off, tolerances, barrier, no MIP parameters

[out, logFile, logToFile] = setCplexParametersForProblem(cplexProblem, ptp, struct(), 'LP');
P = out.Param;
assert(P.output.writelevel.Cur == 0 && P.barrier.display.Cur == 0 && P.simplex.display.Cur == 0);
assert(P.sifting.display.Cur == 0 && P.paramdisplay.Cur == 0 && isequal(out.DisplayFunc, 0));
assert(logFile == 0 && logToFile == false && P.output.clonelog.Cur == -1);
assert(P.simplex.tolerances.feasibility.Cur == 1e-7 && P.network.tolerances.feasibility.Cur == 1e-7);
assert(P.simplex.tolerances.optimality.Cur == 1e-8 && P.network.tolerances.optimality.Cur == 1e-8);
assert(P.lpmethod.Cur == 4);
assert(~isfield(P, 'mip') && ~isfield(P, 'timelimit') && ~isfield(P, 'qpmethod'));
assert(~isfield(P, 'read') && ~isfield(P, 'emphasis') && ~isfield(P, 'advance'));

%% the log destinations: command window (1), none (empty), a file (appended to)

ptpShow = ptp;
ptpShow.printLevel = 1;
ptpShow.logFile = 1;
[out, logFile, logToFile] = setCplexParametersForProblem(cplexProblem, ptpShow, struct(), 'LP');
assert(out.Param.output.writelevel.Cur == 1 && out.Param.paramdisplay.Cur == 1);
assert(logFile == 1 && logToFile == false && ~isfield(out.Param.output, 'clonelog'));
assert(isa(out.DisplayFunc, 'function_handle'));
% the display function prints a line of the CPLEX log to the command window
out.DisplayFunc('testSetCplexParametersForProblem: a line of the CPLEX log');
% printLevel 2: the display function is kept, and the parameter display is on (1)
ptpEmpty = ptp;
ptpEmpty.printLevel = 2;
ptpEmpty.logFile = [];
[out, logFile, logToFile] = setCplexParametersForProblem(cplexProblem, ptpEmpty, struct(), 'LP');
assert(isequal(out.DisplayFunc, @disp) && out.Param.paramdisplay.Cur == 1 && out.Param.simplex.display.Cur == 2);
assert(logFile == 0 && logToFile == false && out.Param.output.clonelog.Cur == -1);
% a file name: opened for appending, and the display function writes to it
ptpFile = ptp;
ptpFile.logFile = fullfile(logFolder, 'cplex.log');
fid = fopen(ptpFile.logFile, 'w');
fprintf(fid, 'earlier\n');
fclose(fid);
[out, logFile, logToFile] = setCplexParametersForProblem(cplexProblem, ptpFile, struct(), 'LP');
assert(logFile > 2 && logToFile == true && isa(out.DisplayFunc, 'function_handle'));
out.DisplayFunc('a line of the CPLEX log');
fclose(logFile);
assert(strcmp(fileread(ptpFile.logFile), sprintf('earlier\na line of the CPLEX log\n')));

%% lpmethod (LP only): numeric codes kept, names translated to the CPLEX codes

out = setCplexParametersForProblem(cplexProblem, ptp, struct('lpmethod', 2), 'LP');
assert(out.Param.lpmethod.Cur == 2);
lpNames = {'AUTOMATIC', 'PRIMAL', 'DUAL', 'NETWORK', 'BARRIER', 'SIFTING', 'CONCURRENT'};
for k = 1:numel(lpNames)
    out = setCplexParametersForProblem(cplexProblem, ptp, struct('lpmethod', lpNames{k}), 'LP');
    assert(out.Param.lpmethod.Cur == k - 1);
end
assert(verifyCobraFunctionError('setCplexParametersForProblem', 'inputs', ...
    {cplexProblem, ptp, struct('lpmethod', 'FOO'), 'LP'}));
% for other problem types lpmethod is the barrier (4), whatever solverParams.lpmethod says
out = setCplexParametersForProblem(cplexProblem, ptp, struct('lpmethod', 'PRIMAL'), 'QP');
assert(out.Param.lpmethod.Cur == 4);

%% qpmethod (QP only): numeric codes kept, names translated to the CPLEX codes

out = setCplexParametersForProblem(cplexProblem, ptp, struct('qpmethod', 3), 'QP');
assert(out.Param.qpmethod.Cur == 3 && ~isfield(out.Param, 'mip'));
qpNames = {'AUTOMATIC', 'PRIMAL', 'DUAL', 'NETWORK', 'BARRIER', 'CONCURRENT'};
qpCodes = [0, 1, 2, 3, 4, 6];
for k = 1:numel(qpNames)
    out = setCplexParametersForProblem(cplexProblem, ptp, struct('qpmethod', qpNames{k}), 'QP');
    assert(out.Param.qpmethod.Cur == qpCodes(k));
end
assert(verifyCobraFunctionError('setCplexParametersForProblem', 'inputs', ...
    {cplexProblem, ptp, struct('qpmethod', 'SIFTING'), 'QP'}));
% for other problem types qpmethod is not set
out = setCplexParametersForProblem(cplexProblem, ptp, struct('qpmethod', 'PRIMAL'), 'LP');
assert(~isfield(out.Param, 'qpmethod'));

%% MILP: the MIP tolerances and the time limit

out = setCplexParametersForProblem(cplexProblem, ptp, struct(), 'MILP');
P = out.Param;
assert(P.mip.tolerances.mipgap.Cur == 1e-4 && P.mip.tolerances.integrality.Cur == 1e-5);
assert(P.mip.tolerances.absmipgap.Cur == 1e-3 && P.timelimit.Cur == 100);
assert(P.lpmethod.Cur == 4 && ~isfield(P, 'qpmethod'));

%% MIQP: the legacy numeric method codes set qpmethod, with a warning; lpmethod stays barrier

legacyCodes = [-1, 0, 1, 2, 3, 5, 4];
qpmethodFor = [-1, 1, 2, 4, 6, 3, 0];
for k = 1:numel(legacyCodes)
    ptpMethod = ptp;
    ptpMethod.method = legacyCodes(k);
    lastwarn('');
    out = setCplexParametersForProblem(cplexProblem, ptpMethod, struct(), 'MIQP');
    assert(strcmp(lastwarn, 'check the problemTypeParams.method mapping to algorithm numbers is correct'));
    assert(out.Param.qpmethod.Cur == qpmethodFor(k) && out.Param.lpmethod.Cur == 4);
    assert(out.Param.mip.tolerances.mipgap.Cur == 1e-4 && out.Param.timelimit.Cur == 100);
end

%% MIQP: the method names set lpmethod, and the barrier default does not replace them

for k = 1:numel(lpNames)
    ptpMethod = ptp;
    ptpMethod.method = lpNames{k};
    out = setCplexParametersForProblem(cplexProblem, ptpMethod, struct(), 'MIQP');
    assert(out.Param.lpmethod.Cur == k - 1 && ~isfield(out.Param, 'qpmethod'));
end
ptpMethod.method = 'FOO';
assert(verifyCobraFunctionError('setCplexParametersForProblem', 'inputs', ...
    {cplexProblem, ptpMethod, struct(), 'MIQP'}));

%% the solver-specific fields: scaling, time limits, numerical emphasis, Markowitz

solverParams = struct('scaind', -1, 'timelimit', 50, 'emphasis_numerical', 1, 'markowitz', 0.5);
out = setCplexParametersForProblem(cplexProblem, ptp, solverParams, 'MILP');
P = out.Param;
assert(P.read.scale.Cur == -1 && P.timelimit.Cur == 50 && P.emphasis.numerical.Cur == 1);
assert(P.simplex.tolerances.markowitz.Cur == 0.5);
% secondsTimeLimit is multiplied by 5 and applied after timelimit
out = setCplexParametersForProblem(cplexProblem, ptp, struct('timelimit', 50, 'secondsTimeLimit', 3), 'LP');
assert(out.Param.timelimit.Cur == 15);
% multiscale is read but never applied
out = setCplexParametersForProblem(cplexProblem, ptp, struct('multiscale', 1), 'LP');
assert(~isfield(out.Param, 'read') && ~isfield(out.Param, 'emphasis'));

%% a start point: the advanced start switch is on

cplexStart = cplexProblem;
cplexStart.Start = struct('x', [1; 2]);
out = setCplexParametersForProblem(cplexStart, ptp, struct(), 'LP');
assert(out.Param.advance.Cur == 1);

% remove the temporary folder
rmdir(logFolder, 's');

% change the directory
cd(currentDir)
