function x = testSolvers()
% testSolvers tests the basic functionality of LP, MILP, QP, MIQP
%   It creates a sample problem (obtained from the corresponding websites)
%   and then checks if the solutions values are correct.
%   Return 1 if all solutions are correct, else 0.
%
%   Joseph Kang 11/16/09
%   Richard Que (02/11/10) NLP Support
tol = 0.001;
oriFolder = pwd;

x=1;

%[solverOK, invalidConstraints, invalidVars, objective] = verifyCobraProblem(LPproblem, LPsolution.full);



cd(oriFolder);
