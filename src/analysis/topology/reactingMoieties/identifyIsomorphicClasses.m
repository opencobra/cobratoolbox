function [isomorphismClasses, firstSubgraphIndices, subsequentSubgraphIndices] = identifyIsomorphicClasses(CBSubgraphs, sanityChecks)
% Identifies isomorphism classes for a set of subgraphs
%
% USAGE:
%
%    [isomorphismClasses, firstSubgraphIndices, subsequentSubgraphIndices] = identifyIsomorphicClasses(CBSubgraphs, sanityChecks)
%
% INPUTS:
%    CBSubgraphs:                 cell array where each cell contains a subgraph
%    sanityChecks:                boolean flag to enable additional consistency checks
%
% OUTPUTS:
%    isomorphismClasses:          cell array where each cell contains indices of isomorphic subgraphs
%    firstSubgraphIndices:        indices of the first subgraph in each isomorphism class
%    subsequentSubgraphIndices:    array mapping subgraphs to their isomorphism class
%
% NOTE:
%    Requires MATLAB R2016b or later for the `isisomorphic` function with variable
%    matching. Node and edge properties are compared for isomorphism detection.
%    Classification itself is delegated to the shared, invariant-prefiltered
%    helper `classifySubgraphIsomorphism` (feature
%    021-prefilter-isomorphism-classification); this function's own role is
%    to preserve its public signature and re-attach the `sanityChecks`
%    consistency check on non-leader class members.

    [isomorphismClasses, firstSubgraphIndices, subsequentSubgraphIndices] = ...
        classifySubgraphIsomorphism(CBSubgraphs, 'EdgeVariables', 'mets');

    if sanityChecks
        for isomorphismClassNumber = 1:numel(isomorphismClasses)
            currentClass = isomorphismClasses{isomorphismClassNumber};
            for j = currentClass(2:end)
                if any(CBSubgraphs{j, 1}.Nodes.AtomIndex ~= j)
                    error('Inconsistent mapping of atoms to connected components.');
                end
            end
        end
    end
end


