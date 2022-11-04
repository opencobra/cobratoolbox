function [modelOut,nTotalAtomTransitions] = checkRXNFiles(model, RXNFileDir)
% Checks whether the set of RXN files coresponding to a model have the consistent stoichiometry and are elementally balanced
%
% INPUTS:
%    model:         Directed stoichiometric hypergraph
%                   Represented by a matlab structure with following fields:
%
%                     * .S - The `m` x `n` stoichiometric matrix for the metabolic network
%                     * .model.mets - An `m` x 1 array of metabolite identifiers. Should match
%                       metabolite identifiers in `RXNfiles`.
%                     * .model.rxns - An `n` x 1 array of reaction identifiers. Should match
%                       RXNfile names in `RXNFileDir`.
%                     * .lb -  An `n` x 1 vector of lower bounds on fluxes.
%                     * .ub - An `n` x 1 vector of upper bounds on fluxes.
%
%    RXNFileDir:    Path to directory containing `RXNfiles` with atom mappings
%                   for internal reactions in `S`. File names should
%                   correspond to reaction identifiers in input `model.rxns`.
%                   e.g. git clone https://github.com/opencobra/ctf ~/fork-ctf
%                        then RXNFileDir = ~/fork-ctf/rxns/atomMapped
%
% OUTPUT:
% metRXNBool: `m` x 1 vector, true if metabolite identified in at least one RXN file
% RXNBool: `n` x 1 boolean vector, true if RXN file exists
% RXNParsedBool: `n` x 1 boolean vector, true if RXN file could be parsed
% RXNAtomsConservedBool: `n` x 1 boolean vector, true if atoms in RXN file are conserved
% RXNStoichiometryMatchBool:  `n` x 1 boolean vector, true if RXN stoichiometry matches model.S stoichiometry
% RXNStoichiometryMatchUptoProtonsBool:   `n` x 1 boolean vector, true if RXN stoichiometry matches model.S stoichiometry when ingnoring protons.
% RXNSubstrateTransitionNumbersOrdered:   `n` x 1 boolean vector, true if RXN file with substrate transition numbers ordered 1:q.
% RXNProductTransitionNumbersOrdered:   `n` x 1 boolean vector, true if RXN file with product transition numbers ordered 1:q.
% RXNTransitionNumbersMatching:    `n` x 1 boolean vector, true if RXN file with matching numbering of atoms between substrates and products.
% RXNMatchingElementBool:     `n` x 1 boolean vector, true if RXN file with matching elements between substrates and products.
%
% .. Authors: - Ronan M. T. Fleming, 2022.

fprintf('Checking quality of RXN files...\n');

if ~exist('RXNFileDir','var')
    RXNFileDir=pwd;
end
RXNFileDir = [regexprep(RXNFileDir,'(/|\\)$',''), ''];

[nMets,nRxns]= size(model.S);
if length(unique(model.mets))~=nMets
    disp(setdiff(model.mets,unique(model.mets)))
    error('duplicate metabolites')
end
if length(unique(model.rxns))~=nRxns
    disp(setdiff(model.rxns,unique(model.rxns)))
    error('duplicate reactions')
end

[metRXNBool,RXNBool,internalRxnBool] = findRXNFiles(model,RXNFileDir);

%preallocate outputs
RXNParsedBool = NaN*ones(nRxns,1);
RXNAtomsConservedBool = NaN*ones(nRxns,1);
RXNStoichiometryMatchBool = NaN*ones(nRxns,1);
RXNStoichiometryMatchUptoProtonsBool = NaN*ones(nRxns,1);
RXNSubstrateTransitionNumbersOrdered = NaN*ones(nRxns,1);
RXNTransitionNumbersMatching = NaN*ones(nRxns,1);
RXNProductTransitionNumbersOrdered = NaN*ones(nRxns,1);
RXNMatchingElementBool = NaN*ones(nRxns,1);

%identify the protons in the atom mapped subset
pat = '[' + lettersPattern(1) + ']';
hBool = strcmp(model.mets,'h') | matches(model.mets,pat);


