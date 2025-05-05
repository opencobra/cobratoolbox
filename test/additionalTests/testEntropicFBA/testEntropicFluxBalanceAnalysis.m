% The COBRAToolbox: testEntropicFluxBalanceAnalysis.m
%
% Purpose:
%     - %testEntropicFluxBalanceAnalysis.m tests the basic functionality of
%     entropicFluxBalanceAnalysis.m
%
%       entropicFluxBalanceAnalysis.m incorporates entropy maximization
%       principles into the framework of tranditional flux balance analysis
%       to  to predict more realistic and biologically plausible intracellular 
%       flux distributions by assuming that, among all feasible flux states, 
%       cells prefer those that are thermodynamically favourable and least ordered.
%       
% Usage:
%       [solution, modelOut] = entropicFluxBalanceAnalysis(model,param)
%
% Creator: Yanjun Liu May, 2025

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testEntropicFluxBalanceAnalysis'));
cd(fileDir);

% Testing entropicFluxBalanceAnalysis

% 1. load model
model = getDistributedModel('Recon3DModel_301.mat');

% 2. set param for entropicFBA
param.solver ='mosek'; % {('pdco'),'mosek'}
param.entropicFBAMethod ='fluxes'; % {('fluxes'),'fluxesConcentrations','fluxTracer')}
param.printLevel = 0;  % {(0),1}
param.debug = 1;
param.feasTol = 1e-8; %[1e-11,1e-6], 1e-11 might be too strict in some cases
param.optTol = param.feasTol*10;
param.problemType = 'EP';

% 3. Run entropicFluxBalanceAnalysis.
solution = entropicFluxBalanceAnalysis(model,param);

% 4. Expected result

if solution.state ==1
    % output a success message
    fprintf('Done.\n');
else
    assert(solution.state ~=1)
end

% change the directory
cd(currentDir)
