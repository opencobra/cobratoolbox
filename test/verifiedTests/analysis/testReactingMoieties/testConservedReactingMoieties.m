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

% --- feature 026-conserved-moieties-only-option: US1 conserved-moieties-only mode ---
% Placed BEFORE the prepareTest('needsMILP', true) gate below (feature 026 spec FR-002,
% SC-001; analysis finding F1): options.conservedMoietiesOnly = true skips the
% reacting-moiety bond-graph/minimum-set-cover section entirely, so this call must not
% require a MILP solver, and this assertion block must run even on a runner where the
% MILP-gated full-mode call and comparison below are skipped.
optionsConservedOnly = options;
optionsConservedOnly.sanityChecks = 0;
optionsConservedOnly.conservedMoietiesOnly = true;
[armConservedOnly, moietyFormulaeConservedOnly, reactingConservedOnly] = ...
    identifyConservedReactingMoieties(subModel, BG, dATM, optionsConservedOnly);

assert(isstruct(reactingConservedOnly) && isfield(reactingConservedOnly, 'computed') && ...
    reactingConservedOnly.computed == false, ...
    'reacting must be struct(''computed'', false) when options.conservedMoietiesOnly = true (spec FR-004).');
assert(~isfield(reactingConservedOnly, 'selectedReactionNames'), ...
    'reacting must not carry reacting-moiety fields when options.conservedMoietiesOnly = true (spec FR-004).');

% --- feature 027-conserved-moiety-equivalence-test: cross-function equivalence guard ---
% Guards against future divergence between the two independent implementations of the
% conserved-moiety decomposition algorithm: identifyConservedReactingMoieties.m (in
% conserved-only mode, above) uses the newer prefiltered classifySubgraphIsomorphism
% helper internally, while the sibling identifyConservedMoieties.m still uses the
% original nested-loop isisomorphic approach. options.sanityChecks = 0 is used on the
% sibling call because sanityChecks = 1 on the conserved-only call above is a known,
% pre-existing, out-of-scope crash in a bond-subgraph classification path unrelated to
% conserved-moiety computation (spec 027 Edge Cases). Distinct variable names
% (armSibling/moietyFormulaeSibling) avoid colliding with this file's own arm/
% moietyFormulae variables from the full-mode call below. Neither this call nor the
% comparison requires a MILP solver, so this block is placed before the
% prepareTest('needsMILP', true) gate below (spec 027 FR-007).
optionsSibling = struct('sanityChecks', 0);
[armSibling, moietyFormulaeSibling] = identifyConservedMoieties(subModel, dATM, optionsSibling);

assert(isequal(armSibling.L, armConservedOnly.L), ...
    'arm.L must be identical between identifyConservedReactingMoieties(conservedMoietiesOnly=true) and identifyConservedMoieties (spec 027 SC-001/SC-002).');
assert(isequal(armSibling.M2M, armConservedOnly.M2M), ...
    'arm.M2M must be identical between identifyConservedReactingMoieties(conservedMoietiesOnly=true) and identifyConservedMoieties (spec 027 SC-001/SC-002).');
assert(isequal(armSibling.M2R, armConservedOnly.M2R), ...
    'arm.M2R must be identical between identifyConservedReactingMoieties(conservedMoietiesOnly=true) and identifyConservedMoieties (spec 027 SC-001/SC-002).');
assert(isequal(moietyFormulaeSibling, moietyFormulaeConservedOnly), ...
    'moietyFormulae must be identical between identifyConservedReactingMoieties(conservedMoietiesOnly=true) and identifyConservedMoieties (spec 027 SC-001/SC-002).');

% the minimum-set-cover step uses a MILP (intlinprog or solveCobraMILP); require a
% MILP solver so the remaining, full-mode part of this test skips cleanly
% (COBRA:RequirementsNotMet) where none exists. Relocated here (was previously at the
% very top of this file) so the conserved-moieties-only assertions above -- which must
% not require a MILP solver (spec FR-002, SC-001) -- are still exercised on a runner
% with no MILP solver, rather than being skipped along with the rest of the script.
prepareTest('needsMILP', true);

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

