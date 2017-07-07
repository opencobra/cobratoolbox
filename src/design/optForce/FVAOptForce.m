function [minFluxesW, maxFluxesW, minFluxesM, maxFluxesM, boundsW, boundsM] = FVAOptForce(model, constrW, constrM)
% This function calculates flux ranges for each reaction in the wild-type
% strain and in the mutant strain. Constraints should be specified for at
% least one strain (wild-type or mutant)
%
% USAGE:
%
%         [minFluxesW, maxFluxesW, minFluxesM, maxFluxesM, boundsW, boundsM] = FVAOptForce(model, constrWT, constrMT)
%
% INPUTS:
%    model:         Type: structure (COBRA model).
%                   Description: a metabolic model with at least
%                   the following fields:
%
%                     * .rxns - Reaction IDs in the model
%                     * .mets - Metabolite IDs in the model
%                     * .S -    Stoichiometric matrix (sparse)
%                     * .b -    RHS of Sv = b (usually zeros)
%                     * .c -    Objective coefficients
%                     * .lb -   Lower bounds for fluxes
%                     * .ub -   Upper bounds for fluxes
%    constrW:       Type: structure.
%                   Description: structure containing contraints
%                   for the wild-type strain. The structure has
%                   the following fields:
%
%                     * .rxnList - Reaction list (cell array)
%                     * .values -  Values for constrained reactions (double
%                       array)
%                     * .rxnBoundType - Type of bound (char array)
%                       ('b': both bounds; 'l': lower bound; 'u': upper bound)
%                       E.g.: constrW=struct('rxnList', {{'R75'; 'EX_suc'}}, ...
%                       'rxnValues', [0; 155.55], 'rxnBoundType', ['b'; 'b']);
%    constrM:       Type: structure.
%                   Description: structure containing contraints
%                   for the mutant strain.
%                   The structure has the following:
%                   fields:
%
%                     * .rxnList -      Reaction list (cell array)
%                     * .values -       Values for constrained reactions
%                       (double array)
%                     * .rxnBoundType - Type of bound (char array)
%                       ('b': both bounds; 'l': lower bound; 'u': upper bound)
%                       E.g.: constrW=struct('rxnList', {{'R75'; 'EX_suc'}}, ...
%                       'rxnValues', [0; 155.55], 'rxnBoundType', ['b'; 'b']);
%
% OUTPUTS:
%    minFluxesW:    Type: double array.
%                   Description: minimum values for reactions in
%                   the wild-type strain. It has dimensions
%                   (number of reactions) x 1
%    maxFluxesW:    Type: double array.
%                   Description: maximum values for reactions in
%                   the wild-type strain. It has dimensions
%                   (number of reactions) x 1
%    minFluxesM:    Type: double array.
%                   Description: minimum values for reactions in
%                   the mutant strain. It has dimensions
%                   (number of reactions) x 1
%    maxFluxesM:    Type: double array.
%                   Description: minimum values for reactions in
%                   the wild-type strain. It has dimensions
%                   (number of reactions) x 1
%    boundsW:       Type: cell array.
%                   Description: bounds given by the minimum and
%                   maximum values for reactions in the wild-type
%                   strain. The reaction IDs are in the first
%                   column, the minimun values in the second and
%                   the maximum values in the third. It has
%                   dimensions (number of reactions) x 3
%    boundsM:       Type: cell array.
%                   Description: bounds given by the minimum and
%                   maximum values for reactions in the mutant
%                   strain. The reaction IDs are in the first
%                   column, the minimun values in the second and
%                   the maximum values in the third. It has
%                   dimensions (number of reactions) x 3
%
% .. Author: - Sebastian Mendoza, May 30th 2017, Center for Mathematical Modeling, University of Chile, snmendoz@uc.cl

if nargin < 1 || isempty(model) % Inputs handling
    error('OptForce: No model specified');
else
    if ~isfield(model,'S'), error('OptForce: Missing field S in model');  end
    if ~isfield(model,'rxns'), error('OptForce: Missing field rxns in model');  end
    if ~isfield(model,'mets'), error('OptForce: Missing field mets in model');  end
    if ~isfield(model,'lb'), error('OptForce: Missing field lb in model');  end
    if ~isfield(model,'ub'), error('OptForce: Missing field ub in model');  end
    if ~isfield(model,'c'), error('OptForce: Missing field c in model'); end
    if ~isfield(model,'b'), error('OptForce: Missing field b in model'); end
end

if (nargin < 2 || isempty(constrW)) || (nargin < 3 || isempty(constrM))
    error('OptForce: You should specify constraints for at least one strain');
