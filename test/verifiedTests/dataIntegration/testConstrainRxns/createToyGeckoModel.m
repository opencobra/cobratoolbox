function [model, specificData, param] = createToyGeckoModel()
    % - creates a toy GECKO model for testing the case 'allConstraints' of
    % 'constrainRxns' that:
    % * couples extra variables (enzyme usage) with reaction fluxes:
    %   v1 - e1 = 0
    %   v2 - e2 = 0
    %   e1 + e2 - epool = 0
    % * has an enzyme pool, which is minimized
    model.mets = {'met'};
    model.rxns = {'v1'; 'v2'};
    model.rxnNames = model.rxns;
    model.S = [1 -1];
    model.lb = [0; 0];
    model.ub = [10; 10];
    model.evars = {'e1'; 'e2'; 'epool'};
    model.evarNames = model.evars;
    model.evarlb = [0; 0; 0];
    model.evarub = [1; 1; 1];
    model.evarc = [0; 0; 1]; % epool is the objective
    nRxn = numel(model.rxns);
    model.c = zeros(nRxn, 1);
    model.osense = 1; % minimize epool
    model.osenseStr = "min";
    model.E = zeros(size(model.S, 1), numel(model.evars));
    model.C = [1 0; 0 1; 0 0];
    model.D = [-1 0 0; 0 -1 0; 1 1 -1];
    model.d = [0; 0; 0];
    model.dsense = ['E'; 'E'; 'E'];
    model.ctrs = {'v1_minus_e1'; 'v2_minus_e2'; 'e1_plus_e2_minus_epool'};
    model.ctrNames = model.ctrs;
    specificData = struct();
    specificData.exoMet = table("epool", 10, 1, 'VariableNames', {'varID', 'mean', 'SD'});
    param = struct();
    param.metabolomicWeights = 'SD';
    param.weightLower_flx_default = inf; % do not relax reaction flux bounds
    param.weightUpper_flx_default = inf;
    param.weightLower_e_default = 1; % allow relaxation of bounds of extra variables, as it is not Inf
    param.weightUpper_e_default = 1;
end

