% The COBRAToolbox: testFindMetMatch.m
%
% Purpose:
%     - findMetMatch ranks the metabolites of the template model TMODEL (global) as matches
%       for one metabolite of the compared model CMODEL (global). Each template metabolite
%       scores 1 for a matching identifier in metID (plus 1 for an exact ':<id>[' match),
%       0.01 for the same compartment and -5 for another one, 1 for a matching name, formula,
%       KEGG or SEED identifier and 0.1 for the same charge; negative scores become 0. When
%       none of identifier, name, formula, KEGG or SEED matched, the positive scores get the
%       similarity of the names (shared 4-letter words, function stringSimilarityForward).
%       Scores are shifted to a minimum of 0 and divided by their maximum; for a matched
%       template reaction tRxn the metabolites outside it get 0, and metabolites of another
%       compartment are multiplied by 0.1. Outputs: sorted scores, their indices, and the
%       flag hit. The function is QUARANTINED (Constitution III-Defects, quarantine in
%       back-fill campaigns): a SEED identifier given as a cell stops it, so no assertion
%       about the function is made.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/findMetMatch.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver; a test would set hand-built CMODEL and TMODEL
%     globals (and close the waitbar of the name-similarity branch).
%
% Coverage exemptions:
%     every line - findMetMatch is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers). Line 146 is reachable (a KEGG identifier given as
%     a cell, e.g. CMODEL.metKEGGID{1} = {'C00031'}); an earlier version of this header called
%     it dead code.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Names and identifiers are used as regular expressions without escaping
%       SEVERITY: wrong-result
%       TRIGGER: a compared metabolite whose name (or identifier, formula, KEGG or SEED
%         identifier) contains a regular-expression metacharacter, for example the name
%         'Water (pure)' against the identical template name 'Water (pure)'
%       OBSERVED: regexpi({'Water (pure)'}, '(\||\<)Water (pure)(\>|\|)') finds no match
%         ('(pure)' is a group matching 'pure'); a name such as
%         '(R)-3-Hydroxybutanoyl-[acyl-carrier protein]' does not match itself either, so the
%         name criterion adds nothing for such metabolites; '.' or '+' match other
%         characters (R2025a, 2026-11-15)
%       EXPECTED: the text matched literally (regexptranslate('escape', ...)), as the
%         criterion compares names. Severity audit 2026-11-15: OUTPUTS documents "matchScores:
%         Array of sorted, normalized scores for each met"; the name criterion (lines 84, 86,
%         113, 126, 151, 169) wraps names in \< \> to match them as whole words, i.e.
%         literally, but metacharacters common in metabolite names (parentheses, brackets, +,
%         .) are not escaped, so identical names do not match and the scores are wrong for a
%         large class of valid inputs
%       LINES: 84, 86, 113, 126, 151, 169
%     - DEFECT: A SEED identifier given as a cell stops the function
%       SEVERITY: limitation
%       TRIGGER: global CMODEL TMODEL with TMODEL the six template metabolites of
%         testMetCompare (glc_D[c], atp[c], adp[c], g6p[c], h[c], glc_D[e] with metID, metNames,
%         metFormulas, metCharge, metKEGGID, metSEEDID, S); CMODEL.mets = {'glc_D[c]'},
%         metNames = {'D-Glucose'}, metFormulas = {'C6H12O6'}, metCharge = 0,
%         metKEGGID = {'C00031'}, metSEEDID = {{'cpd00027'}}; findMetMatch(1)
%       OBSERVED: "Invalid data type. Argument must be numeric, char, or logical." at line 168:
%         the KEGG branch converts a cell pipePos with cell2mat (lines 145-147) and accepts a
%         cell identifier, the SEED branch does not (R2025a, 2026-11-15)
%       EXPECTED: a cell SEED identifier handled as a cell KEGG identifier is (an undocumented
%         input: verifyModelBorg, its line 272, builds metSEEDID as a cell of char)
%       LINES: 164-169
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindMetMatch'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
