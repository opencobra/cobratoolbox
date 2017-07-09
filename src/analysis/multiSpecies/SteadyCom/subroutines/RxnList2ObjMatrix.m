function objMatrix = RxnList2ObjMatrix(rxnList, varNameDisp, xName, n, nVar, callName)
% subroutine to transform a list of K reactions or K linear combinations of reactions into a matrix (#rxns + #organisms)-by-K matrix
if ischar(rxnList)
    % if input is a string, make it a cell
    rxnList = {rxnList};
end
if isnumeric(rxnList)  % if the input is numeric
    if size(rxnList,1) >= n && size(rxnList,1) <= nVar
        % it is a matrix of objective vectors
        objMatrix = [sparse(rxnList); sparse(nVar - size(rxnList,1), size(rxnList,2))];
    elseif size(rxnList, 1) == 1 || size(rxnList, 2) == 1 
        % reaction index (better in row to distinguish from matrix input)
        objMatrix = sparse(rxnList, 1:numel(rxnList), ones(numel(rxnList),1),...
            nVar, max(size(rxnList)));
    else
        error(['Invalid numerical input of %s.\n', ...
            'Either a (#rxns + #organisms)-by-K matrix for K targets to be analyzed,\n'...
            'or an index row vector v (but not column vector)'], callName);
    end
elseif iscell(rxnList)  % if the input is a cell array
    [row, col] = deal([]);
    for jRxnName = 1:numel(rxnList)
        % Each rxnNameList{jRxnName} can be a cell array of reactions. 
        % In this case, treat as the unweighted sum of the reactions
        [~, rJ] = ismember(rxnList{jRxnName}, varNameDisp);
        % check if names for biomass variables exist
        if ~all(rJ)
            invalidName = false;
            if ~isempty(xName)
                if iscell(rxnList{jRxnName})  % the cell contains a cell array of strings
                    [~, id] = ismember(rxnList{jRxnName}(rJ == 0), xName);
                    id(id ~= 0) = n + id(id ~= 0);  % biomass variable index = n + #organism
                    rJ(rJ == 0) = id;
                    if ~all(rJ)
                        invalidName = true;
                    end
                else  % if the cell contains a string not found in .rxns
                    id = strcmp(xName, rxnList{jRxnName});
                    if any(id)
                        rJ = find(id) + n;  % biomass variable index = n + #organism
                    else
                        invalidName = true;
                    end
                end
            else
                invalidName = true;
            end
            if invalidName
                if iscell(rxnList{jRxnName})
                    toPrint = strjoin(rxnList{jRxnName}(rJ == 0), ', ');
                else
                    toPrint = rxnList{jRxnName};
                end
                error('Invalid names in options.%s: #%d %s', callName, jRxnName, toPrint);
            end
        end
        [row, col] = deal([row; rJ(:)], [col; jRxnName * ones(numel(rJ), 1)]);
    end
    objMatrix = sparse(row, col, 1, nVar, numel(rxnList));
else
    error('Invalid input of %s. Either cell array or numeric input.', callName);
end
end