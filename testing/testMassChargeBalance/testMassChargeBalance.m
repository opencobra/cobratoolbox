function status = testMassChargeBalance()

options = logical([0 0 0; 0 0 1; 0 1 0 ; 0 1 1; 1 0 0 ; 1 0 1 ; 1 1 0 ; 1 1 1]);
status = 1;
for i= 1:size(options,1)
    model = createToyModel(options(i,1),options(i,2),options(i,3));
    [massImbalance,imBalancedMass,imBalancedCharge,imBalancedRxnBool,Elements,missingFormulaeBool,balancedMetBool] = checkMassChargeBalance(model);
    if options(i,1)
        if ~any(imBalancedRxnBool(2:4)) || ~any(missingFormulaeBool) || ~any(any(isnan(massImbalance)))
            %There should be at least one imbalanced internal reaction and
            %one missing formula bool if we look at a network with missing
            %formulas Also, if we have unknown formulas, we should have NaN
            %values.
            status = 0;
        end
    else
        if any(missingFormulaeBool)
            %There should be no missing formulas (but we can't say anything
            %more
            status = 0;
        end
        if ~options(i,3) && ~any(balancedMetBool)
            %if we don't have a problem with the balanceing of reaction 4
            %we should have at least one balanced Metabolite
            status = 0;
        end
    end
    
    if options(i,2)
        if ~any(imBalancedCharge(2:4)) 
            %if we have a wrong charge this should come up in at least one
            %internal 
            status = 0;                    
        end
    else
        %Our reaction imbalanceing is happening in reaction 4, so 2 and 3
        %should have acceptable charge balances
        if any(imBalancedCharge(2:3))
            status = 0
        end
    end
    
    if options(i,3)
        %Now, we have an imbalanced reaction
        if ~any(imBalancedRxnBool(2:4)) || ~any(imBalancedCharge(2:4)) || ~any(cellfun(@isempty , imBalancedMass(2:4)))
            status = 0;
        end
    else
        if ~options(i,1) && ~options(i,2)
            if any(imBalancedRxnBool(2:4)) || any(imBalancedCharge(2:4)) || any(any(massImbalance(2:4,:)))
                status = 0;
            end
        end
    end
end
            