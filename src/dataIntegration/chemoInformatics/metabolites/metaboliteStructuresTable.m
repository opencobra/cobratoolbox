function metTable = metaboliteStructuresTable(metDir, saveDir)
% This fucntion creates a table of different representations of a
% metabolite structure including  smiles, inchi and inchikey,
%
% USAGE:
%
%    metTable = metaboliteStructuresTable(metDir, saveDir)
%
% INPUT:
%    metDir:  String with the directory containing mol files
%
% OPTIONAL INPUTS:
%    saveDir: String with the directory where the table format will be
%             saved. If is empty, the format is not saved.

if nargin < 2 || isempty(saveDir)
    toSave = false;
else
    toSave = true;
    saveDir = [regexprep(saveDir,'(/|\\)$',''), filesep];
end

% Read directory
metDir = [regexprep(metDir,'(/|\\)$',''), filesep];
fnames = dir([metDir '*.mol']);
fnames = {fnames.name}';

% Exchange metabolite table
nRows = numel(fnames);
varTypes = {'string', 'string', 'string', 'string'};
varNames = {'mets', 'inchikey', 'inchi', 'smiles'};
metTable = table('Size', [nRows length(varTypes)], 'VariableTypes', varTypes,...
    'VariableNames', varNames);

for i = 1:length(fnames)
    metTable.mets(i) = regexprep(fnames(i), '.mol', '');
    % InChIKey
    structure = openBabelConverter([metDir fnames{i}], 'inchikey');
    if ~isempty(structure)
        metTable.inchikey(i) = structure;
    end
    % InChI
    structure = openBabelConverter([metDir fnames{i}], 'inchi');
    if ~isempty(structure)
        metTable.inchi(i) = structure;
    end
    % SMILES
    structure = openBabelConverter([metDir fnames{i}], 'smiles');
    if ~isempty(structure)
        metTable.smiles(i) = structure;
    end
end

% save table
if toSave
    writetable(metTable, [saveDir 'metaboliteStructures.txt'])
end
end
