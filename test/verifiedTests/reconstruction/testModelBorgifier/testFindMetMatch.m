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
%       flag hit. The test builds four template metabolites by hand and derives every
%       expected score by hand in the comments.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/findMetMatch.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs. The name-similarity
%     branch opens a waitbar (figure), which the test closes.
%
% Coverage exemptions:
%     Line 146: unreachable (dead code). pipePos is built at line 144 by concatenating
%     numbers, so iscell(pipePos) on line 145 is never true.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Names and identifiers are used as regular expressions without escaping
%       SEVERITY: limitation
%       TRIGGER: a compared metabolite whose name (or identifier, formula, KEGG or SEED
%         identifier) contains a regular-expression metacharacter, for example the name
%         'Water (pure)' against the identical template name 'Water (pure)'
%       OBSERVED: regexpi({'Water (pure)'}, '(\||\<)Water (pure)(\>|\|)') finds no match
%         ('(pure)' is a group matching 'pure'); a name such as
%         '(R)-3-Hydroxybutanoyl-[acyl-carrier protein]' does not match itself either, so the
%         name criterion adds nothing for such metabolites; '.' or '+' match other
%         characters (R2025a, 2026-11-15)
%       EXPECTED: the text matched literally (regexptranslate('escape', ...)), as the
%         criterion compares names
%       LINES: 84, 86, 113, 126, 151, 169
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

% the function reads the globals CMODEL and TMODEL: save them and remember the globals that
% existed before the test
globalsBefore = who('global');
global CMODEL TMODEL
savedCMODEL = CMODEL;
savedTMODEL = TMODEL;

% the waitbar of the name-similarity branch is created invisible and closed below
defaultVisible = get(groot, 'DefaultFigureVisible');
set(groot, 'DefaultFigureVisible', 'off');
figuresBefore = findall(groot, 'Type', 'figure');

% scores are sums of a few decimal constants and ratios of them; 1e-12 allows for their
% rounding only
tol = 1e-12;

% template metabolites:
%   t1 glc_D[c], t2 glc_D[e] (same annotation as t1), t3 atp[c], t4 h2o[c]
% one template reaction, 1: glc_D[e] -> atp[c] (involves t2 and t3 only)
TMODEL = struct();
TMODEL.mets = {'glc_D[c]'; 'glc_D[e]'; 'atp[c]'; 'h2o[c]'};
TMODEL.metID = {'m1:glc_D[c]'; 'm1:glc_D[e]'; 'm1:atp[c]|m2:ATP'; 'm2:water'};
TMODEL.metNames = {'D-Glucose'; 'D-Glucose'; 'ATP|Adenosine triphosphate'; 'Water'};
TMODEL.metFormulas = {'C6H12O6'; 'C6H12O6'; 'C10H12N5O13P3'; 'H2O'};
TMODEL.metCharge = [0; 0; -4; 0];
TMODEL.metKEGGID = {'C00031'; 'C00031'; 'C00002'; 'C00001'};
TMODEL.metSEEDID = {'cpd00027'; 'cpd00027'; ''; ''};
TMODEL.S = sparse([0; -1; 1; 0]);

% compared metabolites:
%   1 glc_D[c]: same annotation as t1
%   2 ATP: identifier without compartment, two names, two KEGG identifiers, no SEED identifier
%   3 xyz[c]: nothing in common with any template metabolite but the compartment
CMODEL = struct();
CMODEL.mets = {'glc_D[c]'; 'ATP'; 'xyz[c]'};
CMODEL.metNames = {'D-Glucose'; 'Adenosine triphosphate|ATP'; 'Glucose-6-phosphate'};
CMODEL.metFormulas = {'C6H12O6'; 'C10H12N5O13P3'; 'C6H11O9P'};
CMODEL.metCharge = [0; -4; -2];
CMODEL.metKEGGID = {'C00031'; 'C00002|C99999'; ''};
CMODEL.metSEEDID = {'cpd00027'; ''; ''};

%% a metabolite with matching annotation

% raw scores of glc_D[c]:
%   t1: identifier 1 + exact 1, compartment 0.01, name 1, formula 1, charge 0.1, KEGG 1, SEED 1 = 6.11
%   t2: identifier 2, compartment -5, name, formula, KEGG, SEED 4, charge 0.1          = 1.1
%   t3: compartment 0.01                                                                 = 0.01
%   t4: compartment 0.01, charge 0.1                                                     = 0.11
% shifted by the minimum 0.01 and divided by the maximum 6.1: [1, 1.09, 0, 0.1] / 6.1;
% t2 is in another compartment: 1.09 / 6.1 * 0.1
[matchScores, matchIndex, hit] = findMetMatch(1);
assert(isequal(matchIndex, [1 2 4 3]));
assert(norm(matchScores - [1, 0.109 / 6.1, 0.1 / 6.1, 0]) < tol);
assert(hit == 1);
% the output has no third element when it is not requested
[matchScores, matchIndex] = findMetMatch(1);
assert(isequal(matchIndex, [1 2 4 3]));

%% a matched template reaction removes the metabolites outside it

