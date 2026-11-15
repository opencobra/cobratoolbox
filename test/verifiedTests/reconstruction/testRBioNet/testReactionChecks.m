% The COBRAToolbox: testReactionChecks.m
%
% Purpose:
%     - ReactionChecks(rxn, metab, meta_compartment, newrxns, data) checks the new reactions
%       newrxns (rows: abbreviation, description, formula, ...) before rBioNet adds them to
%       the reaction database rxn: abbreviations must be given and distinct, every reaction
%       must be mass and charge balanced with the metabolites of metab (columns abbreviation,
%       description, neutral formula, charged formula, charge) in the compartments of
%       meta_compartment, and each new reaction is compared with the database. A new reaction
%       with the same metabolites as a database reaction (any compartment, any coefficient)
%       is listed in data as {abbreviation, database row, database row, ...}; one identical to
%       a database reaction (same metabolites, compartments, coefficients and reversibility)
%       is removed with a warning box. The output is {newrxns, data, 1}, or [] after an error
%       box. The test uses a hand-built database of glycolysis reactions; the expected
%       outputs follow from the documentation and from the formulae (balance checked by
%       hand in the comments). Message boxes are closed by the test.
%
% Function under test:
%     src/reconstruction/rBioNet/ReactionChecks.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built rBioNet reaction and metabolite tables.
%
% Coverage exemptions:
%     Lines 59-60, 70-112: GUI - an abbreviation already in the database opens a modal
%     question dialog (questdlg). Lines 145-147, 187-217: GUI - a metabolite not in metab
%     leads to the modal question dialog of line 196. Lines 156, 174-181: GUI - a charged
%     formula containing FULLRCO opens a modal question dialog. Lines 161-168, 223-225: GUI -
%     an unbalanced reaction opens the unbalanced window, which waits (uiwait) for the user
%     (line 162 is moreover unreachable: balancecheck with output 1 never returns []).
%     Lines 118-122: unreachable (dead code), see the second defect below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The balance check prints ans = [] for every new reaction
%       SEVERITY: cosmetic
%       TRIGGER: any call that reaches the balance check, for example the first section below
%       OBSERVED: (R2025a, 2026-11-15) "ans =" and "[]" printed once per new reaction, because
%         the call showprogress(i/S_nrxns(1)) has no semicolon and showprogress returns []
%       EXPECTED: only the progress bar printed
%       LINES: 142
%     - DEFECT: The missing-formula message is never shown; an empty formula raises an index error
%       SEVERITY: cosmetic
%       TRIGGER: ReactionChecks(rxn, metab, compartments, {'NOF', 'no formula', '', 1, 0}, [])
%         with the tables of this test
%       OBSERVED: (R2025a, 2026-11-15) error 'Index exceeds array bounds.' at line 144:
%         isempty(newrxns(i,3)) on line 117 tests a 1 x 1 cell, which is never empty, so the
%         box 'is missing the formula' is never opened and LoadReaction returns an empty
%         0 x 6 cell for the empty formula
%       EXPECTED: the box of line 118 and the output []
%       LINES: 117-122
%     - DEFECT: A metabolite without charged formula raises an error after BalancePrep's message
%       SEVERITY: cosmetic
%       TRIGGER: a metab row {'nochg', 'no charged formula', 'H', '', '0'} and
%         ReactionChecks(rxn, metab, compartments, {'NOC', 'x', 'nochg[c] -> h[c]', 1, 0}, [])
%       OBSERVED: (R2025a, 2026-11-15) BalancePrep opens the box 'Reaction cannot be created
%         with metabolites that are missing the charged formula.' and returns [], then
%         ReactionChecks fails with 'Brace indexing is not supported for variables of this
%         type.' at line 150
%       EXPECTED: the output [] after the box
%       LINES: 149-150
%     - DEFECT: A new reaction identical to a database reaction leaves an empty row in data
%       SEVERITY: cosmetic
%       TRIGGER: newrxns {'ENO2', 'x', '2pg[c] -> h2o[c] + pep[c]', 0, 0; 'ENO_DUP', 'x',
%         '2pg[c] <=> h2o[c] + pep[c]', 1, 0; 'GLCt', 'x', 'glc-D[e] <=> glc-D[c]', 1, 0;
%         'PGIe', 'x', 'g6p[c] <=> f6p[e]', 1, 0} with the database rows ENO and PGI of this
%         test
%       OBSERVED: (R2025a, 2026-11-15) data = {'ENO2', ENO row; [], []; 'PGIe', PGI row}: the
%         rows of data follow the rows of the similarity list, and the row of the removed
%         reaction ENO_DUP stays empty when a later new reaction has similar reactions
%       EXPECTED: one row of data per remaining new reaction with similar reactions
%       LINES: 318-319
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReactionChecks'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the progress bar (showprogress) creates global variables; they are removed at the end
globalsBefore = who('global');

% metabolites: abbreviation, description, neutral formula, charged formula, charge
metab = {
    '2pg', 'D-Glycerate 2-phosphate', 'C3H7O7P', 'C3H4O7P', '-3'
    'pep', 'Phosphoenolpyruvate', 'C3H5O6P', 'C3H2O6P', '-3'
    'h2o', 'Water', 'H2O', 'H2O', '0'
    'glc-D', 'D-Glucose', 'C6H12O6', 'C6H12O6', '0'
    'atp', 'ATP', 'C10H16N5O13P3', 'C10H12N5O13P3', '-4'
    'adp', 'ADP', 'C10H15N5O10P2', 'C10H12N5O10P2', '-3'
    'g6p', 'D-Glucose 6-phosphate', 'C6H13O9P', 'C6H11O9P', '-2'
    'f6p', 'D-Fructose 6-phosphate', 'C6H13O9P', 'C6H11O9P', '-2'
    'h', 'Proton', 'H', 'H', '1'};
