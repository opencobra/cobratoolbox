% The COBRAToolbox: testSolveCobraLPCPLEX.m
%
% Purpose:
%     - testSolveCobraLPCPLEX tests the SolveCobraLPCPLEX
%     function and its different methods
%
% Author:
%     - Marouen BEN GUEBILA - 31/01/2017


% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end - (length('initCobraToolbox.m') + 1));

cd([CBTDIR filesep 'test' filesep 'verifiedTests' filesep 'testSolveCobraLPCPLEX'])
 
load testDataSolveCobraLPCPLEX;
load('ecoli_core_model','model');

tol = 0.01;%set tolerance
ecoli_blckd_rxn = {'EX_fru(e)','EX_fum(e)','EX_gln_L(e)','EX_mal_L(e)',...
    'FRUpts2','FUMt2_2','GLNabc','MALt2_2'};%blocked rxn in Ecoli

%test TOMLAB
solTest=solveCobraLPCPLEX(model,0,0,0,[],0,'tomlab_cplex')
%test was performed on objective as solution can vary between machines,
%solver version etc..
assert(any(abs(solTest.obj-sol.obj) < tol))

%test ILOG
% solTest=solveCobraLPCPLEX(model,0,0,0,[],0,'ILOGcomplex');
% assert(any(abs(solTest.obj-sol.obj) < tol))

%test solver packages
solverPkgs = {'tomlab_cplex'};%,'ILOGcomplex'};

for k =1:length(solverPkgs)
    %test minNorm
    solTest=solveCobraLPCPLEX(model,0,0,0,[],1e-6,solverPkgs{k});
    assert(isequal(ecoli_blckd_rxn,model.rxns(find(~solTest.full))'))
    assert(any(abs(solTest.obj-sol.obj) < tol))

    %test basis generation
    [solTest,basisTest]=solveCobraLPCPLEX(model,0,1,0,[],0,solverPkgs{k});
    assert(any(abs(solTest.obj-sol.obj) < tol))

    %test basis reuse
    [solTest]=solveCobraLPCPLEX(basis,0,1,0,[],0,solverPkgs{k});
    assert(any(abs(solTest.obj-sol.obj) < tol))
end
% change the directory
cd(CBTDIR) 