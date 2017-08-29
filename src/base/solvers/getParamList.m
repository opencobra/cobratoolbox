function [paramList, paramPath, addCur] = getParamList(param, bottomFlag)
% Get all the end parameters and their paths for matching CPLEX parameters appropriately
% (e.g., if param.simplex.display is a parameter, then we will have 'display'
% in paramList and 'param.simplex' in paramPath)
%
% USAGE:
%
%    [paramList, paramPath, addCur] = getParamList(param, bottomFlag)
%
% INPUTS:
%    param:           existing structure with parameters for Cplex
%    bottomFlag:      boolean switch to extract parameters based on 'Cur' at the
%                     bottom level in the user-supplied parameter structure
%
% OUTPUTS:
%    paramList:       Cell with proper parameter names
%    paramPath:       Cell with superseeding parameter structure
%    addCur:          Structure with booleans whether or not `.Cur` has been
%                     added to the `paramPath` for user-supplied parameters
%

structCur = param;  % current structure
lv = 1;  % current level of the structure
% use a stack structure to store the found parameters
lvFieldN = zeros(10,1);
lvFieldN(1) = 1;  % the number of fields being checked at the current level
lvField = cell(10, 1);
lvField{lv} = fieldnames(structCur);  % all fields in the current level
paramPath = {};
paramList = {};
addCur = [];
while lv > 0
    if isstruct(structCur.(lvField{lv}{lvFieldN(lv)}))
        % if the current level is still a structure
        if ~isempty(fieldnames(structCur.(lvField{lv}{lvFieldN(lv)})))
            % if it is not an empty structure, go into that structure
            structCur = structCur.(lvField{lv}{lvFieldN(lv)});
            lv = lv + 1;  % level + 1
            % start checking from the first field in the next level of structure
            lvFieldN(lv) = 1;
            % get all fields for the next structure
            lvField{lv} = fieldnames(structCur);
        else
            % an empty structure, go back to the closest level with any unchecked structures
            while lvFieldN(lv) == numel(lvField{lv})
                lv = lv - 1;
                if lv == 0
                    % finish if level = 0
                    break
                end
            end
            if lv > 0
                % check the next structure in the current level
                lvFieldN(lv) = lvFieldN(lv) + 1;
                structCur = param;
                for j = 1:lv-1
                    structCur = structCur.(lvField{j}{lvFieldN(j)});
                end
            end
        end
    else
        addCurLv = false;
        if ~bottomFlag || strcmpi(lvField{lv}{lvFieldN(lv)}, 'Cur')
            % if the current level is not a structure, with the bottomFlag off
            % (not going to the bottom level, for LP.Param), or if the current level
            % is named 'Cur' (may happen in the user-supplied parameter structure),
            % decrease one level since the bottom level of all parameters is either
            % 'Min', 'Max', 'Cur', 'Def', 'Name', 'Help' containing the information
            % for the parameter, which is the name for the structure immediately on
            % top of the current level
            lv = lv - 1;
            if bottomFlag  % 'Cur' at the bottom level in the user-supplied parameters
                addCurLv = true;
            end
        end
        if lv > 0
            % get the path for the current parameter
            c = {};
            for j = 1:lv
                c = [c lvField{j}(lvFieldN(j))];
            end
            paramPath = [paramPath; strjoin(c,'.')];
            % whether or not need to add back .Cur to the path for user-supplied parameters
            if addCurLv
                addCur = [addCur; true];
            else
                addCur = [addCur; false];
            end
            paramList = [paramList; c(end)];
            % go back to the closest level with any unchecked structures
            while lvFieldN(lv) == numel(lvField{lv})
                lv = lv - 1;
                if lv == 0
                    % finish if level = 0
                    break
                end
            end
            if lv > 0
                % check the next structure in the current level
                lvFieldN(lv) = lvFieldN(lv) + 1;
                structCur = param;
                for j = 1:lv-1
                    structCur = structCur.(lvField{j}{lvFieldN(j)});
                end
            end
        else
            % if lv = 0 because of bottomFlag, continue at lv = 1
            lv = 1;
            if lvFieldN(lv) == numel(lvField{lv})
                break
            else
                lvFieldN(1) = lvFieldN(1) + 1;
            end
        end
    end
end
end
