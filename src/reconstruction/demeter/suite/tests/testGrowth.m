function [AerobicGrowth, AnaerobicGrowth] = testGrowth(model, biomassReaction)
% Tests growth, both on unlimited media and complex medium, both aerobic and
% anaerobic conditions. In anaerobic conditions, both oxygen uptake
% (exchange reaction) and cytosolic oxygen-utilizing reactions are blocked.
%
% INPUT
% model             COBRA model structure
% biomassReaction   String listing the biomass reaction
%
% OUTPUT
% AerobicGrowth     Numeric vector showing the flux through the biomass
%                   reaction (aerobic conditions):
%                   Column 1: "unlimited" media (all exchanges to -1000
%                   mmol/gDW/h)
%                   Column 2: complex medium as defined in
%                   InputFiles\ComplexMedium.txt
% AnaerobicGrowth   Numeric vector showing the flux through the biomass
%                   reaction (anaerobic conditions):
%                   Column 1: "unlimited" media (all exchanges to -1000
%                   mmol/gDW/h)
%                   Column 2: complex medium as defined in
%                   InputFiles\ComplexMedium.txt
%
% Stefania Magnusdottir, Nov 2017

tol=0.000001;

AerobicGrowth = zeros(1, 2);
AnaerobicGrowth = zeros(1, 2);

% Test if model can grow
% set "unlimited" constraints
model = changeRxnBounds(model, model.rxns(strncmp('EX_', model.rxns, 3)), -1000, 'l');
model = changeRxnBounds(model, model.rxns(strncmp('EX_', model.rxns, 3)), 1000, 'u');

% set objective
if nargin < 2
    error('Please provide biomass reaction')
end
if ~any(ismember(model.rxns, biomassReaction))
    error(['Biomass reaction "', biomassReaction, '" not found in model.'])
else
    model = changeObjective(model, biomassReaction);
end

% aerobic environment
modelO2 = changeRxnBounds(model, 'EX_o2(e)', -10, 'l');

% simulate
FBA = optimizeCbModel(modelO2, 'max');
if FBA.stat==1
    AerobicGrowth(1, 1) = FBA.f;
    if FBA.f > tol
        fprintf('Model grows on unlimited media (aerobic), flux through BOF: %d mmol/gDW/h\n', FBA.f)
    else
        warning('Model cannot grow on unlimited media (aerobic)')
    end
else
    warning('Model cannot grow on unlimited media (aerobic)')
end

% anaerobic environment
modelNoO2 = changeRxnBounds(model, 'EX_o2(e)', 0, 'l');

% simulate
FBA = optimizeCbModel(modelNoO2, 'max');
if FBA.stat==1
    AnaerobicGrowth(1, 1) = FBA.f;
    if FBA.f > tol
        fprintf('Model grows on unlimited media (anaerobic), flux through BOF: %d mmol/gDW/h\n', FBA.f)
    else
        warning('Model cannot grow on unlimited media (anaerobic)')
    end
else
    warning('Model cannot grow on unlimited media (anaerobic)')
end

% implement complex medium
constraints = readtable('ComplexMedium.txt', 'Delimiter', 'tab');
constraints=table2cell(constraints);
constraints=cellstr(string(constraints));

% apply complex medium
model = useDiet(model,constraints);

% aerobic environment
modelO2 = changeRxnBounds(model, 'EX_o2(e)', -10, 'l');

% simulate
FBA = optimizeCbModel(modelO2, 'max');
if FBA.stat==1
    AerobicGrowth(1, 2) = FBA.f;
    if FBA.f > tol
        fprintf('Model grows on complex medium (aerobic), flux through BOF: %d mmol/gDW/h\n', FBA.f)
    else
        warning('Model cannot grow on complex medium (aerobic)')
    end
else
    warning('Model cannot grow on complex medium (aerobic)')
end

% anaerobic environment
modelNoO2 = changeRxnBounds(model, 'EX_o2(e)', 0, 'l');

% simulate
FBA = optimizeCbModel(modelNoO2, 'max');
if FBA.stat==1
    AnaerobicGrowth(1, 2) = FBA.f;
    if FBA.f > tol
        fprintf('Model grows on complex medium (anaerobic), flux through BOF: %d mmol/gDW/h\n', FBA.f)
    else
        warning('Model cannot grow on complex medium (anaerobic)')
    end
else
    warning('Model cannot grow on complex medium (anaerobic)')
end

end
