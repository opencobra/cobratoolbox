function database = loadOptStoicDatabase(dataDir, varargin)
% Loads the database of metabolites and reactions used by optStoic and
% minFlux/minRxn (Chowdhury and Maranas, 2015) from the GAMS include files
% distributed in https://github.com/maranasgroup/optstoic-gams (folder
% `data`) and returns it as a COBRA model structure. Reaction bounds are
% defined from the reaction types as in `minFlux.gms`/`minRxn.gms`:
% forward irreversible (type 0) [0, vmax], reversible (type 1)
% [-vmax, vmax] and backward irreversible (type 2) [-vmax, 0]. ATP-related
% reactions listed in `atp_irreversible.txt` are set as forward
% irreversible and those in `backward_irreversible_rxn.txt` as backward
% irreversible.
%
% USAGE:
%
%    database = loadOptStoicDatabase(dataDir, varargin)
%
% INPUT:
%    dataDir:                    (string) folder with the GAMS include files:
%
%                                  * metabolites_modified.txt
%                                  * reactions_modified.txt
%                                  * Sij_modified.txt
%                                  * metabolite_details.txt
%                                  * rxntype_modified.txt
%                                  * atp_irreversible.txt
%                                  * backward_irreversible_rxn.txt
%                                  * inc_stoic.txt
%                                  * blocked_reactions.txt (optional)
%                                  * no_formula_met.txt (optional)
%
% OPTIONAL INPUTS:
%    rxnTypeFile:                (string) file with the reaction types
%                                (Default = 'rxntype_modified.txt')
%    vmax:                       (double) maximum absolute flux (Default = 1000)
%    removeIncorrectStoichiometry: (logical) block the reactions listed in
%                                `inc_stoic.txt` (Default = true)
%    removeAdHocRxns:            (logical) block the ad hoc reactions
%                                'NAD_ATP' and 'FAD_ATP' (Default = true)
%    annotationFile:             (string) Excel file with reaction
%                                annotations (`reaction_db.xlsx` of the
%                                folder `info`). If empty, the file
%                                `../info/reaction_db.xlsx` is used when it
%                                exists (Default = '')
%    inferMetNames:              (logical) infer metabolite names from the
%                                reaction descriptions of the annotation
%                                file (Default = true)
%    printLevel:                (double) verbosity level (Default = 1)
%
% OUTPUT:
%    database:                   (structure) COBRA model structure with the
%                                standard fields (`S`, `mets`, `rxns`, `lb`,
%                                `ub`, `c`, `b`, `csense`, `osenseStr`,
%                                `metNames`, `metFormulas`, `metCharges`,
%                                `rxnNames`, `rxnECNumbers`) and the fields:
%
%                                  * .elements - element names {'C', 'H', ...}
%                                  * .metComposition - nMets x nElements
%                                    matrix with the number of atoms
%                                  * .metDeltaGf - standard Gibbs free energy
%                                    of formation (kcal/mol); NaN if unknown
%                                  * .metHasFormula - false for metabolites
%                                    without formula
%                                  * .rxnType - 0 forward irreversible,
%                                    1 reversible, 2 backward irreversible
%                                  * .rxnAbbreviations, .rxnDescriptions,
%                                    .rxnDeltaGr, .rxnDeltaGrLB,
%                                    .rxnDeltaGrUB - annotations (when
%                                    available, kcal/mol)
%                                  * .incorrectStoichRxns - reactions with
%                                    potential stoichiometric imbalance
%                                  * .blockedRxns - reactions reported as
%                                    blocked (not used to set bounds)
%
% EXAMPLE:
%
%    database = loadOptStoicDatabase('optstoic-gams/data');
%
% NOTE:
%
%    Metabolite and reaction IDs are KEGG identifiers. Metabolite names are
%    not part of the GAMS data: they are inferred (majority vote) by
%    aligning the KEGG IDs of the stoichiometry and the names of the
%    description of each annotated reaction, and set to the metabolite ID
%    when they cannot be inferred. In `metabolite_details.txt`, unknown
%    Gibbs free energies of formation are written as 1e7 or 1e8; they are
%    set to NaN, so that these metabolites are not allowed by default in
%    `optStoic` (as reactants, they would make any conversion
%    thermodynamically favorable).
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation of the data handling of optStoic-GAMS (A. Chowdhury, C.Y. Ng, C.D. Maranas)

