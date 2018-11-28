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

