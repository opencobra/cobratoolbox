function [COBRAparams, solverParams] = parseSolverParameters(problemType,varargin)
%


%Build the default Parameter Structure
COBRASolverParameters = getCobraSolverParamsOptionsForType(problemType);
eval(['global CBT_' problemType '_SOLVER;'])
eval(['defaultSolver = CBT_' problemType '_SOLVER;']);
solverVars = cell(numel(COBRASolverParameters),1);
[solverVars{:}] = getCobraSolverParams(problemType,COBRASolverParameters,struct('solver',defaultSolver));
defaultParams = [columnVector(COBRASolverParameters),columnVector(solverVars)];
%Parse the supplied parameters
if numel(varargin) > 0
    if mod(numel(varargin),2) == 1 %We should have a struct at the end                       
        optParamStruct = varargin{end};
        if ~isstruct(optParamStruct)
            optParamStruct = varargin{1};
            varargin(1) = [];
            if ~isstruct(optParamStruct)
                error(['Invalid Parameters supplied.\n',...
                       'Parameters have to be supplied either as parameter/Value pairs, or as struct.\n',...
                       'A combination is possible, if the last or first input argument is a struct, and all other arguments are parameter/value pairs'])
            end
        else
            varargin(end) = [];    
        end
        
    else
        optParamStruct = struct();
    end
    for i = 1:2:numel(varargin)
        cparam = varargin{i};
        if ~ischar(cparam)
            error('Parameters have to be supplied as ''parameterName''/Value pairs');
        end
        %the param struct overrides the individ
        if ~isfield(optParamStruct,cparam)
            try
                optParamStruct.(cparam) = varargin{i+1};
            catch
                error('All parameters have to be valid matlab field names. %s is not a valid field name',cparam);
            end
        else
            warning('Duplicate parameter %s, both supplied as a field name and a parameter/value pair!',cparam);
        end
    end
else
    optParamStruct = struct();
end
COBRAparams = struct();

for i = 1:numel(defaultParams(:,1))
    if isfield(optParamStruct,defaultParams{i,1})
        COBRAparams.(defaultParams{i,1}) = optParamStruct.(defaultParams{i,1});
        optParamStruct = rmfield(optParamStruct,defaultParams{i,1});
    else
        COBRAparams.(defaultParams{i,1}) = defaultParams{i,2};
    end
end
solverParams = optParamStruct;    