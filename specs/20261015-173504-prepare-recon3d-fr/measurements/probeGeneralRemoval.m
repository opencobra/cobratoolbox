% Phase-0 probe for User Story 5: trace the opt-in general removal on the
% irreducible fixture (A+B->P, C+D->P, A+C->Q, B+D->Q), with and without a
% backbone cycle P <-> Q, using removeMetabolites(...,true,'inclusive').
for withBackbone = [false, true]
    mets = {'A'; 'B'; 'C'; 'D'; 'P'; 'Q'};
    S = [-1  0 -1  0;
         -1  0  0 -1;
          0 -1 -1  0;
          0 -1  0 -1;
          1  1  0  0;
          0  0  1  1];
    rxns = {'r1'; 'r2'; 'r3'; 'r4'};
    if withBackbone
        S = [S, [0 0 0 0 -1 1]', [0 0 0 0 1 -1]'];
        rxns = [rxns; {'r5'; 'r6'}];
    end
    model = struct('S', sparse(S), 'mets', {mets}, 'rxns', {rxns}, ...
        'lb', zeros(numel(rxns), 1), 'ub', 1000 * ones(numel(rxns), 1));
    fprintf('\n=== backbone %d\n', withBackbone);
    for it = 1:20
        N = model.S;
        FR = [max(-N, 0), max(N, 0)];
        m = size(FR, 1);
        if m == 0
            fprintf('iter %d: empty model\n', it);
            break
        end
        r = rank(full(FR));
        fprintf('iter %d: mets {%s}, rxns {%s}, m = %d, rank = %d\n', it, strjoin(model.mets', ','), strjoin(model.rxns', ','), m, r);
        if r == m
            break
        end
        zeroRow = full(~any(FR, 2));
        if any(zeroRow)
            model = removeMetabolites(model, model.mets(zeroRow), false);
            model = removeTrivialStoichiometry(model);
            fprintf('  zeroRow removal\n');
            continue
        end
        Y = null(full(FR'), 'r');
        nInt = full(sum(N ~= 0, 2));
        chosen = {};
        deadRxns = {};
        for t = 1:size(Y, 2)
            supp = find(abs(Y(:, t)) > 1e-9);
            dead = supp(nInt(supp) == 1);
            for s = dead'
                deadRxns = [deadRxns; model.rxns(N(s, :) ~= 0)]; %#ok<AGROW>
            end
            [~, k] = sortrows([nInt(supp), supp]);
            chosen = [chosen; model.mets(supp(k(1)))]; %#ok<AGROW>
            fprintf('  witness support {%s}\n', strjoin(model.mets(supp)', ','));
        end
        if ~isempty(deadRxns)
            deadRxns = unique(deadRxns, 'stable');
            model = removeRxns(model, deadRxns);
            fprintf('  deadEnd removal {%s}\n', strjoin(deadRxns', ','));
        else
            chosen = unique(chosen, 'stable');
            [model, rmRxns] = removeMetabolites(model, chosen, true, 'inclusive');
            fprintf('  generalRemoval mets {%s} rxns {%s}\n', strjoin(chosen', ','), strjoin(rmRxns', ','));
        end
    end
end
