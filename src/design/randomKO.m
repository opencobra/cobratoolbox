function [products,productRates,KOrxns,BOF] = randomKO(modelRed,selectedRxns,N)
% Knocks out `N` random genes and reports products from FBA
%
% USAGE:
%
%    [products, productRates, KOrxns, BOF] = randomKO(modelRed, selectedRxns, N)
%
% INPUTS:
%    modelRed:         a reduced model (from the `reduceModel.m` function)
%    selectedRxns:     the reactions eligible for deletion (from the
%                      `getOptKnockTargets.m` function)
%    N:                the number of reactions to randomly knockout
%
% OUTPUTS:
%    products:         the exchange reactions that produce a siginifcant output
%    productRates:     the rates of those exhange reactions
%    KOrxns:           the `N` reactions randomly knocked out
%    BOF:              the value of the biomass objective function of the
%                      knockout strain
%
% .. Author: - Jeff Orth (5/15/07)

rxnNum = length(selectedRxns); % pick N unique random targets, no repeats, no 0s
repeats = true;
while (repeats == true)
    rands = ceil(rxnNum*rand(1,N));
    repeatsFound = false;
    for i = 1:N
        for j = 1:N
            if ((i ~= j)&&(rands(i)==rands(j)))||(rands(i)==0)
                repeatsFound = true;
            end
        end
    end
    repeats = repeatsFound;
end
targets = selectedRxns(rands);

% knockout the N targets
modelKO = modelRed;
for i = 1:N
    modelKO = changeRxnBounds(modelKO,targets(i),0,'b');
end

try
    % do flux balance analysis, optimize BOF
    FBAsolutionKO = optimizeCbModel(modelKO,'max',false);

    % list products
    [selExc,selUpt] = findExcRxns(modelKO,false,true);
    excRxns = find(selExc);  %get indices of all exchange reactions
    productRates = FBAsolutionKO.x(excRxns);  %get exchange rates of all products
    sigProds = excRxns(find(productRates > .000001));  %get indices of sigificant products
    products = modelKO.rxns(sigProds);  %list the significant products
    productRates = FBAsolutionKO.x(sigProds);  %list the exchange rates of the products
    KOrxns = targets;  %list the knockout targets
    BOF = FBAsolutionKO.f;  %list the biomass objective function
catch
    %no FBA solution was found, do another random KO
    [products,productRates,KOrxns,BOF] = randomKO(modelRed,selectedRxns,N);
end
