function [funParams, cobraParams, solverVarargin] = parseCobraVarargin(varArgIn, optArgin, defaultValues, validator, problemTypes, keyForSolverParams)
% Parse varargin for a COBRA function to obtain function inputs and
% cobra-problem-specific parameters. Used to handle inputs for functions
% supporting all of (i) direct argument inputs, (ii) name-value inputs, and
% (iii) parameter structure inputss
%
% USAGE:
%    [funParams, cobraParams, solverVaragin] = parseCobraVarargin(optArgin, defaultValues, validator, problemTypes, varArgIn)
%
% INPUTS:
%    varArgIn:          cell array of additional inputs for the function (= varargin in that function)
%    optArgin:          cell array of strings for the optional arguments of a function 
%    defaultValues:     cell array of default values corresponding to optArgin
%    validator:         cell array of function handles for validating the inputs corresponding to optArgin
%                         Will return error if the inputs do not return true from the validator
%
% OPTIONAL INPUTS:
%    problemTypes:       cell array of cobra supported optimization problems needed to solve in the function
%                        (default {'LP', 'MILP', 'QP', 'MIQP'})
%    keyForSolverParams: the keyword for solver-specific parameter structure in optArgin 
%                        if solver-specific parameter structure is an explicit optional input argument in optArgi,
%                        which is NOT encouraged when writing cobra functions because the solver-specific parameter 
%                        structure as a convention among cobra functions can be inputted as a structure without keyword 
%                        and is handled this way in this parsing process. If this is the case, provide the keyword and 
%                        it will be handled (default '')
%
% OUTPUTS:
%    funParams:          cell array of optional argument inputs corresponding to optArgin.
%                         Can be assigned in the function easily by [argIn1, argIn2, ...] = deal(funParams{:})
%    cobraParams:        structure containing parsed cobra parameters for each problem type in `problemTypes`, 
%                        to be used within the cobra function being written.
%    solverVaragin:      structure containing parsed cobra-problem-specific addition inputs for each problem type in `problemTypes`,
%                        e.g., solverVarargin.LP contains the additional inputs for solveCobraLP,
%                        called as solveCobraLP(LPproblem, solverVarargin.LP{:})

if nargin < 5 || isempty(problemTypes)
    problemTypes = {'LP', 'MILP', 'QP', 'MIQP'};
end
if nargin < 6
    keyForSolverParams = '';
end

cobraOptions = getCobraSolverParamsOptionsForType(problemTypes);

pSpos = 1;
% parse the inputs accordingly.
paramValueInput = false;
if ~isempty(varArgIn)
    % Check if we have parameter/value inputs.
    
    % Handle the case where `keyForSolverParams` (solver-specific parameters) is an explicit function input argument 
    % (which is NOT encouraged when writing cobra functions because the solver-specific parameter 
    %  structure as a convention among cobra functions can be inputted as a structure without keyword ),
    
    % detect if it is supplied as a direct input.
    % Order of solverParams in the direct input (0 if not in there):
    PosSolverParams = 0;
    idTmp = strcmp(optArgin, keyForSolverParams);
    if any(idTmp)
        % if the keyword is found (i.e., solver parameters inputted as name-value argument)
        % remove the keyword and put the structure at the end
        sPInVin = find(strcmp(varArgIn, keyForSolverParams));
        if ~isempty(sPInVin) && numel(sPInVin) ~= numel(varArgIn)
            varArgIn = [varArgIn(1:(sPInVin - 1)), ...
                varArgIn((sPInVin + 2):end), varArgIn(sPInVin + 1)];
        else
            % keyword not found, may be a direct input
            PosSolverParams = find(idTmp);
        end
        % remove the keyword from optArgin, defaultValues and validator
        optArgin = optArgin(~idTmp);
        defaultValues = defaultValues(~idTmp);
        validator = validator(~idTmp);
    end
        
    for pSpos = 1:numel(varArgIn)
        if isstruct(varArgIn{pSpos})
            if pSpos == PosSolverParams && numel(varArgIn) > 7  
                % if PosSolverParams is non-zero and a solver-specific parameter structure is a direct input
                % Put it as the last argument, as if the standard way of inputting solver-specific parameter structure
                % but if the structure is the last optional input, then no need to change. But need to break with the paramValueInput flag on
                varArgIn = [varArgIn(1:(pSpos - 1)), varArgIn((pSpos + 1):end), varArgIn(pSpos)];
            else
                % its a struct, so yes, we do have additional inputs.
                paramValueInput = true;
                break;
            end
        end
        if ischar(varArgIn{pSpos}) && (any(strncmpi(varArgIn{pSpos}, optArgin, length(varArgIn{pSpos}))) ...
                || any(ismember(varArgIn{pSpos}, cobraOptions)))
            % its a keyword (support partial matching), so yes, we have paramValu input.
            paramValueInput = true;
            break
        end    
    end
