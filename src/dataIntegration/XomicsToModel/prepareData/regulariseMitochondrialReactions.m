function [modelOut, options, problemRxnList, fixedRxnList] = regulariseMitochondrialReactions(model, options, printLevel)
% Replace the metabolite h[i] with h[c] and remove the reaction Htmi (h[i] -> h[m])
%
% USAGE:
%
%    [modelOut, options, problemRxnList, fixedRxnList] = regulariseMitochondrialReactions(model, options, printLevel)
%
% INPUTS:
%    model:    COBRA model with fields:
%
%                * .S - `m x n` stoichiometric matrix
%                * .mets - `m x 1` metabolite identifiers
%                * .rxns - `n x 1` reaction identifiers
%
%    options:    structure of context-specific data, with fields:
%
%                  * .activeReactions - reactions known to be active (updated when a problem reaction is renamed)
%                  * .rxns2constrain - table of custom reaction constraints (updated when a problem reaction is renamed)
%
%    printLevel:    set greater than zero to print the old and new reaction formulas
%
% OUTPUTS:
%    modelOut:    the input model with h[i] replaced by h[c] in the affected reactions
%    options:    the input options structure with reaction identifiers updated
%    problemRxnList:    reactions that contained the metabolite h[i]
%    fixedRxnList:    the renamed replacement reactions
%
% .. Author: - Ronan Fleming
problemRxnList = model.rxns(model.S(contains(model.mets, 'h[i]'), :) ~= 0);

problemRxnList = setdiff(problemRxnList, 'Htmi');

if printLevel > 0
    display('Old reaction formulas')
    problemRxnFormulae = printRxnFormula(model, 'rxnAbbrList', problemRxnList, 'printFlag', true);
else
    problemRxnFormulae = printRxnFormula(model, 'rxnAbbrList', problemRxnList, 'printFlag', false);
end

for i = 1:length(problemRxnFormulae)
    fixedRxnFormulae{i, 1} = strrep(problemRxnFormulae{i}, '[i]', '[c]');
    fixedRxnList{i, 1} = [problemRxnList{i} 'new'];
end

% ATPS4mi	adp[m] + pi[m] + 4 h[i] 	->	h2o[m] + 3 h[m] + atp[m] 
% CYOR_u10mi	2 h[m] + 2 ficytC[m] + q10h2[m] 	->	q10[m] + 2 focytC[m] + 4 h[i] 
% NADH2_u10mi	5 h[m] + nadh[m] + q10[m] 	->	nad[m] + q10h2[m] + 4 h[i] 
% CYOOm3i	o2[m] + 7.92 h[m] + 4 focytC[m] 	->	1.96 h2o[m] + 4 ficytC[m] + 0.02 o2s[m] + 4 h[i] 
% CYOOm2i	o2[m] + 8 h[m] + 4 focytC[m] 	->	2 h2o[m] + 4 ficytC[m] + 4 h[i] 

hiInd = find(strcmp(model.mets, 'h[i]'));
hcInd = find(strcmp(model.mets, 'h[c]'));
for i = 1:length(problemRxnList)
    rxnBool = strcmp(model.rxns, problemRxnList{i});
    model.S(hcInd, rxnBool) = model.S(hiInd, rxnBool);
    model.S(hiInd, rxnBool) = 0;
    model.rxns{rxnBool} = fixedRxnList{i};
    
    %replace the corresponding reaction in the active reaction list
    
    if isfield(options, 'activeReactions')
        rxnBool = strcmp(options.activeReactions, problemRxnList{i});
        if any(rxnBool)
            options.activeReactions{rxnBool} = fixedRxnList{i};
        end
    end
    %replace the corresponding reaction in the rxns2constrain list
     if isfield(options, 'rxns2constrain')
         rxnBool = strcmp(options.rxns2constrain.rxns, problemRxnList{i});
         if any(rxnBool)
         options.rxns2constrain.rxns{rxnBool}=fixedRxnList{i};
         end
     end
%     
%     %replace the old active reaction abbreviations with new ones
%     %options.activeReactions = strrep(options.activeReactions,problemRxnList,fixedRxnList);
%     for i=1:length(problemRxnList)
%         bool = strcmp(options.activeReactions,problemRxnList{i});
%         if any(bool)
%             options.activeReactions{bool}=fixedRxnList{i};
%         end
%     end
    
end

% Htmi	h[i] 	->	h[m] 
[modelOut, metRemoveList, ctrsRemoveList] = removeRxns(model, 'Htmi', 'metRemoveMethod', 'exclusive', 'ctrsRemoveMethod','infeasible');

if ~all(strcmp(metRemoveList, 'h[i]'))
    if printLevel > 0
        printRxnFormula(modelOut, fixedRxnList);
    end
    error('Incorrect removal of metabolite h[i]')
end

if printLevel > 0
    display('')
    display('New reaction formulas')
    problemRxnFormulae = printRxnFormula(model, fixedRxnList);    
end

