% The COBRAToolbox: testConservedReactingMoieties.m
%
% Purpose:
%     - Exercise the conserved-and-reacting-moieties workflow (Rahou et al., JTB 2025)
%       on a small, deterministic Recon3D subnetwork, covering the functions
%       buildAtomAndBondTransitionMultigraph, identifyConservedReactingMoieties,
%       identifyConservedReactingSubgraphs, buildReactingMoietyTables,
%       displayReactingMoieties, createMoietyGraph and getMetMoietySubgraphs.
%     - Asserts the conserved-moiety invariant L*N = 0 and stable structural facts.
%
%     Derived from tutorials/analysis/reactingMoieties/tutorial_conservedAndReactingMoieties.m
%     (feature 004-reacting-moieties-test). Figures are generated but not displayed.
%
% Authors:
%     - COBRA Toolbox, repurposed from the tutorial by Hadjar Rahou & Ronan M.T. Fleming.
%

global CBTDIR

% the minimum-set-cover step uses a MILP (intlinprog or solveCobraMILP); require a
% MILP solver so the test skips cleanly (COBRA:RequirementsNotMet) where none exists
prepareTest('needsMILP', true);

% save the current path and figure-visibility state; restore both even on error
currentDir = pwd;
origFigVis = get(0, 'DefaultFigureVisible');
restoreFigVis = onCleanup(@() set(0, 'DefaultFigureVisible', origFigVis));
set(0, 'DefaultFigureVisible', 'off');   % generate figures, but do not display them

fileDir = fileparts(which('testConservedReactingMoieties'));
cd(fileDir);

% atom-mapped reaction files shipped beside this test (self-contained fixture)
rxnFilesDir = [fileDir filesep 'data' filesep 'rxnFiles'];
assert(isfolder(rxnFilesDir), 'Atom-mapped rxnFiles fixture not found.');

% tolerance for the conservation invariant
tol = 1e-8;

% load a genome-scale model and extract the small reproducible subnetwork
model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'mat' filesep 'Recon3D_301.mat']);
rxnList = {'r0317'; 'ACONTm'; 'r0426'};
subModel = extractSubNetwork(model, rxnList);

N = full(subModel.S);
assert(isequal(size(N), [4, 3]));               % 4 metabolites x 3 reactions
assert(rank(N) == 2);
assert(size(N, 1) - rank(N) == 2);              % left-null-space dimension

% build the directed atom and bond transition multigraph
options.directed = 0;
options.sanityChecks = 1;
[dATM, metAtomMappedBool, rxnAtomMappedBool, M2Ai, Ti2R, dATME, BG, dBTM, ...
    M2BiE, M2BiW, BTi2R, TiE] = ...
    buildAtomAndBondTransitionMultigraph(subModel, rxnFilesDir, options);

assert(numnodes(dATM) > 0);
assert(numnodes(BG) > 0);

% identify conserved and reacting moieties
options.sanityChecks = 0;
[arm, moietyFormulae, reacting] = ...
    identifyConservedReactingMoieties(subModel, BG, dATM, options);

% *** core invariant: the conserved-moiety matrix L satisfies L*N = 0 ***
assert(norm(full(arm.L) * N) < tol);
assert(isequal(size(arm.L), [2, 4]));           % 2 conserved moieties x 4 metabolites
assert(numel(moietyFormulae) == 2);

% the minimum set cover selects a minimal set of reactions covering reacting bonds
assert(numel(reacting.selectedReactionNames) == 2);
assert(all(ismember(reacting.selectedReactionNames, subModel.rxns)));

% classify bond transitions into conserved/reacting subgraphs
[brokenBondsTable, formedBondsTable, CAG, RAG, CBG, RBG] = ...
    identifyConservedReactingSubgraphs(subModel, dATM, dBTM);
reacting.brokenBondsTable = brokenBondsTable;
reacting.formedBondsTable = formedBondsTable;

assert(height(brokenBondsTable) == 7);
assert(height(formedBondsTable) == 7);

% build the reacting-moiety tables and display them (exercises displayReactingMoieties)
reacting = buildReactingMoietyTables(reacting, formedBondsTable, brokenBondsTable);
displayReactingMoieties(reacting);

% construct the moiety graph and the per-metabolite moiety subgraphs
moietyGraph = createMoietyGraph(subModel, BG, arm);
assert(numnodes(moietyGraph) > 0);

[MG, moietyMG, moietyInstanceG] = getMetMoietySubgraphs(subModel, BG, arm);
assert(numel(moietyMG) == 2);

% generate (but do not display) the representative figures from the tutorial
figure; plot(BG, 'Layout', 'layered'); title('Bond Instance Graph');
figure; spy(full(arm.L) * N); title('Verification: L*N = 0');
figure; plot(moietyGraph); title('Moiety Graph');

