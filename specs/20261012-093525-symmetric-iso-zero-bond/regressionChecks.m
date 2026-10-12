% regressionChecks.m
%
% Regression checks of feature 20261012-093525-symmetric-iso-zero-bond against develop f1581781c,
% run after implementation at the maintainer's request (2026-10-12). Environment variable
% CBT_REG_CHECK selects one check:
%   'endToEnd' - identifyConservedReactingMoieties on the 1,960-reaction model (conserved-only,
%                moiety graphs on, the default) with the source helpers; arm, moietyFormulae and
%                reacting compared with the golden outputs of feature 20260928-100409
%                (n1960-endToEnd-golden.mat), as in isomorphismLabelOnlyCheck.m
%   'builder'  - buildAtomAndBondTransitionMultigraph on the same model and RXN corpus with the
%                develop copies (FEATURE/baseline/readerBuilder) and the source; all 12 outputs
%                compared with isequaln, and their classes and sparsity
%   'reader'   - readABRXNFile on every file of the std RXN corpus with the develop copy and the
%                source; atoms and bonds compared with isequaln; files that errored on develop
%                are counted and listed with the source result
% Results are appended to results/20261012-093525-symmetric-iso-zero-bond/regressionChecks.log.
%
% USAGE (headless): CBT_REG_CHECK=endToEnd matlab -batch "run('<this file>')"

featureDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(featureDir));
baselineDir = fullfile(featureDir, 'baseline', 'readerBuilder');
srcDir = fullfile(repoRoot, 'src', 'analysis', 'topology', 'reactingMoieties');
resultsDir = fullfile(repoRoot, 'results', '20261012-093525-symmetric-iso-zero-bond');
logPath = fullfile(resultsDir, 'regressionChecks.log');
outputsDir = '/home/jackmcgoldrick/repos/reconXmoieties/results/moietySizing/outputs';
rxnDir = '/media/JACK/repos/ctf/rxns/moiety_rxns/atomMapped_std';
check = getenv('CBT_REG_CHECK');

