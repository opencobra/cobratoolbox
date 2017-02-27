function model = xls2model(fileName,biomassRxnEquation)
% xls2model Writes a model from Excel spreadsheet.
%
% model = xls2model(fileName,biomassRxnEquation)
%
% INPUT
% fileName      xls spreadsheet, with one 'Reaction List' and one 'Metabolite List' tab
%
% 'Reaction List' tab: Required headers (case sensitive):
%   'Abbreviation'      HEX1
%   'Description'       Hexokinase
%   'Reaction'          1 atp[c] + 1 glc-D[c] --> 1 adp[c] + 1 g6p[c] + 1 h[c]
%   'GPR'               (3098.3) or (80201.1) or (2645.3) or ...
%   'Genes'             2645.1,2645.2,2645.3,...  (optional)
%   'Proteins'          Flj22761.1, Hk1.3, Gck.2,...  (optional)
%   'Subsystem'         Glycolysis
%   'Reversible'        0 (false) or 1 (true)
%   'Lower bound'       0
%   'Upper bound'       1000
%   'Objective'         0   (optional)
%   'Confidence Score'  0,1,2,3,4
%   'EC Number'         2.7.1.1,2.7.1.2
%   'Notes'             'Reaction also associated with EC 2.7.1.2' (optional)
%   'References'        PMID:2043117,PMID:7150652,...   (optional)
%
% 'Metabolite List' tab: Required headers (case sensitive): (needs to be complete list of metabolites, i.e., if a metabolite appears in multiple compartments it has to be represented in multiple rows. Abbreviations need to overlap with use in Reaction List
%   'Abbreviation'      glc-D or glc-D[c]
%   'Description'       D-glucose
%   'Neutral formula'   C6H12O6
%   'Charged formula'   C6H12O6
%   'Charge'            0
%   'Compartment'       cytosol
%   'KEGG ID'           C00031
%   'PubChem ID'        5793
%   'ChEBI ID'          4167
%   'InChI string'      InChI=1/C6H12O6/c7-1-2-3(8)4(9)5(10)6(11)12-2/h2-11H,1H2/t2-,3-,4+,5-,6?/m1/s1
%   'SMILES'            OC[C@H]1OC(O)[C@H](O)[C@@H](O)[C@@H]1O
%   'HMDB ID'           HMDB00122
%
% OPTIONAL INPUT (may be required for input on unix macines)
% biomassRxnEquation        .xls may have a 255 character limit on each cell,
%                           so pass the biomass reaction separately if it hits this maximum.
%
% OUTPUT
% model         COBRA Toolbox model
%
% Ines Thiele   01/02/09
% Richard Que   04/27/10    Modified reading of PubChemID and ChEBIID so that if met
%                           has multiple IDs, all are passed to model. Confidence Scores
%                           PubChemIDs, and ChEBIIDs, are properly passed as cell arrays.
% Ronan Fleming 08/17/10    Support for unix
% Hulda S.H.    10/11/10    Modified reading of xls document. Identifies
%                           columns by their headers. Added reading of
%                           HMDB ID.
%
warning off

if isunix
    %assumes that one has an xls file with two tabs
    [~, Strings, rxnInfo] = xlsread(fileName,'Reaction List');
    [~, MetStrings, metInfo] = xlsread(fileName,'Metabolite List');
    %trim empty row from Numbers and MetNumbers
    %     Numbers = Numbers(2:end,:);
    %     MetNumbers = MetNumbers(2:end,:);
    
    rxnInfo = rxnInfo(1:size(Strings,1),:);
    metInfo = metInfo(1:size(MetStrings,1),:);
    
    if isempty(MetStrings)
        error('Save .xls file as Windows 95 version using gnumeric not openoffice!');
    end
    
else
    %assumes that one has an xls file with two tabs
    [~, Strings, rxnInfo] = xlsread(fileName,'Reaction List');
    [~, MetStrings, metInfo] = xlsread(fileName,'Metabolite List');
    
    rxnInfo = rxnInfo(1:size(Strings,1),:);
    metInfo = metInfo(1:size(MetStrings,1),:);
    
end

rxnHeaders = rxnInfo(1,:);

for n = 1:length(rxnHeaders)
    if isnan(rxnHeaders{n})
        rxnHeaders{n} = '';
    end
end

% Assuming first row is header row
rxnAbrList = Strings(2:end,strmatch('Abbreviation',rxnHeaders,'exact'));
rxnNameList = Strings(2:end,strmatch('Description',rxnHeaders,'exact'));
rxnList = Strings(2:end,strmatch('Reaction',rxnHeaders,'exact'));
grRuleList = Strings(2:end,strmatch('GPR',rxnHeaders,'exact'));
Protein = Strings(2:end,strmatch('Proteins',rxnHeaders,'exact'));
subSystemList = Strings(2:end,strmatch('Subsystem',rxnHeaders,'exact'));

if isunix
    for n=1:length(rxnList)
        if length(rxnList{n})==255
            if exist('biomassRxnEquation','var')
                rxnList{n}=biomassRxnEquation;
            else
                error('biomassRxnEquation .xls may have a 255 character limit on each cell, so pass the biomass reaction separately if it hits this maximum.')
            end
        end
    end
end

if ~isempty(strmatch('Reversible',rxnHeaders,'exact'))
    revFlagList = cell2mat(rxnInfo(2:end,strmatch('Reversible',rxnHeaders,'exact')));
else
    revFlagList = [];
end
if ~isempty(strmatch('Lower bound',rxnHeaders,'exact'))
    lowerBoundList = cell2mat(rxnInfo(2:end,strmatch('Lower bound',rxnHeaders,'exact')));
else
    lowerBoundList = 1000*ones(length(rxnAbrList),1);
end
if ~isempty(strmatch('Upper bound',rxnHeaders,'exact'))
    upperBoundList = cell2mat(rxnInfo(2:end,strmatch('Upper bound',rxnHeaders,'exact')));
else
    upperBoundList = 1000*ones(length(rxnAbrList),1);
end
if ~isempty(strmatch('Objective',rxnHeaders,'exact'))
    Objective = cell2mat(rxnInfo(2:end,strmatch('Objective',rxnHeaders,'exact')));
else
    Objective = zeros(length(rxnAbrList),1);
end

model = createModel(rxnAbrList,rxnNameList,rxnList,revFlagList,lowerBoundList,upperBoundList,subSystemList,grRuleList);

if ~isempty(strmatch('Confidence Score',rxnHeaders,'exact'))
    model.confidenceScores = rxnInfo(2:end,strmatch('Confidence Score',rxnHeaders,'exact'));
else
    model.confidenceScores = cell(length(model.rxns),1); %empty cell instead of NaN
end
if ~isempty(strmatch('EC Number',rxnHeaders,'exact'))
    model.rxnECNumbers = Strings(2:end,strmatch('EC Number',rxnHeaders,'exact'));
end
if ~isempty(strmatch('Notes',rxnHeaders,'exact'))
    model.rxnNotes = Strings(2:end,strmatch('Notes',rxnHeaders,'exact'));
end
if ~isempty(strmatch('References',rxnHeaders,'exact'))
    model.rxnReferences = Strings(2:end,strmatch('References',rxnHeaders,'exact'));
end

%fill in opt info for metabolites
if ~isempty(Objective) && length(Objective) == length(model.rxns)
    model.c = (Objective);
end
model.proteins = Protein;

metHeaders = metInfo(1,:);

for n = 1:length(metHeaders)
    if isnan(metHeaders{n})
        metHeaders{n} = '';
    end
end

% case 1: all metabolites in List have a compartment assignement

metCol = strmatch('Abbreviation',metHeaders,'exact');

if ~cellfun('isempty',(strfind(MetStrings(2,metCol),'[')))
    for i = 2 : length(MetStrings(:,metCol))% assumes that first row is header
        % finds metabolites in model structure
        MetLoc =  strmatch(MetStrings{i,metCol},model.mets,'exact');
        if ~isempty(MetLoc)
            model.metNames{MetLoc} = MetStrings{i,strmatch('Description',metHeaders,'exact')};
            model.metFormulasNeutral{MetLoc} = MetStrings{i,strmatch('Neutral formula',metHeaders,'exact')};
            %   model.metFormulas{MetLoc} = char(MetStrings{i,4});
            model.metFormulas{MetLoc} = MetStrings{i,strmatch('Charged formula',metHeaders,'exact')};
            
            if ~isempty(strmatch('Compartment',metHeaders,'exact')) % If Metabolite List contains compartment specifications
                model.metCompartment{MetLoc} = MetStrings{i,strmatch('Compartment',metHeaders,'exact')};
                
            else % If Metabolite List contains only unique metabolites without compartment specifications
                compartmentAbbr = {'c', 'e', 'm', 'n', 'r', 'x', 'l', 'g'};
                compartments = {'cytosol', 'extracellular', 'mitochondria', 'nucleus', 'endoplasmatic reticulum', 'peroxisome', 'lysosome', 'golgi aparatus'};
                compartmentBool = strcmp(model.mets{MetLoc}(end-1),compartmentAbbr);
                
                if any(compartmentBool)
                    model.metCompartment{MetLoc} = compartments{compartmentBool};
                end
                
            end
            if ~isempty(strmatch('InChI string',metHeaders,'exact'))
                model.metKEGGID{MetLoc} = MetStrings{i,strmatch('KEGG ID',metHeaders,'exact')};
            end
            if ~isempty(strmatch('InChI string',metHeaders,'exact'))
                model.metInChIString{MetLoc} = MetStrings{i,strmatch('InChI string',metHeaders,'exact')};
            end
            if ~isempty(strmatch('HMDB ID',metHeaders,'exact'))
                model.metHMDBID{MetLoc} = MetStrings{i,strmatch('HMDB ID',metHeaders,'exact')};
            end
            if ~isempty(strmatch('SMILES',metHeaders,'exact'))
                model.metSmiles{MetLoc} = MetStrings{i,strmatch('SMILES',metHeaders,'exact')};
            end
            if ~isempty(strmatch('Charge',metHeaders,'exact'))
                model.metCharges(MetLoc) = metInfo{i,strmatch('Charge',metHeaders,'exact')};
            end
            if ~isempty(strmatch('PubChem ID',metHeaders,'exact'))
                model.metPubChemID(MetLoc) = metInfo{i,strmatch('PubChem ID',metHeaders,'exact')};
            end
            if ~isempty(strmatch('ChEBI ID',metHeaders,'exact'))
                model.metChEBIID{MetLoc} = metInfo{i,strmatch('ChEBI ID',metHeaders,'exact')};
            end
        else
            warning(['Metabolite ' metInfo{i,metCol} ' not in model']);
        end
        MetLoc=[];
    end
else
    % case 2: all metabolites in List have no compartment assignement
    for i = 2 : length(MetStrings(:,metCol)) % assumes that first row is header
        % finds metabolites in model structure
        % this assumes that the compartment is shown with '[ ]'
        MetLoc =  strmatch(strcat(MetStrings{i,metCol},'['),model.mets);
        if ~isempty(MetLoc)
            for j = 1 : length(MetLoc)
                model.metNames{MetLoc(j)} = MetStrings{i,strmatch('Description',metHeaders,'exact')};
                model.metFormulasNeutral{MetLoc(j)} = MetStrings{i,strmatch('Neutral formula',metHeaders,'exact')};
                %   model.metFormulas{MetLoc} = char(MetStrings{i,4});
                model.metFormulas{MetLoc(j)} = MetStrings{i,strmatch('Charged formula',metHeaders,'exact')};
                
                if ~isempty(strmatch('Compartment',metHeaders,'exact')) % If Metabolite List contains compartment specifications
                    model.metCompartment{MetLoc(j)} = MetStrings{i,strmatch('Compartment',metHeaders,'exact')};
                    
                else % If Metabolite List contains only unique metabolites without compartment specifications
                    compartmentAbbr = {'c', 'e', 'm', 'n', 'r', 'x', 'l', 'g'};
                    compartments = {'cytosol', 'extracellular', 'mitochondria', 'nucleus', 'endoplasmatic reticulum', 'peroxisome', 'lysosome', 'golgi aparatus'};
                    compartmentBool = strcmp(model.mets{MetLoc(j)}(end-1),compartmentAbbr);
                    
                    if any(compartmentBool)
                        model.metCompartment{MetLoc(j)} = compartments{compartmentBool};
                    end
                    
                end
                
                model.metKEGGID{MetLoc(j)} = MetStrings{i,strmatch('KEGG ID',metHeaders,'exact')};
                if ~isempty(strmatch('InChI string',metHeaders,'exact'))
                    model.metInChIString{MetLoc(j)} = MetStrings{i,strmatch('InChI string',metHeaders,'exact')};
                end
                if ~isempty(strmatch('HMDB ID',metHeaders,'exact'))
                    model.metHMDBID{MetLoc(j)} = MetStrings{i,strmatch('HMDB ID',metHeaders,'exact')};
                end
                if ~isempty(strmatch('SMILES',metHeaders,'exact'))
                    model.metSmiles{MetLoc(j)} = MetStrings{i,strmatch('SMILES',metHeaders,'exact')};
                end
                if ~isempty(strmatch('Charge',metHeaders,'exact'))
                    model.metCharges(MetLoc(j)) = metInfo{i,strmatch('Charge',metHeaders,'exact')};
                end
                if ~isempty(strmatch('PubChem ID',metHeaders,'exact'))
                    model.metPubChemID(MetLoc(j)) = metInfo{i,strmatch('PubChem ID',metHeaders,'exact')};
                end
                if ~isempty(strmatch('ChEBI ID',metHeaders,'exact'))
                    model.metChEBIID{MetLoc(j)} = metInfo{i,strmatch('ChEBI ID',metHeaders,'exact')};
                end
            end
        else
            warning(['Metabolite ' metInfo{i,metCol} ' not in model']);
        end
        MetLoc=[];
    end
end

%% Verify all vectors are column Vectors
model.lb = columnVector(model.lb);
model.ub = columnVector(model.ub);
model.rev = columnVector(model.rev);
model.c = columnVector(model.c);
model.b = columnVector(model.b);
model.rxns = columnVector(model.rxns);
model.rxnNames = columnVector(model.rxnNames);
model.mets = columnVector(model.mets);
model.metNames = columnVector(model.metNames);
model.metFormulas = columnVector(model.metFormulas);
model.metCharges = columnVector(model.metCharges); % all others have plural for vector
model.metFormulasNeutral = columnVector(model.metFormulasNeutral);
model.subSystems = columnVector(model.subSystems);
model.rules = columnVector(model.rules);
model.grRules = columnVector(model.grRules);
model.genes = columnVector(model.genes);
model.confidenceScores = columnVector(model.confidenceScores);
model.rxnECNumbers = columnVector(model.rxnECNumbers);
model.rxnNotes = columnVector(model.rxnNotes);
model.rxnReferences = columnVector(model.rxnReferences);
model.proteins = columnVector(model.proteins);
model.metPubChemID = columnVector(model.metPubChemID);
model.metChEBIID = columnVector(model.metChEBIID);

if isfield(model,'metCompartment')
    model.metCompartment = columnVector(model.metCompartment);
end
if isfield(model,'metKEGGID')
    model.metKEGGID = columnVector(model.metKEGGID);
end
if isfield(model,'metInChIString')
    model.metInChIString = columnVector(model.metInChIString);
end
if isfield(model,'metSmiles')
    model.metSmiles = columnVector(model.metSmiles);
end
if isfield(model,'metHMDBID')
    model.metHMDBID = columnVector(model.metHMDBID);
end

warning on