% --- feature 026-conserved-moieties-only-option: US2 equivalence with the existing
% full computation (spec FR-003/FR-008/FR-009, SC-002/SC-003) ---
% The conserved-moieties-only run above and this full-mode run must agree exactly on
% every conserved-moiety-specific field, since both execute the identical conserved-
% moiety code path -- the option only decides whether execution continues past it.
assert(isequal(armConservedOnly.L, arm.L), ...
    'arm.L must be identical between conserved-moieties-only mode and the full computation (spec SC-002).');
assert(isequal(armConservedOnly.M2M, arm.M2M), ...
    'arm.M2M must be identical between conserved-moieties-only mode and the full computation (spec SC-002).');
assert(isequal(armConservedOnly.M2R, arm.M2R), ...
    'arm.M2R must be identical between conserved-moieties-only mode and the full computation (spec SC-002).');
assert(isequal(moietyFormulaeConservedOnly, moietyFormulae), ...
    'moietyFormulae must be identical between conserved-moieties-only mode and the full computation (spec SC-002).');

% the conservation invariant must also hold on the conserved-moieties-only run's arm.L
% (spec Acceptance Scenario 3 of US2), reusing the same N and tol as the full-mode check.
assert(norm(full(armConservedOnly.L) * N) < tol);

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

% --- feature 020-canonicalize-symmetric-atom-bonds: coa[m]/coa[x]/coa[r]/crn[m] symmetry/
% resonance bond-node-identity regression (spec FR-007, SC-001-003) ---
% coa[m], coa[x] and coa[r] each contain CoA's gem-dimethyl pair of methyl carbons, which
% independently-generated RXN files number inconsistently; pre-fix, each resolves to 86
% bond-graph nodes (true count: 82). crn[m] additionally exercises carnitine's three
% symmetric N-methyl carbons and its resonance-ambiguous carboxylate bond type; pre-fix,
% it resolves to 29 nodes (true count: 25). See specs/020-canonicalize-symmetric-atom-bonds/
% spec.md Problem Statement and research.md R2/R2.3 for the full root-cause analysis.
symmetryFixtures = {'coaMBondKeySubmodel.mat', 'coa[m]', 82; ...
                     'coaXBondKeySubmodel.mat', 'coa[x]', 82; ...
                     'coaRBondKeySubmodel.mat', 'coa[r]', 82; ...
                     'crnMBondKeySubmodel.mat', 'crn[m]', 25};

for symIdx = 1:size(symmetryFixtures, 1)
    symFixtureFile = symmetryFixtures{symIdx, 1};
    symMet = symmetryFixtures{symIdx, 2};
    symExpectedCount = symmetryFixtures{symIdx, 3};

    symSubModel = load([fileDir filesep 'data' filesep symFixtureFile]);
    symSubModel = symSubModel.subModel;

    lastwarn('');
    options.directed = 0;
    options.sanityChecks = 1;
    [~, ~, ~, ~, ~, ~, ~, symDBTM] = ...
        buildAtomAndBondTransitionMultigraph(symSubModel, rxnFilesDir, options);
    [symWarnMsg, ~] = lastwarn();

    symActualCount = nnz(ismember(symDBTM.Nodes.mets, symMet));
    assert(symActualCount == symExpectedCount, ...
        sprintf('%s should resolve to %d bond-graph nodes (its true bond count), got %d.', ...
        symMet, symExpectedCount, symActualCount));

    % Metabolite-named substring check (rather than a blanket phrase check): the coa[x]
    % fixture also contains h2o2[x], which has its own, pre-existing, out-of-scope FR-008
    % mismatch unrelated to this feature (research.md scope: this feature targets
    % coa[m]/coa[x]/coa[r]/crn[m] specifically) -- a blanket check for the warning phrase
    % alone would spuriously fail on that unrelated warning even though coa[x] itself is
    % correct, so the assertion below names the target metabolite explicitly (matching
    % exactly what the FR-008 warning text embeds for that metabolite).
    assert(isempty(strfind(symWarnMsg, sprintf('%s bond-graph node count', symMet))), ...
        sprintf('buildAtomAndBondTransitionMultigraph should not warn of a bond-count mismatch for %s.', symMet));
