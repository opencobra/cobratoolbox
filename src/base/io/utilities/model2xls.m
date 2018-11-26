function model2xls(model, fileName, compSymbols, compNames)
% Writes a model to and Excel spreadsheet.
%
% USAGE:
%
%    model2xls(model, fileName, compSymbols, compNames)
%
% INPUT:
%    model:          A COBRA model struct
%    fileName:       filename with an xsl extension.
%
% OPTIONAL INPUT:
%
%    compSymbols:    Symbols of compartments used in metabolite ids
%    compNames:      Names of the compartments identified by the symbols
%
% EXAMPLE:
%
%                   'Reaction List' tab headers (case sensitive):
%
%                     * Required:
%
%                       * 'Abbreviation':      HEX1
%                       * 'Reaction':          `1 atp[c] + 1 glc-D[c] --> 1 adp[c] + 1 g6p[c] + 1 h[c]`
%                       * 'GPR':               (3098.3) or (80201.1) or (2645.3) or ...
%                     * Optional:
%
%                       * 'Description':       Hexokinase
%                       * 'Subsystem':         Glycolysis
%                       * 'Reversible':        0 (false) or 1 (true)
%                       * 'Lower bound':       0
%                       * 'Upper bound':       1000
%                       * 'Objective':         0/1
%                       * 'Confidence Score':  0,1,2,3,4
%                       * 'EC Number':         2.7.1.1;2.7.1.2
%                       * 'KEGG ID':           R000001
%                       * 'Notes':             Reaction also associated with EC 2.7.1.2
%                       * 'References':        PMID:2043117;PMID:7150652,...
%
%                   'Metabolite List' tab: Required headers (case sensitive): (needs to be complete list of metabolites,
%                   i.e., if a metabolite appears in multiple compartments it has to be represented in multiple rows.
%                   Abbreviations need to overlap with use in Reaction List
%
%                     * Required
%
%                       * 'Abbreviation':      glc-D or glc-D[c]
%                     * Optional:
%
%                       * 'Charged formula' or formula:   C6H12O6
%                       * 'Charge':                       0
%                       * 'Compartment':                  cytosol
%                       * 'Description':                  D-glucose
%                       * 'KEGG ID':                      C00031
%                       * 'PubChem ID':                   5793
%                       * 'ChEBI ID':                     4167
%                       * 'InChI string':                 InChI=1/C6H12O6/c7-1-2-3(8)4(9)5(10)6(11)12-2/h2-11H,1H2/t2-,3-,4+,5-,6?/m1/s1
%                       * 'SMILES':                       OC[C@H]1OC(O)[C@H](O)[C@@H](O)[C@@H]1O
%                       * 'HMDB ID':                      HMDB00122
%
% NOTE:
%
%    Optional inputs may be required for input on unix machines.
%
% .. Authors:
%        - extracted from writeCbModel
%        - Thomas Pfau June 2017

if ~exist('compSymbols','var')
    if isfield(model,'comps') && isfield(model,'compNames')
        compSymbols = model.comps;
        compNames = model.compNames;
    else
        [compSymbols,compNames] = getDefaultCompartments();
    end
end

%Set up xlwrite in case its not set up.
setupxlwrite();

ReactionXlsFields = {'Abbreviation','Description','Reaction','GPR','Lower bound','Upper bound',...
    'Objective','Confidence Score','Subsystem','Notes','EC Number','References','KEGG ID'};
ReactionModelFields = {'rxns','rxnNames','formulas','grRules','lb','ub',...
    'c','rxnConfidenceScore','subSystems','rxnNotes','rxnECNumbers','rxnReferences','rxnKEGGID'};
if isfield(model,'rules')
    model = creategrRulesField(model);
end
if isfield(model,'osenseStr')
    %Only do something if minimisation is requested. Assume that osenseStr
    %is valid.
    if strcmpi(model.osenseStr,'min')
        model.c = model.c*-1;
    end
end

%Explicit handling of subSystems:
if isfield(model,'subSystems')
    %Merge the subSystems with separating ';'
    model.subSystems = cellfun(@(x) strjoin(x,';'),model.subSystems,'UniformOutput',0);
end

model.formulas = printRxnFormula(model,'printFlag',0);
actualFieldNames = fieldnames(model);
usedFields = ismember(ReactionModelFields,actualFieldNames);
ExcelFields = ReactionXlsFields(usedFields);
modelFields = ReactionModelFields(usedFields);
tmpData = cell(numel(model.rxns) + 1,sum(usedFields));
tmpData(1,:) = ExcelFields;
for i = 1:numel(ExcelFields)
    modelField = model.(modelFields{i});
    if isnumeric(modelField)

        for j = 2:length(modelField)+1
            tmpData{j,i} = num2str(modelField(j-1));
        end
        %tmpData(2:end,i) = mat2str(modelField);
    else
        modelField = cellfun(@chopForExcel, modelField,'UniformOutput',0);
        tmpData(2:end,i) = modelField;
    end
end

xlwrite(fileName,tmpData,'Reaction List');

MetaboliteXlsFields = {'Abbreviation','Description','Charged formula','Charge','Compartment','KEGG ID',...
    'PubChem ID','ChEBI ID','InChi string','SMILES','HMDB ID'};
MetaboliteModelFields = {'mets','metNames','metFormulas','metCharges','metComps','metKEGGID',...
    'metPubChemID','metChEBIID','metInChIString','metSmiles','metHMDBID'};
%determine compartments
[tokens tmp_met_struct] = regexp(model.mets,'(?<met>.+)\[(?<comp>.+)\]$','tokens','names'); % add the third type for parsing the string such as "M_10fthf5glu_c"
%if we have any compartment, we will use unknown as compartment ID for
%metabolites without compartment.

actualFieldNames = fieldnames(model);
usedFields = ismember(MetaboliteModelFields,actualFieldNames);
ExcelFields = MetaboliteXlsFields(usedFields);
modelFields = MetaboliteModelFields(usedFields);
tmpData = cell(numel(model.mets) + 1,sum(usedFields));
tmpData(1,:) = ExcelFields;
for i = 1:numel(ExcelFields)
    modelField = model.(modelFields{i});
    if isnumeric(modelField)
        tmpData(2:end,i) = num2cell(modelField);
    else
        modelField = cellfun(@chopForExcel, modelField,'UniformOutput',0);
        tmpData(2:end,i) = modelField;
    end
end

xlwrite(fileName,tmpData,'Metabolite List');

end

%% Chop strings for excel output
function strOut = chopForExcel(str)

if (length(str) > 5000)
    strOut = str(1:5000);
    fprintf('String longer than 5000 characters - truncated for Excel output\n%s\n',str);
else
    strOut = str;
end
end
