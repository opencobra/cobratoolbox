function model = xls2model(fileName,biomassRxnEquation, defaultbound)
% xls2model Writes a model from Excel spreadsheet.
%
% model = xls2model(fileName,biomassRxnEquation)
%
% INPUT
% fileName      xls spreadsheet, with one 'Reaction List' and one 'Metabolite List' tab
%
% 'Reaction List' tab headers (case sensitive): 
%   Required:
%   'Abbreviation'      HEX1
%   'Reaction'          1 atp[c] + 1 glc-D[c] --> 1 adp[c] + 1 g6p[c] + 1 h[c]
%   'GPR'               (3098.3) or (80201.1) or (2645.3) or ...
%   Optional:
%   'Description'       Hexokinase
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
%   Required
%   'Abbreviation'      glc-D or glc-D[c]
%   Optional:
%   'Charged formula'   C6H12O6
%   'Charge'            0
%   'Compartment'       cytosol
%   'Description'       D-glucose
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
% defaultbound              the deault bound for lower and upper bounds, if
%                           no bounds are specified in the Excel sheet
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

if ~exist('defaultbound','var')
    defaultbound = 1000;
end

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
if ~isempty(strmatch('Description',rxnHeaders,'exact'))
    rxnNameList = Strings(2:end,strmatch('Description',rxnHeaders,'exact'));
else
    rxnNameList = Strings(2:end,strmatch('Abbreviation',rxnHeaders,'exact'));
end
rxnList = Strings(2:end,strmatch('Reaction',rxnHeaders,'exact'));
grRuleList = Strings(2:end,strmatch('GPR',rxnHeaders,'exact'));
if ~isempty(strmatch('Proteins',rxnHeaders,'exact'))
    Protein = Strings(2:end,strmatch('Proteins',rxnHeaders,'exact'));
end

if ~isempty(strmatch('Subsystem',rxnHeaders,'exact'))
    subSystemList = Strings(2:end,strmatch('Subsystem',rxnHeaders,'exact'));
else
    subSystemList = cell(size(rxnList,1),1);
    subSystemList(:) = {''};
end

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

if ~isempty(strmatch('Lower bound',rxnHeaders,'exact'))
    lowerBoundList = columnVector(cell2mat(rxnInfo(2:end,strmatch('Lower bound',rxnHeaders,'exact'))));
    %Default -1000
    lowerBoundList(isnan(lowerBoundList)) = -1000;
else
    lowerBoundList = -defaultbound*ones(length(rxnAbrList),1);
end

if ~isempty(strmatch('Upper bound',rxnHeaders,'exact'))
    upperBoundList = columnVector(cell2mat(rxnInfo(2:end,strmatch('Upper bound',rxnHeaders,'exact'))));
    %Default 1000;
    upperBoundList(isnan(upperBoundList)) = 1000;
else
    upperBoundList = defaultbound*ones(length(rxnAbrList),1);
end

revFlagList = lowerBoundList<0;

if ~isempty(strmatch('Objective',rxnHeaders,'exact'))
    Objective = columnVector(cell2mat(rxnInfo(2:end,strmatch('Objective',rxnHeaders,'exact'))));
    Objective(isnan(Objective)) = 0;    
else
    Objective = zeros(length(rxnAbrList),1);
end

model = createModel(rxnAbrList,rxnNameList,rxnList,revFlagList,lowerBoundList,upperBoundList,subSystemList,grRuleList);

if ~isempty(strmatch('Confidence Score',rxnHeaders,'exact'))
    model.rxnConfidenceScores = rxnInfo(2:end,strmatch('Confidence Score',rxnHeaders,'exact'));
else
    model.rxnConfidenceScores = cell(length(model.rxns),1); %empty cell instead of NaN
end
if ~isempty(strmatch('EC Number',rxnHeaders,'exact'))
    %This needs to be changed to the new annotation scheme and putting the
    %ECNumbers there.
    model.rxnECNumbers = Strings(2:end,strmatch('EC Number',rxnHeaders,'exact'));
