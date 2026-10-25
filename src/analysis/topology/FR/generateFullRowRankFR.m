function [modelOut, report] = generateFullRowRankFR(model, param)
% Edits a model until the internal forward/reverse half-stoichiometric matrix
% `[F, R]` has full row rank, and reports every change made.
%
% Each pass recomputes `[F, R]` from the current model and applies the first
% applicable remedy:
%
%   1. remove metabolites whose row of `[F, R]` is zero;
%   2. lump each group of metabolites with identical rows of `[F, R]` into one
%      representative (or, with `remedy = 'removeRxns'`, remove the reactions
%      that contain the group);
%   3. compute a left-null basis of `[F, R]`; for every null vector whose
%      support contains dead-end metabolites (each in exactly one internal
%      reaction), remove those dead-end reactions.
%
% If a dependency remains that none of these remedies applies to, the function
% stops and reports the null vector as a witness (default), or, with
% `irreducibleRemedy = 'removeMetabolites'`, removes one chosen metabolite of
% each null vector's support together with every reaction it takes part in,
% and continues. The latter option guarantees full row rank.
%
% USAGE:
%
%    [modelOut, report] = generateFullRowRankFR(model, param)
%
% INPUTS:
%    model:             COBRA model structure with at least the fields:
%
%                         * .S - `m x n` stoichiometric matrix
%                         * .mets - `m x 1` metabolite identifiers
%                         * .rxns - `n x 1` reaction identifiers
%                         * .lb - `n x 1` lower flux bounds
%                         * .ub - `n x 1` upper flux bounds
%
%                       If present, `.SConsistentRxnBool` selects the internal
%                       reactions (see `param.rxnBool`).
%
% OPTIONAL INPUTS:
%    param:             structure with the optional fields:
%
%                         * .rxnBool - `n x 1` logical selecting the internal reactions
%                           (default: `model.SConsistentRxnBool` if present, otherwise
%                           `SIntRxnBool` from `findSExRxnInd`)
%                         * .printLevel - verbose level (default 0, silent)
%                         * .maxIterations - maximum number of passes (default 20, or
%                           `m + n` when `irreducibleRemedy = 'removeMetabolites'`)
%                         * .remedy - remedy for identical rows: 'lump' (default) keeps
%                           the first metabolite of each group as its representative;
%                           'removeRxns' removes the reactions that contain the group
%                         * .tol - tolerance on the residual of left-null vectors and on
%                           their support (default 1e-9)
%                         * .irreducibleRemedy - remedy when no other remedy applies:
%                           'stop' (default) stops and reports the witness;
%                           'removeMetabolites' removes, for each witness, the support
%                           metabolite whose removal deletes the fewest reactions (ties:
%                           fewest internal reactions, then first in `model.mets`),
%                           together with every reaction it takes part in, internal or
%                           external, using `removeMetabolites(model, mets, true, 'inclusive')`
%
% OUTPUTS:
%    modelOut:          model with full row rank `[F, R]`, or the model reached before
%                       a reported stop. If `[F, R]` already has full row rank, the
%                       input model is returned unchanged.
%    report:            structure with the fields:
%
%                         * .mBefore, .nBefore - size of `model.S`
%                         * .mAfter, .nAfter - size of `modelOut.S`
%                         * .rankBefore, .rankAfter - rank of `[F, R]` for the input and output
%                         * .rankMethod - cell array, method of each rank decision:
%                           'getRankLUSOL', 'sparseQR' (when LUSOL and a sparse QR disagree)
%                           or 'empty'
%                         * .rankLog - structure array (iteration, m, rankLUSOL, rankQR, rankMethod)
%                         * .rxnBoolSource - 'param', 'SConsistentRxnBool' or 'findSExRxnInd'
%                         * .fullRowRank - true if `rankAfter == mAfter`
%                         * .removedMets - structure array (met, iteration, reason), reason
%                           'zeroRow', 'lumped', 'generalRemoval' or 'orphaned' (removed as a
%                           side effect of another edit)
%                         * .removedRxns - structure array (rxn, iteration, reason, internal),
%                           reason 'deadEnd', 'identicalRowGroup', 'duplicateAfterLump',
%                           'generalRemoval' or 'emptyColumn' (left without metabolites)
%                         * .removedCtrs - structure array (ctr, iteration) of coupling
%                           constraints removed as a side effect of reaction removal
%                         * .lumpedGroups - structure array (members, representative,
%                           rxnsRewritten, differenceVectors, iteration); each difference
%                           vector `{member, 1; representative, -1}` is a left-null vector
%                           of `[F, R]` before lumping
%                         * .nullVectors - structure array (iteration, support, coefficients,
%                           residual, remedy, chosenMet, rxnsRemoved), remedy
%                           'deadEndRemoval', 'generalRemoval' or 'none'
%                         * .flaggedForReview - structure array (rxns, sharedSubstrate,
%                           iteration): pairs of reactions removed together as dead ends
%                           that share a substrate not common to all of them
%                         * .generalRemovalUsed - true if `irreducibleRemedy` removed metabolites
%                         * .iterations - number of passes
%                         * .stopReason - '' on success, otherwise 'irreducibleDependency',
%                           'maxIterations' or 'noInternalReactions'
%
% EXAMPLE:
%
%    [modelOut, report] = generateFullRowRankFR(model);
%    [modelOut, report] = generateFullRowRankFR(model, struct('irreducibleRemedy', 'removeMetabolites'));
%
% NOTE:
%
%    Let `N = S(:, rxnBool)` be the internal stoichiometric matrix. Then
%    `F = max(-N, 0)`, `R = max(N, 0)` and `N = R - F`. The goal is
%    `rank([F, R]) = m`, where `m` is the number of rows of `modelOut.S`.
%    Exchange and other external columns are not part of `N`; they are removed
%    only when left without metabolites, or by the opt-in general removal.
%    Warnings raised by the toolbox functions used here, for example by
%    `addReaction` when it rewrites an existing reaction, are not suppressed.
%
% .. Author:
%       - Ronan Fleming, 2026

