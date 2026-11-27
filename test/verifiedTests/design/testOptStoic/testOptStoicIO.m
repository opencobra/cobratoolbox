% The COBRAToolbox: testOptStoicIO.m
%
% Purpose:
%     - tests readGAMSSet and readGAMSParameter on small GAMS include files
%       (quoted and bare identifiers, comments, repeated elements, one- and
%       two-dimensional parameters)
%     - tests loadOptStoicDatabase on a small synthetic database written with
%       the format of the files of optstoic-gams: metabolites and reactions
%       found only in the stoichiometry, repeated entries, reaction types and
%       curated directionality, reactions with incorrect stoichiometry,
%       metabolites without formula, reaction annotations and inference of
%       metabolite names. No solver is needed.
%
% Authors:
%     - Sebastián N. Mendoza, 24/11/2026
%

global CBTDIR

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% set the tolerance
tol = 1e-12;

% temporary folder with small GAMS include files and a synthetic database
% with the format of the files of optstoic-gams
testDir = tempname;
dataDir = fullfile(testDir, 'db', 'data');
infoDir = fullfile(testDir, 'db', 'info');
mkdir(dataDir);
mkdir(infoDir);
tab = char(9);
% in the database, C00050 and R6 only appear in the stoichiometry and the
% repeated entry of C00030 in R2 replaces the first one
files = {
    'set.txt', {'/', '* comment line', '''X1'' /* inline comment */', '''X2'', ''X3''', 'X4', '''X1''', ...
        '/* comment', 'in two lines */', 'not an identifier', '/'};
    'emptySet.txt', {'/', '* no elements', '/'};
    'param2.txt', {'* comment line', '''a''.''b''    1', '''a'' . ''c''  -2.5e-1 /* comment */', ...
        ['''d''.''e''' tab '+3'], '  ''f''.''g''  .5'};
    'param1.txt', {'''r1''    0', '''r2''    2.0', '*''r3''    1'};
    'paramMixed.txt', {'''a''    1', '''b''.''c''    2'};
    fullfile('db', 'data', 'metabolites_modified.txt'), {'/', '''C00010'' /* glucose */', '''C00020''', ...
        '''C00030'', ''C00040''', '''C00010''', '/'};
    fullfile('db', 'data', 'reactions_modified.txt'), {'', '''R1''', '''R2''', '''R3''', '''R4''', 'R5', '''NAD_ATP'''};
    fullfile('db', 'data', 'Sij_modified.txt'), {'', '''C00010''.''R1''    -1', ...
        '''C00020''.''R1''    1 /* comment */', '''C00020''.''R2''    -1', '''C00030''.''R2''    2', ...
        '''C00030''.''R2''    1', '''C00030''.''R3''    -1', '''C00040''.''R3''    1.5e0', ...
        '''C00040''.''R4''    -1', '''C00010''.''R6''    -1', '''C00050''.''R6''    1', ...
        '''C00010''.''NAD_ATP''    -1', '''C00020''.''NAD_ATP''    1', '* comment line'};
    fullfile('db', 'data', 'metabolite_details.txt'), {['''C00010''.''C''' tab '6'], ['''C00010''.''H''' tab '12.0'], ...
        ['''C00010''.''O''' tab '6'], ['''C00010''.''charge''' tab '0'], ['''C00010''.''dGf''' tab '-218.28'], ...
        '''C00020''.''C''  3', '''C00020''.''H''  3', '''C00020''.''O''  3', '''C00020''.''charge''  -1', ...
        '''C00020''.''dGf''  -113.43', '''C00030''.''C''  1', '''C00030''.''H''  4', '''C00030''.''charge''  0', ...
        '''C00030''.''dGf''  -12.13', '''C00040''.''C''  2', '''C00040''.''R''  1', '''C00040''.''charge''  0', ...
        '''C00040''.''dGf''  10000000', '''C99999''.''C''  1'};
    fullfile('db', 'data', 'rxntype_modified.txt'), {'''R1''    0', '''R2''    1', '''R3''    2', '''R4''    1'};
    fullfile('db', 'data', 'rxntype_alternative.txt'), {'''R5''    0'};
    fullfile('db', 'data', 'atp_irreversible.txt'), {'/', '', '*** irreversible reactions related to ATP', '''R2''', '/'};
    fullfile('db', 'data', 'backward_irreversible_rxn.txt'), {'/', '''R4''', '/'};
    fullfile('db', 'data', 'inc_stoic.txt'), {'* reactions with incorrect stoichiometry', '/', '*''R1''', ...
        '''R3''', '''R99''', '/'};
    fullfile('db', 'data', 'no_formula_met.txt'), {'''C00040'''};
    fullfile('db', 'data', 'blocked_reactions.txt'), {'R1', 'R2'}};
for i = 1:size(files, 1)
    fid = fopen(fullfile(testDir, files{i, 1}), 'w');
    fprintf(fid, '%s\n', files{i, 2}{:});
    fclose(fid);
end

% readGAMSSet: quoted and bare identifiers, comments, duplicates and set delimiters
elements = readGAMSSet(fullfile(testDir, 'set.txt'));
assert(isequal(elements, {'X1'; 'X2'; 'X3'; 'X4'}));
elements = readGAMSSet(string(fullfile(testDir, 'set.txt')));
assert(isequal(elements, {'X1'; 'X2'; 'X3'; 'X4'}));
assert(isempty(readGAMSSet(fullfile(testDir, 'emptySet.txt'))));

% readGAMSParameter: two-dimensional parameter with comments and number formats
[keys, values] = readGAMSParameter(fullfile(testDir, 'param2.txt'));
assert(isequal(keys, {'a', 'b'; 'a', 'c'; 'd', 'e'; 'f', 'g'}));
assert(max(abs(values - [1; -0.25; 3; 0.5])) < tol);
% one-dimensional parameter (commented entries are ignored)
[keys, values] = readGAMSParameter(string(fullfile(testDir, 'param1.txt')));
assert(isequal(keys, {'r1'; 'r2'}));
assert(isequal(values, [0; 2]));
% mixed dimensions: the second key of one-dimensional entries is empty
[keys, values] = readGAMSParameter(fullfile(testDir, 'paramMixed.txt'));
assert(isequal(keys, {'a', ''; 'b', 'c'}));
assert(isequal(values, [1; 2]));

% wrong inputs of the readers
assert(verifyCobraFunctionError('readGAMSSet', 'inputs', {1}));
assert(verifyCobraFunctionError('readGAMSSet', 'inputs', {fullfile(testDir, 'missing.txt')}));
assert(verifyCobraFunctionError('readGAMSParameter', 'inputs', {{}}));
assert(verifyCobraFunctionError('readGAMSParameter', 'inputs', {fullfile(testDir, 'missing.txt')}));

% reaction annotations (format of reaction_db.xlsx): the names of the
% metabolites are inferred by aligning the stoichiometry and the description
annotations = cell2table({ ...
    'R1', 'reaction one', 'RXN1', 'Glucose <=> Pyruvate', 'C00010 <=> C00020', '1.1.1.1', -10, -12, -8; ...
    'R2', 'reaction two', 'RXN2', 'Pyruvate => 2 Methane', 'C00020 => 2 C00030', '2.2.2.2', 1e6, 1e6, 1e6; ...
    'R3', 'reaction three', '', 'Methane <=> X + Y', 'C00030 <=> C00040', '', -5, -6, -4; ...
    'R4', 'reaction four', 'RXN4', 'Ethane <=>', '', '', NaN, NaN, NaN; ...
    'R5', '', 'RXN5', 'Pyruvic acid => Methane', 'C00020 => C00030', '', 0, -1, 1; ...
    'R6', 'reaction six', 'RXN6', 'Glucose <=> A <=> B', 'C00010 <=> C00050 <=> C00010', '', 0, 0, 0; ...
    'R98', 'terms without KEGG IDs', '', 'Ethane => Propane', 'X => Y', '', 0, 0, 0; ...
    'R99', 'missing reaction', 'RXN99', 'Glucose <=> Pyruvate', 'C00010 <=> C00020', '', 0, 0, 0}, ...
    'VariableNames', {'rxn', 'name', 'abbreviation', 'description', 'stoichiometry', 'EC', 'dGr', 'dGrLB', 'dGrUB'});
annotationFile = fullfile(infoDir, 'reaction_db.xlsx');
writetable(annotations, annotationFile);

% default options (annotation file found in ../info)
database = loadOptStoicDatabase(dataDir, 'printLevel', 1);
assert(isequal(database.mets, {'C00010'; 'C00020'; 'C00030'; 'C00040'; 'C00050'}));
assert(isequal(database.rxns, {'R1'; 'R2'; 'R3'; 'R4'; 'R5'; 'NAD_ATP'; 'R6'}));
assert(full(database.S(3, 2)) == 1 && full(database.S(4, 3)) == 1.5 && full(database.S(5, 7)) == 1);
assert(nnz(database.S(:, 5)) == 0);
% bounds: R1 forward, R2 forward (ATP-related), R3 blocked (incorrect
% stoichiometry), R4 backward (curated), R5 and R6 reversible (no type),
% NAD_ATP blocked (ad hoc reaction)
assert(isequal(database.lb, [0; 0; 0; -1000; -1000; 0; -1000]));
assert(isequal(database.ub, [1000; 1000; 0; 0; 1000; 0; 1000]));
assert(isequal(database.rxnType, [0; 0; 2; 2; 1; 1; 1]));
assert(isequal(database.incorrectStoichRxns, {'R3'}));
assert(isequal(database.blockedRxns, {'R1'; 'R2'}));
% metabolite details
assert(isequal(database.metFormulas, {'C6H12O6'; 'C3H3O3'; 'CH4'; ''; ''}));
assert(isequal(database.metHasFormula, [true; true; true; false; false]));
assert(isequal(database.metCharges(1:4), [0; -1; 0; 0]) && isnan(database.metCharges(5)));
% unknown Gibbs free energies of formation (1e7 in the GAMS data) are NaN
assert(abs(database.metDeltaGf(1) + 218.28) < tol && isnan(database.metDeltaGf(4)) && isnan(database.metDeltaGf(5)));
assert(database.metComposition(4, strcmp(database.elements, 'R')) == 1);
assert(all(isnan(database.metComposition(5, :))));
assert(database.metComposition(3, strcmp(database.elements, 'O')) == 0);
% annotations: R99 is ignored, empty names are replaced by the reaction ID
% and values >= 1e6 (not estimated) are replaced by NaN
assert(isequal(database.rxnNames, {'reaction one'; 'reaction two'; 'reaction three'; 'reaction four'; 'R5'; ...
    'NAD_ATP'; 'reaction six'}));
assert(isequal(database.rxnAbbreviations([1, 2, 3, 5]), {'RXN1'; 'RXN2'; ''; 'RXN5'}));
assert(strcmp(database.rxnECNumbers{2}, '2.2.2.2'));
assert(database.rxnDeltaGr(1) == -10 && database.rxnDeltaGrLB(1) == -12 && database.rxnDeltaGrUB(1) == -8);
assert(isnan(database.rxnDeltaGr(2)) && isnan(database.rxnDeltaGr(4)));
% metabolite names: majority vote (Pyruvate twice, Pyruvic acid once); C00040
% (unequal number of terms) and C00050 (more than one arrow) keep their IDs
assert(isequal(database.metNames, {'Glucose'; 'Pyruvate'; 'Methane'; 'C00040'; 'C00050'}));

% options: no curation of incorrect stoichiometry and ad hoc reactions,
% alternative reaction types, flux bound, explicit annotation file without
% inference of names
database = loadOptStoicDatabase(dataDir, 'removeIncorrectStoichiometry', false, 'removeAdHocRxns', false, ...
    'rxnTypeFile', 'rxntype_alternative.txt', 'vmax', 10, 'annotationFile', annotationFile, ...
    'inferMetNames', false, 'printLevel', 0);
assert(isequal(database.lb, [-10; 0; -10; -10; 0; -10; -10]));
assert(isequal(database.ub, [10; 10; 10; 0; 10; 10; 10]));
assert(isequal(database.metNames, database.mets));
assert(strcmp(database.rxnNames{1}, 'reaction one'));

% database without annotation file (no folder info)
noInfoDir = fullfile(testDir, 'dbNoInfo', 'data');
copyfile(dataDir, noInfoDir);
database = loadOptStoicDatabase(noInfoDir, 'printLevel', 0);
assert(isequal(database.rxnNames, database.rxns));
assert(all(cellfun(@isempty, database.rxnAbbreviations)) && all(isnan(database.rxnDeltaGr)));
% optional files are not needed
delete(fullfile(noInfoDir, 'no_formula_met.txt'));
delete(fullfile(noInfoDir, 'blocked_reactions.txt'));
database = loadOptStoicDatabase(noInfoDir, 'printLevel', 0);
assert(isempty(database.blockedRxns) && database.metHasFormula(4));

% wrong inputs
assert(verifyCobraFunctionError('loadOptStoicDatabase', 'inputs', {fullfile(testDir, 'missing')}));
assert(verifyCobraFunctionError('loadOptStoicDatabase', 'inputs', {dataDir, 'annotationFile', ...
    fullfile(testDir, 'missing.xlsx'), 'printLevel', 0}));
assert(verifyCobraFunctionError('loadOptStoicDatabase', 'inputs', {dataDir, 'vmax', -1}));
delete(fullfile(noInfoDir, 'inc_stoic.txt'));
assert(verifyCobraFunctionError('loadOptStoicDatabase', 'inputs', {noInfoDir}));

% remove the temporary files
rmdir(testDir, 's');

% change the directory
cd(currentDir)
