% The COBRAToolbox: testMassChargeBalance.m
%
% Purpose:
%     - testMassChargeBalance tests the checkMassChargeBalance function using a small toy model.
%
% Function under test:
%     src/reconstruction/modelGeneration/massBalance/checkMassChargeBalance.m
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: imBalancedMass is [] instead of an nRxn x 1 cell when every reaction is mass balanced
%       SEVERITY: wrong-result
%       TRIGGER: a model without exchange reactions whose reactions are all mass balanced, for
%         example cm = createModel({'R1','R2'}, {'',''}, {'a[c] -> b[c]', 'b[c] -> c[c]'},
%         'printLevel', 0); cm.metFormulas = {'C';'C';'C'}; cm.metCharges = [0;0;1];
%         [~, imBalancedMass] = checkMassChargeBalance(cm)
%       OBSERVED: (R2025a, 2026-11-23) imBalancedMass = [] (lines 200-202); callers that index
%         it as a cell stop, for example testModelMassChargeBalance at its line 83 ("Brace
%         indexing is not supported for variables of this type.")
%       EXPECTED: an nRxn x 1 cell of '' (OUTPUTS: "nRxn x 1 cell with mass imbalance")
%       LINES: 200-202
%     - DEFECT: printLevel -1 and 2 stop when every reaction is mass balanced and a charge is not
%       SEVERITY: error
%       TRIGGER: cm = createModel({'R1','R2'}, {'',''}, {'a[c] -> b[c]', 'b[c] -> c[c]'},
%         'printLevel', 0); cm.metFormulas = {'C';'C';'C'}; cm.metCharges = [0;0;1];
%         cm = findSExRxnInd(cm); checkMassChargeBalance(cm, -1, 'x') (or printLevel 2)
%       OBSERVED: (R2025a, 2026-11-23) "Brace indexing is not supported for variables of this
%         type." at line 235 (printLevel -1) and line 260 (printLevel 2): imBalancedMass is set
%         to [] at line 201 when every reaction is mass balanced, then read as a cell
%       EXPECTED: the mass balanced, charge imbalanced reactions written to the file (-1) or
%         printed (2), as for a model with some mass imbalanced reaction
%       LINES: 200-202, 235, 260
%     - DEFECT: printLevel 2 lists the mass balanced, charge imbalanced reactions by a stale index
%       SEVERITY: cosmetic
%       TRIGGER: the model above with metFormulas {'C';'C';'CH'} and metCharges [0;1;1],
%         checkMassChargeBalance(cm, 2)
%       OBSERVED: (R2025a, 2026-11-23) R1 (mass balanced, charge imbalanced) is not printed under
%         "Mass balanced, but charged imbalanced reactions:": line 260 tests imBalancedMass{p, 1},
%         p being the last index of the loop of line 180, instead of q
%       EXPECTED: every mass balanced, charge imbalanced internal reaction printed
%       LINES: 260
%
% Authors:
%     - Original file: Thomas Pfau 09/02/2017
%     - CI integration: Laurent Heirendt Feburary 2017
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMassChargeBalance'));
cd(fileDir);

options = logical([0 0 0; 0 0 1; 0 1 0; 0 1 1; 1 0 0; 1 0 1; 1 1 0; 1 1 1]);

for i= 1:size(options, 1)
    for printLevel = -1:2
        model = createToyModel(options(i, 1), options(i, 2), options(i, 3));
        [massImbalance, imBalancedMass, imBalancedCharge, imBalancedRxnBool, ~, missingFormulaeBool, balancedMetBool] = checkMassChargeBalance(model, printLevel);

        if options(i, 1)
            % there should be at least one imbalanced internal reaction and
            % one missing formula bool if we look at a network with missing
            % formulas Also, if we have unknown formulas, we should have NaN
            % values.
            %assert(~any(imBalancedRxnBool(2:4)) || ~any(missingFormulaeBool) || ~any(any(isnan(massImbalance))))
            assert(any(imBalancedRxnBool(2:4)) && any(missingFormulaeBool) && any(any(isnan(massImbalance))))
        else
            % there should be no missing formulas (but we can't say anything more)
            assert(~any(missingFormulaeBool))

            % if we don't have a problem with the balancing of reaction 4 we should have at least one balanced Metabolite
            if ~options(i, 3)
                assert(any(balancedMetBool))
            end
        end

        if options(i, 2)
            %if we have a wrong charge this should come up in at least one internal
            assert(~isempty(imBalancedCharge) && any(imBalancedCharge(2:4)))
        else
            % Our reaction imbalanceing is happening in reaction 4, so 2 and 3
            % should have acceptable charge balances
            assert(isempty(imBalancedCharge) || ~any(imBalancedCharge(2:3)))
        end

        if options(i, 3)
            % Now, we have an imbalanced reaction
            assert( ~(~any(imBalancedRxnBool(2:4)) || isempty(imBalancedCharge) || (~isempty(imBalancedCharge) && ~any(imBalancedCharge(2:4))) || ~any(cellfun(@isempty , imBalancedMass(2:4)))))
        elseif ~options(i, 1) && ~options(i, 2)
            assert(~(any(imBalancedRxnBool(2:4)) || ( ~isempty(imBalancedCharge) && any(imBalancedCharge(2:4))) || any(any(massImbalance(2:4,:)))))
        end
    end
end

fileNames = {'charge_imbalanced_reactions.txt', 'mass_imbalanced_reactions.txt', 'metabolites_without_formulae.txt'};

for i = 1:length(fileNames)
    % remove the generated files
    fullFileNamePath = [fileparts(which(mfilename)), filesep, fileNames{i}];
    if exist(fullFileNamePath, 'file') == 2
        system(['rm ', fullFileNamePath]);
    end
end

% change the directory
cd(currentDir)
