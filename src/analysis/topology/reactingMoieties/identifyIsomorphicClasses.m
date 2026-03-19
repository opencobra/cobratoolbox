function [isomorphismClasses, firstSubgraphIndices, subsequentSubgraphIndices] = identifyIsomorphicClasses(CBSubgraphs, sanityChecks)
% identifyIsomorphicClasses - Identifies isomorphism classes for a set of subgraphs.
%
% Inputs:
%   CBSubgraphs - Cell array where each cell contains a subgraph.
%   sanityChecks - Boolean flag to enable additional consistency checks.
%
% Outputs:
%   isomorphismClasses - Cell array where each cell contains indices of isomorphic subgraphs.
%   firstSubgraphIndices - Indices of the first subgraph in each isomorphism class.
%   subsequentSubgraphIndices - Array mapping subgraphs to their isomorphism class.
%
% Notes:
%   - Requires MATLAB R2016b or later for the `isisomorphic` function with variable matching.
%   - Node and edge properties are compared for isomorphism detection.

    % Initialize variables
    numSubgraphs = size(CBSubgraphs, 1);
    excludedSubgraphs = false(numSubgraphs, 1); % Track excluded subgraphs
    isomorphismClasses = {}; % To store groups of isomorphic subgraphs
    firstSubgraphIndices = zeros(numSubgraphs, 1); % First subgraph in each class
    subsequentSubgraphIndices = zeros(numSubgraphs, 1); % Map subgraphs to classes
    isomorphismClassNumber = 1; % Initialize class counter

    % Loop through subgraphs
    for i = 1:numSubgraphs
        % Skip already classified subgraphs
        if excludedSubgraphs(i) == false
            % Initialize current class
            currentClass = i;
            for j = 1:numSubgraphs
                % Check only unclassified and non-self subgraphs
                if i ~= j && excludedSubgraphs(j) == false
                    % Check for isomorphism with specified edge variables
                    if isisomorphic(CBSubgraphs{i, 1}, CBSubgraphs{j, 1}, 'EdgeVariables', 'mets')
                        currentClass = [currentClass, j]; %#ok<AGROW>
                        excludedSubgraphs(j) = true;
                        subsequentSubgraphIndices(j) = isomorphismClassNumber;

                        % Perform sanity checks if enabled
                        if sanityChecks
                            if any(CBSubgraphs{j, 1}.Nodes.AtomIndex ~= j)
                                error('Inconsistent mapping of atoms to connected components.');
                            end
                        end
                    end
                end
            end

            % Store the isomorphism class
            isomorphismClasses{isomorphismClassNumber} = currentClass;
            firstSubgraphIndices(isomorphismClassNumber) = i;
            subsequentSubgraphIndices(i) = isomorphismClassNumber;

            % Map atoms and edges to the current isomorphism class
            if sanityChecks
                atrans2component(CBSubgraphs{i, 1}.Edges.TransIndex) = i; %#ok<NASGU>
                atoms2isomorphismClass(CBSubgraphs{i, 1}.Nodes.AtomIndex) = isomorphismClassNumber; %#ok<NASGU>
                atrans2isomorphismClass(CBSubgraphs{i, 1}.Edges.TransIndex) = isomorphismClassNumber; %#ok<NASGU>
            end

            % Increment isomorphism class counter
            isomorphismClassNumber = isomorphismClassNumber + 1;
        end
    end

    % Trim unused entries in firstSubgraphIndices
    firstSubgraphIndices = firstSubgraphIndices(1:isomorphismClassNumber - 1);
end