compartments = {'Cytoplasm (c)'; 'Extracellular space (e)'};

% reaction database: abbreviation, description, formula, reversible, confidence score.
% ENOm has the metabolites of ENO in another compartment
rxnDatabase = {
    'ENO', 'enolase', '2pg[c] <=> h2o[c] + pep[c]', 1, 0
    'PGI', 'glucose-6-phosphate isomerase', 'g6p[c] <=> f6p[c]', 1, 0
    'HEX1', 'hexokinase', 'atp[c] + glc-D[c] -> adp[c] + g6p[c] + h[c]', 0, 0
    'H2Ot', 'water transport', 'h2o[e] <=> h2o[c]', 1, 0
    'ENOm', 'enolase, mitochondrial', '2pg[m] <=> h2o[m] + pep[m]', 1, 0};

% new reactions, all balanced:
%   ENO2    2pg -> h2o + pep: C3H4O7P = H2O + C3H2O6P, charge -3 = 0 - 3; irreversible, so
%           not identical to ENO
%   PGIe    g6p[c] <=> f6p[e]: C6H11O9P both sides, charge -2; f6p in another compartment
%   GLCt    glc-D[e] <=> glc-D[c]: no database reaction has only glc-D
%   ENO_DUP the formula of ENO, identical to it
%   PGI_DUP the formula of PGI, identical to it
eno2 = {'ENO2', 'enolase, irreversible', '2pg[c] -> h2o[c] + pep[c]', 0, 0};
pgiE = {'PGIe', 'glucose-6-phosphate isomerase, export', 'g6p[c] <=> f6p[e]', 1, 0};
glcT = {'GLCt', 'glucose transport', 'glc-D[e] <=> glc-D[c]', 1, 0};
enoDup = {'ENO_DUP', 'enolase copy', '2pg[c] <=> h2o[c] + pep[c]', 1, 0};
pgiDup = {'PGI_DUP', 'isomerase copy', 'g6p[c] <=> f6p[c]', 1, 0};

%% a balanced reaction without similar database reaction is returned unchanged

% the data input is returned as given when no similar reaction exists
output = ReactionChecks(rxnDatabase, metab, compartments, glcT, []);
assert(isequal(output, {glcT, [], 1}));
output = ReactionChecks(rxnDatabase, metab, compartments, glcT, {});
assert(isequal(output, {glcT, {}, 1}));
assert(isempty(closeMessageBoxes()));

%% reactions with the metabolites of database reactions are listed in data

% ENO2 has the metabolites of ENO and ENOm (database rows 1 and 5), PGIe those of PGI
% (row 2); the shorter row of data is filled with []; GLCt has none and is not listed
newReactions = [eno2; pgiE; glcT];
output = ReactionChecks(rxnDatabase, metab, compartments, newReactions, []);
assert(isequal(output{1}, newReactions));
assert(isequal(output{2}, {'ENO2', rxnDatabase(1, :), rxnDatabase(5, :); ...
    'PGIe', rxnDatabase(2, :), []}));
assert(isequal(output{3}, 1));
assert(isempty(closeMessageBoxes()));

%% a reaction identical to a database reaction is removed with a warning box

% ENO_DUP is identical to ENO; ENO2 is only similar to it (database without ENOm)
output = ReactionChecks(rxnDatabase(1:4, :), metab, compartments, [eno2; enoDup], []);
assert(isequal(output, {eno2, {'ENO2', rxnDatabase(1, :)}, 1}));
assert(strcmp(closeMessageBoxes(), 'Reaction: ENO_DUP exists under ENO and will not be added.'));

% two identical reactions around a new one: both are removed, the remaining one is kept
output = ReactionChecks(rxnDatabase(1:4, :), metab, compartments, [enoDup; glcT; pgiDup], []);
assert(isequal(output, {glcT, [], 1}));
boxText = closeMessageBoxes();
assert(contains(boxText, 'Reaction: ENO_DUP exists under ENO and will not be added.'));
assert(contains(boxText, 'Reaction: PGI_DUP exists under PGI and will not be added.'));

%% a missing abbreviation gives [] and an error box

noName = glcT;
noName{1} = '';
assert(isempty(ReactionChecks(rxnDatabase, metab, compartments, noName, [])));
assert(strcmp(closeMessageBoxes(), ...
    'No rxn name specified. Make sure all reaction have specified abbreviations.'));

%% two new reactions with the same abbreviation give [] and an error box

sameName = [glcT; glcT];
assert(isempty(ReactionChecks(rxnDatabase, metab, compartments, sameName, [])));
assert(strcmp(closeMessageBoxes(), 'New reactions cannot have the same name (GLCt).'));

% remove the global variables created by the progress bar
newGlobals = setdiff(who('global'), globalsBefore);
for iGlobal = 1:numel(newGlobals)
    clear('global', newGlobals{iGlobal});
end

% change the directory
cd(currentDir)

function boxText = closeMessageBoxes()
% Returns the text of the open message boxes and closes them, so that no window stays open.
boxes = findall(0, 'Type', 'figure', '-regexp', 'Tag', '^Msgbox_');
boxText = '';
for iBox = 1:numel(boxes)
    boxLines = cellstr(get(findall(boxes(iBox), 'Type', 'text'), 'String'));
    boxText = strtrim([boxText, ' ', strjoin(strtrim(boxLines), ' ')]);
end
delete(boxes);
end
