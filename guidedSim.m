function [minFlux,maxFlux]= guidedSim(model,FVAtype,rl)
% This function is part of the MgPipe pipeline and runs FVA on a series of 
% selected reactions with different possible FVAfunctions. Solver is 
% automatically set to 'cplex', objective function is maximized, and 
% optPercentage set to 99.99.  
%
% INPUTS
%   model         COBRA model structure with n joined microbes with biomass
%                 metabolites 'Microbe_biomass[c]'.
%   FVAtype       double indicating what FVA function to use 
%                 FVAtype=1 for fastFVA; FVAtype=0 for fastFVAex; FVAtype=3 
%                 for fluxVariability
%   rl            nx1 vector with the reactions of interest.
%
% OUTPUTS
%   minFlux:      Minimum flux for each reaction
%   maxFlux:      Maximum flux for each reaction
%
% Author: - Federico Baldini,  2017-2018
if FVAtype == 1 
      cpxControl.PARALLELMODE=1;
      cpxControl.THREADS=1;
      cpxControl.AUXROOTTHREADS=2;
     %[minFlux,maxFlux] = fastFVA(model,99.999,'max','cplex',rl,'A')
      [minFlux,maxFlux] = fastFVA(model,99.99,'max',{},rl,'A',cpxControl) 

 end
 if FVAtype == 0 
     warning('fast FVAex function used consider using fastFVA  > newFVA=1')
     [minFlux,maxFlux] = fastFVAex(model,99.99,'max','cplex',rl)
 end 
 if FVAtype == 3 
     warning('Normal FVA in use: consider using fastFVA  > newFVA=1')
     model.S=model.A
     [minFlux,maxFlux] = fluxVariability(model,99.999,'max',rl)
 end
end
 
%cpxControl.threads=1;
%cpxControl.parallel=1;
%cpxControl.auxrootthreads=2;
%cpxControl.SCAIND =-1;