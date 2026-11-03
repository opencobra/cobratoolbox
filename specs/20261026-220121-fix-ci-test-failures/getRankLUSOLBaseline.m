function same = getRankLUSOLBaseline(mode)
% Records or compares the outputs of getRankLUSOL on fixed matrices, to show that the
% print-level change of feature 20261026-220121-fix-ci-test-failures leaves the outputs
% bit-for-bit unchanged (SC-005).
%
% USAGE:
%
%    same = getRankLUSOLBaseline(mode)
%
% INPUT:
%    mode:    'record' saves the outputs to baseline/getRankLUSOL.mat beside this file;
%             'compare' recomputes them and compares with the saved ones
%
% OUTPUT:
%    same:    true if every output is identical to the record ('compare'), true after
%             saving ('record')
%
% NOTE:
%
%    A documented reproducibility check (constitution Principle III), not a CI test.
%    Run it with `matlab -batch` on the unchanged source ('record') and after the change
%    ('compare').
%
% Author: - feature 20261026-220121-fix-ci-test-failures, 2026-10-26

featureDir = fileparts(mfilename('fullpath'));
baselineFile = fullfile(featureDir, 'baseline', 'getRankLUSOL.mat');

iAF1260 = getDistributedModel('iAF1260.mat');
ecoli = getDistributedModel('ecoli_core_model.mat');
rng(20261026, 'twister');
matrices = struct('name', {'iAF1260.S', 'ecoli_core.S', 'ecoli_core.S with zero column', ...
    'sprand(200,300,0.02)', 'sparse(0,3)'}, ...
    'A', {iAF1260.S, ecoli.S, [ecoli.S, sparse(size(ecoli.S, 1), 1)], ...
    sprand(200, 300, 0.02), sparse(0, 3)});

results = struct('name', {}, 'printLevel', {}, 'rankA', {}, 'p', {}, 'q', {});
for i = 1:numel(matrices)
    for printLevel = 0:1
        [rankA, p, q] = getRankLUSOL(matrices(i).A, printLevel);
        results(end + 1) = struct('name', matrices(i).name, 'printLevel', printLevel, ...
            'rankA', rankA, 'p', p, 'q', q); %#ok<AGROW>
    end
end

switch mode
    case 'record'
        if ~exist(fileparts(baselineFile), 'dir')
            mkdir(fileparts(baselineFile));
        end
        save(baselineFile, 'results');
        fprintf('getRankLUSOLBaseline: recorded %d runs to %s\n', numel(results), baselineFile);
        same = true;
    case 'compare'
        recorded = load(baselineFile);
        same = isequal(recorded.results, results);
        for i = 1:numel(results)
            fprintf('getRankLUSOLBaseline: %-32s printLevel %d rank %4d identical %d\n', ...
                results(i).name, results(i).printLevel, results(i).rankA, ...
                isequal(recorded.results(i), results(i)));
        end
        fprintf('getRankLUSOLBaseline: all identical %d\n', same);
    otherwise
        error('getRankLUSOLBaseline:badMode', 'mode must be ''record'' or ''compare''.');
end