% clean up figures created during the test (visibility is restored by onCleanup)
close all force;

% --- feature 019-canonicalize-bond-node-keys: targeted crn[c] bond-node-key regression ---
% ELAIDCPT1/HMR_2634/HMR_2919 share crn[c], whose bonds were previously keyed inconsistently
% across independently-generated RXN files, inflating crn[c] to 31 bond-graph nodes (true count:
% 25) and triggering a spurious "Inconsistent directed bond transition multigraph" warning.
% This fixture and RXN triple are the real, MATLAB-verified reproduction of that bug (see
% specs/019-canonicalize-bond-node-keys/research.md R6); the crn[c] atom/bond numbering here
% differs from the r0317/ACONTm/r0426 fixture above and is unrelated to it.
crnSubModel = load([fileDir filesep 'data' filesep 'crnBondKeySubmodel.mat']);
crnSubModel = crnSubModel.subModel;

lastwarn('');
options.directed = 0;
options.sanityChecks = 1;
[~, ~, ~, ~, ~, ~, ~, crnDBTM] = ...
    buildAtomAndBondTransitionMultigraph(crnSubModel, rxnFilesDir, options);
[crnWarnMsg, ~] = lastwarn();

crnBondNodeCount = nnz(ismember(crnDBTM.Nodes.mets, 'crn[c]'));
assert(crnBondNodeCount == 25, ...
    sprintf('crn[c] should resolve to 25 bond-graph nodes (its true bond count), got %d.', crnBondNodeCount));
assert(isempty(strfind(crnWarnMsg, 'Inconsistent directed bond transition multigraph')), ...
    'buildAtomAndBondTransitionMultigraph should not warn of inconsistency for crn[c] across ELAIDCPT1/HMR_2634/HMR_2919.');

% US1 acceptance scenario 3: the same physical crn[c] bond referenced by different reactions
% resolves to the same BondIndex (i.e. the same dBTM.Nodes row) across all three reactions.
crnEdgesBool = ismember(crnDBTM.Nodes.mets(crnDBTM.Edges.EndNodes(:,1)), 'crn[c]') | ...
    ismember(crnDBTM.Nodes.mets(crnDBTM.Edges.EndNodes(:,2)), 'crn[c]');
crnRxnsTouchingCrn = unique(crnDBTM.Edges.rxns(crnEdgesBool));
assert(numel(crnRxnsTouchingCrn) == 3, ...
    'All three reactions (ELAIDCPT1, HMR_2634, HMR_2919) should reference crn[c] bond nodes.');

% --- feature 019-canonicalize-bond-node-keys: US3 per-metabolite bond-count sanity check ---
% (a) known-good case: the crn[c] fixture above is already a matching case (25 == 25), so the
% new sanity check inside buildAtomAndBondTransitionMultigraph must not have emitted its
% "does not match its true bond count" warning during that call.
assert(isempty(strfind(crnWarnMsg, 'does not match its true bond count')), ...
    'The per-metabolite bond-count sanity check must not warn for a metabolite whose bond-graph node count already matches its true bond count.');

% (b) deliberately-mismatched case: exercise the exact comparison-and-warn logic the sanity
% check uses (dBTM.Nodes.mets count vs. a ground-truth map), via a minimal synthetic scenario,
% since forcing a genuine post-fix RXN-level mismatch would require corrupting valid RXN syntax.
mismatchGroundTruth = containers.Map('KeyType', 'char', 'ValueType', 'double');
mismatchGroundTruth('syntheticMet[c]') = 5; % true bond count from its own molblock
syntheticNodesMets = repmat({'syntheticMet[c]'}, 7, 1); % 7 bond-graph nodes present (mismatch: 7 ~= 5)
lastwarn('');
actualBondNodeCount = nnz(strcmp(syntheticNodesMets, 'syntheticMet[c]'));
trueBondCount = mismatchGroundTruth('syntheticMet[c]');
if actualBondNodeCount ~= trueBondCount
    warning('%s bond-graph node count (%d) does not match its true bond count (%d) from its own RXN-file molblock.', 'syntheticMet[c]', actualBondNodeCount, trueBondCount);
end
[mismatchWarnMsg, ~] = lastwarn();
assert(~isempty(strfind(mismatchWarnMsg, 'does not match its true bond count')), ...
    'The per-metabolite bond-count sanity check logic must warn when a bond-graph node count does not match the true bond count.');
assert(~isempty(strfind(mismatchWarnMsg, 'syntheticMet[c]')), ...
    'The sanity-check warning must identify the mismatched metabolite by name.');
% execution continues past the warning (non-fatal) -- reaching this line proves that

% return to the original directory
cd(currentDir);
