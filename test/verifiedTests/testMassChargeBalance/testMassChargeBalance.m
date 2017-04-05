% The COBRAToolbox: testMassChargeBalance.m
%
% Purpose:
%     - testMassChargeBalance tests the checkMassChargeBalance function using a small toy model.
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
