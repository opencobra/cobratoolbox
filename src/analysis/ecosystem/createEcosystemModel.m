function eco = createEcosystemModel(models, prefixes, varargin)
% Creates an ecosystem structure that contains a community model built by
% merging individual member models through a shared pool compartment. Each
% member keeps its own reactions and metabolites (renamed with its prefix),
% and each exchanged metabolite is connected to a pool metabolite that is in
% turn exchanged with the environment. The community objective is the sum of
% the member objectives (one biomass reaction per member).
%
% For every exchange (boundary) reaction of member `k` of the form
% `met_e <=>` the community model contains:
%
%    prefix_k_EX_met_e:   prefix_k_met_e <=> met_e_pool   (member exchange)
%    EX_met_e:            met_e_pool <=>                  (pool exchange)
%
% USAGE:
%
%    eco = createEcosystemModel(models, prefixes, varargin)
%
% INPUTS:
%    models:           cell array of COBRA model structures (one per member).
%                      Each model must have a single reaction in its
%                      objective (`.c`) and exchange reactions with a single
%                      metabolite. Fields used:
%
%                        * .S - Stoichiometric matrix
%                        * .mets - Metabolite IDs
%                        * .rxns - Reaction IDs
%                        * .lb - Lower bounds
%                        * .ub - Upper bounds
%                        * .c - Objective coefficients
%    prefixes:         cell array of strings with one prefix per member,
%                      e.g. `{'org1', 'org2'}`. Reaction and metabolite IDs
%                      of member `k` are renamed as `[prefixes{k} '_' id]`.
%
% OPTIONAL INPUTS:
%    communityName:    (string) name of the community model
%                      (Default = 'My community model')
%    communityID:      (string) ID of the community model
%                      (Default = 'community')
%    poolBounds:       (double) 1 x 2 vector with the bounds of the pool
%                      exchange reactions (Default = [-1000 1000])
%    printLevel:       (double) 0 silent, 1 prints a construction report
%                      (Default = 1)
%
% OUTPUT:
%    eco:              (structure) ecosystem structure with fields:
%
%                        * .model - COBRA community model. Its objective is
%                          the sum of the member objective reactions
%                        * .name - community name
%                        * .id - community ID
%                        * .prefixes - member prefixes (column cell array)
%                        * .size - number of members
%                        * .objectives - member objective reaction IDs in the
%                          community model (one per member)
%                        * .memberRxns - cell array (one cell per member) with
%                          the IDs of the reactions belonging to each member
%                        * .exchangeInfo - structure with the exchanged
%                          metabolites information: `.mets` (metabolite IDs
%                          without prefix), `.poolMets`, `.poolRxns`,
%                          `.memberMets` and `.memberRxns` (nEx x nMembers,
%                          empty when a member does not exchange the
%                          metabolite) and `.memberBounds` (nEx x 2 x
%                          nMembers, original bounds)
%                        * .conflicts - IDs of exchanged metabolites with
%                          different names, formulas or charges among members
%                        * .rxn2cluster, .points, .pfractions,
%                          .feasiblePoints, .qualVectors, .fvaResults,
%                          .clusters, .k - empty fields filled by the
%                          downstream analysis functions
%
% EXAMPLE:
%
%    eco = createEcosystemModel({model1, model2}, {'org1', 'org2'}, ...
%                               'communityName', 'toy-example', 'communityID', 'org1-org2');
%
% NOTE:
%
%    Metabolite IDs written in the COBRA format `met[e]` are converted to
%    `met_e` to build the IDs of pool metabolites and pool exchanges (e.g.
%    `glc__D[e]` is exchanged through `glc__D_e_pool` and `EX_glc__D_e`).
%    This function reproduces the `Ecosystem` class constructor of the Python
%    implementation of Jiménez et al. (2023), https://github.com/mathomics/ecosystem
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on the Python code of N.E. Jiménez et al.

parser = inputParser();
parser.addRequired('models', @(x) iscell(x) && numel(x) >= 2 && all(cellfun(@isstruct, x)));
parser.addRequired('prefixes', @(x) iscellstr(x) || isstring(x));
parser.addParameter('communityName', 'My community model', @(x) ischar(x) || isstring(x));
parser.addParameter('communityID', 'community', @(x) ischar(x) || isstring(x));
parser.addParameter('poolBounds', [-1000 1000], @(x) isnumeric(x) && numel(x) == 2 && x(1) <= x(2));
parser.addParameter('printLevel', 1, @(x) isnumeric(x) || islogical(x));
parser.parse(models, prefixes, varargin{:});