end

% T009b: the crn[m] carboxylate carbon (atom 5) is bonded to two resonance-equivalent
% oxygens (atoms 3 and 6); their bond TYPE (not their atom identity -- the two bonds
% remain, correctly, two distinct bond-graph nodes) is only formally single/double
% depending on which Kekulé structure the atom-mapping tool recorded in a given RXN file.
% PPACOAATREVm is processed before HMR_2634 in this submodel's model.rxns order, so the
% first-seen bond-type cache (research R7) must resolve both canonicalized bond-node keys
% to PPACOAATREVm's own recorded bond types, deterministically, regardless of what
% HMR_2634 records for the same keys. Expected literal values captured directly against
% the post-fix pipeline (T007/T016 baseline-capture pass, feature 020 implementation,
% 2026-08-18): 2 (double) for the atom-5/atom-3 bond, 1 (single) for the atom-5/atom-6 bond.
crnMSubModel = load([fileDir filesep 'data' filesep 'crnMBondKeySubmodel.mat']);
crnMSubModel = crnMSubModel.subModel;
options.directed = 0;
options.sanityChecks = 1;
[~, ~, ~, ~, ~, ~, ~, crnMDBTM] = ...
    buildAtomAndBondTransitionMultigraph(crnMSubModel, rxnFilesDir, options);
assert(isequal(crnMSubModel.rxns(1:2), {'PPACOAATREVm'; 'HMR_2634'}), ...
    'crn[m] fixture''s model.rxns order changed -- T009b''s hardcoded expected BondType values assume PPACOAATREVm is processed first.');

carboxylateDoubleBondIdx = find(strcmp(crnMDBTM.Nodes.Bond, 'crn[m]#3#O#crn[m]#5#C'));
carboxylateSingleBondIdx = find(strcmp(crnMDBTM.Nodes.Bond, 'crn[m]#5#C#crn[m]#6#O'));
assert(isscalar(carboxylateDoubleBondIdx) && isscalar(carboxylateSingleBondIdx), ...
    'crn[m]''s canonicalized carboxylate bond-node keys (atom 5 to atom 3, and atom 5 to atom 6) must each resolve to exactly one dBTM.Nodes row.');
assert(full(crnMDBTM.Nodes.BondType(carboxylateDoubleBondIdx)) == 2, ...
    sprintf('crn[m]''s atom-5/atom-3 carboxylate bond-node should resolve to PPACOAATREVm''s first-seen BondType (2), got %d.', ...
    full(crnMDBTM.Nodes.BondType(carboxylateDoubleBondIdx))));
assert(full(crnMDBTM.Nodes.BondType(carboxylateSingleBondIdx)) == 1, ...
    sprintf('crn[m]''s atom-5/atom-6 carboxylate bond-node should resolve to PPACOAATREVm''s first-seen BondType (1), got %d.', ...
    full(crnMDBTM.Nodes.BondType(carboxylateSingleBondIdx))));