useSource(baselineDir, srcDir);
assert(strcmp(which('classifySubgraphIsomorphism'), fullfile(srcDir, 'classifySubgraphIsomorphism.m')));
[~, gitCommit] = system(sprintf('git -C "%s" rev-parse --short HEAD', repoRoot));
header = sprintf('\n### %s, %s UTC, HEAD %s + working tree\n', check, ...
    char(datetime('now', 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd HH:mm')), strtrim(gitCommit));

switch check
    case 'endToEnd'
        inputs = load(fullfile(outputsDir, 'conservedMoietyHotspots', 'n1960-identifyInputs.mat'), ...
            'model', 'BG', 'dATM');
        options = struct('sanityChecks', 0, 'conservedMoietiesOnly', true);
        classifySubgraphIsomorphism('resetCallCount');
        tStart = tic;
        [arm, moietyFormulae, reacting] = identifyConservedReactingMoieties(inputs.model, inputs.BG, ...
            inputs.dATM, options);
        identifySeconds = toc(tStart);
        callCount = classifySubgraphIsomorphism('getCallCount');
        fallbackCount = classifySubgraphIsomorphism('getFallbackCount');
        clear inputs
        golden = load(fullfile(outputsDir, 'extractBondSubgraphsPeeling', 'n1960-endToEnd-golden.mat'), ...
            'arm', 'moietyFormulae', 'reacting');
        sameArm = isequaln(arm, golden.arm);
        armFields = fieldnames(golden.arm);
        differentFields = armFields(~cellfun(@(f) isfield(arm, f) && isequaln(arm.(f), golden.arm.(f)), armFields));
        sameFormulae = isequaln(moietyFormulae, golden.moietyFormulae);
        sameReacting = isequaln(reacting, golden.reacting);
        msg = sprintf(['%s- identify %.1f s; %d moieties, %d moiety graphs; total classification calls %d, ' ...
            'fallbacks %d\n- arm identical %d (fields differing: %s); moietyFormulae identical %d; ' ...
            'reacting identical %d\n'], header, identifySeconds, size(arm.L, 1), numel(arm.MG), ...
            callCount, fallbackCount, sameArm, strjoin(differentFields', ', '), sameFormulae, sameReacting);
        isPass = sameArm && sameFormulae && sameReacting;

    case 'builder'
        inputs = load(fullfile(outputsDir, 'conservedMoietyHotspots', 'n1960-identifyInputs.mat'), 'model');
        model = inputs.model;
        clear inputs
        options = struct('sanityChecks', 0);
        builderOutputs = cell(2, 12);
        builderSeconds = zeros(2, 1);
        for version = 1:2
            if version == 1
                useBaseline(baselineDir, srcDir);
            else
                useSource(baselineDir, srcDir);
            end
            tStart = tic;
            [builderOutputs{version, :}] = buildAtomAndBondTransitionMultigraph(model, rxnDir, options);
            builderSeconds(version) = toc(tStart);
        end
        useSource(baselineDir, srcDir);
        outputNames = {'dATM', 'metAtomMappedBool', 'rxnAtomMappedBool', 'M2Ai', 'Ti2R', 'dATME', 'BG', ...
            'dBTM', 'M2BiE', 'M2BiW', 'BTi2R', 'BTiE'};
        isSame = false(1, 12);
        for k = 1:12
            isSame(k) = isequaln(builderOutputs{1, k}, builderOutputs{2, k}) && ...
                strcmp(class(builderOutputs{1, k}), class(builderOutputs{2, k})) && ...
                issparse(builderOutputs{1, k}) == issparse(builderOutputs{2, k});
        end
        msg = sprintf(['%s- %d reactions, corpus %s; build develop %.1f s, source %.1f s\n' ...
            '- outputs identical (value, class, sparsity): %d of 12%s\n'], header, numel(model.rxns), ...
            rxnDir, builderSeconds(1), builderSeconds(2), nnz(isSame), ...
            ternary(all(isSame), '', [' — differ: ' strjoin(outputNames(~isSame), ', ')]));
        isPass = all(isSame);

    case 'reader'
        files = dir(fullfile(rxnDir, '*.rxn'));
        rxnIds = regexprep({files.name}', '\.rxn$', '');
        numFiles = numel(rxnIds);
        status = zeros(numFiles, 1); % 1 identical, 2 develop error and source reads, 3 same error, 4 different
        detail = cell(numFiles, 1);
        tStart = tic;
        % one pass per version, so the path is switched only twice
        readResults = cell(numFiles, 3, 2);
        for version = 1:2
            if version == 1
                useBaseline(baselineDir, srcDir);
            else
                useSource(baselineDir, srcDir);
            end
            for k = 1:numFiles
                [readResults{k, 1, version}, readResults{k, 2, version}, readResults{k, 3, version}] = ...
                    readOnce(rxnIds{k}, rxnDir);
            end
        end
        for k = 1:numFiles
            [baselineAtoms, baselineBonds, baselineError] = readResults{k, :, 1};
            [sourceAtoms, sourceBonds, sourceError] = readResults{k, :, 2};
            if isempty(baselineError) && isempty(sourceError)
                if isequaln(baselineAtoms, sourceAtoms) && isequaln(baselineBonds, sourceBonds)
                    status(k) = 1;
                else
                    status(k) = 4;
                    detail{k} = sprintf('%s: tables differ', rxnIds{k});
                end
            elseif ~isempty(baselineError) && isempty(sourceError)
                status(k) = 2;
                detail{k} = sprintf('%s: develop error "%s"; source reads %d atoms, %d bonds', ...
                    rxnIds{k}, baselineError, height(sourceAtoms), height(sourceBonds));
            elseif strcmp(baselineError, sourceError)
                status(k) = 3;
                detail{k} = sprintf('%s: both "%s"', rxnIds{k}, baselineError);
            else
                status(k) = 4;
                detail{k} = sprintf('%s: develop "%s", source "%s"', rxnIds{k}, baselineError, sourceError);
            end
        end
        useSource(baselineDir, srcDir);
        msg = sprintf(['%s- %d RXN files in %s, read in %.0f s\n- identical %d; develop error, source ' ...
            'reads %d; same error in both %d; different %d\n'], header, numFiles, rxnDir, toc(tStart), ...
            nnz(status == 1), nnz(status == 2), nnz(status == 3), nnz(status == 4));
        for k = find(status >= 2)'
            msg = [msg sprintf('  - [%d] %s\n', status(k), detail{k})]; %#ok<AGROW>
        end
        isPass = ~any(status == 4);

    otherwise
        error('regressionChecks:unknownCheck', 'Unknown CBT_REG_CHECK "%s".', check);
end
fid = fopen(logPath, 'a');
fprintf(fid, '%s- verdict: %s\n', msg, ternary(isPass, 'PASS', 'FAIL'));
fclose(fid);
fprintf('%s- verdict: %s\n', msg, ternary(isPass, 'PASS', 'FAIL'));

%% Local functions
function useBaseline(baselineDir, srcDir)
% develop copies of readABRXNFile, checkABRXNFiles and buildAtomAndBondTransitionMultigraph in front
addpath(baselineDir, '-begin');
for name = {'readABRXNFile', 'checkABRXNFiles', 'buildAtomAndBondTransitionMultigraph'}
    assert(strcmp(which(name{1}), fullfile(baselineDir, [name{1} '.m'])), 'Wrong %s active.', name{1});
end
assert(~startsWith(which('classifySubgraphIsomorphism'), baselineDir));
end

function useSource(baselineDir, srcDir)
% source versions only
if contains(path, baselineDir)
    rmpath(baselineDir);
end
for name = {'readABRXNFile', 'checkABRXNFiles', 'buildAtomAndBondTransitionMultigraph'}
    assert(strcmp(which(name{1}), fullfile(srcDir, [name{1} '.m'])), 'Wrong %s active.', name{1});
end
end

function [atoms, bonds, errorText] = readOnce(rxnId, rxnDir)
% read one RXN file; an error is returned as its identifier and message, compared between the two
% versions (their line numbers differ), and printed with its location (Principle VII-C)
atoms = [];
bonds = [];
errorText = '';
try
    [atoms, bonds] = readABRXNFile(rxnId, rxnDir);
catch ME
    errorText = sprintf('%s: %s', ME.identifier, ME.message);
    fprintf('readABRXNFile error on %s: %s (%s:%d)\n', rxnId, errorText, ME.stack(1).file, ME.stack(1).line);
end
end

function out = ternary(condition, a, b)
if condition
    out = a;
else
    out = b;
end
end
