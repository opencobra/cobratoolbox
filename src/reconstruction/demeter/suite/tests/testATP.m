function [atpFluxAerobic, atpFluxAnaerobic] = testATP(model)
% Tests flux through the ATP demand reaction (DM_atp_c_) on a complex
% medium-constrained model, both aerobic and anaerobic.
%
% INPUT
% model             COBRA model structure
%
% OUTPUT
% atpFluxAerobic    Numeric vector showing the flux through the ATP demand
%                   reaction under aerobic conditions (mmol/gDW/h).
% atpFluxAnaerobic  Numeric vector showing the flux through the ATP demand
%                   reaction under anaerobic conditions (mmol/gDW/h)
%
% Stefania Magnusdottir, Nov 2017

fprintf('Testing flux through the ATP demand reaction\n')

% check if ATP demand reaction is present, add if not
if ~any(ismember(model.rxns, 'DM_atp_c_'))
    model = addReaction(model, 'DM_atp_c_', 'reactionFormula', ...
                        'atp[c] + h2o[c] -> adp[c] + h[c] + pi[c]');
end

% load complex medium
constraints = readtable('ComplexMedium.txt', 'Delimiter', 'tab');
constraints=table2cell(constraints);
constraints=cellstr(string(constraints));

% apply complex medium
model = useDiet(model,constraints);

% aerobic
model = changeRxnBounds(model, 'EX_o2(e)', -10, 'l');

% set objective
model = changeObjective(model, 'DM_atp_c_');

% FBA
FBA = optimizeCbModel(model, 'max');

% store result
atpFluxAerobic = FBA.f;
fprintf('Aerobic ATP flux on complex medium: %d mmol/gDW/h\n', FBA.f)

% anaerobic
model = changeRxnBounds(model, 'EX_o2(e)', 0, 'l');
% block internal O2-utilizing cytosolic reactions
if any(ismember(model.mets, 'o2[c]'))
    o2rxns = find(any(model.S(ismember(model.mets, 'o2[c]'), :), 1));
    model = changeRxnBounds(model, model.rxns(o2rxns), 0, 'b');
end

% set objective
model = changeObjective(model, 'DM_atp_c_');

% FBA
FBA = optimizeCbModel(model, 'max');

% store result
atpFluxAnaerobic = FBA.f;
fprintf('Anaerobic ATP flux on complex medium: %d mmol/gDW/h\n', FBA.f)