models = parser.Results.models(:);
prefixes = cellstr(parser.Results.prefixes);
prefixes = prefixes(:);
communityName = char(parser.Results.communityName);
communityID = char(parser.Results.communityID);
poolBounds = parser.Results.poolBounds(:)';
printLevel = parser.Results.printLevel;

nMembers = numel(models);
if numel(prefixes) ~= nMembers
    error('The number of prefixes (%d) must be equal to the number of models (%d).', numel(prefixes), nMembers);
end
if numel(unique(prefixes)) ~= nMembers
    error('Prefixes must be unique.');
end
requiredFields = {'S', 'mets', 'rxns', 'lb', 'ub', 'c'};
for k = 1:nMembers
    missing = setdiff(requiredFields, fieldnames(models{k}));
    if ~isempty(missing)
        error('Model %d (%s) does not have the field(s): %s', k, prefixes{k}, strjoin(missing, ', '));
    end
    if nnz(models{k}.c) ~= 1
        error(['More than one (or no) reaction in the objective function of member %s. ' ...
            'Not supported! Set a single objective reaction.'], prefixes{k});
    end
end

if printLevel > 0
    fprintf('1. Storing exchanged metabolites information ...\n');
end
% exchanged metabolites in the order they appear in the member models
exMets = {};
exInfo = struct('mets', {{}}, 'names', {{}}, 'formulas', {{}}, 'charges', {[]}, ...
    'memberMets', {{}}, 'memberRxns', {{}}, 'memberBounds', {[]}, ...
    'memberColumns', {[]}, 'memberRows', {[]}, 'memberCoefs', {[]});
memberExCount = zeros(nMembers, 1);
for k = 1:nMembers
    model = models{k};
    nnzPerRxn = full(sum(model.S ~= 0, 1));
    boundary = find(nnzPerRxn == 1);
    memberExCount(k) = numel(boundary);
    for j = boundary
        i = find(model.S(:, j));
        baseId = regexprep(model.mets{i}, '\[(\w+)\]$', '_$1');
        pos = find(strcmp(exMets, baseId), 1);
        if isempty(pos)
            exMets{end + 1, 1} = baseId; %#ok<AGROW>
            pos = numel(exMets);
            exInfo.memberMets(pos, 1:nMembers) = {''};
            exInfo.memberRxns(pos, 1:nMembers) = {''};
            exInfo.memberBounds(pos, 1:2, 1:nMembers) = NaN;
            exInfo.memberColumns(pos, 1:nMembers) = 0;
            exInfo.memberRows(pos, 1:nMembers) = 0;
            exInfo.memberCoefs(pos, 1:nMembers) = 0;
            exInfo.names{pos, 1} = '';
            exInfo.formulas{pos, 1} = '';
            exInfo.charges(pos, 1) = NaN;
        end
        exInfo.memberMets{pos, k} = [prefixes{k} '_' model.mets{i}];
        exInfo.memberRxns{pos, k} = [prefixes{k} '_' model.rxns{j}];
        exInfo.memberBounds(pos, :, k) = [model.lb(j), model.ub(j)];
        exInfo.memberColumns(pos, k) = j;
        exInfo.memberRows(pos, k) = i;
        exInfo.memberCoefs(pos, k) = full(model.S(i, j));
    end
end
exInfo.mets = exMets;
nEx = numel(exMets);

% check for conflicts (names, formulas, charges) among members
conflicts = {};
memberNames = cell(nEx, nMembers);
memberFormulas = cell(nEx, nMembers);
memberCharges = NaN(nEx, nMembers);
for k = 1:nMembers
    model = models{k};
    for e = 1:nEx
        i = exInfo.memberRows(e, k);
        if i > 0
            memberNames{e, k} = '';
            memberFormulas{e, k} = '';
            if isfield(model, 'metNames'), memberNames{e, k} = model.metNames{i}; end
            if isfield(model, 'metFormulas'), memberFormulas{e, k} = model.metFormulas{i}; end
            if isfield(model, 'metCharges'), memberCharges(e, k) = model.metCharges(i); end
        end
    end
