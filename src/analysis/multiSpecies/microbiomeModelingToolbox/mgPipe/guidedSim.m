function [minFlux, maxFlux] = guidedSim(model, fvaType, rl)
% This function is part of the MgPipe pipeline and runs FVAs on a series of
% selected reactions with different possible FVA functions. Solver is
% automatically set to 'cplex', objective function is maximized, and
% optPercentage set to 99.99.
%
% USAGE:
%
%   [minFlux, maxFlux] = guidedSim(model, fvaType, rl)
%
% INPUTS:
%    model:         COBRA model structure with n joined microbes with biomass
%                   metabolites 'Microbe_biomass[c]'.
%    fvaType:       char defining whether flux variability analysis to compute the 
%                   metabolic profiles should be performed, and which FVA function 
%                   should be used. Allowed inputs are 'fastFVA', 'fluxVariability', 'none'.
%    rl:            nx1 vector with the reactions of interest.
%    solver:        char with slver name to use.
%
% OUTPUTS:
%   minFlux:      Minimum flux for each reaction
%   maxFlux:      Maximum flux for each reaction
%
% ..Author:  Federico Baldini,  2017-2018

if strcmp(fvaType,'fastFVA')
      warning('fastFVA in use. This function is compatible only with cplex solver. If you don?t have a compatible cplex version please set > fvaType=3. If you have CPLEX but the following code crushes please consider separatelly running > generateMexFastFVA() and then running again the pipeline')
%       cpxControl.PARALLELMODE = 1;
%       cpxControl.THREADS = 1;
%       cpxControl.AUXROOTTHREADS = 2;
      [minFlux,maxFlux] = fastFVA(model,99.99,'max',{},rl,'A');
      % cpxControl.threads=1;
      % cpxControl.parallel=1;
      % cpxControl.auxrootthreads=2;
      % cpxControl.SCAIND =-1;
%      [minFlux,maxFlux] = fastFVA(model,99.99,'max',{},rl,'A',cpxControl)

 elseif strcmp(fvaType,'fluxVariability')
     warning('Normal FVA in use with your available solver: consider using fastFVA  > fvaType=1')
     % changeCobraSolver(solver,'all')
     [minFlux,maxFlux] = fluxVariability(model,99.999,'max',rl);
 end

end

