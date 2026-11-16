% The COBRAToolbox: testExpa.m
%
% Purpose:
%     - expa computes the extreme pathways of a model (Schilling, Letscher and Palsson
%       2000): reversible internal reactions are split into a forward and a '_rev' reaction,
%       reactions are sorted (internal first, then by name), exchange reactions open in both
%       directions are taken out of the elimination and added back at the end, and the
%       pathways are returned as the rows of P in the decomposed model (fullmodel) and in the
%       collapsed model (model), where P(:, rxn) = P(:, rxn) - P(:, rxn_rev).
%     - The test uses two hand-built models in the COBRA exchange convention (coefficient -1,
%       uptake = negative flux). Expected pathways are derived by hand: for model 1
%       (R1: A <=> B, R2: B -> C, EX_A input only, EX_B open both ways, EX_C output only) the
%       extreme rays with A and C balanced (B is exchanged freely) are A -> B (out),
%       B (in) -> C and the two-cycle R1 + R1_rev, each closed by the EX_B flux that balances
%       B; A -> B -> C is their sum and therefore not extreme; for model 2
%       (R1: A -> B, R2: A -> C, EX_A input, EX_B and EX_C outputs) the pathways A -> B and
%       A -> C. Every row is also checked against S * p' = 0 (exact, the entries are small
%       integers).
%
% Function under test:
%     src/visualization/SAMMIM/expa.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation and exact integer elimination, no solver; two hand-built
%     models with three metabolites reach every branch that does not need user input.
%
% Coverage exemptions:
%     Line 340: reached only after the user answered 'e' to the prompt below (interactive
%     input); Lines 352-353, 390-391: progress messages printed only after that answer
%     (interactive input); Lines 360-379, 398-416: the prompt shown only when one elimination
%     step has run for more than 15 s (interactive input); Line 470: keyboard (debugging stop,
%     interactive), reached only on an internal size mismatch of the pathway columns of a
%     '_rev' reaction and its forward partner; Lines 560-579: askinput, the input() prompt helper called only from
%     the lines above (interactive input).
%     The coverage tool of the feature (CodeCoveragePlugin, Cobertura) lists no executable
%     line for this file; the lines above come from MATLAB's profiler (callstats file_lines
%     and profile ExecutedLines) on a run of this test.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The collapsed model does not match the input model as documented: its reactions are sorted and its objective is zero
%       SEVERITY: cosmetic
%       TRIGGER: [model, fullmodel] = expa(m) for any m whose reactions are not already internal-first in name order, or whose c is not zero
%       OBSERVED: model.rxns is {'R1'; 'R2'; 'EX_A'; 'EX_B'; 'EX_C'} for the input order {'R1'; 'R2'; 'EX_A'; 'EX_C'; 'EX_B'}, and model.c is all zero; the fields are mutually consistent (S, P, bounds and the optional fields follow the same order)
%       EXPECTED: "The model output matches the original model input" (OUTPUTS); the order and the objective are documentation issues, the pathways themselves are correct
%       LINES: 184-198, 207
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testExpa'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% model 1: reversible internal reaction, input, output and a two-way exchange
% columns: R1 A <=> B, R2 B -> C, EX_A, EX_C, EX_B (COBRA convention, coefficient -1)
model1 = struct();
model1.S = sparse([-1, 0, -1, 0, 0; 1, -1, 0, 0, -1; 0, 1, 0, -1, 0]);
model1.rxns = {'R1'; 'R2'; 'EX_A'; 'EX_C'; 'EX_B'};
model1.mets = {'A'; 'B'; 'C'};
model1.lb = [-10; 0; -10; 0; -10];
model1.ub = [10; 10; 0; 10; 10];
model1.rev = [1; 0; 0; 0; 1];
model1.c = [0; 1; 0; 0; 0];
% optional reaction fields, which expa reorders and prunes with the reactions
model1.rules = {'x(1)'; 'x(2)'; ''; ''; ''};
model1.rxnGeneMat = sparse([1, 0; 0, 1; 0, 0; 0, 0; 0, 0]);
model1.grRules = {'g1'; 'g2'; ''; ''; ''};
model1.subSystems = {'s1'; 's2'; 's3'; 's4'; 's5'};
model1.confidenceScores = [1; 2; 3; 4; 5];
model1.rxnReferences = {'ref1'; 'ref2'; 'ref3'; 'ref4'; 'ref5'};
model1.rxnECNumbers = {'ec1'; 'ec2'; 'ec3'; 'ec4'; 'ec5'};
model1.rxnNotes = {'n1'; 'n2'; 'n3'; 'n4'; 'n5'};
model1.rxnNames = {'name1'; 'name2'; 'name3'; 'name4'; 'name5'};

% 'y' switches on the progress messages (print branch)
[modelOut, fullModel] = expa(model1, 'y');

