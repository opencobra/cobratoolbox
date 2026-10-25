function model = readCobrapyJSONModel(fileName, varargin)
% Reads a constraint-based model stored in the JSON format of cobrapy
% (`cobra.io.save_json_model`) and returns a COBRA model structure.
%
% USAGE:
%
%    model = readCobrapyJSONModel(fileName, varargin)
%
% INPUT:
%    fileName:      (string) path to the JSON file
%
% OPTIONAL INPUT:
%    printLevel:    (double) verbosity level (Default = 0)
%
% OUTPUT:
%    model:         COBRA model structure with fields `S`, `mets`,
%                   `metNames`, `metFormulas`, `metCharges`, `metComps`
%                   (compartment of each metabolite), `b`, `csense`, `rxns`,
%                   `rxnNames`, `lb`, `ub`, `c`, `osenseStr`, `subSystems`,
%                   `genes`, `grRules`, `rules`, `modelID` and `modelName`
%
% EXAMPLE:
%
%    model = readCobrapyJSONModel('biomin_newgrid_sce_a02_biocons_75Fe_5S.json');
%
% NOTE:
%
%    The stoichiometric coefficients are parsed from the raw text of the
%    file, so metabolite IDs are kept exactly as written (keys of JSON
%    objects that are not valid MATLAB identifiers are modified by
%    `jsondecode`).
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026

parser = inputParser();
parser.addRequired('fileName', @(x) ischar(x) || isstring(x));
parser.addParameter('printLevel', 0, @(x) isnumeric(x) || islogical(x));
parser.parse(fileName, varargin{:});
fileName = char(parser.Results.fileName);
printLevel = parser.Results.printLevel;
if ~exist(fileName, 'file')
    error('File %s not found.', fileName);
end

txt = fileread(fileName);
j = jsondecode(txt);
if ~isfield(j, 'metabolites') || ~isfield(j, 'reactions')
    error('%s is not a cobrapy JSON model.', fileName);
end
mets = j.metabolites;
if isstruct(mets)
    mets = num2cell(mets);
end
rxns = j.reactions;
if isstruct(rxns)
    rxns = num2cell(rxns);
end
nMets = numel(mets);
nRxns = numel(rxns);

model = struct();
model.mets = cellfun(@(m) m.id, mets, 'UniformOutput', false);
model.metNames = repmat({''}, nMets, 1);
model.metFormulas = repmat({''}, nMets, 1);
model.metCharges = zeros(nMets, 1);
model.metComps = repmat({''}, nMets, 1);
for i = 1:nMets
    m = mets{i};
    if isfield(m, 'name') && ~isempty(m.name), model.metNames{i} = m.name; end
    if isfield(m, 'formula') && ~isempty(m.formula), model.metFormulas{i} = m.formula; end
    if isfield(m, 'charge') && ~isempty(m.charge), model.metCharges(i) = m.charge; end
    if isfield(m, 'compartment') && ~isempty(m.compartment), model.metComps{i} = m.compartment; end
end
model.rxns = cellfun(@(r) r.id, rxns, 'UniformOutput', false);
model.rxnNames = repmat({''}, nRxns, 1);
model.lb = zeros(nRxns, 1);
model.ub = zeros(nRxns, 1);
model.c = zeros(nRxns, 1);
model.subSystems = repmat({''}, nRxns, 1);
model.grRules = repmat({''}, nRxns, 1);
for i = 1:nRxns
    r = rxns{i};
    if isfield(r, 'name') && ~isempty(r.name), model.rxnNames{i} = r.name; end
    if isfield(r, 'lower_bound'), model.lb(i) = r.lower_bound; end
    if isfield(r, 'upper_bound'), model.ub(i) = r.upper_bound; end
    if isfield(r, 'objective_coefficient') && ~isempty(r.objective_coefficient)
        model.c(i) = r.objective_coefficient;
    end
    if isfield(r, 'subsystem') && ~isempty(r.subsystem), model.subSystems{i} = r.subsystem; end
    if isfield(r, 'gene_reaction_rule') && ~isempty(r.gene_reaction_rule)
        model.grRules{i} = r.gene_reaction_rule;
    end
end

% stoichiometry parsed from the raw text to keep metabolite IDs
blocks = regexp(txt, '"metabolites"\s*:\s*\{([^{}]*)\}', 'tokens');
if numel(blocks) ~= nRxns
    error('The number of reaction stoichiometries (%d) differs from the number of reactions (%d).', ...
        numel(blocks), nRxns);
end
metIndex = containers.Map(model.mets, num2cell(1:nMets));
[iS, jS, vS] = deal(cell(nRxns, 1));
for k = 1:nRxns
    pairs = regexp(blocks{k}{1}, '"((?:[^"\\]|\\.)*)"\s*:\s*([-+0-9.eE]+)', 'tokens');
    ids = cellfun(@(x) x{1}, pairs, 'UniformOutput', false);
    ids = regexprep(ids, '\\(.)', '$1');
    coefs = cellfun(@(x) str2double(x{2}), pairs);
    if ~all(isKey(metIndex, ids))
        missing = ids(~isKey(metIndex, ids));
        error('Metabolite %s of reaction %s is not defined in the model.', missing{1}, model.rxns{k});
    end
    iS{k} = cell2mat(values(metIndex, ids))';
    jS{k} = k * ones(numel(ids), 1);
    vS{k} = coefs(:);
end
model.S = sparse(vertcat(iS{:}), vertcat(jS{:}), vertcat(vS{:}), nMets, nRxns);
model.b = zeros(nMets, 1);
model.csense = repmat('E', nMets, 1);
model.osenseStr = 'max';

if isfield(j, 'genes') && ~isempty(j.genes)
    genes = j.genes;
    if isstruct(genes)
        genes = num2cell(genes);
    end
    model.genes = cellfun(@(g) g.id, genes, 'UniformOutput', false);
else
    model.genes = cell(0, 1);
end
if any(~cellfun(@isempty, model.grRules))
    model = generateRules(model, printLevel);
else
    model.rules = repmat({''}, nRxns, 1);
end
model.modelID = '';
model.modelName = '';
if isfield(j, 'id') && ~isempty(j.id), model.modelID = j.id; end
if isfield(j, 'name') && ~isempty(j.name), model.modelName = j.name; end
if printLevel > 0
    fprintf('Model %s read: %d metabolites, %d reactions.\n', model.modelID, nMets, nRxns);
end
end