end
for e = 1:nEx
    present = exInfo.memberRows(e, :) > 0;
    first = find(present, 1);
    exInfo.names{e} = memberNames{e, first};
    exInfo.formulas{e} = memberFormulas{e, first};
    exInfo.charges(e) = memberCharges(e, first);
    names = memberNames(e, present);
    formulas = memberFormulas(e, present);
    charges = memberCharges(e, present);
    charges = charges(~isnan(charges));
    if numel(unique(names)) > 1 || numel(unique(formulas)) > 1 || numel(unique(charges)) > 1
        conflicts{end + 1, 1} = exMets{e}; %#ok<AGROW>
        if printLevel > 0
            fprintf('Conflicts for exchange metabolite %s (names: %s; formulas: %s)\n', exMets{e}, ...
                strjoin(unique(names), ', '), strjoin(unique(formulas), ', '));
        end
    end
end

if printLevel > 0
    fprintf('2. Updating member model objects ids ...\n');
    fprintf('3. Storing member objectives ...\n');
    fprintf('4. Merging member models ...\n');
end
nMetsMember = cellfun(@(m) numel(m.mets), models);
nRxnsMember = cellfun(@(m) numel(m.rxns), models);
metOffset = [0; cumsum(nMetsMember)];
rxnOffset = [0; cumsum(nRxnsMember)];
nMetsTotal = metOffset(end) + nEx;
nRxnsTotal = rxnOffset(end) + nEx;

% genes and rules are kept only if all members have them
keepGenes = all(cellfun(@(m) isfield(m, 'genes') && isfield(m, 'rules'), models));
keepSubSystems = all(cellfun(@(m) isfield(m, 'subSystems'), models));
geneOffset = 0;

cmodel = struct();
cmodel.S = sparse(nMetsTotal, nRxnsTotal);
cmodel.mets = cell(nMetsTotal, 1);
cmodel.metNames = cell(nMetsTotal, 1);
cmodel.metFormulas = cell(nMetsTotal, 1);
cmodel.metCharges = zeros(nMetsTotal, 1);
cmodel.b = zeros(nMetsTotal, 1);
cmodel.csense = repmat('E', nMetsTotal, 1);
cmodel.rxns = cell(nRxnsTotal, 1);
cmodel.rxnNames = cell(nRxnsTotal, 1);
cmodel.lb = zeros(nRxnsTotal, 1);
cmodel.ub = zeros(nRxnsTotal, 1);
cmodel.c = zeros(nRxnsTotal, 1);
if keepGenes
    cmodel.genes = {};
    cmodel.rules = cell(nRxnsTotal, 1);
end
if keepSubSystems
    cmodel.subSystems = cell(nRxnsTotal, 1);
end
memberRxns = cell(nMembers, 1);
objectives = cell(nMembers, 1);
[iAll, jAll, vAll] = deal([]);
for k = 1:nMembers
    model = models{k};
    metIdx = metOffset(k) + (1:nMetsMember(k));
    rxnIdx = rxnOffset(k) + (1:nRxnsMember(k));
    [i, j, v] = find(model.S);
    iAll = [iAll; metOffset(k) + i(:)]; %#ok<AGROW>
    jAll = [jAll; rxnOffset(k) + j(:)]; %#ok<AGROW>
    vAll = [vAll; v(:)]; %#ok<AGROW>
    cmodel.mets(metIdx) = strcat(prefixes{k}, '_', model.mets(:));
    if isfield(model, 'metNames')
        cmodel.metNames(metIdx) = model.metNames(:);
    else
        cmodel.metNames(metIdx) = model.mets(:);
    end
    if isfield(model, 'metFormulas')
        cmodel.metFormulas(metIdx) = model.metFormulas(:);
    else
        cmodel.metFormulas(metIdx) = {''};
    end
    if isfield(model, 'metCharges')
        cmodel.metCharges(metIdx) = model.metCharges(:);
    end
    cmodel.rxns(rxnIdx) = strcat(prefixes{k}, '_', model.rxns(:));
    if isfield(model, 'rxnNames')
        cmodel.rxnNames(rxnIdx) = model.rxnNames(:);
    else
        cmodel.rxnNames(rxnIdx) = model.rxns(:);
    end
    cmodel.lb(rxnIdx) = model.lb(:);
    cmodel.ub(rxnIdx) = model.ub(:);
    cmodel.c(rxnIdx) = model.c(:);
    if keepGenes
        cmodel.genes = [cmodel.genes; strcat(prefixes{k}, '_', model.genes(:))];
        cmodel.rules(rxnIdx) = regexprep(model.rules(:), 'x\((\d+)\)', ...
            ['x(${num2str(str2double($1) + ' num2str(geneOffset) ')})']);
        geneOffset = geneOffset + numel(model.genes);
    end
    if keepSubSystems
        cmodel.subSystems(rxnIdx) = model.subSystems(:);
    end
    memberRxns{k} = cmodel.rxns(rxnIdx);
    objectives{k} = cmodel.rxns{rxnOffset(k) + find(model.c)};
    if printLevel > 0
        fprintf('{''%s'': %g}\n', objectives{k}, full(model.c(model.c ~= 0)));
    end