end
if ~isempty(strmatch('Notes',rxnHeaders,'exact'))
    model.rxnNotes = Strings(2:end,strmatch('Notes',rxnHeaders,'exact'));
end
if ~isempty(strmatch('References',rxnHeaders,'exact'))
    %This needs to be changed to the new annotation scheme and putting the
    %PubMed id using isDescribedBy there.
    model.rxnReferences = Strings(2:end,strmatch('References',rxnHeaders,'exact'));
end

%fill in opt info for metabolites
if ~isempty(Objective) && length(Objective) == length(model.rxns)
    model.c = (Objective);
end

metHeaders = metInfo(1,:);

for n = 1:length(metHeaders)
    if isnan(metHeaders{n})
        metHeaders{n} = '';
    end
end

% case 1: all metabolites in List have a compartment assignement

metCol = strmatch('Abbreviation',metHeaders,'exact');
Compartments = {};
mets = MetStrings(:,metCol);
%Now, we could have a problem, if the reactions are presented without
%compartments. In this instance, we would have to first put a "[c]" id
%behind all metabolites. 
metCompAbbrev = cellfun(@(x) regexp(x,'.*\[(.*)\]$','tokens'), mets, 'UniformOutput', 0);
%get those which don't have a compartmentID
noncomps = cellfun(@isempty, metCompAbbrev);
mets(noncomps) = strcat(mets(noncomps),'[c]');

[A,B] = ismember(model.mets,mets);
matchingmets = mets(B(A));

if numel(matchingmets) ~= numel(model.mets)
    fprintf('The following metabolites from the reaction formulas did not have a matching metabolite in the metabolite list:\n');
    disp(setdiff(model.mets,mets));
    error('Not all metabolites could be matched');
end

if isempty(strmatch('Compartment',metHeaders,'exact'))
    %we use default compartments
    compartmentAbbr = {'c', 'e', 'm', 'n', 'r', 'x', 'l', 'g'};
    compartments = {'cytosol', 'extracellular', 'mitochondria', 'nucleus', 'endoplasmatic reticulum', 'peroxisome', 'lysosome', 'golgi aparatus'};
    %lets check if all metabolites do have a standard compartment
    metCompAbbrev = cellfun(@(x) regexp(x,['.*\[([' strjoin(compartmentAbbr,'') '])\]$'],'tokens'), matchingmets, 'UniformOutput', 0);
    noncomps = cellfun(@isempty, metCompAbbrev);
    if any(noncomps)
        %So, there are missing compartment ids.
        %lets move all those metabolites to the cytosol, checking, that we
        %don't generate replicates.
        matchingmets(noncomps) = strcat(matchingmets(noncomps),'[c]');
        if numel(unique(matchingmets)) ~= numel(matchingmets)
            [~,ia] = unique(matchingmets);
            non_unique = matchingmets(setdiff(1:numel(matchinmets),ia));
            disp(unique(non_unique))
            error('The above metabolites are present both without compartment identifier and with id in the cytosol.Metabolites without compartment id are assumed to be located in the cytosol, and these metabolites would lead to duplicate metabolite ids!');
        end
    end
    %Now, there should be no metabolites without compartment.
    %lets collect the compartments.
    Comps = cellfun(@(x) x{1} ,cellfun(@(x) regexp(x,['.*\[([' strjoin(compartmentAbbr,'') '])\]$'],'tokens'), matchingmets));
    %matchingmets has already the right order.
    model.comps = columnVector(compartmentAbbr(ismember(compartmentAbbr,Comps)));
    model.compNames = columnVector(compartments(ismember(compartmentAbbr,Comps)));
    model.mets = columnVector(matchingmets);