% reaction 1 involves t2 and t3: t1 and t4 get 0; t2 keeps 1.09 / 6.1 * 0.1; ties (0) keep
% the order of the template metabolites
[matchScores, matchIndex, hit] = findMetMatch(1, 1);
assert(isequal(matchIndex, [2 1 3 4]));
assert(norm(matchScores - [0.109 / 6.1, 0, 0, 0]) < tol);
assert(hit == 1);
% tRxn = 0 means no matched reaction
[~, matchIndex] = findMetMatch(1, 0);
assert(isequal(matchIndex, [1 2 4 3]));

%% a metabolite without compartment, several names and KEGG identifiers, no SEED identifier

% ATP matches the identifier of t3 (case-insensitive) and its exact form 'm1:atp[': 2;
% its compartment 'ATP' matches none: -5 for all; both names match t3 (counted once): 1;
% formula 1, charge 0.1, KEGG C00002 1: t3 = 2 - 5 + 1 + 1 + 0.1 + 1 = 0.1; t1, t2 and t4
% get -5 and become 0. Normalized: t3 = 1. Without a compartment, no factor 0.1 is applied
[matchScores, matchIndex, hit] = findMetMatch(2);
assert(isequal(matchIndex, [3 1 2 4]));
assert(norm(matchScores - [1 0 0 0]) < tol);
assert(hit == 1);

%% nothing matches: the names decide (and a waitbar is shown)

% xyz[c] scores only the compartment: t1, t3, t4 0.01, t2 -5 -> 0. hit is 0, so the names
% of t1, t3 and t4 are compared with 'Glucose-6-phosphate' by 4-letter words:
%   'D-Glucose': words D-Gl -Glu Gluc luco ucos cose, of which the last 4 occur: 4/6
%   'ATP|Adenosine triphosphate': 23 words, of which phos hosp osph spha phat hate occur: 6/23
%   'Water': words Wate ater, none occurs: 0 (0/0 is set to 0)
% normalized by the maximum 0.01 + 2/3 (minimum 0); t2 is 0 in any case
[matchScores, matchIndex, hit] = findMetMatch(3);
assert(isequal(matchIndex, [1 3 4 2]));
expected = [0.01 + 2/3, 0.01 + 6/23, 0.01, 0] / (0.01 + 2/3);
assert(norm(matchScores - expected) < tol);
% the flag is set after the name comparison
assert(hit == 1);

%% an empty name: no name criterion, and identical names in the name comparison score 1

% qqq[c] has an empty name (the name criterion is skipped) and nothing else in common: t1,
% t3, t4 0.01 (compartment), t2 0; hit is 0. With the name of t4 emptied, the name
% comparison gives 1 for t4 (identical empty names) and 0 for t1 and t3 (no word of their
% names occurs in the empty name; 0/0 is set to 0). Normalized by 1.01: t4 1, t1 and t3
% 0.01 / 1.01 (equal scores keep the order of the template metabolites)
CMODEL.mets{4, 1} = 'qqq[c]';
CMODEL.metNames{4, 1} = '';
CMODEL.metFormulas{4, 1} = 'X1';
CMODEL.metCharge(4, 1) = 5;
CMODEL.metKEGGID{4, 1} = '';
CMODEL.metSEEDID{4, 1} = '';
TMODEL.metNames{4} = '';
[matchScores, matchIndex, hit] = findMetMatch(4);
assert(isequal(matchIndex, [4 1 3 2]));
assert(norm(matchScores - [1, 0.01 / 1.01, 0.01 / 1.01, 0]) < tol);
assert(hit == 1);

%% no positive score at all: every metabolite gets 0.01

% zzz[x] is in a compartment of no template metabolite and has nothing in common: all
% scores are -5 and become 0, the name comparison has no candidate, and the scores are set
% to 0.01; all template metabolites are in another compartment: 0.01 * 0.1
CMODEL.mets{5, 1} = 'zzz[x]';
CMODEL.metNames{5, 1} = 'Nothing';
CMODEL.metFormulas{5, 1} = 'Q9';
CMODEL.metCharge(5, 1) = 9;
CMODEL.metKEGGID{5, 1} = '';
CMODEL.metSEEDID{5, 1} = '';
[matchScores, matchIndex, hit] = findMetMatch(5);
assert(isequal(matchIndex, [1 2 3 4]));
assert(norm(matchScores - 0.001 * ones(1, 4)) < tol);
assert(hit == 1);

%% restore the globals, close the waitbar and restore the figure default

CMODEL = savedCMODEL;
TMODEL = savedTMODEL;
newGlobals = setdiff(who('global'), globalsBefore);
if ~isempty(newGlobals)
    clearvars('-global', newGlobals{:});
end
newFigures = setdiff(findall(groot, 'Type', 'figure'), figuresBefore);
% the name-similarity branch opened one waitbar and left it open
assert(numel(newFigures) == 1 && strcmp(get(newFigures, 'Tag'), 'TMWWaitbar'));
close(newFigures);
set(groot, 'DefaultFigureVisible', defaultVisible);

% change the directory
cd(currentDir)
