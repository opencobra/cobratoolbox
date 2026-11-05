% The COBRAToolbox: testVerifyCobraProblem.m
%
% Purpose:
%     - testVerifyCobraProblem tests the verifyCobraProblem method
%
% Function under test:
%     src/base/solvers/verifyCobraProblem.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Line 279: unreachable, validLP is set to true before this check and never reset.
%     Line 297: unreachable, validLP is always true here.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: invalidConstraints names the wrong rows when senses are mixed
%       SEVERITY: wrong-result
%       TRIGGER: an x that violates a row of a problem whose csense mixes E, L and G
%       OBSERVED: the mask computed on the rows of one sense indexes the vector of all rows, so
%         the violated rows are reported at their position among the rows of that sense
%       EXPECTED: the row numbers of the violated rows in A
%       LINES: 335, 341, 347
%     - DEFECT: A NaN in x stops a call with more than one output
%       SEVERITY: error
%       TRIGGER: verifyCobraProblem(problem, x) with a NaN in x and two or more outputs
%       OBSERVED: the function returns before invalidConstraints and invalidVars are assigned, so
%         the call stops with an unassigned output argument
%       EXPECTED: status -1 with empty invalidConstraints and invalidVars
%       LINES: 310-319
%
% Author:
%     - Thomas Pfau, April 2018
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%
% Note:
%       

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testVerifyCobraProblem'));
cd(fileDir);

% declare the requirements: this test needs no solver, toolbox or operating system
prepareTest();

%Start with an empty struct
problem = struct();
% create a valid problem:
problem.A = [1,0;0,1];
problem.b = [0;0];
problem.csense = ['EE']';
problem.lb = [-10;-10];
problem.ub = [10;10];
problem.osense = -1;
problem.c = [0;1];
res = verifyCobraProblem(problem);
assert(res == 1);
% remove A
problem = rmfield(problem,'A');
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'Required field A not found'))
%Add invalid A
problem.A = [1,0;NaN,1];
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'NaN present in A matrix at 2,1.'))
% Add valid A
problem.A = [1,0;0,1];
res = verifyCobraProblem(problem);
assert(res == 1);

% remove b:
problem = rmfield(problem,'b');
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'Required field b not found'))
%add wrong b
problem.b = [1];
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'Wrong size b vector'))
%add NaN b
problem.b = [1,NaN];
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'NaN present in b vector at 2,.'))
%correct b
problem.b = [1;1];
res = verifyCobraProblem(problem);
assert(res == 1);

% remove csense:
problem = rmfield(problem,'csense');
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'Required field csense not found'))
%Add invalid csense
problem.csense = [1;1];
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'Invalid csense entry(s) at 12'))
%Add invalid csense
problem.csense = [1,1];
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'Csense should be a column vector'))
%Add invalid csense
problem.csense = ['E';'E'];
res = verifyCobraProblem(problem);
assert(res == 1);

% remove lb:
problem = rmfield(problem,'lb');
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'Required field lb not found'))
%Add invalid lb
problem.lb = ['E';'E'];
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'lb must be numeric'))
%Add invalid lb
problem.lb = [1];
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'Wrong size lb vector'))
%Add invalid lb (NaN)
problem.lb = [-10;NaN];
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'NaN present in lb vector at 2,.'))
%Add invalid lb (wrong size)
problem.lb = [-10,-10];
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'Wrong size lb vector'))
%Add valid lb 
problem.lb = [-10;-10];
res = verifyCobraProblem(problem);
assert(res == 1);


% remove ub:
problem = rmfield(problem,'ub');
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'Required field ub not found')) 
%Add invalid ub
problem.ub = ['E';'E'];
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'ub must be numeric')) 
%Add invalid ub
problem.ub = [1];
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'Wrong size ub vector')) 
%Add invalid ub (NaN)
problem.ub = [-10;NaN];
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'NaN present in ub vector at 2,.')) 
%Add invalid ub (wrong size)
problem.ub = [-10,-10];
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'Wrong size ub vector')) 
%Add invalid ub (ub < lb)
problem.ub = [-20;-20];
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'Upper bound less than lower bound (ub<lb) at 12'))
%Add valid ub 
problem.ub = [10;10];
res = verifyCobraProblem(problem);
assert(res == 1);