if ~exist('param', 'var') || isempty(param)
    param = struct();
end
[mBefore, nBefore] = size(model.S);
if ~isfield(param, 'printLevel') || isempty(param.printLevel)
    param.printLevel = 0;
end
if ~isfield(param, 'remedy') || isempty(param.remedy)
    param.remedy = 'lump';
end
if ~isfield(param, 'tol') || isempty(param.tol)
    param.tol = 1e-9;
end
if ~isfield(param, 'irreducibleRemedy') || isempty(param.irreducibleRemedy)
    param.irreducibleRemedy = 'stop';
end
if ~ismember(param.remedy, {'lump', 'removeRxns'})
    error('generateFullRowRankFR:badRemedy', 'param.remedy must be ''lump'' or ''removeRxns''.');
end
if ~ismember(param.irreducibleRemedy, {'stop', 'removeMetabolites'})
    error('generateFullRowRankFR:badIrreducibleRemedy', 'param.irreducibleRemedy must be ''stop'' or ''removeMetabolites''.');
end
if ~isfield(param, 'maxIterations') || isempty(param.maxIterations)
    if strcmp(param.irreducibleRemedy, 'removeMetabolites')
        % every editing pass removes at least one metabolite or reaction
        param.maxIterations = mBefore + nBefore;
    else
        param.maxIterations = 20;
    end
end

report = initReport();
report.mBefore = mBefore;
report.nBefore = nBefore;

% internal reactions, tracked by identifier through all edits
if isfield(param, 'rxnBool') && ~isempty(param.rxnBool)
    if numel(param.rxnBool) ~= nBefore
        error('generateFullRowRankFR:badRxnBool', 'param.rxnBool must have one entry per reaction (%d).', nBefore);
    end
    rxnBool = logical(param.rxnBool(:));
    report.rxnBoolSource = 'param';
elseif isfield(model, 'SConsistentRxnBool')
    rxnBool = logical(model.SConsistentRxnBool(:));
    report.rxnBoolSource = 'SConsistentRxnBool';
else
    % computed on a copy, so that no field is added to the returned model
    modelCopy = findSExRxnInd(model, [], 0);
    rxnBool = logical(modelCopy.SIntRxnBool(:));
    report.rxnBoolSource = 'findSExRxnInd';
