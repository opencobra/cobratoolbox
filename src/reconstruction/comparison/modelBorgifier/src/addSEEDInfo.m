% This file is published under Creative Commons BY-NC-SA.
%
% Please cite:
% Sauls, J. T., & Buescher, J. M. (2014). Assimilating genome-scale 
% metabolic reconstructions with modelBorgifier. Bioinformatics 
% (Oxford, England), 30(7), 1036?8. http://doi.org/10.1093/bioinformatics/btt747
%
% Correspondance:
% johntsauls@gmail.com
%
% Developed at:
% BRAIN Aktiengesellschaft
% Microbial Production Technologies Unit
% Quantitative Biology and Sequencing Platform
% Darmstaeter Str. 34-36
% 64673 Zwingenberg, Germany
% www.brain-biotech.de
%
function Model = addSEEDInfo(Model, rxnFileName, cpdFileName) 
% This function takes the compound and reaction database files from SEED
% and compares them to a model, adding any additional information it can
% find and checking to see if current information is in agreement with the
% databases. It returns the augmented model. 
%
% USAGE:
%    Model = addSEEDInfo(Model, rxnFileName, cpdFileName)
%
% INPUTS:
%    Model:         Model with SEED reaction and metabolite IDs
%    rxnFileName:   rxn database as downloaded from the modelSEED in .csv
%                   with ; delimiters.
%    cpdFileName:   cpd database as downloaded from the modelSEED in .csv
%                   with ; delimiters.
%
% OUTPUTS:
%    Model     
%
% CALLS:
%    csvimport
%    fixNames
%    makeNamesUnique
%    removeDuplicateNames
%    fixChemFormulas
%
% CALLED BY:
%    None
%

%% Declare variables.
% Load reaction and metabolite files into cell arrays.
% Note: csvimport does not like for the file to be open anywhere else.
rxnDb = csvimport(rxnFileName, 'delimiter', ';');
cpdDb = csvimport(cpdFileName, 'delimiter', ';'); 

% Clean up names. 
cpdDb(:, 3) = fixNames(cpdDb(:, 3)); % Abbreviations.
cpdDb(:, 4) = fixNames(cpdDb(:, 4)); % Names.
cpdDb(:, 6) = fixChemFormulas(cpdDb(:, 6)); % Chem formulas.

% Remove starting and trailing pipes from EC Numbers.
rxnDb(:, 3) = regexprep(rxnDb(:, 3), '^\|', ''); 
rxnDb(:, 3) = regexprep(rxnDb(:, 3), '\|$', '');

% Reaction and metabolite information to be added to. 
rxnFields = {'rxnNames', 'rxnECNumbers', 'rxnKEGGID'};
metFields = {'metNames', 'metFormulas', 'metKEGGID'};

% Corresponding data column locations.
rxnDataCol = [2, 3, 4];
metDataCol = [4, 6, 5];

%% Reactions
% Which reactions have SEEDIDs.
withRxnSEED = find(~cellfun(@isempty, Model.rxnSEEDID));

% Compare individual IDs agianst database. 
for iRxn = 1:length(withRxnSEED)
    matchPos = find(strcmp(Model.rxns{withRxnSEED(iRxn)}, rxnDb(:, 1))) ; 
    if ~isempty(matchPos) == 1 && length(matchPos) == 1
        % Add information from database 
        for iField = 1:length(rxnFields)
            Model.(rxnFields{iField}){withRxnSEED(iRxn)} = ...
                [Model.(rxnFields{iField}){withRxnSEED(iRxn)} '|' ...
                 rxnDb{matchPos,rxnDataCol(iField)}];
        end
    end
end

% Remove leading and lone pipes and duplicates.
for iField = 1:length(rxnFields)
    Model.(rxnFields{iField}) = regexprep(Model.(rxnFields{iField}), ...
                                          '^|', '');
    Model.(rxnFields{iField}) = ...
        removeDuplicateNames(Model.(rxnFields{iField})); 
end                                     

%% Metabolites.
% Which reactions have SEEDIDs.
withMetSEED = find(~cellfun(@isempty, Model.metSEEDID));

% Compare individual IDs agianst database. 
for iMet = 1:length(withMetSEED)
    matchPos = find(strcmp(Model.metSEEDID{withMetSEED(iMet)}, cpdDb(:, 1))); 
    if ~isempty(matchPos) == 1 && length(matchPos) == 1
        % Add information from database 
        for iField = 1:length(metFields)
            Model.(metFields{iField}){withMetSEED(iMet)} = ...
                [Model.(metFields{iField}){withMetSEED(iMet)} '|' ...
                 cpdDb{matchPos, metDataCol(iField)}];
            % Replace .mets with abbreviations from db, retain compound.
            Model.mets{withMetSEED(iMet)} = [cpdDb{matchPos, 3} ...
                Model.mets{withMetSEED(iMet)}(end- 2 :end)];
        end
    end
end

% Remove leading and lone pipes and duplicates.
for iField = 1:length(metFields)
    Model.(metFields{iField}) = regexprep(Model.(metFields{iField}), ...
                                          '^|', '');
    Model.(metFields{iField}) = ...
        removeDuplicateNames(Model.(metFields{iField})); 
end

% Make sure .mets are unique, use as ID. 
fprintf('Checking if metabolite IDs (.mets) are unique.\n');
if length(Model.mets) ~= length(unique(Model.mets))
    fprintf('ERROR: Not all metabolites are unique.\n')
    Model.mets = makeNamesUnique(Model.mets,Model.metNames); 
end
Model.metID = Model.mets ; 

% Rebuild reaction equations.
Model = buildRxnEquations(Model) ; 

