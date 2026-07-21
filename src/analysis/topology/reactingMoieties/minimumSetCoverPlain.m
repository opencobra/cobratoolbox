function [selectedColumns, fval] = minimumSetCoverPlain(coverMatrix)
%minimumSetCoverPlain Exact minimum-cardinality set cover without toolboxes.
%
% selectedColumns = minimumSetCoverPlain(coverMatrix) returns column indices
% whose union covers every row with at least one nonzero entry. The objective
% is the standard binary set-cover objective:
% minimize sum(x), subject to coverMatrix*x >= 1 and x is binary.

coverMatrix = spones(sparse(coverMatrix));
nRows = size(coverMatrix, 1);

if nRows == 0
    selectedColumns = zeros(0, 1);
    fval = 0;
    return
end

rowCoverCounts = full(sum(coverMatrix, 2));
if any(rowCoverCounts == 0)
    error('minimumSetCoverPlain:UncoveredRow', ...
        'At least one row cannot be covered by any column.')
end

activeColumns = full(sum(coverMatrix, 1)) > 0;
originalColumns = find(activeColumns);
coverMatrix = coverMatrix(:, activeColumns);
nCols = size(coverMatrix, 2);

columnRows = cell(nCols, 1);
for j = 1:nCols
    columnRows{j} = find(coverMatrix(:, j));
end

rowColumns = cell(nRows, 1);
for i = 1:nRows
    rowColumns{i} = find(coverMatrix(i, :));
end

[bestSelected, bestCount] = greedyInitialCover();
currentSelected = false(nCols, 1);
currentCovered = false(nRows, 1);

search(currentCovered, currentSelected, 0);

selectedColumns = originalColumns(bestSelected)';
fval = bestCount;

    function [greedySelected, greedyCount] = greedyInitialCover()
        greedySelected = false(nCols, 1);
        covered = false(nRows, 1);
        greedyCount = 0;

        while any(~covered)
            gains = zeros(nCols, 1);
            uncovered = ~covered;
            for col = 1:nCols
                if ~greedySelected(col)
                    gains(col) = nnz(uncovered(columnRows{col}));
                end
            end

            [bestGain, col] = max(gains);
            if bestGain == 0
                error('minimumSetCoverPlain:UncoveredRow', ...
                    'At least one row cannot be covered by any column.')
            end

            greedySelected(col) = true;
            covered(columnRows{col}) = true;
            greedyCount = greedyCount + 1;
        end
    end

    function search(covered, selected, selectedCount)
        if selectedCount >= bestCount
            return
        end

        if all(covered)
            bestSelected = selected;
            bestCount = selectedCount;
            return
        end

        uncoveredRows = find(~covered);
        maxGain = maxRemainingGain(covered, selected);
        lowerBound = ceil(numel(uncoveredRows) / maxGain);
        if selectedCount + lowerBound >= bestCount
            return
        end

        branchRow = chooseBranchRow(uncoveredRows, selected);
        candidateCols = rowColumns{branchRow};
        candidateCols = candidateCols(~selected(candidateCols));
        candidateGains = zeros(numel(candidateCols), 1);
        for k = 1:numel(candidateCols)
            candidateGains(k) = nnz(~covered(columnRows{candidateCols(k)}));
        end

        keep = candidateGains > 0;
        candidateCols = candidateCols(keep);
        candidateGains = candidateGains(keep);

        [~, order] = sortrows([-candidateGains, candidateCols(:)]);
        candidateCols = candidateCols(order);

        for k = 1:numel(candidateCols)
            col = candidateCols(k);
            nextSelected = selected;
            nextCovered = covered;
            nextSelected(col) = true;
            nextCovered(columnRows{col}) = true;
            search(nextCovered, nextSelected, selectedCount + 1);
        end
    end

    function gain = maxRemainingGain(covered, selected)
        gain = 0;
        uncovered = ~covered;
        for col = find(~selected)'
            gain = max(gain, nnz(uncovered(columnRows{col})));
        end

        if gain == 0
            error('minimumSetCoverPlain:UncoveredRow', ...
                'At least one row cannot be covered by any remaining column.')
        end
    end

    function row = chooseBranchRow(uncoveredRows, selected)
        bestCandidateCount = inf;
        row = uncoveredRows(1);

        for idx = 1:numel(uncoveredRows)
            candidateRow = uncoveredRows(idx);
            candidateCols = rowColumns{candidateRow};
            candidateCols = candidateCols(~selected(candidateCols));
            candidateCount = numel(candidateCols);

            if candidateCount < bestCandidateCount
                bestCandidateCount = candidateCount;
                row = candidateRow;
            end
        end
    end
end