end

if nargin < 2 || isempty(constrW)
    constrW.rxnList = {};
else

    % check class for constrW
    if ~isstruct(constrW); error('OptForce: Incorrect format for input constrW. It should be a struct'); end;

    % check correct fields.
    if ~isfield(constrW,'rxnList'), error('OptForce: Missing field rxnList in constrW');  end
    if ~isfield(constrW,'rxnValues'), error('OptForce: Missing field rxnValues in constrW');  end
    if ~isfield(constrW,'rxnBoundType'), error('OptForce: Missing field rxnBoundType in constrW');  end

    % check correct length for fields
    if length(constrW.rxnList) == length(constrW.rxnValues) && length(constrW.rxnList) == length(constrW.rxnBoundType)
        if size(constrW.rxnList,1) > size(constrW.rxnList,2); constrW.rxnList = constrW.rxnList'; end;
        if size(constrW.rxnValues,1) > size(constrW.rxnValues,2); constrW.rxnValues = constrW.rxnValues'; end;
        if size(constrW.rxnBoundType,1) > size(constrW.rxnBoundType,2); constrW.rxnBoundType = constrW.rxnBoundType'; end;
    else
        error('OptForce: Incorrect size of fields in constrW');
    end

end

if nargin < 3 || isempty(constrM)
    constrM.rxnList = {};
else
    % check class for constrW
    if ~isstruct(constrM); error('OptForce: Incorrect format for input constrM. It should be a struct'); end;

    % check correct fields.
    if ~isfield(constrM,'rxnList'), error('OptForce: Missing field rxnList in constrM');  end
    if ~isfield(constrM,'rxnValues'), error('OptForce: Missing field rxnValues in constrM');  end
    if ~isfield(constrM,'rxnBoundType'), error('OptForce: Missing field rxnBoundType in constrM');  end

    % check correct length for fields
    if length(constrM.rxnList) == length(constrM.rxnValues) && length(constrM.rxnList) == length(constrM.rxnBoundType)
        if size(constrM.rxnList,1) > size(constrM.rxnList,2); constrM.rxnList = constrM.rxnList'; end;
        if size(constrM.rxnValues,1) > size(constrM.rxnValues,2); constrM.rxnValues = constrM.rxnValues'; end;
        if size(constrM.rxnBoundType,1) > size(constrM.rxnBoundType,2); constrM.rxnBoundType = constrM.rxnBoundType'; end;
    else
        error('OptForce: Incorrect size of fields in constrM');
    end
end

% Initialize model for wild-type strain
modelW = model;

% Set contraints for wildtype
for i = 1:length(constrW.rxnList)
    modelW = changeRxnBounds(modelW, constrW.rxnList{i}, constrW.rxnValues(i) ,constrW.rxnBoundType(i));
end

% FVA for wild-type
minFluxesW = zeros(length(modelW.rxns), 1);
maxFluxesW = zeros(length(modelW.rxns), 1);
for i = 1:length(modelW.rxns)
    modelW.c = zeros(size(modelW.c));
    modelW.c(i) = 1;
    fmin = optimizeCbModel(modelW, 'min');
    fmax = optimizeCbModel(modelW, 'max');
    if fmin.stat == 0 || fmax.stat == 0
        warning('Model infeasible. Make sure you entered correct constraints');
    end
    minFluxesW(i) = fmin.f;
    maxFluxesW(i) = fmax.f;
end

% Save summary information
boundsW = [model.rxns num2cell(minFluxesW) num2cell(minFluxesW)];

% Initialize model for mutant strain
modelM = model;

% Set contraints for mutant
for i = 1:length(constrM.rxnList)
    modelM = changeRxnBounds(modelM, constrM.rxnList{i}, constrM.rxnValues(i), constrM.rxnBoundType(i));
end

% FVA for mutant
minFluxesM = zeros(length(modelM.rxns), 1);
maxFluxesM = zeros(length(modelM.rxns), 1);
for i = 1:length(modelM.rxns)
    modelM.c = zeros(size(modelM.c));
    modelM.c(i) = 1;
    fmin = optimizeCbModel(modelM, 'min');
    fmax = optimizeCbModel(modelM, 'max');
    if fmin.stat == 0 || fmax.stat == 0
        warning('Model infeasible. Make sure you entered correct constraints');
    end
    minFluxesM(i) = fmin.f;
    maxFluxesM(i) = fmax.f;
end

% save summary information
boundsM = [model.rxns num2cell(minFluxesM) num2cell(minFluxesM)];

end
