function status = testMassChargeBalance()
%testMassChargeBalance tests the checkMassChargeBalance function using a
%small toy model.
%
% status = testMassChargeBalance()
%
%OUTPUT
% status        1 - if the test succeeds, 0 if any test fails. 
% v1  Thomas Pfau 09/02/2017


options = logical([0 0 0; 0 0 1; 0 1 0 ; 0 1 1; 1 0 0 ; 1 0 1 ; 1 1 0 ; 1 1 1]);
status = 1;
for i= 1:size(options,1)
    model = createToyModel(options(i,1),options(i,2),options(i,3));
    [massImbalance,imBalancedMass,imBalancedCharge,imBalancedRxnBool,~,missingFormulaeBool,balancedMetBool] = checkMassChargeBalance(model);
    if options(i,1)
        if ~any(imBalancedRxnBool(2:4)) || ~any(missingFormulaeBool) || ~any(any(isnan(massImbalance)))
            %There should be at least one imbalanced internal reaction and
            %one missing formula bool if we look at a network with missing
            %formulas Also, if we have unknown formulas, we should have NaN
            %values.
            disp('No missing formulas detected, while there should be some')
            status = 0;
        end
    else
        if any(missingFormulaeBool)
            %There should be no missing formulas (but we can't say anything
            %more
            disp('missing Formulas detected without missing formulas.')
            status = 0;
        end
        if ~options(i,3) && ~any(balancedMetBool)
            %if we don't have a problem with the balanceing of reaction 4
            %we should have at least one balanced Metabolite
            disp('There was an imbalanced reaction, but it was nto detected')
            status = 0;
        end
    end
    
    if options(i,2)
        if isempty(imBalancedCharge) || ~any(imBalancedCharge(2:4)) 
            %if we have a wrong charge this should come up in at least one
            %internal 
            disp('There should be a charge imbalance, but it was not found')
            status = 0;                    
        end
    else
        %Our reaction imbalanceing is happening in reaction 4, so 2 and 3
        %should have acceptable charge balances
        if ~isempty(imBalancedCharge) && any(imBalancedCharge(2:3))
            disp('An imbalanced charge was occuring in a reaction, that should not have imbalanced charges.')
            status = 0
        end
    end
    
    if options(i,3)
        %Now, we have an imbalanced reaction
        if ~any(imBalancedRxnBool(2:4)) || isempty(imBalancedCharge) || (~isempty(imBalancedCharge) && ~any(imBalancedCharge(2:4))) || ~any(cellfun(@isempty , imBalancedMass(2:4)))
            disp('There was an imbalanced reaction, but at least one indicator did not react to it.')
            status = 0;
        end
    else
        if ~options(i,1) && ~options(i,2)
            if any(imBalancedRxnBool(2:4)) || ( ~isempty(imBalancedCharge) && any(imBalancedCharge(2:4))) || any(any(massImbalance(2:4,:)))
                disp('There was no imbalanced reaction, but the function returned at least one imbalanced reaction.')
                status = 0;
            end
        end
    end
end
            