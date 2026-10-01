global CBTDIR
d = fullfile(CBTDIR, 'test', 'verifiedTests', 'analysis', 'testReactingMoieties');
rxnDir = fullfile(d, 'data', 'rxnFiles');
model = readCbModel(fullfile(CBTDIR, 'test', 'models', 'mat', 'Recon3D_301.mat'));
fixtures = {'main', extractSubNetwork(model, {'r0317'; 'ACONTm'; 'r0426'})};
for f = {'crnBondKeySubmodel.mat', 'coaMBondKeySubmodel.mat', 'coaXBondKeySubmodel.mat', 'coaRBondKeySubmodel.mat', 'crnMBondKeySubmodel.mat'}
    s = load(fullfile(d, 'data', f{1})); fixtures(end+1, :) = {f{1}, s.subModel}; %#ok<SAGROW>
end
for k = 1:size(fixtures, 1)
    try
        [dATM, ~, ~, ~, ~, ~, BG] = buildAtomAndBondTransitionMultigraph(fixtures{k, 2}, rxnDir, struct('directed', 0, 'sanityChecks', 0));
        arm = identifyConservedReactingMoieties(fixtures{k, 2}, BG, dATM, struct('sanityChecks', 0, 'conservedMoietiesOnly', true));
        A = arm.ATG; c = conncomp(A); cnt = accumarray(c(:), 1);
        fprintf('FIX %-26s rxns %3d atoms %4d trans %4d reoriented %3d comps %3d singleAtom %3d MG %3d MGnoEdges %3d moiety0 %d\n', ...
            fixtures{k, 1}, numel(fixtures{k, 2}.rxns), numnodes(A), numedges(A), nnz(A.Edges.orientationATG2dATM == -1), ...
            max(c), nnz(cnt == 1), numel(arm.MG), nnz(cellfun(@numedges, arm.MG) == 0), nnz(A.Nodes.MoietyIndex == 0));
    catch ME
        fprintf('FIX %s ERROR %s (%s:%d)\n', fixtures{k, 1}, ME.message, ME.stack(1).file, ME.stack(1).line);
    end
end