% --- feature 024-fix-empty-selection-bugs: US1 zero-MILP-selection regression ---
% MACACI (VMH) <-> rh_14817 (Rhea) is one of the four real pairs from the broad
% positive-control health-check run (2026-09-04, specs/024-fix-empty-selection-
% bugs/spec.md SC-001) whose reacting-bond minimum set-cover is genuinely
% degenerate: zero reacting bonds map to either candidate reaction, so
% solveCobraMILP's trivial optimum selects zero reactions (m_active == 0).
% Pre-fix, identifyConservedReactingMoieties.m's STEP 5 never executes the
% loops that assign RM_sets/RM_graph in that case, and STEP 6 throws
% "Unrecognized function or variable 'RM_sets'" reading them back (spec
% FR-001/FR-002). This is a hand-built, deliberately-unmerged combined model
% (the Stage 3/Stage 5 pilot convention mirrored from reconXmoieties'
% stage5_pilot_pgm_rh15901.m), built directly from each RXN file's own $MOL
% block header ('maleacac[c]'/'4fumacac[c]'/'CHEBI_17105[c]'/'CHEBI_18034[c]')
% -- not derived from Recon3D_301, since MACACI/rh_14817 are VMH/Rhea
% reactions outside that model. The two RXN files are vendored alongside this
% test's existing fixtures (test/verifiedTests/analysis/testReactingMoieties/
% data/rxnFiles/MACACI.rxn, rh_14817.rxn), copied verbatim from
% reconXmoieties' own staged reproduction data for this pair.
%
% This specific check requires a MILP solver that returns a trivial optimum
% for a fully unconstrained (zero-row) covering problem; gurobi does. glpk's
% MEX wrapper does not ('A cannot be an empty matrix', found empirically
% while building this regression) -- an unrelated, out-of-scope limitation in
% glpk's own zero-row handling, not touched by this feature; skip this
% sub-check gracefully rather than fail on it if gurobi is unavailable.
macaciGurobiOK = false;
try
    macaciGurobiOK = changeCobraSolver('gurobi', 'MILP', 0);
catch
    macaciGurobiOK = false;
end

if ~macaciGurobiOK
    warning('testConservedReactingMoieties:macaciSkipped', ...
        ['Skipping the MACACI/rh_14817 zero-MILP-selection regression: ' ...
         'gurobi MILP solver not available in this session.']);
else
    macaciModel = struct();
    macaciModel.mets = {'maleacac[c]'; '4fumacac[c]'; 'CHEBI_17105[c]'; 'CHEBI_18034[c]'};
    macaciModel.rxns = {'MACACI'; 'rh_14817'};
    macaciModel.S = sparse([-1  0; ...
                              1  0; ...
                              0 -1; ...
                              0  1]);
    macaciModel.lb = [-1000; -1000];
    macaciModel.ub = [ 1000;  1000];

    options.directed = 0;
    options.sanityChecks = 1;
    [macaciDATM, macaciMetBool, macaciRxnBool, ~, ~, ~, macaciBG] = ...
        buildAtomAndBondTransitionMultigraph(macaciModel, rxnFilesDir, options);
    assert(all(macaciMetBool) && all(macaciRxnBool), ...
        'MACACI/rh_14817 fixture should atom-map cleanly (both metabolites and both reactions).');

    options.sanityChecks = 0;
    [~, ~, macaciReacting] = identifyConservedReactingMoieties(macaciModel, macaciBG, macaciDATM, options);

    % US1 Acceptance Scenario 1 (spec.md): completes without error (implicit --
    % reaching this line proves it) and returns {} for both fields, not
    % undefined variables.
    assert(isempty(macaciReacting.selectedReactionNames), ...
        'MACACI/rh_14817''s MILP set-cover should select zero reactions (degenerate/empty covering problem) -- if this fails, the fixture no longer reproduces the zero-selection branch this test targets.');
    assert(iscell(macaciReacting.ReactMoietySets) && isequal(macaciReacting.ReactMoietySets, {}), ...
        'reacting.ReactMoietySets must be {} (not undefined) when the MILP set-cover selects zero reactions (spec FR-001/FR-002).');
    assert(iscell(macaciReacting.ReactMoietyGraphs) && isequal(macaciReacting.ReactMoietyGraphs, {}), ...
        'reacting.ReactMoietyGraphs must be {} (not undefined) when the MILP set-cover selects zero reactions (spec FR-001/FR-002).');
end