% remove c:
problem = rmfield(problem,'c');
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'Required field c not found')) 
%Add invalid c
problem.c = ['E';'E'];
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'c must be numeric')) 
%Add invalid c
problem.c = [1];
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'Wrong size c vector')) 
%Add invalid c (wrong size)
problem.c = [-10,-10];
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'Wrong size c vector')) 
%Add invalid c (wrong size)
problem.c = [-10;NaN];
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'NaN present in c vector at 2,.')) 
%Add valid c - this now is finally a valid Problem.
problem.c = [1;1];
res = verifyCobraProblem(problem);
assert(res == 1);

%Add invalid F
problem.F = ['EE';'EE'];
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'F must be numeric')) 
%Add invalid F
problem.F = [1];
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'Wrong size F matrix')) 
%Add invalid F (wrong size)
problem.F = [-10,-10];
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'F matrix not square')) 
%Add invalid F - other dimension
problem.F = [1;1];
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'F matrix not square')) 
%Add valid F - this now is finally a valid Problem.
problem.F = [1,0;0,1];
res = verifyCobraProblem(problem);
assert(res == 1);

%Add invalid vartype
problem.vartype = 1;
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'Wrong size vartype vector')) 
%Add invalid vartype
problem.vartype = [1;2];
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'Invalid vartype entry(s) at 12')) 
%Add invalid vartype
problem.vartype = 'I';
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'Wrong size vartype vector')) 
%Add invalid vartype
problem.vartype = 'CI';
res = verifyCobraProblem(problem);
assert(res == -1);
assert(strcmp(lastwarn,'Wrong size vartype vector')) 
%Add valid vartype, and we got a valid problem again.
problem.vartype = ['C';'I'];
res = verifyCobraProblem(problem);
assert(res == 1);

%If we don't provide an X vector, this will fail.
assert(verifyCobraFunctionError('verifyCobraProblem','inputs',{problem},'outputArgCount',4));

%Add an x vector to test, this one is invalid.
xVector = [0,0];
res = verifyCobraProblem(problem,xVector);
assert(strcmp(lastwarn,'Wrong size x vector')) 
assert(res == 0)

%Add an x vector to test, this one is invalid.
xVector = [0;0];
[res, invalidConstraints, invalidVars, objective]= verifyCobraProblem(problem,xVector);
assert(isempty(setxor(invalidConstraints,[1:2])));
assert(isempty(invalidVars));
assert(objective == 0);
assert(res == 0)
assert(strcmp(lastwarn,'Equality constraint off')) 

%Test another invalid x vector
xVector = [-15;1];
[res, invalidConstraints, invalidVars, objective]= verifyCobraProblem(problem,xVector);
assert(isempty(setxor(invalidConstraints,1)));
assert(isempty(setxor(invalidVars,1)));
assert(objective == 99);
assert(res == 0)
assert(strcmp(lastwarn,'Equality constraint off')) 

%Allow a huge tolerance, which should make this acceptable...
[res, invalidConstraints, invalidVars, objective]= verifyCobraProblem(problem,xVector,16); 
assert(isempty(invalidConstraints));
assert(isempty(invalidVars));
assert(objective == 99);
assert(res == 1)

%Add an x vector to test, this one is valid.
xVector = [1;1];
[res, invalidConstraints, invalidVars, objective]= verifyCobraProblem(problem,xVector);
assert(res == 1)
assert(isempty(invalidConstraints));
assert(isempty(invalidVars)); 
assert(objective == 3);

%Make it an LP problem
problem = rmfield(problem,'F');
[res, invalidConstraints, invalidVars, objective]= verifyCobraProblem(problem,xVector);
assert(res == 1)
assert(isempty(invalidConstraints));
assert(isempty(invalidVars));
assert(objective == 2);

%% a valid base problem for the sections below
valid = struct('A', [1, 0; 0, 1], 'b', [1; 1], 'csense', ['E'; 'E'], 'lb', [-10; -10], ...
    'ub', [10; 10], 'osense', -1, 'c', [0; 1]);
assert(verifyCobraProblem(valid) == 1);

%% a right hand side that is not numeric
broken = valid;
broken.b = ['a'; 'b'];
assert(verifyCobraProblem(broken) == -1);
assert(strcmp(lastwarn, 'b must be numeric'));