end

parser = inputParser();
% parameters not matched to function input keywords
otherParams = struct();
if ~paramValueInput
    % we only have values specific to this function. Parse the data.
    for jArg = 1:numel(optArgin)
        parser.addOptional(optArgin{jArg}, defaultValues{jArg}, validator{jArg});        
    end    
    parser.parse(varArgIn{1:min(numel(varArgIn),numel(optArgin))});  
else
    % we do have solve specific parameters, so we need to also
    optArgs = varArgIn(1:pSpos-1);
    varArgIn = varArgIn(pSpos:end);
    for jArg = 1:numel(optArgs)
        parser.addOptional(optArgin{jArg}, defaultValues{jArg}, validator{jArg});        
    end
    % if 'solverParams' is inputted as a keyword. Delete the keyword and move the parameter structure 
    % to the end to be consistent with the standard cobra way of input
    idSolverParams = cellfun(@(x) ischar(x) && strncmpi(x, 'solverParams', length(x)), varArgIn);
    if any(idSolverParams)
        f = find(idSolverParams);
        varArgIn = [varArgIn(1:(f - 1)), varArgIn((f + 1):end), varArgIn(f + 1)];
    end
    if mod(numel(varArgIn),2) == 1
        % this should indicate, that there is an LP solver struct somewhere!
        for i = 1:2:numel(varArgIn)
            if isstruct(varArgIn{i})
                % move the solver-specific parameter structure to the end
                varArgIn = [varArgIn(1:i-1),varArgIn(i+1:end),varArgIn(i)];
            end
        end
    end
    
    % convert the input parameters into 2 x N [name; value] cell array
    nameValueParams = inputParamsToCells(varArgIn);
    % now, we create a new parser, that parses all algorithm specific
    % inputs.
    for jArg = numel(optArgs)+1:numel(optArgin)
        parser.addParameter(optArgin{jArg}, defaultValues{jArg}, validator{jArg});
    end
    % and extract the parameters from the field names, as CaseSensitive = 0
    % only works for parameter/value pairs but not for fieldnames.
    functionParams = {};
    % build the parameter/value pairs array
    for i = 1:size(nameValueParams, 2)
        if ~any(strncmpi(nameValueParams{1, i}, optArgin, length(nameValueParams{1, i})))
            otherParams.(nameValueParams{1, i}) = nameValueParams{2, i};
        else
            functionParams(end+1:end+2) = nameValueParams(:, i)';
        end
    end
    % and parse them.
    parser.CaseSensitive = 0;
    parser.parse(optArgs{:},functionParams{:});
end

% fields in otherParams = cobraParams (name-value inputs for solveCobraXXX) + solver-specific parameter structure

% get the true solver-specific parameter structure by excluding all cobra options
solverParams = rmfield(otherParams, intersect(cobraOptions, fieldnames(otherParams)));

% get the cobra parameters for each problem type.
[cobraParams, solverVarargin] = deal(struct());

for str = problemTypes
    cobraParams.(str{1}) = parseSolverParameters(str{1}, otherParams);
    tmp = [fieldnames(cobraParams.(str{1})), struct2cell(cobraParams.(str{1}))]';
    % get the varargin for each solver type
    solverVarargin.(str{1}) = [{solverParams}, tmp(:)'];
end

funParams = cellfun(@(x) parser.Results.(x), optArgin, 'UniformOutput', false);
end

function nameValueParams = inputParamsToCells(inputParams)
% convert the input parameters into 2 x N [name; value] cell array
[nameValueParams, paramErr] = deal({}, false);
for j = 1:2:numel(inputParams)
    if j < numel(inputParams)
        if ischar(inputParams{j})
            nameValueParams(:, end + 1) = columnVector(inputParams(j:(j + 1)));
        else
            paramErr = true;
            break
        end
    elseif isstruct(inputParams{j})
        nameValueParams = [nameValueParams, [columnVector(fieldnames(inputParams{j})), columnVector(struct2cell(inputParams{j}))]'];
    else
        paramErr = true;
    end
end
if paramErr
    error(sprintf(['Invalid Parameters supplied.\nParameters have to be supplied either as parameter/value pairs, or as struct.\n', ...
        'A combination is possible, if the last or first input argument is a struct, and all other arguments']))
end
end