function [minFlux,maxFlux]= guidedSim(model,fvaType,rl)
% This function is part of the MgPipe pipeline and runs FVA on a series of 
% selected reactions with different possible FVAfunctions. Solver is 
% automatically set to 'cplex', objective function is maximized, and 
% optPercentage set to 99.99.  
%
% INPUTS:
%    model:         COBRA model structure with n joined microbes with biomass
%                   metabolites 'Microbe_biomass[c]'.
%    fvaType:       double indicating what FVA function to use 
%                   fvaType=1 for fastFVA; fvaType=0 for fastFVAex; fvaType=3 
%                   for fluxVariability
%    rl:            nx1 vector with the reactions of interest.
%
% OUTPUTS:
%   minFlux:      Minimum flux for each reaction
%   maxFlux:      Maximum flux for each reaction
%
% ..Author:  Federico Baldini,  2017-2018
if fvaType == 1 
      cpxControl.PARALLELMODE=1;
      cpxControl.THREADS=1;
      cpxControl.AUXROOTTHREADS=2;
      %[minFlux,maxFlux] = fastFVA(model,99.999,'max','cplex',rl,'A')
      %cpxControl.threads=1;
      %cpxControl.parallel=1;
      %cpxControl.auxrootthreads=2;
      %cpxControl.SCAIND =-1;
     [minFlux,maxFlux] = fastFVA(model,99.99,'max',{},rl,'A',cpxControl) 

 end
 if fvaType == 0 
     warning('fast FVAex function used consider using fastFVA  > newFVA=1')
     [minFlux,maxFlux] = fastFVAex(model,99.99,'max','cplex',rl)
 end 
 if fvaType == 3 
     warning('Normal FVA in use: consider using fastFVA  > newFVA=1')
     model.S=model.A
     [minFlux,maxFlux] = fluxVariability(model,99.999,'max',rl)
 end
end
 