parser = inputParser();
parser.addRequired('dataDir', @(x) ischar(x) || isstring(x));
parser.addParameter('rxnTypeFile', 'rxntype_modified.txt', @ischar);
parser.addParameter('vmax', 1000, @(x) isnumeric(x) && isscalar(x) && x > 0);
parser.addParameter('removeIncorrectStoichiometry', true, @(x) islogical(x) || isnumeric(x));
parser.addParameter('removeAdHocRxns', true, @(x) islogical(x) || isnumeric(x));
parser.addParameter('annotationFile', '', @ischar);
parser.addParameter('inferMetNames', true, @(x) islogical(x) || isnumeric(x));
parser.addParameter('printLevel', 1, @(x) isnumeric(x) || islogical(x));
parser.parse(dataDir, varargin{:});
dataDir = char(parser.Results.dataDir);
rxnTypeFile = parser.Results.rxnTypeFile;
vmax = parser.Results.vmax;
removeIncorrectStoichiometry = parser.Results.removeIncorrectStoichiometry;
removeAdHocRxns = parser.Results.removeAdHocRxns;
annotationFile = parser.Results.annotationFile;
inferMetNames = parser.Results.inferMetNames;
printLevel = parser.Results.printLevel;

if ~exist(dataDir, 'dir')
    error('Folder %s not found.', dataDir);
end
required = {'metabolites_modified.txt', 'reactions_modified.txt', 'Sij_modified.txt', ...
    'metabolite_details.txt', rxnTypeFile, 'atp_irreversible.txt', 'backward_irreversible_rxn.txt', 'inc_stoic.txt'};
for i = 1:numel(required)
    if ~exist(fullfile(dataDir, required{i}), 'file')
        error('File %s not found in %s.', required{i}, dataDir);
    end
end

% metabolites and reactions
mets = readGAMSSet(fullfile(dataDir, 'metabolites_modified.txt'));
rxns = readGAMSSet(fullfile(dataDir, 'reactions_modified.txt'));
[sKeys, sValues] = readGAMSParameter(fullfile(dataDir, 'Sij_modified.txt'));
newMets = setdiff(unique(sKeys(:, 1)), mets, 'stable');
newRxns = setdiff(unique(sKeys(:, 2)), rxns, 'stable');
if ~isempty(newMets) || ~isempty(newRxns)
    if printLevel > 0
        fprintf('Adding %d metabolites and %d reactions found only in Sij_modified.txt\n', numel(newMets), numel(newRxns));
    end
    mets = [mets; newMets(:)];
    rxns = [rxns; newRxns(:)];
end
nMets = numel(mets);
nRxns = numel(rxns);
[~, iMet] = ismember(sKeys(:, 1), mets);
[~, iRxn] = ismember(sKeys(:, 2), rxns);
% repeated entries: the last one prevails (as in GAMS)
[~, lastIdx] = unique([iMet, iRxn], 'rows', 'last');
S = sparse(iMet(lastIdx), iRxn(lastIdx), sValues(lastIdx), nMets, nRxns);

