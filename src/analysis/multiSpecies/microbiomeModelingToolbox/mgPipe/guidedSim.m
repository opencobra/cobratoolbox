function [minFlux, maxFlux] = guidedSim(model, rl)
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
%    rl:            nx1 vector with the reactions of interest.
%    solver:        char with slver name to use.
%
% OUTPUTS:
%   minFlux:      Minimum flux for each reaction
%   maxFlux:      Maximum flux for each reaction
%
% ..Author:  Federico Baldini,  2017-2018

currentDir=pwd;

% Check for installation of fastFVA
try
    cpxControl.PARALLELMODE = 1;
    cpxControl.THREADS = 1;
    cpxControl.AUXROOTTHREADS = 2;
    [minFlux,maxFlux,optsol,ret] = fastFVA(model,99.99,'max',{},rl,'A',cpxControl);
    if ret~=0
        % infeasibilities in the solution
        minFlux=NaN(length(rl),1);
        maxFlux=NaN(length(rl),1);
    end
    % cpxControl.threads=1;
    % cpxControl.parallel=1;
    % cpxControl.auxrootthreads=2;
    % cpxControl.SCAIND =-1;
    %      [minFlux,maxFlux] = fastFVA(model,99.99,'max',{},rl,'A',cpxControl)

catch
    try
    warning('fastFVA could not run, so fluxVariability is instead used. Consider installing fastFVA for shorter computation times.');
    cd(currentDir)
    [minFlux,maxFlux] = fluxVariability(model,99.999,'max',rl);
    catch
        warning('No feasible solution in fluxVariability was found, using FBA instead.');
        cd(currentDir)

        minFluxTmp={};
        maxFluxTmp={};
        parfor i=1:length(rl)
            modelFVA = changeObjective(model,rl{i});
            solution = optimizeCbModel(modelFVA,'min');
            minFluxTmp{i} = solution;
            solution = optimizeCbModel(modelFVA,'max');
            maxFluxTmp{i} = solution;
        end
        minFlux=zeros(length(rl),1);
        maxFlux=zeros(length(rl),1);
        for i=1:length(rl)
            sol=minFluxTmp{i};
            minFlux(i,1) = sol.f;
            sol=maxFluxTmp{i};
            maxFlux(i,1) = sol.f;
        end
    end
end

end

