function [summary, status] = metDatabaseStatus(model, metDir)
% Prints the status of metabolite structure in a database in relation to a 
% COBRA model.
%
% USAGE:
%
%    [summary, status] = metDatabaseStatus(model, metDir)
%
% INPUTS:
%    model:     COBRA model with following fields:
%           * .mets - An m x 1 array of metabolite identifiers.
%           * .metFromulas - An m x 1 array of metabolite flormulas.
%           * .metCharges - An m x 1 vector of metabolite charges.
%           * .identifiers - An m x 1 array of metabolite identifiers.
%           * .inchi - An m x 1 array of metabolite identifiers.
%           * .kegg - An m x 1 array of metabolite identifiers.
%           * .chebi - An m x 1 array of metabolite identifiers.
%           * .hmdb - An m x 1 array of metabolite identifiers.
%           * .pubchem - An m x 1 array of metabolite identifiers.
%
%    metDir:    Directory of the metabolite database (MDL MOL files)
%
% OUTPUTS:
%    summary:	 Summary of the metabolite database and the identifiers.
%    status:	 Table with the status of each metabolite in the database.

mets = regexprep(model.mets, '(\[\w\])', '');
[umets, ic] = unique(mets);

% Metabolite structures in the database
metDir = [regexprep(metDir,'(/|\\)$',''), filesep];
molFiles = dir([metDir '*.mol']);
molFiles = regexprep({molFiles.name}, '.mol', '')';

% Missing metabolites
missingBool = ~ismember(umets, molFiles);
missingMetabolites = umets(missingBool);

% Prepare the table with the metabolite information
nRows = length(umets);
varTypes = {'string', 'string', 'double', 'string', 'string', 'double', 'double', ...
    'logical', 'logical', 'logical', 'logical', 'logical', 'logical'};
varNames = {'met', 'status', 'noOfIds', 'modelFormula', 'structureFormula', ...
    'modelCharge', 'structureCharge', 'inchiBool', 'smilesBool', 'chebiBool', ...
    'hmdbBool', 'pubchemBool', 'keggBool'};
status = table('Size', [nRows length(varTypes)], 'VariableTypes', varTypes, 'VariableNames', varNames);

% Fetch the fields in the model
fields = fieldnames(model);
formulaFieldBool = ~cellfun(@isempty, regexpi(fields, 'formula'));
chargeFieldBool = ~cellfun(@isempty, regexpi(fields, 'charge'));
inchiFieldBool = ~cellfun(@isempty, regexpi(fields, 'inchi'));
smilesFieldBool = ~cellfun(@isempty, regexpi(fields, 'smiles'));
chebiFieldBool = ~cellfun(@isempty, regexpi(fields, 'chebi'));
hmdbFieldBool = ~cellfun(@isempty, regexpi(fields, 'hmdb'));
keggFieldBool = ~cellfun(@isempty, regexpi(fields, 'kegg'));
if sum(keggFieldBool) > 1
    keggFieldBool = keggFieldBool & ~cellfun(@isempty, regexpi(fields, 'met'));
end
pubchemFieldBool = ~cellfun(@isempty, regexpi(fields, 'pubchem'));

% Add IDs information
status.inchiBool = ~cellfun(@isempty, model.(fields{inchiFieldBool})(ic));
status.smilesBool = ~cellfun(@isempty, model.(fields{smilesFieldBool})(ic));
status.chebiBool = ~cellfun(@isempty, model.(fields{chebiFieldBool})(ic));
status.hmdbBool = ~cellfun(@isempty, model.(fields{hmdbFieldBool})(ic));
status.keggBool = ~cellfun(@isempty, model.(fields{keggFieldBool})(ic));
status.pubchemBool = ~cellfun(@isempty, model.(fields{pubchemFieldBool})(ic));
status.noOfIds = status.inchiBool + status.smilesBool + status.chebiBool + ...
    status.hmdbBool + status.keggBool + status.pubchemBool;

for i = 1:length(umets)
    
    idx = find(ismember(mets, umets{i}));
    
    % Add metabolite information
    status.met(i) = umets(i);
    metFormula = model.(fields{formulaFieldBool})(idx(1));
    if isempty(char(metFormula))
        status.modelFormula(i) = '';
    else
        status.modelFormula(i) = editChemicalFormula(metFormula);
    end
    status.modelCharge(i) = model.(fields{chargeFieldBool})(idx(1));
    
    % Check if a the metabolite is present in the database
    if ismember(umets{i}, molFiles)
        
        % Read the MOL file
        molFile = regexp(fileread([metDir umets{i} '.mol']), '\n', 'split')';
        
        % Fetch the molecular formula of the MOL file
        atomsArray = '';
        for j = 1:str2num(molFile{4}(1:3))
            atomsArray = [atomsArray strtrim(molFile{4 + j}(32:33))];
        end
        status.structureFormula(i) = editChemicalFormula(atomsArray);
        
        % Fetch the charge of the MOL file
        chargeIdx = strmatch('M  CHG', molFile);
        if ~isempty(chargeIdx)
            molCharge = 0;
            for j = 1:length(chargeIdx)
                chargeLine = strsplit(strtrim(molFile{chargeIdx(j)}));
                for k = 5:2:length(chargeLine)
                    molCharge = molCharge + str2double(chargeLine(k));
                end
            end
            status.structureCharge(i) = molCharge;
        end
    else
        status.structureFormula(i) = 'missing';
        status.structureCharge(i) = NaN;
    end
         
    % Compare with model data
    chComparison = isequal(status.structureCharge(i), status.modelCharge(i));
    fComparison = isequal(status.structureFormula(i), status.modelFormula(i));
    
    % Assign group in DB
    switch (chComparison) +  (fComparison * 3)
        case 0 % status.status
            if missingBool(i)
                status.status(i) = 'missing';
            else
                status.status(i) = 'inconsistentChargeAndFormula';
            end
        case 1
            status.status(i) = 'inconsistentCharge';
        case 3
            status.status(i) = 'inconsistentFormula';
        case 4
            status.status(i) = 'consistent';
    end
    
end

% Summary
summary.mets = length(umets);
summary.consistent = sum(ismember(status.status, 'consistent'));
summary.inconsistentFormula = sum(ismember(status.status, 'inconsistentFormula'));
summary.inconsistentCharge = sum(ismember(status.status, 'inconsistentCharge'));
summary.inconsistentChargeAndFormula = sum(ismember(status.status, 'inconsistentChargeAndFormula'));
summary.missing = sum(ismember(status.status, 'missing'));
summary.inchiIds = sum(status.inchiBool);
summary.smilesIds = sum(status.smilesBool);
summary.chebiIds = sum(status.chebiBool);
summary.hmdbIds = sum(status.hmdbBool);
summary.keggIds = sum(status.keggBool);
summary.pubchemIds = sum(status.pubchemBool);
