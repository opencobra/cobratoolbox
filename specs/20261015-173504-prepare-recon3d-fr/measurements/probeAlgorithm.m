% Phase-0 probe (throwaway prototype, NOT the deliverable): run the spec's
% zero-row / identical-row-lump / dead-end loop with the existing toolbox
% building blocks on the two Recon3 variants, to expose cascades, addReaction
% side effects (bounds, GPRs), and the final rank before the plan is fixed.
cbtRoot = fileparts(which('initCobraToolbox'));
files = { ...
    fullfile(getenv('HOME'), 'drive', 'sbgCloud', 'projects', 'variationalKinetics', 'data', 'Recon3T', 'Recon3DModel_301_xomics_input_VK_withL.mat'), ...
    fullfile(cbtRoot, 'test', 'models', 'mat', 'Recon3DModel_301_xomics_input.mat'), ...
    fullfile(cbtRoot, 'papers', '2023_iDopaNeuro', 'models', 'iDopaNeuroC.mat')};
for i = 1:numel(files)
    fprintf('\n=== %s\n', files{i});
    L = load(files{i});
    fn = fieldnames(L);
    model = L.(fn{1});
    model0 = model;
    for it = 1:10
        rxnBool = model.SConsistentRxnBool;
        N = model.S(:, rxnBool);
        FR = [max(-N, 0), max(N, 0)];
        m = size(FR, 1);
        r = getRankLUSOL(FR, 0);
        fprintf('iter %d: m = %d, n = %d, rank = %d\n', it, m, size(model.S, 2), r);
        if r == m
            break
        end
        zeroRow = full(sum(FR ~= 0, 2) == 0);
        if any(zeroRow)
            nBefore = size(model.S, 2);
            model = removeMetabolites(model, model.mets(zeroRow), false);
            fprintf('  removed %d zero-row mets; n %d -> %d\n', nnz(zeroRow), nBefore, size(model.S, 2));
            continue
        end
        [~, ia, ic] = unique(FR, 'rows', 'stable');
        if numel(ia) < m
            internalRxns = model.rxns(rxnBool);
            dropMets = {};
            for g = 1:numel(ia)
                members = find(ic == g);
                if numel(members) > 1
                    rep = members(1);
                    others = members(2:end);
                    for j = find(any(N(members, :), 1))
                        rxnId = internalRxns{j};
                        col = find(strcmp(model.rxns, rxnId));
                        metInd = find(model.S(:, col));
                        metInd = setdiff(metInd, others, 'stable');
                        lb0 = model.lb(col); ub0 = model.ub(col); gr0 = model.grRules{col};
                        model = addReaction(model, rxnId, 'metaboliteList', model.mets(metInd), ...
                            'stoichCoeffList', full(model.S(metInd, col)), 'lowerBound', lb0, 'upperBound', ub0);
                        col2 = find(strcmp(model.rxns, rxnId));
                        fprintf('  rewrote %s: lb/ub kept %d, grRules kept %d, SConsistentRxnBool kept %d\n', rxnId, ...
                            model.lb(col2) == lb0 && model.ub(col2) == ub0, strcmp(model.grRules{col2}, gr0), model.SConsistentRxnBool(col2));
                    end
                    dropMets = [dropMets; model.mets(others)]; %#ok<AGROW>
                end
            end
            model = removeMetabolites(model, dropMets, false);
            [~, removedInd] = checkDuplicateRxn(model, 'FR', 0, 0);
            fprintf('  lumped; dropped %d mets; FR duplicates flagged: %s\n', numel(dropMets), strjoin(model.rxns(removedInd)', ' '));
            continue
        end
        % dead-end remedy on a left-null basis of [F,R]
        A = FR';
        [~, Rq, E] = qr(A, sparse(size(A, 1), 0), 0);
        d = abs(full(diag(Rq)));
        rk = nnz(d > max(size(A)) * eps * max(d));
        nInt = full(sum(N ~= 0, 2));
        rmRxns = {};
        internalRxns = model.rxns(rxnBool);
        for t = 1:(size(A, 2) - rk)
            c = full(Rq(1:rk, 1:rk) \ Rq(1:rk, rk + t));
            y = zeros(m, 1);
            y(E(rk + t)) = 1;
            y(E(1:rk)) = -c;
            supp = find(abs(y) > 1e-8);
            fprintf('  null vector support %d, residual %.3g\n', numel(supp), norm(FR' * y, inf));
            deadEnd = supp(nInt(supp) == 1);
            for s = deadEnd'
                rmRxns = [rmRxns; internalRxns(N(s, :) ~= 0)]; %#ok<AGROW>
            end
        end
        rmRxns = unique(rmRxns, 'stable');
        if isempty(rmRxns)
            fprintf('  irreducible\n');
            break
        end
        model = removeRxns(model, rmRxns);
        model = removeUnusedGenes(model);
        fprintf('  removed %d dead-end rxns: %s\n', numel(rmRxns), strjoin(rmRxns', ' '));
    end
    fprintf('final: m %d -> %d, n %d -> %d\n', size(model0.S, 1), size(model.S, 1), size(model0.S, 2), size(model.S, 2));
end