% decomposed model: R1_rev added, internal reactions first, then exchanges, each by name
assert(isequal(fullModel.rxns, {'R1'; 'R1_rev'; 'R2'; 'EX_A'; 'EX_B'; 'EX_C'}));
fullIdx = [1, 1, 2, 3, 5, 4]; % original reaction of each decomposed reaction
expectedFullS = full(model1.S(:, fullIdx));
expectedFullS(:, 2) = -expectedFullS(:, 2);
assert(isequal(full(fullModel.S), expectedFullS));
assert(isequal(fullModel.lb, [0; 0; 0; -10; -10; 0]));
assert(isequal(fullModel.ub, [10; 10; 10; 0; 10; 10]));
assert(isequal(fullModel.rev, [1; 1; 0; 0; 1; 0]));
assert(isequal(fullModel.c, zeros(6, 1)));
assert(isequal(fullModel.fluxtype, {'i', 'i', 'i', 'x', 'x', 'x'}));
assert(isequal(fullModel.mets, model1.mets));
% optional fields follow the decomposed reactions
assert(isequal(fullModel.rxnNames, model1.rxnNames(fullIdx)));
assert(isequal(fullModel.rules, model1.rules(fullIdx)));
assert(isequal(fullModel.rxnGeneMat, model1.rxnGeneMat(fullIdx, :)));
assert(isequal(fullModel.grRules, model1.grRules(fullIdx)));
assert(isequal(fullModel.subSystems, model1.subSystems(fullIdx)));
assert(isequal(fullModel.confidenceScores, model1.confidenceScores(fullIdx)));
assert(isequal(fullModel.rxnReferences, model1.rxnReferences(fullIdx)));
assert(isequal(fullModel.rxnECNumbers, model1.rxnECNumbers(fullIdx)));
assert(isequal(fullModel.rxnNotes, model1.rxnNotes(fullIdx)));

% pathways (hand-derived, order of rows not fixed by the documentation):
% columns R1 R1_rev R2 EX_A EX_B EX_C
% (A in -> B -> C out = row 1 + row 2 is a combination, so it is not a row)
expectedFullP = [1, 0, 0, -1, 1, 0; ...  % A in -> B out
                 0, 0, 1, 0, -1, 1; ...  % B in -> C out
                 1, 1, 0, 0, 0, 0];      % two-cycle of the split reversible reaction
fullP = full(fullModel.P);
assert(isequal(sortrows(fullP), sortrows(expectedFullP)));
% every pathway is a steady state; entries are small integers, so the check is exact
assert(all(all(fullModel.S * fullP' == 0)));
% internal fluxes are non-negative, the input is never secreted, the output never taken up
assert(all(all(fullP(:, 1:3) >= 0)) && all(fullP(:, 4) <= 0) && all(fullP(:, 6) >= 0));

% collapsed model: R1_rev merged back into R1 (net flux), other fields pruned to match
collapsedIdx = [1, 2, 3, 5, 4];
assert(isequal(modelOut.rxns, {'R1'; 'R2'; 'EX_A'; 'EX_B'; 'EX_C'}));
assert(isequal(full(modelOut.S), full(model1.S(:, collapsedIdx))));
assert(isequal(modelOut.lb, model1.lb(collapsedIdx)));
assert(isequal(modelOut.ub, model1.ub(collapsedIdx)));
assert(isequal(modelOut.rev, [1; 0; 0; 1; 0]));
assert(isequal(modelOut.c, zeros(5, 1)));
assert(isequal(modelOut.fluxtype, {'i', 'i', 'x', 'x', 'x'}));
assert(isequal(modelOut.rxnNames, model1.rxnNames(collapsedIdx)));
assert(isequal(modelOut.rules, model1.rules(collapsedIdx)));
assert(isequal(modelOut.rxnGeneMat, model1.rxnGeneMat(collapsedIdx, :)));
assert(isequal(modelOut.grRules, model1.grRules(collapsedIdx)));
assert(isequal(modelOut.subSystems, model1.subSystems(collapsedIdx)));
assert(isequal(modelOut.confidenceScores, model1.confidenceScores(collapsedIdx)));
assert(isequal(modelOut.rxnReferences, model1.rxnReferences(collapsedIdx)));
assert(isequal(modelOut.rxnECNumbers, model1.rxnECNumbers(collapsedIdx)));
assert(isequal(modelOut.rxnNotes, model1.rxnNotes(collapsedIdx)));
% the collapsed pathways are R1 - R1_rev per row; the two-cycle becomes a zero row
expectedP = [expectedFullP(:, 1) - expectedFullP(:, 2), expectedFullP(:, 3:6)];
P = full(modelOut.P);
assert(isequal(sortrows(P), sortrows(expectedP)));
assert(all(all(modelOut.S * P' == 0)));

%% model 2: one input split over two branches, no two-way exchange, no optional fields
% columns: R1 A -> B, R2 A -> C, EX_A input, EX_B output, EX_C output. A is produced by one
% row and consumed by two, so the elimination of A takes the "fewer positive rows" branch
model2 = struct();
model2.S = sparse([-1, -1, -1, 0, 0; 1, 0, 0, -1, 0; 0, 1, 0, 0, -1]);
model2.rxns = {'R1'; 'R2'; 'EX_A'; 'EX_B'; 'EX_C'};
model2.mets = {'A'; 'B'; 'C'};
model2.lb = [0; 0; -10; 0; 0];
model2.ub = [10; 10; 0; 10; 10];
model2.rev = [0; 0; 0; 0; 0];
model2.c = [1; 0; 0; 0; 0];

% no print argument: no progress messages
[modelOut2, fullModel2] = expa(model2);
% nothing to split or merge: both outputs hold the two hand-derived pathways
% A in -> B out and A in -> C out (columns R1 R2 EX_A EX_B EX_C)
expectedP2 = [1, 0, -1, 1, 0; 0, 1, -1, 0, 1];
assert(isequal(fullModel2.rxns, model2.rxns));
assert(isequal(sortrows(full(fullModel2.P)), sortrows(expectedP2)));
assert(isequal(sortrows(full(modelOut2.P)), sortrows(expectedP2)));
assert(isequal(modelOut2.rxns, model2.rxns));
assert(isequal(full(modelOut2.S), full(model2.S)));
assert(isequal(modelOut2.lb, model2.lb) && isequal(modelOut2.ub, model2.ub));
assert(all(all(modelOut2.S * full(modelOut2.P)' == 0)));

% change the directory
cd(currentDir)