else
    %if Compartments is present, we will create a translation table
    %(ignoring everything that is empty)
    Compartments = MetStrings(B(A),strmatch('Compartment',metHeaders,'exact'));
    Cytosolname = 'cytosol';
    metCompAbbrev = cellfun(@(x) regexp(x,['.*\[(.*)\]$'],'tokens'), matchingmets, 'UniformOutput', 0);
    noncomps = cellfun(@isempty, metCompAbbrev);
    CytoNames = setdiff(unique(Compartments(~cellfun(@isempty, cellfun(@(x) regexp(x,'.*\[(c)\]$','tokens'), matchingmets, 'UniformOutput', 0)))),'');
    if numel(CytoNames) == 1
        Cytosolname = CytoNames{1};
    else
        CytoNames{end+1} = Cytosolname;
        CytoNames = unique(CytoNames);
    end
    
    if any(noncomps)
        matchingmets(noncomps) = strcat(matchingmets(noncomps),'[c]');
        Compartments(noncomps) = {Cytosolname};
        if numel(unique(matchingmets)) ~= numel(matchingmets)
            [~,ia] = unique(matchingmets);
            non_unique = matchingmets(setdiff(1:numel(matchinmets),ia));
            disp(unique(non_unique))
            error('The above metabolites are present both without compartment identifier and with id in the cytosol.Metabolites without compartment id are assumed to be located in the cytosol, and these metabolites would lead to duplicate metabolite ids!');
        end
    end
    metCompAbbrev = cellfun(@(x) x{1}, cellfun(@(x) regexp(x,['.*\[(.*)\]$'],'tokens'), matchingmets));
    
    %now reorder them and assign names to the ids.
    [ucomps, origpos] = unique(Compartments);
    [model.comp,~,origin] = unique(metCompAbbrev(origpos));
    %Column Vector
    model.comp = columnVector(model.comp);
    for i = 1:numel(model.comp)
        %combine all, ignoring empty entries.
        CompNames{i} = strjoin(setdiff(ucomps(origin==i),''),' or ');
    end
    model.compNames = columnVector(CompNames);
    model.mets = columnVector(matchingmets);
end
%%Set metNames
if ~isempty(strmatch('Description',metHeaders,'exact'))
    model.metNames = columnVector(MetStrings(B(A),strmatch('Description',metHeaders,'exact')));
end
%%Set Formulas
if ~isempty(strmatch('Charged formula',metHeaders,'exact'))
    model.metFormulas = columnVector(MetStrings(B(A),strmatch('Charged formula',metHeaders,'exact')));
end
if ~isempty(strmatch('Formula',metHeaders,'exact'))
    model.metFormulas = columnVector(MetStrings(B(A),strmatch('Formula',metHeaders,'exact')));
end
%%Set Charge
if ~isempty(strmatch('Charge',metHeaders,'exact'))    
    model.metCharges = cell2mat(columnVector(metInfo(B(A),strmatch('Charge',metHeaders,'exact'))));
end

if ~isempty(strmatch('SMILES',metHeaders,'exact'))
    model.metSmiles= columnVector(MetStrings(B(A),strmatch('SMILES',metHeaders,'exact')));
end

%% Set annotations. (Has to be updated, once annotation structure is defined)
if ~isempty(strmatch('InChI string',metHeaders,'exact'))
    model.metKEGGID = columnVector(MetStrings(B(A),strmatch('KEGG ID',metHeaders,'exact')));
end
if ~isempty(strmatch('InChI string',metHeaders,'exact'))
    model.metInChIString = columnVector(MetStrings(B(A),strmatch('InChI string',metHeaders,'exact')));
end
if ~isempty(strmatch('HMDB ID',metHeaders,'exact'))
    model.metHMDBID = columnVector(MetStrings(B(A),strmatch('HMDB ID',metHeaders,'exact')));
end

if ~isempty(strmatch('PubChem ID',metHeaders,'exact'))
    model.metPubChemID = columnVector(MetStrings(B(A),strmatch('PubChem ID',metHeaders,'exact')));
end
if ~isempty(strmatch('ChEBI ID',metHeaders,'exact'))
    model.metChEBIID  = columnVector(MetStrings(B(A),strmatch('ChEBI ID',metHeaders,'exact')));
end

model.description = fileName;
model.rxnConfidenceScores = columnVector(model.rxnConfidenceScores);

warning on
end



