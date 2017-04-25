function [hiCarbonRxns,zeroCarbonRxns,nCarbon] = findCarbonRxns(model,nCarbonThr)
% Returns the list of reactions that act of compounds which
% contain cabons greater than the thershhold set.
%
% USAGE:
%
%    [hiCarbonRxns, zeroCarbonRxns, nCarbon] = findCarbonRxns(model, nCarbonThr)
%
% INPUTS:
%    model:            Structure containing all necessary variables to described a
%                      stoichiometric model
%    nCarbonThr:       defines the min # of carbons that a metabolite, that is
%                      acted on in a reaction, can have in the final list of reactions
%
% OUTPUTS:
%    hiCarbonRxns:     The list of reactions that act on metabolites with
%                      greater than the threshold number of carbons
%    zeroCarbonRxns:   Reactions with no carbon
%    nCarbon:          The number of carbons in each metabolite in the model
%
% .. Authors:
%       - Markus Herrgard 2/7/07
%       - Richard Que 11/16/09 Modified to detect Mets with 1 Carbon.

currencyMets = {'h2o','co2','o2','h2o2','nh4','no2','no3','no','h2s',...
    'so3','so4','h','h2','pi','ppi','coa','accoa','ppcoa','aacoa',...
    'butcoa','succoa','atp','gtp','adp','gdp','amp','gmp','nad',...
    'nadp','nadh','nadph','fad','fadh','na1','ahcys','amet','thf','mlthf',...
    'q8h2','q8','mql8','mqn8','2dmmql8','2dmmq8'};
% above currency metabolitees not to be considered
% not sure if L-glutamate, L-glutamine should be included in this list

[baseMetNames,compSymbols,uniqueMetNames,uniqueCompSymbols] = parseMetNames(model.mets);

%[carbons,tmp] = regexp(model.metFormulas,'^C(\d+)','tokens','match');
%changed ^C(\d+) to C(\d*) to detect mets with 1 C and that do not start with C. R. Que (11/16/09)
[carbons,tmp] = regexp(model.metFormulas,'C(\d*)','tokens','match');

nCarbon = [];
for i = 1:length(carbons)
    if (~isempty(carbons{i}))
        if (~isempty(carbons{i}{1}{1}))  %to compensate for mets no numeric after C
            nCarbon(i) = str2num(carbons{i}{1}{1});
        else
            nCarbon(i) = 1;
        end
    else
        nCarbon(i) = 0;
    end
end

nCarbon = columnVector(nCarbon);

selectMets = (nCarbon >= nCarbonThr) & ~ismember(columnVector(baseMetNames),columnVector(currencyMets));

selectRxns = any(model.S(selectMets,:) ~= 0);

hiCarbonRxns = columnVector(model.rxns(selectRxns));

%selectMetsZero = (nCarbon == 0) & ~ismember(columnVector(baseMetNames),columnVector(currencyMets));
selectMetsZero = (nCarbon == 0); % not going to exclude the currency metabolites in this case

selectRxnsZero = sum(model.S ~= 0 & repmat(selectMetsZero,1,size(model.S,2))) == sum(model.S ~= 0);

zeroCarbonRxns = columnVector(model.rxns(selectRxnsZero));
