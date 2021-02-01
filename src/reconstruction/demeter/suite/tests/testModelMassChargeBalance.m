function [massImbalancedRxns, chargeImbalancedRxns, imbalancedRxnMets, metsMissingFormulas] = testModelMassChargeBalance(model, excludeExchanges, biomassReaction)
% Uses the COBRA Toolbox function checkMassChargeBalance to test for mass
% and charge imbalanced reactions. Reports the mass and/or charge imblanced
% reactions along with reaction formulas and imblanced elements. Reports
% metabolites involved in mass or charge imblanced reactions along with
% their formulas and charges.
%
% INPUT
% model                 COBRA model structure
% excludeExchanges      Exclude exchange reactions when reporting imbalanced
%                       reactions (default: true).
%
% OPTIONAL INPUT
% biomassReaction       Model biomass reaction (will be excluded from
%                       report if provided)
%
% OUTPUT
% massImbalancedRxns    Cell array listing (col 1) all mass imbalanced
%                       reactions in the model, (col 2) the reaction
%                       formulas, and (col 3) the imbalanced elements.
% chargeImbalancedRxns  Cell array listing (col 1) all charge imbalanced
%                       reactions in the model, (col 2) the reaction
%                       formulas, and (col 3) the imblanced elements.
% imbalancedRxnMets     Cell array listing (col 1) all metabolites involved
%                       in any mass or charge imblanced reaction, (col 2)
%                       the metabolite name, (col 3) the metabolite
%                       formula, and (col 4) the metabolite charge.
% metsMissingFormulas   Cell array listing (col 1) all metabolites that do
%                       not have metabolite formulas and (col 2) the
%                       metabolite names.
%
% Stefania Magnusdottir, Oct 2017

if nargin < 2
    excludeExchanges = true;
    biomassReaction = '';
end

if nargin < 3
    biomassReaction = '';
else
    if ~any(ismember(model.rxns, biomassReaction))
        error(['Biomass reaction "', biomassReaction, '" not found in model.'])
    end
end

[~, imBalancedMass, imBalancedCharge, imBalancedRxnBool, ~, missingFormulaeBool, ~] = checkMassChargeBalance(model);

% Metabolites without formulas
metsMissingFormulas = cell(0, 2);
if ~any(missingFormulaeBool)
    disp('All metabolites have formulas.');
else
    fprintf('Model contains %d (%4.2f%%) metabolites without formulas.\n', ...
            sum(missingFormulaeBool), 100 * sum(missingFormulaeBool) / length(model.mets));
    metsMissingFormulas(1, 1:2) = {'Metabolite', 'Name'};
    metsMissingFormulas(2:sum(missingFormulaeBool) + 1, 1) = model.mets(missingFormulaeBool);
    metsMissingFormulas(2:sum(missingFormulaeBool) + 1, 2) = model.metNames(missingFormulaeBool);
end

% Mass/charge imbalanced reactions
massImbalancedRxns = cell(0, 3);
chargeImbalancedRxns = cell(0, 3);
imbalancedRxnMets = cell(0, 4);

if ~any(imBalancedRxnBool)
    disp('All reactions mass and charge balanced.');
else
    if excludeExchanges
        exchRxns = findExcRxns(model);
        imBalancedRxnBool(exchRxns) = 0;
        imBalancedMass(exchRxns) = {''};
        imBalancedCharge(exchRxns) = 0;
    end

    if ~isempty(biomassReaction)
        bmInd = find(ismember(model.rxns, biomassReaction));
        imBalancedRxnBool(bmInd) = 0;
        imBalancedMass(bmInd) = {''};
        imBalancedCharge(bmInd) = 0;
    end

    % Total number of imbalanced reactions
    fprintf('Model contains %d (%4.2f%%) imbalanced reactions.\n', ...
            sum(imBalancedRxnBool), 100 * sum(imBalancedRxnBool) / length(model.rxns));

    % list of mass/charge imbalanced reactions
    massImbalancedRxns(1, 1:3) = {'Reaction', 'Formula', 'Element imbalances'};
    massImbalancedRxns(2:sum(~strcmp(imBalancedMass, '')) + 1, 1) = model.rxns(~strcmp(imBalancedMass, ''));
    chargeImbalancedRxns(1, 1:3) = {'Reaction', 'Formula', 'Charge imbalances'};
    chargeImbalancedRxns(2:sum(imBalancedCharge ~= 0) + 1, 1) = model.rxns(imBalancedCharge ~= 0);

    % Number of mass/charge/mass&charge imbalanced reactions
    fprintf('Mass imbalanced reactions: %d\n', length(setdiff(massImbalancedRxns(:, 1), chargeImbalancedRxns(:, 1))));
    fprintf('Charge imbalanced reactions: %d\n', length(setdiff(chargeImbalancedRxns(:, 1), massImbalancedRxns(:, 1))));

    % report reaction, reaction formula, and which elements are imbalanced
    massImbalancedRxns(2:size(massImbalancedRxns, 1), 2) = printRxnFormula(model, ...
                                                                           'rxnAbbrList', massImbalancedRxns(2:size(massImbalancedRxns, 1), 1), ...
                                                                           'printFlag', false);
    massImbalancedRxns(2:size(massImbalancedRxns, 1), 3) = ...
        imBalancedMass(ismember(model.rxns, massImbalancedRxns(2:size(massImbalancedRxns, 1), 1)));

        % report reaction, reaction formula, and which elements are imbalanced
    chargeImbalancedRxns(2:size(chargeImbalancedRxns, 1), 2) = printRxnFormula(model, ...
                                                                               'rxnAbbrList', chargeImbalancedRxns(2:size(chargeImbalancedRxns, 1), 1), ...
                                                                               'printFlag', false);
    chargeImbalancedRxns(2:size(chargeImbalancedRxns, 1), 3) = ...
        cellstr(num2str(imBalancedCharge(ismember(model.rxns, chargeImbalancedRxns(2:size(chargeImbalancedRxns, 1), 1)))));

        % List all metabolites involved in imbalanced reactions and their
        % formula and charge
    imbalancedRxnMets(1, 1:4) = {'Metabolite', 'Name', 'Formula', 'Charge'};
    imbalancedRxnMets(2:sum(any(model.S(:, imBalancedRxnBool), 2)) + 1, 1) = model.mets(any(model.S(:, imBalancedRxnBool), 2));
    imbalancedRxnMets(2:size(imbalancedRxnMets, 1), 2) = ...
        model.metNames(ismember(model.mets, imbalancedRxnMets(2:size(imbalancedRxnMets, 1), 1)));
    imbalancedRxnMets(2:size(imbalancedRxnMets, 1), 3) = ...
        model.metFormulas(ismember(model.mets, imbalancedRxnMets(2:size(imbalancedRxnMets, 1), 1)));
    imbalancedRxnMets(2:size(imbalancedRxnMets, 1), 4) = ...
        cellstr(num2str(model.metCharges(ismember(model.mets, imbalancedRxnMets(2:size(imbalancedRxnMets, 1), 1)))));
end

end