end

if printLevel > 0
    fprintf('5. Creating pool compartment, metabolites and reactions ...\n');
end
poolMetIdx = metOffset(end) + (1:nEx)';
poolRxnIdx = rxnOffset(end) + (1:nEx)';
cmodel.mets(poolMetIdx) = strcat(exMets, '_pool');
cmodel.metNames(poolMetIdx) = exInfo.names;
cmodel.metFormulas(poolMetIdx) = exInfo.formulas;
charges = exInfo.charges;
charges(isnan(charges)) = 0;
cmodel.metCharges(poolMetIdx) = charges;
cmodel.rxns(poolRxnIdx) = strcat('EX_', exMets);
cmodel.rxnNames(poolRxnIdx) = strcat('Pool', {' '}, exInfo.names, ' exchange');
cmodel.lb(poolRxnIdx) = poolBounds(1);
cmodel.ub(poolRxnIdx) = poolBounds(2);
if keepGenes
    cmodel.rules(poolRxnIdx) = {''};
end
if keepSubSystems
    cmodel.subSystems(poolRxnIdx) = {'Exchange'};
end
% pool exchange reactions: met_pool <=>
iAll = [iAll; poolMetIdx];
jAll = [jAll; poolRxnIdx];
vAll = [vAll; -ones(nEx, 1)];
% member exchange reactions: prefix_met_e <=> met_pool
for e = 1:nEx
    for k = 1:nMembers
        if exInfo.memberColumns(e, k) > 0
            iAll(end + 1, 1) = poolMetIdx(e); %#ok<AGROW>
            jAll(end + 1, 1) = rxnOffset(k) + exInfo.memberColumns(e, k); %#ok<AGROW>
            vAll(end + 1, 1) = -exInfo.memberCoefs(e, k); %#ok<AGROW>
        end
    end
end
cmodel.S = sparse(iAll, jAll, vAll, nMetsTotal, nRxnsTotal);
cmodel.osenseStr = 'max';
cmodel.modelID = communityID;
cmodel.modelName = communityName;
if keepGenes
    cmodel.grRules = cell(nRxnsTotal, 1);
    cmodel.grRules(:) = {''};
    cmodel = creategrRulesField(cmodel);
end
if printLevel > 0
    fprintf('6. Updating compartment names ...\n');
    fprintf('Done. Community model created\n');
end

eco = struct();
eco.model = cmodel;
eco.name = communityName;
eco.id = communityID;
eco.prefixes = prefixes;
eco.size = nMembers;
eco.objectives = objectives;
eco.memberRxns = memberRxns;
eco.exchangeInfo = struct('mets', {exInfo.mets}, 'poolMets', {cmodel.mets(poolMetIdx)}, ...
    'poolRxns', {cmodel.rxns(poolRxnIdx)}, 'memberMets', {exInfo.memberMets}, ...
    'memberRxns', {exInfo.memberRxns}, 'memberBounds', {exInfo.memberBounds});
eco.conflicts = conflicts;
eco.rxn2cluster = {};
eco.points = [];
eco.pfractions = [];
eco.maxCommunityGrowth = [];
eco.feasiblePoints = [];
eco.qualVectors = [];
eco.qualPointIndex = [];
eco.fvaResults = [];
eco.clusters = [];
eco.k = [];

if printLevel > 0
    fprintf('Created community model from %d member models:\n', nMembers);
    fprintf('General stats:\n');
    for k = 1:nMembers
        modelID = '';
        if isfield(models{k}, 'modelID'), modelID = models{k}.modelID; end
        fprintf('model (%d):\n', k - 1);
        fprintf('\t id = %s, prefix = %s\n', char(modelID), prefixes{k});
        fprintf('\t\t reactions = %d\n', nRxnsMember(k));
        fprintf('\t\t exchange metabolites = %d\n', memberExCount(k));
    end
    fprintf('community model:\n');
    fprintf('\t id = %s, name = %s\n', communityID, communityName);
    fprintf('\t\t reactions = %d\n', nRxnsTotal);
    fprintf('\t\t exchange metabolites = %d\n', nEx);
    fprintf('Exchange metabolite conflicts (formula, charge, name, id) = %d\n', numel(conflicts));
    fprintf('Community exchange reaction bounds: (%g, %g)\n', poolBounds(1), poolBounds(2));
end
end
