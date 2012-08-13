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
%LP Solver test.
%http://www2.isye.gatech.edu/~spyros/LP/node2.html

% 1. Set up LP problem.
LPproblem.c = [200; 400];
LPproblem.A = [1/40, 1/60; 1/50, 1/50];
LPproblem.b = [1; 1];
LPproblem.lb = [0; 0];
LPproblem.ub = [1; 1];
LPproblem.osense = -1;
LPproblem.csense = ['L'; 'L'];
pass = 1;

% 2. Solve LP problem.
try
    %solve LP problem printing summary information
    LPsolution = solveCobraLP(LPproblem, 'printLevel', 2);
    %[solverOK, invalidConstraints, invalidVars, objective] = verifyCobraProblem(LPproblem, LPsolution.full);
catch 
    disp('Error in LP test');
    x=0;
    pass = 0;
end

% 3. Check results with expected answer.
if pass == 1
    if all(abs(LPsolution.full - [1;1]) < tol) && abs(LPsolution.obj - 600 < tol)
        display('LP Test Passed');
    else
        display('LP Test Not Passed');
        x=0;
    end
end

%MILP Solver test.
%http://www.chemeng.ed.ac.uk/~jwp/MSO/section5/milp.html

% 1. Set up MILP problem.
MILPproblem.c = [20; 6; 8];
MILPproblem.A = [0.8, 0.2, 0.3; 
    0.4, 0.3, 0;
    0.2, 0, 0.1];
MILPproblem.b = [20; 10; 5];
MILPproblem.lb = [0; 0; 0];
MILPproblem.ub = [1000; 1000; 1000];
MILPproblem.osense = -1;
MILPproblem.csense = ['L'; 'L'; 'L'];
MILPproblem.vartype = ['I'; 'I'; 'I'];
MILPproblem.x0 = [0, 0, 0];
pass = 1;

% 2. Solve MILP problem.
try
    %Solve MILP problem setting the relative MIP gap tolerance and
    %integrality tolerance to 1e-12 using parameters structure.
    parameters.relMipGapTol = 1e-12;
    parameters.intTol = 1e-12;
    MILPsolution = solveCobraMILP(MILPproblem, parameters); 
    %[solverOK, invalidConstraints, invalidVars, objective] = verifyCobraProblem(MILPproblem, MILPsolution.full);
catch
    disp('Error in MILP test');
    x=0;
    pass = 0;
end

% 3. Check results with expected answer.
if pass == 1
    if all(abs(MILPsolution.int - [0;31;46]) < tol) && abs(MILPsolution.obj - 554) < tol
        display('MILP Test Passed');
    else
        display('MILP Test Not Passed');
        x=0;
    end
end
%QP Solver test.
% http://tomopt.com/docs/quickguide/quickguide005.php

%if an error pops up asking to changeCobraSolver:
%changeCobraSolver('tomlab_cplex', 'QP')

% 1. Set up QP problem.
QPproblem.F     = [ 8   1; 1   8 ];       % Matrix F in 1/2 * x' * F * x + c' * x
QPproblem.c     = [ 3  -4 ]';    % Vector c in 1/2 * x' * F * x + c' * x
QPproblem.A     = [ 1   1; 1  -1 ];       % Constraint matrix
QPproblem.b = [ 5   0]';
QPproblem.lb   = [ 0  0  ]';  
QPproblem.ub   = [  inf   inf  ]';  
QPproblem.x0   = [  0   1  ]';  % Starting point
QPproblem.osense = 1;
QPproblem.csense = ['L'; 'E'];



pass = 1;
% 2. Solve QP problem.
try
    %Solve QP problem printing errors and warnings
    QPsolution = solveCobraQP(QPproblem, 'printLevel', 1);
    %[solverOK, invalidConstraints, invalidVars, objective] = verifyCobraProblem(QPproblem, QPsolution.full);
catch
    disp('Error in QP test');
    x=0;
    pass = 0;
end

% 3. Check QP results with expected answer.
if pass == 1
    if abs(QPsolution.obj + 0.0278)  < tol & abs(QPsolution.full - 0.0556) < [tol; tol]
        display('QP Test Passed');
    else
        display('QP Test Not Passed');
        x=0;
    end
end
%MIQP Solver test.
% http://tomopt.com/docs/quickguide/quickguide006.php

%if an error pops up asking to changeCobraSolver:
%changeCobraSolver('tomlab_cplex', 'MIQP')

% 1. Set up MIQP problem.
MIQPproblem.c    = [-6 0]';
MIQPproblem.F    = [4 -2;-2 4];
MIQPproblem.A    = [1 1];
MIQPproblem.b  = 1.9;
MIQPproblem.lb  = [0 0]';
MIQPproblem.ub  = [Inf Inf]';
MIQPproblem.osense = 1;
MIQPproblem.csense = 'L';
MIQPproblem.vartype = ['I'; 'C'];



pass = 1;

% 2. Solve MIQP problem.
try
    %Solve MIQP problem without printing
    MIQPsolution = solveCobraMIQP(MIQPproblem, 'printLevel', 0);
    %[solverOK, invalidConstraints, invalidVars, objective] = verifyCobraProblem(MIQPproblem, MIQPsolution.full);
catch
    disp('Error in MIQP test');
    x=0;
    pass = 0;
end

% 3. Check MIQP results with expected answer.
if pass == 1
    if abs(MIQPsolution.obj + 4.5) < tol & all(abs(MIQPsolution.full - [1;0.5]) < tol)
        display('MIQP Test Passed');
    else
        display('MIQP Test Not Passed');
        x=0;
    end
end

%NLP Solver test
% http://tomopt.com/docs/quickguide/quickguide008.php

% setup NLP problem
Name = 'RBB Problem';
NLPproblem.A = [];
NLPproblem.b = [];
NLPproblem.csense = [];
NLPproblem.lb = [-10; -10];
NLPproblem.ub = [2; 2];
NLPproblem.objFunction = 'testNLP_objFunction';
NLPproblem.x0 = [-1.2 1];
NLPproblem.fLowBnd = 0;
NLPproblem.gradFunction = 'testNLP_gradFunction';
NLPproblem.H = 'testNLP_H';
NLPproblem.c = 'testNLP_c';
NLPproblem.dc = 'testNLP_dc';
NLPproblem.d2c = 'testNLP_d2c';
NLPproblem.c_L = -1000;
NLPproblem.c_U = 0;

pass = 1;

%Solve
try
    %Solve, silent printing, problem name = 'RBB Problem' and warnings off.
    NLPsolution = solveCobraNLP(NLPproblem,'printLevel',0,'PbName',Name,'warning',0);
catch
    disp('Error in NLP test 1');
    x=0;
    pass = 0;
end

%Check results
if pass == 1
    if abs(NLPsolution.obj + 0) < tol & all(abs(NLPsolution.full - [1;1]) < tol)
        display('NLP Test 1 Passed');
    else
        display('NLP Test 1 Not Passed');
        x=0;
    end
end

%run sampleNLP script
try
    sampleNLP;
catch
    disp('Error in NLP test 2');
    x=0;
    pass = 0;
end


%Check results
if pass == 1
    if abs(NLPsolution.obj - 0.0117) < tol & all(abs(NLPsolution.full - [2071.06780547;2928.93219453;0.00482843;0.00682843]) < tol)
        display('NLP Test 2 Passed');
    else
        display('NLP Test Not 2 Passed');
        x=0;
    end
end

cd(oriFolder);