% metabolite details
[dKeys, dValues] = readGAMSParameter(fullfile(dataDir, 'metabolite_details.txt'));
elements = {'C', 'H', 'N', 'O', 'P', 'S', 'F', 'Cl', 'Mg', 'Fe', 'Se', 'Co', 'As', 'Br', 'I', 'R'};
[isMet, dMet] = ismember(dKeys(:, 1), mets);
composition = NaN(nMets, numel(elements));
charges = NaN(nMets, 1);
deltaGf = NaN(nMets, 1);
[isElement, dElement] = ismember(dKeys(:, 2), elements);
sel = isMet & isElement;
composition(sub2ind(size(composition), dMet(sel), dElement(sel))) = dValues(sel);
sel = isMet & strcmp(dKeys(:, 2), 'charge');
charges(dMet(sel)) = dValues(sel);
sel = isMet & strcmp(dKeys(:, 2), 'dGf');
deltaGf(dMet(sel)) = dValues(sel);
% unknown Gibbs free energies of formation (1e7 or 1e8 in the GAMS data)
deltaGf(deltaGf >= 1e7) = NaN;
hasDetails = ~all(isnan(composition), 2);
composition(hasDetails & isnan(composition)) = 0;
hasFormula = hasDetails;
if exist(fullfile(dataDir, 'no_formula_met.txt'), 'file')
    noFormula = readGAMSSet(fullfile(dataDir, 'no_formula_met.txt'));
    hasFormula(ismember(mets, noFormula)) = false;
end
formulas = repmat({''}, nMets, 1);
for i = find(hasFormula)'
    formula = '';
    for e = 1:numel(elements)
        n = composition(i, e);
        if n == 1
            formula = [formula elements{e}]; %#ok<AGROW>
        elseif n ~= 0
            formula = [formula elements{e} num2str(n)]; %#ok<AGROW>
        end
    end
    formulas{i} = formula;
end

% reaction types and bounds
[tKeys, tValues] = readGAMSParameter(fullfile(dataDir, rxnTypeFile));
rxnType = ones(nRxns, 1);
[isRxn, tRxn] = ismember(tKeys, rxns);
rxnType(tRxn(isRxn)) = tValues(isRxn);
atpIrreversible = readGAMSSet(fullfile(dataDir, 'atp_irreversible.txt'));
backwardIrreversible = readGAMSSet(fullfile(dataDir, 'backward_irreversible_rxn.txt'));
rxnType(ismember(rxns, atpIrreversible)) = 0;
rxnType(ismember(rxns, backwardIrreversible)) = 2;
lb = -vmax * ones(nRxns, 1);
ub = vmax * ones(nRxns, 1);
lb(rxnType == 0) = 0;
ub(rxnType == 2) = 0;
incorrectStoich = readGAMSSet(fullfile(dataDir, 'inc_stoic.txt'));
incorrectStoich = incorrectStoich(ismember(incorrectStoich, rxns));
if removeIncorrectStoichiometry
    lb(ismember(rxns, incorrectStoich)) = 0;
    ub(ismember(rxns, incorrectStoich)) = 0;
end
if removeAdHocRxns
    adHoc = ismember(rxns, {'NAD_ATP', 'FAD_ATP'});
    lb(adHoc) = 0;
    ub(adHoc) = 0;
end
blockedRxns = {};
if exist(fullfile(dataDir, 'blocked_reactions.txt'), 'file')
    blockedRxns = readGAMSSet(fullfile(dataDir, 'blocked_reactions.txt'));
end

database = struct();
database.S = S;
database.mets = mets;
database.metNames = mets;
database.metFormulas = formulas;
database.metCharges = charges;
database.metDeltaGf = deltaGf;
database.metHasFormula = hasFormula;
database.elements = elements;
database.metComposition = composition;
database.b = zeros(nMets, 1);
database.csense = repmat('E', nMets, 1);
database.rxns = rxns;
database.rxnNames = rxns;
database.lb = lb;
database.ub = ub;
database.c = zeros(nRxns, 1);
database.osenseStr = 'min';
database.rxnType = rxnType;
database.rxnAbbreviations = repmat({''}, nRxns, 1);
database.rxnDescriptions = repmat({''}, nRxns, 1);
database.rxnECNumbers = repmat({''}, nRxns, 1);
database.rxnDeltaGr = NaN(nRxns, 1);
database.rxnDeltaGrLB = NaN(nRxns, 1);
database.rxnDeltaGrUB = NaN(nRxns, 1);
database.incorrectStoichRxns = incorrectStoich;
database.blockedRxns = blockedRxns;
database.modelID = 'optStoic_database';
database.description = ['optStoic database loaded from ' dataDir];

