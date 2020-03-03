function OK = writeLPProblem(LPProblem, varargin)
% Creates an MPS (Mathematical Programming System) format ascii file representing the Linear Programming problem given by LPProblem.
%
% USAGE:
%
%    OK = convertCobraLP2mps(LPProblem, varargin)
%
% INPUT:
%    LPproblem:    Structure containing the following fields describing the LP problem to be solved
%
%                    * .A - LHS matrix
%                    * .b - RHS vector
%                    * .c - Objective coeff vector
%                    * .lb - Lower bound vector
%                    * .ub - Upper bound vector
%                    * .osense - Objective sense (max=-1, min=+1)
%                    * .csense - Constraint senses, a string containting the constraint sense for
%                      each row in A ('E', equality, 'G' greater than, 'L' less than).
%
% OPTIONAL INPUT
%    varargin:     a list of parameter/value pairs with the following parameters:
%
%                    * 'fileName' - Name of the output file (e.g. 'Problem.mps')
%                    * 'solverParams' - A struct containing the solver parameters if provided
%                    * 'outputFormat' - Currently only 'mps' is supported (and default)
%                    * 'writeMatrix' - Only write the Matrix, not the full problem (default
%                      true), will be ignored if solver params are provided
%
% OUTPUT:
%    OK:           1 if saving is success, 0 otherwise
%
% EXAMPLE:
%    Write a model to a specified fileName:
%    OK = convertCobraLP2mps(LPProblem, 'fileName', 'AFileName.ext')
%
%    Write a model problem using the specified solverParams
%    OK = convertCobraLP2mps(LPProblem, 'solverParams', Params)
%
% .. Authors:
%       - Ronan M.T. Fleming: 7 Sept 09
%       - Bruno Luong 03 Sep 2009  Uses MPS format exporting tool
%       http://www.mathworks.com/matlabcentral/fileexchange/19618
%
% ..
%    The MPS (Mathematical Programming System) file format was introduced by
%    IBM in 1970s, but has also been accepted by most subsequent linear
%    programming codes. To learn about MPS format, please see:
%    http://lpsolve.sourceforge.net/5.5/mps-format.htm


optionalArgumentList = {'problemName', 'fileName', 'solverParams', 'outputFormat'};
acceptedTypes = {'mps'};

if numel(varargin) > 0
    % This is only relevant, if we have more than 2 non Required input
    % variables.
    % if this is apparent, we need to check the following:
    % 1. is the 3rd vararginargument a cell array and is the second argument
    % NOT compSymbols or compNames, if the second argument is NOT a char,
    if ischar(varargin{1}) && ~any(ismember(varargin{1}, optionalArgumentList))
        % We assume the old version to be used
        tempargin = cell(1, 2 * numel(varargin));
        % just replace the input by the options and replace varargin
        % accordingly
        for i = 1:numel(varargin)
            tempargin{2 * (i - 1) + 1} = optionalArgumentList{i};
            tempargin{2 * (i - 1) + 2} = varargin{i};
        end
        varargin = tempargin;
    end
end

[defaultCompSymbols, defaultCompNames] = getDefaultCompartmentSymbols();
parser = inputParser();
parser.addRequired('LPProblem', @isstruct);
parser.addParamValue('problemName', 'CobraLPProblem', @ischar);
parser.addParamValue('fileName', '', @ischar);
parser.addParamValue('outputFormat', 'mps', @(x) ischar(x) && any(strcmpi(acceptedTypes)));
parser.addParamValue('solverParams', struct(), @isstruct);
parser.addParamValue('writeMatrix', true, @(x) islogical(x) || isnumeric(x));

parser.parse(LPProblem, varargin{:})
solverParams = parser.Results.solverParams;
outputFormat = parser.Results.outputFormat;
name = parser.Results.problemName;
writeMatrix = parser.Results.writeMatrix;
if isempty(parser.Results.fileName)
    fileName = [name '.mps'];
else
    fileName = parser.Results.fileName;
    if isempty(regexp(fileName, '\.mps$'))
        fileName = [fileName '.mps'];
    end
end

% Setup the problem structure and additional fields.

if isfield(LPProblem, 'S') && ~isfield(LPProblem, 'A')
    LPProblem.A = LPProblem.S;