checkDecompartmentaliseRXN=1;
printAtomTransitionStats=0;
nTotalAtomTransitions = 0;
for i = 1:nRxns
    if RXNBool(i)
        
        if checkDecompartmentaliseRXN==1
            % Read atom mapping from RXNfile to test if it is decompartmentalised
            [atomMets,metEls, metNrs, atomTransitionNrs,isSubstrate,instances] = readRXNFile(model.rxns{1},RXNFileDir);
            
            decompartmentaliseRXN=0;
            atomMetAbbr  = atomMets{1};
            metAbbr = model.mets{1};
            if ~strcmp(atomMetAbbr(end),metAbbr(end))
                if strcmp(atomMetAbbr(end),']')
                    decompartmentaliseRXN=1;
                elseif strcmp(metAbbr(end),']')
                    for j=1:length(model.mets)
                        model.mets{j} = model.mets{j}(1:end-2);
                    end
                end
                checkDecompartmentaliseRXN=0;
            end
        end
        rxn = model.rxns{i};
        
        if strcmp(rxn,'AKGDm')
            %disp(rxn)
        end
        
        try
            %read in each RXN file
            [atomMets,metEls, metNrs, atomTransitionNrs,isSubstrate,instances] = readRXNFile(rxn,RXNFileDir);
            
            if decompartmentaliseRXN
                for k=1:length(atomMets)
                    atomMets{k,1}=atomMets{k,1}(1:end-3);
                end
            end
            RXNParsedBool(i)=1;
        catch ME
            RXNParsedBool(i)=0;
            fprintf('%s%s\n',rxn,' could not be parsed.');
            disp(getReport(ME))
        end
        
        %check there are an even number of atoms in the rxn file
        if mod(length(metEls),2)==0
            RXNAtomsConservedBool(i)=1;
        else
            RXNAtomsConservedBool(i)=0;
            rxnFormula = printRxnFormula(model, 'rxnAbbrList',model.rxns{i},'printFlag',0);
            fprintf('%s%s%s%s\n',rxn,' ',rxnFormula{1},' does not conserve atoms.');
        end
        
        % Check that stoichiometry in rxnfile matches the one in S
        rxnMets = unique(atomMets);
        ss = model.S(:,i);
        as = zeros(size(ss));
        for j = 1:length(rxnMets)
            rxnMet = rxnMets{j};
            
            if isSubstrate(strcmp(atomMets,rxnMet))
                as(strcmp(model.mets,rxnMet)) = -max(instances(strcmp(atomMets,rxnMet)));
            else
                
                as(strcmp(model.mets,rxnMet)) = max(instances(strcmp(atomMets,rxnMet)));
            end
        end
        if all(as == ss)
            RXNStoichiometryMatchBool(i)=1;
        else
            RXNStoichiometryMatchBool(i)=0;
            if all(as == ss  | hBool)
                fprintf('%s%s\n',rxn, ' stoichiometry matches upto protons.')
                RXNStoichiometryMatchUptoProtonsBool(i)=1;
            else
                RXNStoichiometryMatchUptoProtonsBool(i)=0;
                fprintf('%s%s\n',rxn, ' stoichiometry in model and RXNfile do not match:')
                fprintf('%s\t,', 'In model:')
                printRxnFormula(model,'rxnAbbrList',rxn)
                fprintf('%s\t,', 'In RXNfile:')
                model.S(:,ismember(model.rxns,rxn))=as;
                printRxnFormula(model,'rxnAbbrList',rxn)
                fprintf('\n');
            end
        end
        
        %checks specific for atom transitions
        if ~all(atomTransitionNrs==0)
            if printAtomTransitionStats == 0
                printAtomTransitionStats=1;
            end
            if all(sort(atomTransitionNrs(isSubstrate)) == (1:sum(isSubstrate))')
                RXNSubstrateTransitionNumbersOrdered(i)=1;
            else
                RXNSubstrateTransitionNumbersOrdered(i)=0;
                fprintf([rxn, '.rxn, Substrate transition numbers not ordered 1:q.\n'])
            end
            if all(all(sort(atomTransitionNrs(~isSubstrate)) == (1:sum(~isSubstrate))'))
                RXNProductTransitionNumbersOrdered(i)=1;
            else
                RXNProductTransitionNumbersOrdered(i)=0;
                fprintf([rxn, '.rxn, Product transition numbers not ordered 1:q.\n'])
            end
            if all(sort(atomTransitionNrs(isSubstrate)) == sort(atomTransitionNrs(~isSubstrate)))
                RXNTransitionNumbersMatching(i)=1;
            else
                RXNTransitionNumbersMatching(i)=0;
                fprintf([rxn, '.rxn, Substrate and product transition numbers not matching order 1:q.\n'])
            end
            
            nAtomTransitions = max(atomTransitionNrs);
            matchingElementBool=false(nAtomTransitions,1);
            for k=1:nAtomTransitions
                if strcmp(metEls(atomTransitionNrs==k & isSubstrate),metEls(atomTransitionNrs==k & ~isSubstrate))
                    matchingElementBool(k)=1;
                end
            end
            if all(matchingElementBool)
                RXNMatchingElementBool(i)=1;
            else
                RXNMatchingElementBool(i)=0;
                fprintf('%s%s%s%s%u%s\n',RXNfileName,' ',rxnFormula,' contains ', nnz(~matchingElementBool), ' atom transitions violating elemental conservation.');
            end
            %calculate the total number of atom transitions
            nTotalAtomTransitions  = nTotalAtomTransitions + nAtomTransitions;
        end
    end
end

if printAtomTransitionStats
    fprintf('\n%s\n','RXN file with atom mapping summary:')
else
    fprintf('\n%s\n','RXN file summary:')
end
fprintf('%u%s\n',nMets,' metabolites in model')
fprintf('%u%s\n',nnz(metRXNBool),' metabolites in atom mapped subset of model')
fprintf('%u%s\n',nRxns,' reactions in model')
fprintf('%u%s\n',nnz(internalRxnBool),' internal reactions in model')
fprintf('%u%s\n',nnz(RXNBool),' reactions in atom mapped subset of model')
fprintf('%u%s\n',nnz(RXNParsedBool==1),' RXN files parsed.')
fprintf('%u%s\n',nnz(RXNAtomsConservedBool==1),' RXN files with the number of atom conserved between substrates and products.')
fprintf('%u%s\n',nnz(RXNStoichiometryMatchBool==1),' RXN files matching stoichiometry of the model.')
fprintf('%u%s\n',nnz(internalRxnBool & RXNStoichiometryMatchUptoProtonsBool==1),' RXN files matching stoichiometry of the model, upto protons.')
fprintf('%u%s\n',nnz(internalRxnBool & RXNStoichiometryMatchBool~=1 & ~(RXNStoichiometryMatchUptoProtonsBool==1)),' RXN files not matching stoichiometry of model, even ignoring protons.')
if printAtomTransitionStats
    fprintf('%u%s\n',nnz(RXNSubstrateTransitionNumbersOrdered==1),' RXN files with substrate transition numbers ordered 1:q.')
    fprintf('%u%s\n',nnz(RXNProductTransitionNumbersOrdered==1),' RXN files with product transition numbers ordered 1:q.')
    fprintf('%u%s\n',nnz(RXNTransitionNumbersMatching==1),' RXN files with matching numbering of atoms between substrates and products.')
    fprintf('%u%s\n',nnz(RXNMatchingElementBool==1),' RXN files with matching elements between substrates and products.')
end

model.metRXNBool=metRXNBool;
model.RXNBool=RXNBool;
model.RXNParsedBool=RXNParsedBool;
model.RXNAtomsConservedBool=RXNAtomsConservedBool;
model.RXNStoichiometryMatchBool=RXNStoichiometryMatchBool;
model.RXNStoichiometryMatchUptoProtonsBool=RXNStoichiometryMatchUptoProtonsBool;
model.RXNSubstrateTransitionNumbersOrdered=RXNSubstrateTransitionNumbersOrdered;
model.RXNProductTransitionNumbersOrdered=RXNProductTransitionNumbersOrdered;
model.RXNTransitionNumbersMatching=RXNTransitionNumbersMatching;
model.RXNMatchingElementBool=RXNMatchingElementBool;
modelOut=model;