% --- feature 024-fix-empty-selection-bugs: US2 empty-reacting-moiety-table
% schema regression (FR-003/FR-004/FR-009) ---
% Reuses this test's own already-computed r0317/ACONTm/r0426 fixture output
% (reacting, formedBondsTable, brokenBondsTable from earlier in this file) --
% no new biological fixture data needed. buildReactingMoietyTables.m stored a
% bare, columnless table() whenever a selected reaction's formed- and broken-
% bond subtables were BOTH empty (US2 Acceptance Scenario 1), and could not
% even concatenate [F; B] when exactly ONE side was empty (the latent third
% crash, FR-009, found during spec validation pass 2) -- both were traced to
% the same `~isempty(F)`/`~isempty(B)` guards around the BondChange column
% assignment.
phantomReacting = reacting;
phantomReacting.selectedReactionNames = [reacting.selectedReactionNames; ...
    {'PHANTOM_NO_REACTING_BONDS'}; {'PHANTOM_ONE_SIDE_EMPTY'}];

% one-sided phantom row: matches formedBondsTable's own column schema (a row
% slice of the same dBTM.Edges table brokenBondsTable is sliced from -- see
% identifyConservedReactingSubgraphs.m:58-59), so no column is hand-typed
% here; only its `rxns` value is overwritten to the phantom reaction name.
phantomFormedRow = formedBondsTable(1, :);
phantomFormedRow.rxns = {'PHANTOM_ONE_SIDE_EMPTY'};
phantomFormedBondsTable = [formedBondsTable; phantomFormedRow];

phantomReacting = buildReactingMoietyTables(phantomReacting, phantomFormedBondsTable, brokenBondsTable);

% both-empty branch (US2 Acceptance Scenario 1, FR-003/FR-004): no row of
% either formedBondsTable or brokenBondsTable names 'PHANTOM_NO_REACTING_BONDS'.
phantomBothEmptyIdx = find(strcmp(phantomReacting.selectedReactionNames, 'PHANTOM_NO_REACTING_BONDS'));
assert(isscalar(phantomBothEmptyIdx), 'Phantom both-empty reaction name not found where expected.');
bothEmptyTable = phantomReacting.reactMoietyTables{phantomBothEmptyIdx};
assert(istable(bothEmptyTable) && height(bothEmptyTable) == 0, ...
    'A reaction with no formed/broken bonds must produce a zero-row table (not error).');
assert(ismember('BondChange', bothEmptyTable.Properties.VariableNames), ...
    'The zero-row table for a no-reacting-bonds reaction must still carry a BondChange column (spec FR-003/FR-004) -- not a bare table().');

% one-empty branch (FR-009): exactly one phantom formed-bond row, zero
% broken-bond rows, for 'PHANTOM_ONE_SIDE_EMPTY'.
phantomOneSideIdx = find(strcmp(phantomReacting.selectedReactionNames, 'PHANTOM_ONE_SIDE_EMPTY'));
assert(isscalar(phantomOneSideIdx), 'Phantom one-side-empty reaction name not found where expected.');
oneSideEmptyTable = phantomReacting.reactMoietyTables{phantomOneSideIdx};
assert(istable(oneSideEmptyTable) && height(oneSideEmptyTable) == 1, ...
    '[F; B] must concatenate without error when exactly one side is empty, yielding the one real (formed) row (spec FR-009).');
assert(ismember('BondChange', oneSideEmptyTable.Properties.VariableNames) && ...
    strcmp(string(oneSideEmptyTable.BondChange(1)), 'formed'), ...
    'The one-empty-subtable result must carry a uniform BondChange column regardless of which side was empty (spec FR-009).');

% US2 Acceptance Scenario 3 (non-regression): the non-empty r0317/ACONTm/
% r0426 reactions computed earlier in this file are unaffected by the phantom
% additions above (same object identity for the real entries).
for realIdx = 1:numel(reacting.selectedReactionNames)
    assert(isequal(phantomReacting.reactMoietyTables{realIdx}, reacting.reactMoietyTables{realIdx}), ...
        'Pre-existing (non-phantom) reactMoietyTables entries must be unchanged by this regression check.');
end

% return to the original directory
cd(currentDir);
