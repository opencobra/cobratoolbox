function Data = findRxnMatch(cRxn, nMatch, scoreTotal)
% Finds the highest scoring matches for a given reaction.
% Called by `reactionCompareGUI`.
%
% USAGE:
%
%    Data = findRxnMatch(cRxn, nMatch, scoreTotal)
%
% INPUTS:
%    cRxn:          Number of the compared rxn.
%    nMatch:        Number of matches to return.
%    scoreTotal:    summed SCORE of reactions vs reactions.
%    CMODEL:        global input
%    TMODEL:        global input
%
% OUTPUTS:
%    Data:          Structure containing comparison information.
%
% Please cite:
% `Sauls, J. T., & Buescher, J. M. (2014). Assimilating genome-scale
% metabolic reconstructions with modelBorgifier. Bioinformatics
% (Oxford, England), 30(7), 1036?8`. http://doi.org/10.1093/bioinformatics/btt747
%
% ..
%    Edit the above text to modify the response to help addMetInfo
%    Last Modified by GUIDE v2.5 06-Dec-2013 14:19:28
%    This file is published under Creative Commons BY-NC-SA.
%
%    Correspondance:
%    johntsauls@gmail.com
%
%    Developed at:
%    BRAIN Aktiengesellschaft
%    Microbial Production Technologies Unit
%    Quantitative Biology and Sequencing Platform
%    Darmstaeter Str. 34-36
%    64673 Zwingenberg, Germany
%    www.brain-biotech.de

global CMODEL TMODEL % Declare variables.

% Structure comtaining comparison information
Data = ([]);

%% cRxn Reaction Info
Data.cRxnTable = cell(8,1) ;
Data.cRxnTable(:) = {''} ;
Data.cRxnTable{1} = num2str(cRxn) ;
Data.cRxnTable{2} = CMODEL.rxns{cRxn} ;
Data.cRxnTable{3} = CMODEL.rxnNames{cRxn} ;
Data.cRxnTable{4} = CMODEL.rxnEquations{cRxn} ;
Data.cRxnTable{5} = CMODEL.rxnECNumbers{cRxn} ;
Data.cRxnTable{6} = CMODEL.rxnKEGGID{cRxn} ;
Data.cRxnTable{7} = CMODEL.rxnSEEDID{cRxn} ;
Data.cRxnTable{8} = CMODEL.subSystems{cRxn} ;

%% cRxn Metabolite Info
Data.cMetTable = cell(14, 1);
Data.cMetTable(:) = {''};

% Reactants from model
Data.cMetTable{1} = num2str(CMODEL.metNums(cRxn, 3)); % # of reactants

metPos = find(CMODEL.S(:, cRxn) < 0) ; % find reactants
if ~isempty(metPos)
    metlist = CMODEL.mets{metPos(1)} ; % add in first metabolite Id
    names = CMODEL.metNames{metPos(1)} ;
    stoics = num2str(abs(CMODEL.S(metPos(1), cRxn))) ; % add in first stoic
    forms = CMODEL.metFormulas{metPos(1)} ; % first formula
    charges = num2str(CMODEL.metCharge(metPos(1))) ; % first charge
    keggs = CMODEL.metKEGGID{metPos(1)} ; % first charge

    % If there are more than one mets, add additional info.
    if length(metPos) > 1
        for j = 2:length(metPos)
            metlist = strcat(metlist, '; ', CMODEL.mets{metPos(j)});
            names = strcat(names, '; ', CMODEL.metNames{metPos(j)});
            stoics = strcat(stoics, '; ', ...
                            num2str(abs(CMODEL.S(metPos(j), cRxn))));
            forms = strcat(forms, '; ', CMODEL.metFormulas{metPos(j)});
            charges = strcat(charges, '; ', ...
                             num2str(CMODEL.metCharge(metPos(j))));
            keggs = strcat(keggs, '; ', CMODEL.metKEGGID{metPos(j)});
        end
    end

    % Assign to table.
    Data.cMetTable{2} = metlist ;
    Data.cMetTable{3} = names ;
    Data.cMetTable{4} = stoics ;
    Data.cMetTable{5} = forms ;
    Data.cMetTable{6} = charges ;
    Data.cMetTable{7} = keggs ;
end

% Products from crxn.
% Number of products.
Data.cMetTable{8} = num2str(CMODEL.metNums(cRxn, 5));

% Find product position.
metPos = find(CMODEL.S(:, cRxn) > 0) ;

if ~isempty(metPos)
    % First product.
    metlist = CMODEL.mets{metPos(1)};
    names = CMODEL.metNames{metPos(1)} ;
    stoics = num2str(abs(CMODEL.S(metPos(1), cRxn)));
    forms = CMODEL.metFormulas{metPos(1)};
    charges = num2str(CMODEL.metCharge(metPos(1)));
    keggs = CMODEL.metKEGGID{metPos(1)};

    % Additional products.
    if length(metPos) > 1
        for j = 2:length(metPos)
            metlist = strcat(metlist, '; ', CMODEL.mets{metPos(j)});
            names = strcat(names, '; ', CMODEL.metNames{metPos(j)});
            stoics = strcat(stoics, '; ', ...
                            num2str(abs(CMODEL.S(metPos(j), cRxn))));
            forms = strcat(forms, '; ', CMODEL.metFormulas{metPos(j)});
            charges = strcat(charges, '; ', ...
                             num2str(CMODEL.metCharge(metPos(j))));
            keggs = strcat(keggs, '; ', CMODEL.metKEGGID{metPos(j)});
        end
    end

    % Assign data.
    Data.cMetTable{9} = metlist ;
    Data.cMetTable{10} = names ;
    Data.cMetTable{11} = stoics ;
    Data.cMetTable{12} = forms ;
    Data.cMetTable{13} = charges ;
    Data.cMetTable{14} = keggs ;
    clear metlist; clear stoics; clear forms; clear charges; clear keggs