end

mlt = size(LPProblem.A, 1);
if ~isfield(LPProblem, 'csense')
    LPProblem.csense(1:mlt) = 'E';
end
if size(LPProblem.csense, 1) > size(LPProblem.csense, 2)
    LPProblem.csense = LPProblem.csense';
end

% Assume constraint S*v = 0 if b not provided
if ~isfield(LPProblem, 'b')
    warning('LP problem has no defined b in S*v=b. b should be defined, for now we assume b=0')
    LPProblem.b = zeros(size(LPProblem.A, 1), 1);
end

% Assume max c'v s.t. S v = b if osense not provided
if ~isfield(LPProblem, 'osense')
    LPProblem.osense = -1;
end

if ~isfield(LPProblem, 'vartype')
    LPProblem.vartype = [];
end
if ~isfield(LPProblem, 'x0')
    LPProblem.x0 = [];
end

[A, b, c, lb, ub, csense, osense, vartype, x0] = deal(LPProblem.A, LPProblem.b, LPProblem.c, LPProblem.lb, LPProblem.ub, LPProblem.csense, LPProblem.osense, LPProblem.vartype, LPProblem.x0);

switch outputFormat
    case 'mps'
        param = solverParams;
        if isfield(param, 'EleNames')
            EleNames = param.EleNames;
        else
            EleNames = '';
        end
        if isfield(param, 'EqtNames')
            EqtNames = param.EqtNames;
        else
            EqtNames = '';
        end
        if isfield(param, 'VarNames')
            VarNames = param.VarNames;
        else
            VarNames = '';
        end
        if isfield(param, 'EleNameFun')
            EleNameFun = param.EleNameFun;
        else
            EleNameFun = @(m)(['LE' num2str(m)]);
        end
        if isfield(param, 'EqtNameFun')
            EqtNameFun = param.EqtNameFun;
        else
            EqtNameFun = @(m)(['EQ' num2str(m)]);
        end
        if isfield(param, 'VarNameFun')
            VarNameFun = param.VarNameFun;
        else
            VarNameFun = @(m)(['X' num2str(m)]);
        end
        if isfield(param, 'PbName')
            PbName = param.PbName;
        else
            PbName = name;
        end
        if isfield(param, 'MPSfilename')
            MPSfilename = [param.MPSfilename '.mps'];
        else
            MPSfilename = fileName;
        end
        % split A matrix for L and E csense
        Ale = [A(csense == 'L', :); -A(csense == 'G', :)];
        ble = [b(csense == 'L'); -b(csense == 'G')];
        Aeq = A(csense == 'E', :);
        beq = b(csense == 'E');

        % create index of integer and binary variables
        intIndex = find(vartype == 'I');
        binaryIndex = find(vartype == 'B');

        %%%%Adapted from BuildMPS%%%%%
        [neq nvar] = size(Aeq);
        nle = size(Ale, 1);
        if isempty(EleNames)
            EleNames = arrayfun(EleNameFun, (1:nle), 'UniformOutput', false);
        end
        if isempty(EqtNames)
            EqtNames = arrayfun(EqtNameFun, (1:neq), 'UniformOutput', false);
        end
        if isempty(VarNames)
            VarNames = arrayfun(VarNameFun, (1:nvar), 'UniformOutput', false);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % http://www.mathworks.com/matlabcentral/fileexchange/19618-mps-format-exporting-tool/content/BuildMPS/BuildMPS.m
        % 31st Jan 2016, changed c to osense*c as most solvers assume minimisation
        if writeMatrix && any(ismember(parser.UsingDefaults, 'solverParams'))
            [Contain] = BuildMPS(Ale, ble, Aeq, beq, osense * c, lb, ub, PbName);
            OK = SaveMPS(fileName, Contain);
        else
            [solution] = BuildMPS(Ale, ble, Aeq, beq, osense * c, lb, ub, PbName, 'MPSfilename', MPSfilename, 'EleNames', EleNames, 'EqtNames', EqtNames, 'VarNames', VarNames, 'Integer', intIndex, 'Binary', binaryIndex);
            OK = ~isempty(solution);
        end
        % display([' > The .MPS file <', MPSfilename, '> has been written to ', pwd]);
end
