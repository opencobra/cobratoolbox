function objectiveAbbr = checkObjective(model)
% checkObjective print out the Stoichiometric Coefficients for each
% Metabolite, with the name of the objective
%
% objectiveAbbr = checkObjective(model)
%
% INPUT:
%  model:             COBRA model structure
%
% OUTPUT:
%  objectiveAbbr     Objective reaction abbreviation
%
% Ronan Fleming 22/10/2008
% Thomas Pfau 15/12/2015 - Made the function compatible with sparse S matrices
% Laurent Heirendt March 2017 - Compatibility with large models and conversion to table

objRxnInd = find(model.c ~= 0);
objectiveAbbr = model.rxns(objRxnInd);
T = cell(length(objRxnInd), 1);

if isempty(objRxnInd)
    warning('There is no objective!');
else
    objMetVect = {};
    objRxnVect = {};
    objCoeffVect = {};
    for k = 1:length(objRxnInd)
        objMetInd = find(model.S(:, objRxnInd(k)));
        objMetVect{k} = model.mets(objMetInd);
        rxnName = model.rxns(objRxnInd(k));
        objCoeffVect{k} = full(model.S(objMetInd, objRxnInd(k)));

        objRxnVect = {};
        objRxnIDVect = {};
        % fill the list with the reaction name and ID
        for m = 1:length(objMetInd)
            objRxnVect{m} = char(rxnName);
            objRxnIDVect{m} = objRxnInd(k);
        end

        % save the table for reaction k
        T{k} = table(objCoeffVect{k}, categorical(objMetVect{k}), objMetInd, categorical(objRxnVect'), cell2mat(objRxnIDVect'), ...
                     'VariableNames', {'Coefficient', 'Metabolite', 'metID', 'Reaction', 'RxnID'});

        % concatenate the tables
        if k == 1
            summaryT = T{1};
        else
            summaryT = vertcat(summaryT, T{k});
        end
    end

    % display a summary
    display(summaryT);
end
