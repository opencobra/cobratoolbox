function objectiveAbbr = checkObjective(model)
% Prints out the Stoichiometric Coefficients for each
% Metabolite, with the name of the objective
%
% USAGE:
%
%    objectiveAbbr = checkObjective(model)
%
% INPUT:
%    model:            COBRA model structure with fields:
%
%                        * .c - `n` x 1 objective coefficient vector
%                        * .rxns - `n` x 1 cell array of reaction identifiers
%                        * .S - `m` x `n` stoichiometric matrix
%                        * .mets - `m` x 1 cell array of metabolite identifiers
%
% OUTPUT:
%    objectiveAbbr:    Objective reaction abbreviation
%
% .. Authors:
%       - Ronan Fleming 22/10/2008
%       - Thomas Pfau 15/12/2015 - Made the function compatible with sparse S matrices
%       - Laurent Heirendt March 2017 - Compatibility with large models and conversion to table

warning('checkObjective will be depreciated because the function name is a misnomer, please use printObjective instead')

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