end
internalRxns = model.rxns(rxnBool);

modelOut = model;
isFullRank = false;
if ~any(rxnBool)
    [rankFR, report] = decideRank(computeFR(modelOut.S, rxnBool), 0, report);
    report.rankBefore = rankFR;
    report.stopReason = 'noInternalReactions';
else
    for iteration = 1:param.maxIterations
        report.iterations = iteration;
        rxnBool = ismember(modelOut.rxns, internalRxns);
        FR = computeFR(modelOut.S, rxnBool);
        [rankFR, report] = decideRank(FR, iteration, report);
        if iteration == 1
            report.rankBefore = rankFR;
        end
        if param.printLevel > 0
            fprintf('generateFullRowRankFR: pass %d, m = %d, n = %d, rank([F, R]) = %d\n', ...
                iteration, size(modelOut.S, 1), size(modelOut.S, 2), rankFR);
        end
        if rankFR == size(FR, 1)
            isFullRank = true;
            break
        end
        [modelOut, report, isEdited] = repairPass(modelOut, FR, rxnBool, internalRxns, iteration, param, report);
        if ~isEdited
            break
        end
    end
end

if isFullRank
    report.rankAfter = rankFR;
else
    rxnBool = ismember(modelOut.rxns, internalRxns);
    [report.rankAfter, report] = decideRank(computeFR(modelOut.S, rxnBool), report.iterations, report);
end
[report.mAfter, report.nAfter] = size(modelOut.S);
report.fullRowRank = report.rankAfter == report.mAfter;
if ~report.fullRowRank && isempty(report.stopReason)
    report.stopReason = 'maxIterations';
end

if param.printLevel > 0
    fprintf('generateFullRowRankFR: m %d -> %d, n %d -> %d, rank %d -> %d, full row rank %d', ...
        report.mBefore, report.mAfter, report.nBefore, report.nAfter, report.rankBefore, report.rankAfter, report.fullRowRank);
    if ~isempty(report.stopReason)
        fprintf(', stopped: %s', report.stopReason);
    end
    fprintf('\n');
    if param.printLevel > 1
        isValidModel = verifyModel(modelOut, 'simpleCheck', true);
        fprintf('generateFullRowRankFR: verifyModel simple check passed: %d\n', isValidModel);
    end
end
end

function report = initReport()
% report with every field initialised (empty lists are 0 x 1 structure arrays)
report.mBefore = 0;
report.nBefore = 0;
report.mAfter = 0;
report.nAfter = 0;
report.rankBefore = 0;
report.rankAfter = 0;
report.rankMethod = cell(0, 1);
report.rankLog = repmat(struct('iteration', 0, 'm', 0, 'rankLUSOL', 0, 'rankQR', 0, 'rankMethod', ''), 0, 1);
report.rxnBoolSource = '';
report.fullRowRank = false;
report.removedMets = repmat(struct('met', '', 'iteration', 0, 'reason', ''), 0, 1);
report.removedRxns = repmat(struct('rxn', '', 'iteration', 0, 'reason', '', 'internal', false), 0, 1);
report.removedCtrs = repmat(struct('ctr', '', 'iteration', 0), 0, 1);
report.lumpedGroups = repmat(struct('members', {{}}, 'representative', '', 'rxnsRewritten', {{}}, ...
    'differenceVectors', {{}}, 'iteration', 0), 0, 1);
report.nullVectors = repmat(struct('iteration', 0, 'support', {{}}, 'coefficients', [], 'residual', 0, ...
    'remedy', '', 'chosenMet', '', 'rxnsRemoved', {{}}), 0, 1);
report.flaggedForReview = repmat(struct('rxns', {{}}, 'sharedSubstrate', '', 'iteration', 0), 0, 1);
report.generalRemovalUsed = false;
report.iterations = 0;
report.stopReason = '';
end

function FR = computeFR(S, rxnBool)
% [F, R] of the internal columns, with F = max(-N, 0), R = max(N, 0), N = S(:, rxnBool)
N = S(:, rxnBool);
FR = [max(-N, 0), max(N, 0)];
end

