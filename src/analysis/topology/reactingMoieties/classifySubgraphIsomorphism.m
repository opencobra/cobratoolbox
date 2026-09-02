function [isomorphismClasses, firstSubgraphIndices, subsequentSubgraphIndices] = classifySubgraphIsomorphism(subgraphs, varargin)
% Groups a cell array of subgraphs into isomorphism equivalence classes
%
% USAGE:
%
%    [isomorphismClasses, firstSubgraphIndices, subsequentSubgraphIndices] = classifySubgraphIsomorphism(subgraphs, varargin)
%
% INPUTS:
%    subgraphs:                   cell array where each cell contains a MATLAB `graph`/`digraph` object to classify
%
% OPTIONAL INPUTS:
%    varargin:                    name-value pairs forwarded verbatim to `isisomorphic` for every candidate pair, for example `'NodeVariables', 'mets'` or `'EdgeVariables', 'mets'`; omit for plain structural isomorphism with no label matching
%
% OUTPUTS:
%    isomorphismClasses:          `1 x numClasses` cell array; each cell is an ascending-order row vector of subgraph indices belonging to that class, with the class leader (minimum index) first
%    firstSubgraphIndices:        `numClasses x 1` vector of the leader index of each class, in the same order as `isomorphismClasses`
%    subsequentSubgraphIndices:   `numSubgraphs x 1` vector mapping every subgraph index (leaders included) to its 1-based class number
%
% NOTE:
%    Before calling `isisomorphic` for a candidate pair, a cheap structural
%    invariant (node count, edge count, and, when `NodeVariables`/
%    `EdgeVariables` is present in `varargin`, the sorted multiset of that
%    node/edge label column) is compared for the two subgraphs; the pair is
%    treated as non-isomorphic, without calling `isisomorphic`, whenever the
%    invariants differ. This invariant is a necessary, not sufficient,
%    condition for isomorphism, so no truly isomorphic pair is ever missed
%    (the full `isisomorphic` check still runs for every pair whose
%    invariants match). A bucket with exactly one member never triggers an
%    `isisomorphic` call. This is the single shared classification helper
%    for `findAndExtractMolecularGraphs`, `identifyConservedReactingMoieties`,
%    and `identifyIsomorphicClasses`, replacing three independent all-pairs
%    loops (feature 021-prefilter-isomorphism-classification).
%
%    Since those three functions' public signatures are frozen (Constitution
%    Principle II), the total real `isisomorphic` call count cannot be
%    surfaced through a normal output argument without changing them. A
%    minimal, opt-in diagnostic side channel is provided instead, used only
%    by the feature's non-CI Tyrosine reproducibility check:
%    `classifySubgraphIsomorphism('resetCallCount')` resets a persistent
%    counter to zero, and `n = classifySubgraphIsomorphism('getCallCount')`
%    reads it. This branch never triggers during normal classification
%    calls, which always pass a cell array as `subgraphs`.
%
% Author:
%    - COBRA Toolbox, feature 021-prefilter-isomorphism-classification

    persistent isisomorphicCallCount
    if isempty(isisomorphicCallCount)
        isisomorphicCallCount = 0;
    end

    if ischar(subgraphs) || (isstring(subgraphs) && isscalar(subgraphs))
        action = lower(char(subgraphs));
        switch action
            case 'resetcallcount'
                isisomorphicCallCount = 0;
                isomorphismClasses = {};
            case 'getcallcount'
                isomorphismClasses = isisomorphicCallCount;
            otherwise
                error('classifySubgraphIsomorphism:UnknownAction', ...
                    'Unknown action "%s". Valid actions: resetCallCount, getCallCount.', subgraphs);
        end
        firstSubgraphIndices = [];
        subsequentSubgraphIndices = [];
        return;
    end

    numSubgraphs = numel(subgraphs);

    isomorphismClasses = {};
    firstSubgraphIndices = [];
    subsequentSubgraphIndices = zeros(numSubgraphs, 1);

    if numSubgraphs == 0
        return;
    end

    % identify which label column, if any, participates in the invariant
    % and in the isisomorphic comparison mode
    nodeVarName = '';
    edgeVarName = '';
    for k = 1:2:numel(varargin)
        if strcmpi(varargin{k}, 'NodeVariables')
            nodeVarName = varargin{k + 1};
        elseif strcmpi(varargin{k}, 'EdgeVariables')
            edgeVarName = varargin{k + 1};
        end
    end

    % precompute the structural invariant once per subgraph
    numNodesVec = zeros(numSubgraphs, 1);
    numEdgesVec = zeros(numSubgraphs, 1);
    nodeLabels = cell(numSubgraphs, 1);
    edgeLabels = cell(numSubgraphs, 1);
    for i = 1:numSubgraphs
        numNodesVec(i) = numnodes(subgraphs{i, 1});
        numEdgesVec(i) = numedges(subgraphs{i, 1});
        if ~isempty(nodeVarName)
            nodeLabels{i} = sort(subgraphs{i, 1}.Nodes.(nodeVarName));
        end
        if ~isempty(edgeVarName)
            edgeLabels{i} = sort(subgraphs{i, 1}.Edges.(edgeVarName));
        end
    end

    % single forward-scan exclusion algorithm: for each not-yet-excluded
    % leader i, sweep the remaining not-yet-excluded j > i, skip the
    % isisomorphic call whenever the invariant rules it out, and fall back
    % to the exhaustive check otherwise
    excludedSubgraphs = false(numSubgraphs, 1);
    isomorphismClassNumber = 0;

    for i = 1:numSubgraphs
        if excludedSubgraphs(i)
            continue;
        end

        isomorphismClassNumber = isomorphismClassNumber + 1;
        currentClass = i;
        excludedSubgraphs(i) = true;
        subsequentSubgraphIndices(i) = isomorphismClassNumber;

        for j = (i + 1):numSubgraphs
            if excludedSubgraphs(j)
                continue;
            end

            if numNodesVec(i) ~= numNodesVec(j) || numEdgesVec(i) ~= numEdgesVec(j)
                continue;
            end
            if ~isempty(nodeVarName) && ~isequal(nodeLabels{i}, nodeLabels{j})
                continue;
            end
            if ~isempty(edgeVarName) && ~isequal(edgeLabels{i}, edgeLabels{j})
                continue;
            end

            isisomorphicCallCount = isisomorphicCallCount + 1;
            if isisomorphic(subgraphs{i, 1}, subgraphs{j, 1}, varargin{:})
                currentClass = [currentClass, j]; %#ok<AGROW>
                excludedSubgraphs(j) = true;
                subsequentSubgraphIndices(j) = isomorphismClassNumber;
            end
        end

        isomorphismClasses{1, isomorphismClassNumber} = currentClass; %#ok<AGROW>
        firstSubgraphIndices(isomorphismClassNumber, 1) = i; %#ok<AGROW>
    end
end