end

%% Match Reaction(s) Info
% Allocate match reaction table.
Data.tRxnTable = cell(8, nMatch);
Data.tRxnTable(:) = {''};

% Sort scores, I is the original index.
[y, I] = sort(scoreTotal(cRxn, :), 'descend');

for i = 1:nMatch
    Data.tRxnTable{1, i} = strcat(num2str(y(i)), '; ', num2str(I(i)));
    Data.tRxnTable{2, i} = TMODEL.rxns{I(i)} ;
    Data.tRxnTable{3, i} = TMODEL.rxnNames{I(i)} ;
    Data.tRxnTable{4, i} = TMODEL.rxnEquations{I(i)} ;
    Data.tRxnTable{5, i} = TMODEL.rxnECNumbers{I(i)} ;
    Data.tRxnTable{6, i} = TMODEL.rxnKEGGID{I(i)} ;
    Data.tRxnTable{7, i} = TMODEL.rxnSEEDID{I(i)} ;
    Data.tRxnTable{8, i} = TMODEL.subSystems{I(i)} ;
end

%% Match Metabolite Info
Data.tMetTable = cell(14, nMatch);
Data.tMetTable(:) = {''};

for i = 1:nMatch
    % Reactants from model.
    Data.tMetTable{1,i} = num2str(TMODEL.metNums(I(i),3));

    % First reactant.
    metPos = find(TMODEL.S(:,I(i)) < 0) ;

    if ~isempty(metPos)
        metlist = TMODEL.mets{metPos(1)};
        names = TMODEL.metNames{metPos(1)} ;
        stoics = num2str(abs(TMODEL.S(metPos(1),I(i))));
        forms = TMODEL.metFormulas{metPos(1)};
        charges = num2str(TMODEL.metCharge(metPos(1)));
        keggs = TMODEL.metKEGGID{metPos(1)};

        % Additioanl Reactants.
        if length(metPos) > 1
            for j = 2:length(metPos)
                metlist = strcat(metlist, '; ', TMODEL.mets{metPos(j)});
                names = strcat(names, '; ', TMODEL.metNames{metPos(j)});
                stoics = strcat(stoics, '; ', ...
                                num2str(abs(TMODEL.S(metPos(j), I(i)))));
                forms = strcat(forms, '; ', TMODEL.metFormulas{metPos(j)});
                charges = strcat(charges, '; ', ...
                                 num2str(TMODEL.metCharge(metPos(j))));
                keggs = strcat(keggs, '; ', TMODEL.metKEGGID{metPos(j)});
            end
        end

        Data.tMetTable{2, i} = metlist ;
        Data.tMetTable{3, i} = names ;
        Data.tMetTable{4, i} = stoics ;
        Data.tMetTable{5, i} = forms ;
        Data.tMetTable{6, i} = charges ;
        Data.tMetTable{7, i} = keggs ;
    end

    % Products from model.
    if TMODEL.metNums(I(i), 5) ~= 0
        Data.tMetTable{8, i} = num2str(TMODEL.metNums(I(i), 5));

        % Find product indexes.
        metPos = find(TMODEL.S(:, I(i)) > 0) ;

        % First product
        metlist = TMODEL.mets{metPos(1)};
        names = TMODEL.metNames{metPos(1)} ;
        stoics = num2str(abs(TMODEL.S(metPos(1), I(i))));
        forms = TMODEL.metFormulas{metPos(1)};
        charges = num2str(TMODEL.metCharge(metPos(1)));
        keggs = TMODEL.metKEGGID{metPos(1)};

        % Additional products.
        if length(metPos) > 1
            for j = 2:length(metPos)
                metlist = strcat(metlist, '; ', TMODEL.mets{metPos(j)});
                names = strcat(names, '; ', TMODEL.metNames{metPos(j)});
                stoics = strcat(stoics, '; ', ...
                                num2str(abs(TMODEL.S(metPos(j), I(i)))));
                forms = strcat(forms, '; ', TMODEL.metFormulas{metPos(j)});
                charges = strcat(charges, '; ', ...
                                 num2str(TMODEL.metCharge(metPos(j))));
                keggs = strcat(keggs, '; ', TMODEL.metKEGGID{metPos(j)});
            end
        end

        % Assign to table.
        Data.tMetTable{9, i} = metlist ;
        Data.tMetTable{10, i} = names ;
        Data.tMetTable{11, i} = stoics ;
        Data.tMetTable{12, i} = forms ;
        Data.tMetTable{13, i} = charges ;
        Data.tMetTable{14, i} = keggs ;
    end
end
