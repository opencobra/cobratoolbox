function LP = setCplexParam(LP, solverParams,verbFlag)
% Sets the parameters of the IBM ILOG CPLEX object according to the structure `solverParams`
% The `solverParams` structure has to contain the same structure as the
% Cplex.Param structue in a Cplex object. But values can be set by directly
% setting the respective parameter instead of the `Cur` value which would
% be necessary if directly modifying the Cplex.Param structure.
% USAGE:
%
%    LP = setCplexParam(LP, solverParams, verbFlag);
%
% INPUTS:
%    LP:              IBM-ILOG Cplex object
%    solverParams:    parameter structure for Cplex. Check `LP.Param`. For example,
%                     `[solverParams.simplex.display, solverParams.tune.display, solverParams.barrier.display, solverParams.sifting.display, solverParams.conflict.display] = deal(0);`
%                     `[solverParams.simplex.tolerances.optimality, solverParams.simplex.tolerances.feasibility] = deal(1e-9,1e-8);`
%
%                     The full set of parameters can be obtained by calling 'Cplex().Param'
%    verbFlag:        true to show which parameter input is problematic if any (optional, default true)

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
