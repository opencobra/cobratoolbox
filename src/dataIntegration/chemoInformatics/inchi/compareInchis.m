function comparisonTable = compareInchis(model, inchis, met)
% Compare inchi strings. Each inchi string is given a score based on its similarity 
% to the chemical formula and charge of the metabolite in the model. Factors such 
% as stereochemistry, if it is a standard inchi, and its similarity to the other 
% inchis are also considered.
%
% USAGE:
%
%    comparisonTable = compareInchis(model, inchis, met)
%
% INPUT:
%    model:     COBRA model
%                   *.mets - 1xm list of metabolite IDs
%                   *.metFormulas - 1xm list of metabolite Formulas
%                   *.metCharges - 1xm list of metabolite charges
%    inchis:    List of InChIs to compare
%    met:       Metabolite ID in the model
%
% OUTPUTS:
%    comparisonTable: Table containing the information used for each InChI
%

if isrow(inchis)
    inchis = inchis';
end
mets = regexprep(model.mets, '(\[\w\])', '');

% Prepare the table with inchi data
nRows = length(inchis);
varTypes = {'double', 'logical', 'string', 'string', 'logical', 'double', 'logical',...
    'logical', 'logical', 'double', 'double', 'logical', 'double', 'logical', 'string'};
varNames = {'scores', 'rGroup', 'InChI', 'metFormula', 'formulaOkBool', 'netCharge',...
    'chargeOkBool', 'stereochemicalSubLayers', 'standard', 'sourceSimilarity', ...
    'mainLayerSimilarity', 'isotopicLayer', 'layers', 'inchiWithMoreLayers', 'mainLayer'};
comparisonTable = table('Size', [nRows length(varTypes)], 'VariableTypes', varTypes,...
    'VariableNames', varNames);
   
emptyBool = cellfun(@isempty, inchis);
comparisonTable.InChI = inchis;

% Get InChI data
for i = 1:length(inchis)
    if ~emptyBool(i)
        inchiLayersDetail = getInchiData(inchis{i});
        comparisonTable.layers(i) = inchiLayersDetail.layers;
        comparisonTable.standard(i) = inchiLayersDetail.standard;
        comparisonTable.metFormula(i) = inchiLayersDetail.metFormula;
        comparisonTable.mainLayer(i) = inchiLayersDetail.mainLayer;
        comparisonTable.netCharge(i) = inchiLayersDetail.netCharge;
        comparisonTable.stereochemicalSubLayers(i) = inchiLayersDetail.stereochemicalSubLayers;
        comparisonTable.isotopicLayer(i) = inchiLayersDetail.isotopicLayer;
    end
end

% Charge comparison
% Compares the net charge in the InChI with the charge in the corresponding 
% metabolite in the model.
if isfield(model, 'metCharges')
    modelMetCharge = unique(model.metCharges(ismember(mets, met)));
    comparisonTable.chargeOkBool = ~emptyBool & comparisonTable.netCharge == modelMetCharge;
end
if isfield(model, 'metCharge')
    modelMetCharge = unique(model.metCharge(ismember(mets, met)));
    comparisonTable.chargeOkBool = ~emptyBool & comparisonTable.netCharge == modelMetCharge;
end

% Formula comparison 
% Compares the formula with the formula in the corresponding metabolite in the
% model. Hydrogens should be ignored because they are considered in the charge 
% or isotopic layers.
modelMetFormula = unique(model.metFormulas(ismember(mets, met)));
% Remove the R groups from the formula
rGroup = ["X", "Y", "*", "FULLR"];
if contains(modelMetFormula, rGroup)
    if isempty(regexprep(modelMetFormula, rGroup, ''))
        modelMetFormula = 'H';
    else
        modelMetFormula = editChemicalFormula(modelMetFormula);
    end
end
% Check if the formulas match
comparisonTable.formulaOkBool = ismember(regexprep(comparisonTable.metFormula, ...
    'H\d*', ''), regexprep(modelMetFormula, 'H\d*', ''));

% Source similarity
% For each InChI is calculated the number of equal InChIs divided between 
% the number of InChIs
inchis(emptyBool) = {'noData'};
for i = 1:length(inchis)
    if ~emptyBool(i)
        comparisonTable.sourceSimilarity(i) = sum(ismember(inchis, inchis(i))) / sum(~emptyBool);
    end
end

% Main layer similarity
% For each InChI is calculated the the number of equal main layer similarity 
% divided between the number of InChIs
for i = 1:length(inchis)
    if ~emptyBool(i)
        comparisonTable.mainLayerSimilarity(i) = sum(ismember(comparisonTable.mainLayer, ...
            comparisonTable.mainLayer(i))) / sum(~emptyBool);
    end
end

% InChI with more layers (stereochemistry and charge)
comparisonTable.inchiWithMoreLayers = comparisonTable.layers == max(comparisonTable.layers);

% Final score
% Priority will be given to molecules that have the same chemical formula as 
% the corresponding metabolite in the model, excluding hydrogen and non-chemical 
% atoms.
comparisonTable.scores = comparisonTable.chargeOkBool + (comparisonTable.formulaOkBool * 10)...
    + comparisonTable.stereochemicalSubLayers + comparisonTable.standard + ...
    comparisonTable.sourceSimilarity + comparisonTable.mainLayerSimilarity + ...
    comparisonTable.inchiWithMoreLayers;

end