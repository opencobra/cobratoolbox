function LP = setCplexParam(LP, solverParams,verbFlag)
% set the parameters of the IBM ILOG CPLEX object according to the structure solverParams
%
% USAGE:
%    LP = setCplexParam(LP, solverParams, verbFlag);
% 
% INPUTS:
%    LP:            IBM-ILOG Cplex object
%    solverParams:  parameter structure for Cplex. Check LP.Param. For example,
%                     [solverParams.simplex.display, solverParams.tune.display, solverParams.barrier.display,...
%                     solverParams.sifting.display, solverParams.conflict.display] = deal(0);
%                     [solverParams.simplex.tolerances.optimality, solverParams.simplex.tolerances.feasibility] = deal(1e-9,1e-8);
%                     The full set of parameters can be obtained by calling 'Cplex().Param'
%    verbFlag:      true to show which parameter input is problematic if any (optional, default true)
if nargin < 3
    verbFlag = true;
end
if isempty(fieldnames(solverParams))
    return
end
% get all the end parameters and their paths from LP.Param
%(e.g., LP.Param.simplex.display will have 'display' in paramList and 'LP.Param.simplex' in paramPath)
[paramList, paramPath] = getParamList(LP.Param, 0);
% similarly get all parameters and paths from the user-supplied parameter structure
% (but not going to the bottom level. User-supplied parameter structure no
% need to have *.Cur field after every parameter. But still supported if there is .Cur)
[paramUserList, paramUserPath, addCur] = getParamList(solverParams, 1);
% whether an user-supplied parameter can be matched to LP.Param
paramIden = false(numel(paramUserList), 1);
for p = 1:numel(paramUserList)
    f = strcmpi(paramList,paramUserList{p});
    if sum(f) == 1
        % uniquely matched
        paramIden(p) = true;
        str = ['LP.Param.' paramPath{f} '.Cur = solverParams.' paramUserPath{p}];
        if addCur(p)  % add back .Cur if in the user-supplied parameters
            str = [str '.Cur'];
        end
        str = [str ';'];
        eval(str);
    elseif sum(f) > 1
        % not uniquely matched (for parameters end with 'display' etc.)
        % compare the path then
        if ismember(lower(paramUserPath{p}), paramPath)
            paramIden(p) = true;
            str = ['LP.Param.' lower(paramUserPath{p}) '.Cur = solverParams.' paramUserPath{p}];
            if addCur(p)  % add back .Cur if in the user-supplied parameters
                str = [str '.Cur'];
            end
            str = [str ';'];
            eval(str);
        else
            if verbFlag
                warning('*.%s cannot be uniquely identified as a valid cplex parameter. Ignore.', paramUserPath{p});
            end
        end
    else
        % not matched at all
        if verbFlag
            warning('*.%s cannot be identified as a valid cplex parameter. Ignore.', paramUserPath{p});
        end
    end
end
end

function [paramList, paramPath, addCur] = getParamList(param, bottomFlag)
% Get all the end parameters and their paths for matching CPLEX parameters appropriately
% (e.g., if param.simplex.display is a parameter, then we will have 'display' 
% in paramList and 'param.simplex' in paramPath)
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