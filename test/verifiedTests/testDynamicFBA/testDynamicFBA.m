% The COBRAToolbox: testDynamicFBA.m
%
% Purpose:
%     - testDynamicFBA tests the DynamicFBA function and its different outputs
%
% Author:
%     - Marouen BEN GUEBILA - 31/01/2017
  
  
% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end - (length('initCobraToolbox.m') + 1));
  
cd([CBTDIR '/test/verifiedTests/testDynamicFBA'])
  
load ecoli_core_model;

smi = {'EX_glc(e)'
    'EX_ac(e)'};%Exchange reaction for substrate in environment

smc = [10.8; 0.4]; % Glucose, Acetate concentration (all in mM)

Xec = 0.001;%Initial biomass
dt = 1/100;%Time steps
time = 1/dt; %Simulation time

for k ={'tomlab_cplex' 'ibm_cplex' 'glpk'}
    solverLPOK = changeCobraSolver(k{1});
    if solverLPOK
        [concentrationMatrixtest,excRxnNamestest,timeVectest,biomassVectest]=dynamicFBA(model,smi,smc,Xec,dt,time);

        tol = eps(0.5);%set tolerance
        assert(any(any(abs(concentrationMatrixtest-concentrationMatrix) < tol)))
        assert(isequal(excRxnNamestest,excRxnNames))
        assert(isequal(timeVectest,timeVec))
        assert(any(abs(biomassVectest-biomassVec) < tol))
    end
end

% change the directory
cd(CBTDIR)  
