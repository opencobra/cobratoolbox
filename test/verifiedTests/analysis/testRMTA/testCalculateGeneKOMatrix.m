% The COBRAToolbox: testCalculateGeneKOMatrix.m
%
% Purpose:
%     - calculateGeneKOMatrix(model, SeparateTranscript, printLevel) groups the transcripts of
%       model.genes into genes (the text before the first SeparateTranscript character; the
%       default '' keeps every transcript as its own gene), knocks out all transcripts of each
%       gene with deleteModelGenes and returns geneKO.genes (sorted gene names), geneKO.rxns
%       (= model.rxns) and the logical matrix geneKO.matrix (reactions x genes) that is true
%       where the knock-out of the gene blocks the reaction. The test uses a hand-built model
%       with a reaction without rule, an OR rule of two transcripts of one gene, a single-gene
%       rule, an AND rule and a gene that appears in two reactions; every expected matrix is
%       derived by hand from the gene-reaction rules (a reaction is blocked when its rule is
%       false with the knocked-out transcripts set to false).
%
% Function under test:
%     src/analysis/rMTA/calculateGeneKOMatrix.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation (gene knock-outs on a hand-built model), no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCalculateGeneKOMatrix'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the progress display (showprogress, printLevel > 0) creates the global WAITBAR_HANDLE;
% record the globals now so that the new ones are removed at the end
globalsBefore = who('global');

% hand-built model
%   R1:  -> A    no rule
%   R2: A -> B   g1.1 or g1.2   (two transcripts of gene g1, either one suffices)
%   R3: A -> B   g2.1           (single transcript)
%   R4: B -> C   g3.1 and g4.1  (complex: either transcript missing blocks it)
%   R5: C ->     g3.2           (second transcript of gene g3)
model = createModel({'R1'; 'R2'; 'R3'; 'R4'; 'R5'}, {'R1'; 'R2'; 'R3'; 'R4'; 'R5'}, ...
    {' -> A'; 'A -> B'; 'A -> B'; 'B -> C'; 'C -> '}, ...
    'grRuleList', {''; 'g1.1 or g1.2'; 'g2.1'; 'g3.1 and g4.1'; 'g3.2'});

%% Transcripts kept apart (SeparateTranscript = '', printLevel = 0)
% Each transcript is a gene of its own (sorted: g1.1, g1.2, g2.1, g3.1, g3.2, g4.1).
% Knocking out g1.1 or g1.2 alone leaves R2 active (OR rule): their columns are empty.
% g2.1 blocks R3; g3.1 and g4.1 each block R4 (AND rule); g3.2 blocks R5. R1 has no rule
% and is never blocked. Integer and logical values: exact comparison.
geneKO = calculateGeneKOMatrix(model, '', 0);
expectedGenes = {'g1.1'; 'g1.2'; 'g2.1'; 'g3.1'; 'g3.2'; 'g4.1'};
expectedMatrix = false(5, 6);
expectedMatrix(3, 3) = true;  % g2.1 -> R3
expectedMatrix(4, 4) = true;  % g3.1 -> R4
expectedMatrix(4, 6) = true;  % g4.1 -> R4
expectedMatrix(5, 5) = true;  % g3.2 -> R5
assert(isequal(geneKO.genes, expectedGenes));
assert(isequal(geneKO.rxns, model.rxns));
assert(islogical(geneKO.matrix));
assert(isequal(geneKO.matrix, expectedMatrix));

%% Transcripts grouped by '.' with the default printLevel (progress shown)
% The genes are g1, g2, g3, g4. Knocking out g1 removes both transcripts of R2's OR rule,
% so R2 is blocked; g2 blocks R3; g3 (g3.1 and g3.2) blocks R4 and R5; g4 blocks R4.
geneKOgrouped = calculateGeneKOMatrix(model, '.');
expectedGroupedMatrix = false(5, 4);
expectedGroupedMatrix(2, 1) = true;  % g1 -> R2
expectedGroupedMatrix(3, 2) = true;  % g2 -> R3
expectedGroupedMatrix(4, 3) = true;  % g3 -> R4
expectedGroupedMatrix(5, 3) = true;  % g3 -> R5
expectedGroupedMatrix(4, 4) = true;  % g4 -> R4
assert(isequal(geneKOgrouped.genes, {'g1'; 'g2'; 'g3'; 'g4'}));
assert(isequal(geneKOgrouped.rxns, model.rxns));
assert(isequal(geneKOgrouped.matrix, expectedGroupedMatrix));

%% Defaults: SeparateTranscript = '' (documented default)
% With only the model the result equals the explicit '' call above.
geneKOdefault = calculateGeneKOMatrix(model);
assert(isequal(geneKOdefault.genes, expectedGenes));
assert(isequal(geneKOdefault.matrix, expectedMatrix));

%% Invalid optional inputs are rejected by the input parser
% SeparateTranscript must be text and printLevel a numeric scalar.
assert(verifyCobraFunctionError('calculateGeneKOMatrix', 'inputs', {model, 0}));
assert(verifyCobraFunctionError('calculateGeneKOMatrix', 'inputs', {model, '.', 'a'}));

% remove the globals created by the progress display
newGlobals = setdiff(who('global'), globalsBefore);
if ~isempty(newGlobals)
    clear('global', newGlobals{:});
end

% change the directory
cd(currentDir)