%% the length of csense, with and without dsense
broken = valid;
broken.csense = 'E';
assert(verifyCobraProblem(broken) == -1);
assert(strcmp(lastwarn, 'Wrong size csense vector...'));

% csense and dsense together have to fit the rows of A
broken.dsense = ['L'; 'L'];
assert(verifyCobraProblem(broken) == -1);
assert(strcmp(lastwarn, 'Wrong size dsense vector...'));
broken.dsense = 'L';
assert(verifyCobraProblem(broken) == 1);

%% a NaN in F
broken = valid;
broken.F = [1, 0; NaN, 1];
assert(verifyCobraProblem(broken) == -1);
assert(strcmp(lastwarn, 'NaN present in F matrix at 2,1.'));

%% F that is not numeric
broken.F = ['ab'; 'cd'];
assert(verifyCobraProblem(broken) == -1);
assert(strcmp(lastwarn, 'F must be numeric'));

%% integer and binary variables with bounds that do not fit
broken = valid;
broken.lb = [0.2; -10];
broken.ub = [0.8; 10];
broken.vartype = ['I'; 'C'];
assert(verifyCobraProblem(broken) == -1);
assert(strcmp(lastwarn, 'Integer or binary variables lb to ub range does not contain an integer'));

broken = valid;
broken.vartype = ['B'; 'C'];
broken.ub = [1; 10];
assert(verifyCobraProblem(broken) == -1);
assert(strcmp(lastwarn, 'Binary variables have lower bound not equal to zero.  This is inconsistent'));

broken = valid;
broken.vartype = ['B'; 'C'];
broken.lb = [0; -10];
assert(verifyCobraProblem(broken) == -1);
assert(strcmp(lastwarn, 'Binary variables have upper bound not equal to one.  This is inconsistent'));

%% a NaN in x
status = verifyCobraProblem(valid, [1; NaN]);
assert(status == -1);
assert(strcmp(lastwarn, 'NaN present in x vector at 2,.'));

%% an x above the upper bound
[status, ~, invalidVars] = verifyCobraProblem(valid, [11; 1]);
assert(status == 0 && isequal(invalidVars, 1));
assert(strcmp(lastwarn, 'Equality constraint off'));

%% violated L and G rows
inequalities = valid;
inequalities.csense = ['L'; 'G'];
% the status and the warnings are asserted; invalidConstraints is not, see the defect above
status = verifyCobraProblem(inequalities, [2; 0]);
assert(status == 0);
assert(strcmp(lastwarn, 'G constraint off'));
status = verifyCobraProblem(inequalities, [2; 1]);
assert(status == 0);
assert(strcmp(lastwarn, 'L constraint off'));

%% the integrality of x, and the two messages of a valid x
mixed = valid;
mixed.A = [1, 1];
mixed.b = 2.5;
mixed.csense = 'E';
mixed.vartype = ['I'; 'C'];
[status, invalidConstraints, invalidVars, objective] = verifyCobraProblem(mixed, [1.5; 1]);
assert(status == 0 && isempty(invalidConstraints) && isempty(invalidVars) && objective == 1);
assert(strcmp(lastwarn, 'Integer constraint off'));

printed = evalc('status = verifyCobraProblem(mixed, [1; 1.5]);');
assert(status == 1 && contains(printed, 'Valid x vector for MIXP problem'));
printed = evalc('status = verifyCobraProblem(valid, [1; 1]);');
assert(status == 1 && contains(printed, 'Valid x vector for XP problem'));

%% the verbose report
printed = evalc('status = verifyCobraProblem(valid, [], [], true);');
assert(status == 1 && contains(printed, 'Valid LP problem') && contains(printed, 'Invalid MILP problem'));
assert(contains(printed, 'Invalid QP problem') && contains(printed, 'Invalid MIQP problem'));
miqp = valid;
miqp.F = eye(2);
miqp.vartype = ['C'; 'C'];
printed = evalc('status = verifyCobraProblem(miqp, [], [], true);');
assert(status == 1 && contains(printed, 'Valid MILP problem'));
assert(contains(printed, 'Valid QP problem') && contains(printed, 'Valid MIQP problem'));

% change the directory back
cd(currentDir);