function [rankFR, report] = decideRank(FR, iteration, report)
% rank of [F, R] by getRankLUSOL, cross-checked by a sparse QR of [F, R]'
m = size(FR, 1);
if m == 0 || size(FR, 2) == 0 || nnz(FR) == 0
    rankFR = 0;
    rankLUSOL = 0;
    rankQR = 0;
    method = 'empty';
else
    rankLUSOL = getRankLUSOL(FR, 0);
    rankQR = getRankQR(FR);
    if rankLUSOL == rankQR
        rankFR = rankLUSOL;
        method = 'getRankLUSOL';
    else
        rankFR = rankQR;
        method = 'sparseQR';
        warning('generateFullRowRankFR:rankDisagreement', ...
            'getRankLUSOL gives rank %d but sparse QR gives rank %d for [F, R] of size %d x %d; using the sparse QR rank.', ...
            rankLUSOL, rankQR, m, size(FR, 2));
    end
end
report.rankMethod{end + 1, 1} = method;
report.rankLog(end + 1, 1) = struct('iteration', iteration, 'm', m, 'rankLUSOL', rankLUSOL, 'rankQR', rankQR, 'rankMethod', method);
end

function [rankQR, Rq, E] = getRankQR(FR)
% rank of [F, R] from the column-pivoted sparse QR factorisation of [F, R]'
[~, Rq, E] = qr(FR', sparse(size(FR, 2), 0), 0);
d = abs(full(diag(Rq)));
if isempty(d)
    rankQR = 0;
else
    rankQR = nnz(d > max(size(FR)) * eps * max(d));
end
end

function [modelOut, report, isEdited] = repairPass(model, FR, rxnBool, internalRxns, iteration, param, report)
% apply the first applicable remedy to a rank-deficient [F, R]
modelOut = model;
isEdited = true;

% 1. zero rows
zeroRowBool = ~any(FR, 2);
if any(zeroRowBool)
    zeroMets = model.mets(zeroRowBool);
    modelOut = removeMetabolites(model, zeroMets, false);
    modelOut = removeTrivialStoichiometry(modelOut);
    report = recordEdit(report, model, modelOut, zeroMets, 'zeroRow', {}, '', iteration, internalRxns);
    modelOut = removeGenesAfterRxnRemoval(model, modelOut);
    printEdit(param, iteration, 'removed %d zero-row metabolite(s)', numel(zeroMets));
    return
end

% 2. identical rows
groups = findIdenticalGroups(FR);
if ~isempty(groups)
    if strcmp(param.remedy, 'lump')
        [~, flaggedBefore] = checkDuplicateRxn(model, 'FR', 0, 0);
        flaggedBefore = model.rxns(flaggedBefore);
        modelLumped = model;
        lumpedAway = {};
        for g = 1:numel(groups)
            [modelLumped, group] = lumpGroup(modelLumped, groups{g}, internalRxns, iteration);
            report.lumpedGroups(end + 1, 1) = group;
            lumpedAway = [lumpedAway; group.members(2:end)]; %#ok<AGROW>
        end
        modelOut = removeMetabolites(modelLumped, lumpedAway, false);
        modelOut = removeTrivialStoichiometry(modelOut);
        report = recordEdit(report, model, modelOut, lumpedAway, 'lumped', {}, '', iteration, internalRxns);
        modelOut = removeGenesAfterRxnRemoval(model, modelOut);
        [modelOut, report] = removeNewInternalDuplicates(modelOut, flaggedBefore, internalRxns, iteration, report);
        printEdit(param, iteration, 'lumped %d identical-row group(s)', numel(groups));
    else
        groupRxns = {};
        for g = 1:numel(groups)
            members = model.mets(groups{g});
            rxns = intersect(findRxnsFromMets(model, members), internalRxns, 'stable');
            report.lumpedGroups(end + 1, 1) = struct('members', {members}, 'representative', '', 'rxnsRewritten', {cell(0, 1)}, ...
                'differenceVectors', {differenceVectors(members)}, 'iteration', iteration);
            groupRxns = [groupRxns; rxns(:)]; %#ok<AGROW>
        end
        groupRxns = unique(groupRxns, 'stable');
        modelOut = removeRxns(model, groupRxns);
        report = recordEdit(report, model, modelOut, {}, '', groupRxns, 'identicalRowGroup', iteration, internalRxns);
        modelOut = removeGenesAfterRxnRemoval(model, modelOut);
        printEdit(param, iteration, 'removed %d reaction(s) of %d identical-row group(s)', numel(groupRxns), numel(groups));
    end
    return
end

% 3. remaining dependencies: left-null witnesses
witnesses = leftNullWitnesses(FR, model.mets, param.tol);
N = model.S(:, rxnBool);
nInternal = full(sum(N ~= 0, 2));
internalNames = model.rxns(rxnBool);
deadEndRxns = {};
for t = 1:numel(witnesses)
    supportInd = witnesses(t).supportInd;
    deadEnds = supportInd(nInternal(supportInd) == 1);
    rxns = cell(numel(deadEnds), 1);
    for s = 1:numel(deadEnds)
        rxns(s) = internalNames(full(N(deadEnds(s), :) ~= 0));
    end
    witnesses(t).rxnsRemoved = unique(rxns, 'stable');
    deadEndRxns = [deadEndRxns; witnesses(t).rxnsRemoved]; %#ok<AGROW>
end
deadEndRxns = unique(deadEndRxns, 'stable');

if ~isempty(deadEndRxns)
    modelOut = removeRxns(model, deadEndRxns);
    report = recordEdit(report, model, modelOut, {}, '', deadEndRxns, 'deadEnd', iteration, internalRxns);
    modelOut = removeGenesAfterRxnRemoval(model, modelOut);
    report = flagSharedSubstrates(report, model, deadEndRxns, iteration);
    for t = 1:numel(witnesses)
        if isempty(witnesses(t).rxnsRemoved)
            remedy = 'none';
        else
            remedy = 'deadEndRemoval';
        end
        report = recordWitness(report, witnesses(t), iteration, remedy, '');
    end
    printEdit(param, iteration, 'removed %d dead-end reaction(s)', numel(deadEndRxns));
elseif strcmp(param.irreducibleRemedy, 'removeMetabolites')
    chosenMets = cell(numel(witnesses), 1);
    for t = 1:numel(witnesses)
        chosenMets{t} = chooseGeneralRemoval(model, rxnBool, witnesses(t).supportInd);
    end
    uniqueChosen = unique(chosenMets, 'stable');
    [modelOut, rxnRemovedList] = removeMetabolites(model, uniqueChosen, true, 'inclusive');
    report = recordEdit(report, model, modelOut, uniqueChosen, 'generalRemoval', rxnRemovedList, 'generalRemoval', ...
        iteration, internalRxns);
    modelOut = removeGenesAfterRxnRemoval(model, modelOut);
    for t = 1:numel(witnesses)
        witnesses(t).rxnsRemoved = model.rxns(full(model.S(strcmp(model.mets, chosenMets{t}), :) ~= 0));
        report = recordWitness(report, witnesses(t), iteration, 'generalRemoval', chosenMets{t});
    end
    report.generalRemovalUsed = true;
    printEdit(param, iteration, 'general removal of %d metabolite(s) and %d reaction(s)', ...
        numel(uniqueChosen), numel(rxnRemovedList));
else
    for t = 1:numel(witnesses)
        witnesses(t).rxnsRemoved = {};
        report = recordWitness(report, witnesses(t), iteration, 'none', '');
    end
    report.stopReason = 'irreducibleDependency';
    isEdited = false;
    printEdit(param, iteration, 'stopped: %d irreducible dependency(ies)', numel(witnesses));
end
end

function groups = findIdenticalGroups(FR)
% groups (row indices, in model order) of nonzero rows of [F, R] that are identical
nonzeroRows = find(any(FR, 2));
[~, ia, ic] = unique(FR(nonzeroRows, :), 'rows', 'stable');
groups = {};
for g = 1:numel(ia)
    members = nonzeroRows(ic == g);
    if numel(members) > 1
        groups{end + 1, 1} = members; %#ok<AGROW>
    end
end
end

function vectors = differenceVectors(members)
% conserved difference vectors e_i - e_representative, one per non-representative member
vectors = cell(numel(members) - 1, 1);
for i = 2:numel(members)
    vectors{i - 1} = {members{i}, 1; members{1}, -1};
end
end

function [model, group] = lumpGroup(model, memberInd, internalRxns, iteration)
% rewrite every internal reaction of a group without its non-representative members
members = model.mets(memberInd);
others = members(2:end);
% addReaction reads the objective of an existing reaction; supply a zero
% objective for the rewrite if the model has none, and remove it afterwards
hasObjective = isfield(model, 'c');
if ~hasObjective
    model.c = zeros(numel(model.rxns), 1);
end
rxnsRewritten = intersect(findRxnsFromMets(model, members), internalRxns, 'stable');
rxnsRewritten = rxnsRewritten(:);
for r = 1:numel(rxnsRewritten)
    col = find(strcmp(model.rxns, rxnsRewritten{r}));
    metInd = find(model.S(:, col));
    metInd = metInd(~ismember(model.mets(metInd), others));
    args = {'metaboliteList', model.mets(metInd), 'stoichCoeffList', full(model.S(metInd, col)), ...
        'lowerBound', model.lb(col), 'upperBound', model.ub(col), 'printLevel', 0};
    args = [args, {'objectiveCoef', model.c(col)}]; %#ok<AGROW>
    if isfield(model, 'rxnNames')
        args = [args, {'reactionName', model.rxnNames{col}}]; %#ok<AGROW>
    end
    if isfield(model, 'grRules')
        args = [args, {'geneRule', model.grRules{col}}]; %#ok<AGROW>
    end
    if isfield(model, 'subSystems')
        originalSubSystem = model.subSystems{col};
        args = [args, {'subSystem', originalSubSystem}]; %#ok<AGROW>
    end
    model = addReaction(model, rxnsRewritten{r}, args{:});
    if isfield(model, 'subSystems')
        % addReaction may change the stored format of the subsystem entry
        model.subSystems{strcmp(model.rxns, rxnsRewritten{r})} = originalSubSystem;
    end
end
if ~hasObjective
    model = rmfield(model, 'c');
end
group = struct('members', {members}, 'representative', members{1}, 'rxnsRewritten', {rxnsRewritten}, ...
    'differenceVectors', {differenceVectors(members)}, 'iteration', iteration);
end

function [model, report] = removeNewInternalDuplicates(model, flaggedBefore, internalRxns, iteration, report)
% remove internal reactions that became duplicates under the [F, R] criterion by lumping
while true
    [~, flaggedAfter] = checkDuplicateRxn(model, 'FR', 0, 0);
    newDuplicates = setdiff(model.rxns(flaggedAfter), flaggedBefore, 'stable');
    newDuplicates = newDuplicates(ismember(newDuplicates, internalRxns));
    if isempty(newDuplicates)
        return
    end
    modelBefore = model;
    model = removeRxns(model, newDuplicates);
    report = recordEdit(report, modelBefore, model, {}, '', newDuplicates, 'duplicateAfterLump', iteration, internalRxns);
    model = removeGenesAfterRxnRemoval(modelBefore, model);
end
end

function witnesses = leftNullWitnesses(FR, mets, tol)
% sparse left-null basis of [F, R] from the column-pivoted sparse QR of [F, R]'
[rankQR, Rq, E] = getRankQR(FR);
m = size(FR, 1);
witnesses = repmat(struct('supportInd', [], 'support', {{}}, 'coefficients', [], 'residual', 0, 'rxnsRemoved', {{}}), 0, 1);
for t = 1:(m - rankQR)
    y = zeros(m, 1);
    y(E(rankQR + t)) = 1;
    if rankQR > 0
        y(E(1:rankQR)) = -full(Rq(1:rankQR, 1:rankQR) \ Rq(1:rankQR, rankQR + t));
    end
    supportInd = find(abs(y) > tol * max(abs(y)));
    residual = full(norm(FR' * y, inf));
    if residual > tol
        warning('generateFullRowRankFR:largeResidual', ...
            'Left-null vector %d of [F, R] has residual %g > tol = %g.', t, residual, tol);
    end
    witnesses(end + 1, 1) = struct('supportInd', supportInd, 'support', {mets(supportInd)}, ...
        'coefficients', y(supportInd), 'residual', residual, 'rxnsRemoved', {{}}); %#ok<AGROW>
end
end

function chosenMet = chooseGeneralRemoval(model, rxnBool, supportInd)
% support metabolite whose removal deletes the fewest reactions; ties: fewest
% internal reactions, then first in model.mets
nTotal = full(sum(model.S(supportInd, :) ~= 0, 2));
nInternal = full(sum(model.S(supportInd, rxnBool) ~= 0, 2));
[~, order] = sortrows([nTotal, nInternal, supportInd(:)]);
chosenMet = model.mets{supportInd(order(1))};
end

function report = recordWitness(report, witness, iteration, remedy, chosenMet)
% append one left-null witness to the report
report.nullVectors(end + 1, 1) = struct('iteration', iteration, 'support', {witness.support}, ...
    'coefficients', witness.coefficients, 'residual', witness.residual, 'remedy', remedy, ...
    'chosenMet', chosenMet, 'rxnsRemoved', {witness.rxnsRemoved(:)});
end

function report = recordEdit(report, before, after, targetMets, metReason, targetRxns, rxnReason, iteration, internalRxns)
% report every metabolite, reaction and coupling constraint that one edit removed;
% items not explicitly targeted were removed as side effects
goneMets = setdiff(before.mets, after.mets, 'stable');
for i = 1:numel(goneMets)
    if ismember(goneMets{i}, targetMets)
        reason = metReason;
    else
        reason = 'orphaned';
    end
    report.removedMets(end + 1, 1) = struct('met', goneMets{i}, 'iteration', iteration, 'reason', reason);
end
goneRxns = setdiff(before.rxns, after.rxns, 'stable');
for j = 1:numel(goneRxns)
    if ismember(goneRxns{j}, targetRxns)
        reason = rxnReason;
    else
        reason = 'emptyColumn';
    end
    report.removedRxns(end + 1, 1) = struct('rxn', goneRxns{j}, 'iteration', iteration, 'reason', reason, ...
        'internal', ismember(goneRxns{j}, internalRxns));
end
if isfield(before, 'ctrs')
    if isfield(after, 'ctrs')
        goneCtrs = setdiff(before.ctrs, after.ctrs, 'stable');
    else
        goneCtrs = before.ctrs;
    end
    for k = 1:numel(goneCtrs)
        report.removedCtrs(end + 1, 1) = struct('ctr', goneCtrs{k}, 'iteration', iteration);
    end
end
end

function report = flagSharedSubstrates(report, model, removedRxns, iteration)
% pairs of reactions removed together that share a substrate not common to all of them
if numel(removedRxns) < 2
    return
end
substrates = cell(numel(removedRxns), 1);
for r = 1:numel(removedRxns)
    substrates{r} = model.mets(full(model.S(:, strcmp(model.rxns, removedRxns{r})) < 0));
end
common = substrates{1};
for r = 2:numel(removedRxns)
    common = intersect(common, substrates{r});
end
for i = 1:numel(removedRxns) - 1
    for j = i + 1:numel(removedRxns)
        shared = setdiff(intersect(substrates{i}, substrates{j}), common);
        if ~isempty(shared)
            report.flaggedForReview(end + 1, 1) = struct('rxns', {removedRxns([i; j])}, ...
                'sharedSubstrate', strjoin(shared(:)', ','), 'iteration', iteration);
        end
    end
end
end

function modelOut = removeGenesAfterRxnRemoval(before, modelOut)
% remove genes no longer used, after an edit that removed reactions
if numel(modelOut.rxns) < numel(before.rxns) && isfield(modelOut, 'genes') && ...
        (isfield(modelOut, 'rules') || isfield(modelOut, 'grRules'))
    modelOut = removeUnusedGenes(modelOut);
end
end

function printEdit(param, iteration, formatSpec, varargin)
% one line per edit at printLevel > 1
if param.printLevel > 1
    fprintf(['generateFullRowRankFR: pass %d: ' formatSpec '\n'], iteration, varargin{:});
end
end
