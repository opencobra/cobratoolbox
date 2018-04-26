% The COBRAToolbox: testVerifyCobraProblem.m
%
% Purpose:
%     - testVerifyCobraProblem tests the verifyCobraProblem method
%
% Author:
%     - Thomas Pfau, April 2018
%
% Note:
%       

global CBTDIR

%Start with an empty struct
problem = struct();

res = verifyCobraProblem(problem);
assert(res == -1);
%Add A
problem.A = [1,0;0,1];
res = verifyCobraProblem(problem);
assert(res == -1);
%add wrong b
problem.b = [1];
res = verifyCobraProblem(problem);
assert(res == -1);
%correct b
problem.b = [1;1];
res = verifyCobraProblem(problem);
assert(res == -1);

%Add invalid csense
problem.csense = [1;1];
res = verifyCobraProblem(problem);
assert(res == -1);

%Add invalid csense
problem.csense = [1,1];
res = verifyCobraProblem(problem);
assert(res == -1);

%Add invalid csense
problem.csense = ['E';'E'];
res = verifyCobraProblem(problem);
assert(res == -1);

%Add invalid lb
problem.lb = ['E';'E'];
res = verifyCobraProblem(problem);
assert(res == -1);

%Add invalid lb
problem.lb = [1];
res = verifyCobraProblem(problem);
assert(res == -1);

%Add invalid lb (wrong size)
problem.lb = [-10,-10];
res = verifyCobraProblem(problem);
assert(res == -1);

%Add valid lb 
problem.lb = [-10;-10];
res = verifyCobraProblem(problem);
assert(res == -1);


%Add invalid ub
problem.ub = ['E';'E'];
res = verifyCobraProblem(problem);
assert(res == -1);

%Add invalid ub
problem.ub = [1];
res = verifyCobraProblem(problem);
assert(res == -1);

%Add invalid ub (wrong size)
problem.ub = [-10,-10];
res = verifyCobraProblem(problem);
assert(res == -1);

%Add invalid ub (ub < lb)
problem.ub = [-20;-20];
res = verifyCobraProblem(problem);
assert(res == -1);


%Add valid ub 
problem.ub = [10;10];
res = verifyCobraProblem(problem);
assert(res == -1);

%Add invalid c
problem.c = ['E';'E'];
res = verifyCobraProblem(problem);
assert(res == -1);

%Add invalid c
problem.c = [1];
res = verifyCobraProblem(problem);
assert(res == -1);

%Add invalid c (wrong size)
problem.c = [-10,-10];
res = verifyCobraProblem(problem);
assert(res == -1);

%Add valid c - this now is finally a valid Problem.
problem.c = [1;1];
res = verifyCobraProblem(problem);
assert(res == 1);

%Add invalid F
problem.F = ['EE';'EE'];
res = verifyCobraProblem(problem);
assert(res == -1);

%Add invalid F
problem.F = [1];
res = verifyCobraProblem(problem);
assert(res == -1);

%Add invalid F (wrong size)
problem.F = [-10,-10];
res = verifyCobraProblem(problem);
assert(res == -1);

%Add valid F - this now is finally a valid Problem.
problem.F = [1;1];
res = verifyCobraProblem(problem);
assert(res == -1);

%Add valid F - this now is finally a valid Problem.
problem.F = [1,0;0,1];
res = verifyCobraProblem(problem);
assert(res == 1);

%Add invalid vartype
problem.vartype = 1;
res = verifyCobraProblem(problem);
assert(res == -1);

%Add invalid vartype
problem.vartype = [1;2];
res = verifyCobraProblem(problem);
assert(res == -1);

%Add invalid vartype
problem.vartype = 'I';
res = verifyCobraProblem(problem);
assert(res == -1);

%Add invalid vartype
problem.vartype = 'CI';
res = verifyCobraProblem(problem);
assert(res == -1);

%Add valid vartype, and we got a valid problem again.
problem.vartype = ['C';'I'];
res = verifyCobraProblem(problem);
assert(res == 1);

%If we don't provide an X vector, this will fail.
assert(verifyCobraFunctionError('verifyCobraProblem','inputs',{problem},'outputArgCount',4));

%Add an x vector to test, this one is invalid.
xVector = [0,0];
res = verifyCobraProblem(problem,xVector);
assert(res == 0)

%Add an x vector to test, this one is invalid.
xVector = [0;0];
[res, invalidConstraints, invalidVars, objective]= verifyCobraProblem(problem,xVector);
assert(isempty(setxor(invalidConstraints,[1:2])));
assert(isempty(invalidVars));
assert(objective == 0);
assert(res == 0)

%Test another invalid x vector
xVector = [-15;1];
[res, invalidConstraints, invalidVars, objective]= verifyCobraProblem(problem,xVector);
assert(isempty(setxor(invalidConstraints,1)));
assert(isempty(setxor(invalidVars,1)));
assert(objective == 99);
assert(res == 0)

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