% reaction annotations
if isempty(annotationFile)
    candidate = fullfile(dataDir, '..', 'info', 'reaction_db.xlsx');
    if exist(candidate, 'file')
        annotationFile = candidate;
    end
end
if ~isempty(annotationFile)
    if ~exist(annotationFile, 'file')
        error('Annotation file %s not found.', annotationFile);
    end
    opts = detectImportOptions(annotationFile, 'VariableNamingRule', 'preserve');
    opts = setvartype(opts, opts.VariableNames(1:6), 'char');
    T = readtable(annotationFile, opts);
    names = T.Properties.VariableNames;
    [found, pos] = ismember(T.(names{1}), rxns);
    database.rxnNames(pos(found)) = T.(names{2})(found);
    database.rxnAbbreviations(pos(found)) = T.(names{3})(found);
    database.rxnDescriptions(pos(found)) = T.(names{4})(found);
    database.rxnECNumbers(pos(found)) = T.(names{6})(found);
    if numel(names) >= 9
        database.rxnDeltaGr(pos(found)) = T.(names{7})(found);
        database.rxnDeltaGrLB(pos(found)) = T.(names{8})(found);
        database.rxnDeltaGrUB(pos(found)) = T.(names{9})(found);
    end
    database.rxnNames(cellfun(@isempty, database.rxnNames)) = rxns(cellfun(@isempty, database.rxnNames));
    database.rxnDeltaGr(database.rxnDeltaGr >= 1e6) = NaN;

    if inferMetNames
        % metabolite names inferred by aligning, side by side, the
        % stoichiometry (KEGG IDs) and the description (names) of each
        % reaction when both sides have the same number of terms
        stoich = T.(names{5});
        descr = T.(names{4});
        votes = containers.Map('KeyType', 'char', 'ValueType', 'any');
        for r = 1:height(T)
            if isempty(stoich{r}) || isempty(descr{r})
                continue
            end
            sSides = strsplit(stoich{r}, {'<=>', '=>', '<='});
            dSides = strsplit(descr{r}, {'<=>', '=>', '<='});
            if numel(sSides) ~= 2 || numel(dSides) ~= 2
                continue
            end
            for side = 1:2
                sTerms = strtrim(strsplit(strtrim(sSides{side}), ' + '));
                dTerms = strtrim(strsplit(strtrim(dSides{side}), ' + '));
                if numel(sTerms) ~= numel(dTerms) || isempty(sTerms{1}) || isempty(dTerms{1})
                    continue
                end
                for t = 1:numel(sTerms)
                    metId = regexp(sTerms{t}, 'C\d{5}', 'match', 'once');
                    name = strtrim(regexprep(dTerms{t}, '^\d+(\.\d+)?\s+', ''));
                    if isempty(metId) || isempty(name)
                        continue
                    end
                    if isKey(votes, metId)
                        votes(metId) = [votes(metId); {name}];
                    else
                        votes(metId) = {name};
                    end
                end
            end
        end
        votedMets = keys(votes);
        [isDbMet, posMet] = ismember(votedMets, mets);
        for i = find(isDbMet)
            [candidates, ~, idx] = unique(votes(votedMets{i}));
            [~, best] = max(accumarray(idx, 1));
            database.metNames{posMet(i)} = candidates{best};
        end
        if printLevel > 0
            fprintf('Names inferred for %d metabolites from reaction descriptions.\n', sum(isDbMet));
        end
    end
end

if printLevel > 0
    fprintf('optStoic database: %d metabolites (%d with formula and dGf), %d reactions\n', nMets, ...
        sum(hasFormula & ~isnan(deltaGf)), nRxns);
    fprintf('  forward irreversible: %d, reversible: %d, backward irreversible: %d, blocked by curation: %d\n', ...
        sum(lb == 0 & ub > 0), sum(lb < 0 & ub > 0), sum(lb < 0 & ub == 0), sum(lb == 0 & ub == 0));
end
end
