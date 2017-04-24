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


% this test is only available with tomlab_snopt
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
