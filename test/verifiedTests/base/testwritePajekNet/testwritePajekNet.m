% The COBRAToolbox: testwritePajekNet.m
%
% Purpose:
%     - tests writePajekNet: directed Pajek output (*Arcs), tolerance-based
%       filtering of inactive reactions, biomass / objective exclusion,
%       and graceful failure when the LP cannot be solved.
%
% Authors:
%     - Marouen BEN GUEBILA 09/02/2017 (initial)
%     - 2026: rewritten to assert semantics, not a byte-equal fixture

global CBTDIR

currentDir = pwd;
fileDir = fileparts(which('testwritePajekNet'));
cd(fileDir);

model = getDistributedModel('ecoli_core_model.mat');

solverPkgs = prepareTest('needsLP', true, 'useSolversIfAvailable', {'glpk', 'gurobi', 'tomlab_cplex'});

for k = 1:length(solverPkgs.LP)
    solver = solverPkgs.LP{k};
    fprintf('   Testing writePajekNet using %s ... ', solver);
    solverOK = changeCobraSolver(solver, 'LP', 0);
    assert(solverOK == 1, 'Failed to set LP solver %s', solver);

    outFile = 'COBRAmodel.net';
    if exist(outFile, 'file'); delete(outFile); end

    % --- nominal call ---------------------------------------------------
    writePajekNet(model);
    assert(exist(outFile, 'file') == 2, 'writePajekNet did not produce output');

    txt = fileread(outFile);
    lines = regexp(txt, '\r?\n', 'split');
    lines = lines(~cellfun('isempty', lines));

    % vertex header lists every metabolite
    assert(strcmp(lines{1}, sprintf('*Vertices %d', numel(model.mets))), ...
           'Vertex header is wrong: %s', lines{1});
    for i = 1:numel(model.mets)
        expected = sprintf('%d "%s"', i, model.mets{i});
        assert(strcmp(lines{1 + i}, expected), 'Vertex line %d wrong: %s', i, lines{1 + i});
    end

    % directed: must use *Arcs (not *Edges)
    arcsHeaderIdx = 1 + numel(model.mets) + 1;
    arcsHeader = lines{arcsHeaderIdx};
    tok = regexp(arcsHeader, '^\*Arcs\s+(\d+)$', 'tokens', 'once');
    assert(~isempty(tok), 'Expected *Arcs header, got: %s', arcsHeader);
    declaredArcs = str2double(tok{1});
    actualArcs = numel(lines) - arcsHeaderIdx;
    assert(declaredArcs == actualArcs, ...
           'Declared arc count %d != written arcs %d', declaredArcs, actualArcs);

    % every arc references valid vertex ids and a positive weight
    nMets = numel(model.mets);
    for i = arcsHeaderIdx + 1:numel(lines)
        parts = sscanf(lines{i}, '%f');
        assert(numel(parts) == 3, 'Malformed arc line: %s', lines{i});
        assert(parts(1) >= 1 && parts(1) <= nMets, 'src out of range: %s', lines{i});
        assert(parts(2) >= 1 && parts(2) <= nMets, 'dst out of range: %s', lines{i});
        assert(parts(3) > 0, 'arc weight must be positive: %s', lines{i});
    end

    % biomass / objective reactions must not appear as edges. Verify by
    % ensuring no arc weight equals a biomass-reaction flux.
    FBA = solveCobraLP(model);
    objIdx = find(model.c ~= 0);
    biomassIdx = find(~cellfun('isempty', regexpi(model.rxns, 'biomass')));
    excluded = unique([objIdx(:); biomassIdx(:)]);
    excludedFluxes = abs(FBA.full(excluded));
    excludedFluxes = excludedFluxes(excludedFluxes > 1e-9);
    arcWeights = zeros(actualArcs, 1);
    for i = 1:actualArcs
        parts = sscanf(lines{arcsHeaderIdx + i}, '%f');
        arcWeights(i) = parts(3);
    end
    for w = excludedFluxes(:)'
        assert(~any(abs(arcWeights - w) < 1e-12), ...
               'Excluded reaction with flux %g leaked into the graph', w);
    end

    delete(outFile);

    % --- tolerance filtering -------------------------------------------
    % With a tolerance larger than every flux, no arcs should be written.
    writePajekNet(model, max(abs(FBA.full)) + 1, outFile);
    txt = fileread(outFile);
    tok = regexp(txt, '\*Arcs\s+(\d+)', 'tokens', 'once');
    assert(~isempty(tok) && str2double(tok{1}) == 0, ...
           'Tolerance filtering did not suppress all arcs');
    delete(outFile);

    % --- solver failure path -------------------------------------------
    % Make the LP infeasible by setting incompatible bounds on the
    % objective reaction; writePajekNet must error rather than emit junk.
    badModel = model;
    objRxn = find(model.c ~= 0, 1);
    badModel.lb(objRxn) = 1;
    badModel.ub(objRxn) = -1;
    threw = false;
    try
        writePajekNet(badModel, [], outFile);
    catch ME
        threw = strcmp(ME.identifier, 'writePajekNet:lpFailed');
    end
    assert(threw, 'Expected writePajekNet:lpFailed on infeasible LP');
    if exist(outFile, 'file'); delete(outFile); end

    fprintf('Done.\n');
end

cd(currentDir)

