function [removableRxns, time] = checkModelConsistency(model, method, r, tol)
% This function is designed to quickly identify dead-end reactions in a
% stoichiometric model. The algorithm is largely based on the heuristic
% speed-up to Flux Variability Analysis (FVA) proposed by Jerby et al. [1],
% with modifications to further reduce computation time in Matlab. The
% function can operate independently to report the inactive reactions for
% an entire model, or within a pruning algorithm (e.g., MBA) to examine the
% effect of removing reactions.
%
%INPUTS
%	model           COBRA model structure
% 
%OPTIONAL INPUTS
%	method          parameter specifying whether to use fluxVaribility (1) or fastcc (2)
%	r               name of reaction to be removed (for model pruning in
%                   mCADRE or MBA)
%   tol             tolerance by which reactions are defined inactive after model extraction
%                   (recommended lowest value 1e-8 since solver tolerance
%                   is 1e-9)
% 
%OUTPUTS
%	removableRxns   list of IDs corresponding to reactions with 0 mininum and
%                   0 maximum flux
%	time            CPU time required to complete function
%
%This script is an adapted version of the implementation from
%https://github.com/jaeddy/mcadre. Modified and commented by S. Opdam and A. Richelle,
%May 2017.

    if numel(r)
       % Remove reaction r from the model
        model = removeRxns(model, r);
    end
    model.c(logical(model.c)) = 0;
    
    t0 = clock;

    % Maximize and minimize reactions to identify those with zero flux
    % capacity.
    % If the option is specified, fastFVA is used to quickly scan through all
    % reactions. **note: may want to include option to use fastFVA with GLPK
    % Check for inactive reactions with either fluxVariability or fastcc
    if method == 1
        display('Checking all reactions (fluxVariability)...')
        
        model.c(logical(model.c)) = 0;
        %This part can be modified to use fastFVA instead of
        %fluxVariability
        %[optMin, optMax] = fastFVA(model, 0, 'max', 'glpk');
        [optMin, optMax] = fluxVariability(model, 0, 'max', 'glpk');
        is_inactive = (abs(optMax) < tol) & (abs(optMin) < tol);
        inactiveRxns = model.rxns(is_inactive);

    else % otherwise, use FASTCC
        display('Checking all reactions (FASTCC)...')
        is_active = fastcc(model, tol);
        inactiveRxns = setdiff(model.rxns, model.rxns(is_active));
    end

    removableRxns = union(r, inactiveRxns);

    time = etime(clock,t0);
    display(['check_model_consistency time: ',num2str(time, '%1.2f'), ' s'])
end