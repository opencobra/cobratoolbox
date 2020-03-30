function LPproblem = liftModel(model, BIG, printLevel,fileName,directory)
% Lifts a COBRA model with badly-scaled stoichiometric and
% coupling constraints of the form:
% :math:`max c*v`  subject to: :math:`Sv = 0, x, Cv <= 0`
% Converts it into a COBRA LPproblem structure, which can be used with
% solveCobraLP. Fluxes for the reactions should stay the same i.e. 
% sol.full(1:nRxns) should yield an optimal flux vector.
%
% USAGE:
%
%    LPproblem = liftModel(model, BIG, printLevel,fileName,directory)
%
% INPUTS:
%    model:     COBRA LPproblem Structure containing the original LP to be solved. The format of
%                   this struct is described in the documentation for `solveCobraLP.m`
%
% OPTIONAL INPUTS:
%    BIG:           A parameter the controls the largest entries that appear in the
%                   reformulated problem (default = 1000).
%    printLevel:    printLevel = 1 enables printing of problem statistics (default);
%                   printLevel = 0 silent
%    fileName:      name of th file to load
%    directory:     file directory (if `model` is empty, you can load it using `fileName` and `directory`)
%
%
% OUTPUTS:
%    LPproblem:         COBRA Structure contain the reformulated LP to be solved.
%
% .. Authors:
%       - Michael Saunders, saunders@stanford.edu
%       - Yuekai Sun, yuekai@stanford.edu, Systems Optimization Lab (SOL), Stanford University
%       - Ronan Fleming   (updated interface to take COBRA model structure)
%       - Thomas Pfau - Updated information, that the lifted problem is
%                       converted to a COBRA LP structure

if ~exist('BIG','var')
    BIG=1000;
end
if ~exist('printLevel','var')
    printLevel=1;
end
if exist('fileName','var') && exist('directory','var') && isempty(model)
    model = loadIdentifiedModel(fileName,directory);
end

%save original model
LPproblem = buildLPproblemFromModel(model);


% Assume constraint matrix is S if no A provided.
if ~isfield(LPproblem,'A')
    if isfield(LPproblem,'S')
        LPproblem.A = LPproblem.S;
    end
end

% Assume constraint S*v = b if csense not provided
if ~isfield(LPproblem,'csense')
    % If csense is not declared in the model, assume that all
    % constraints are equalities.
    LPproblem.csense(:,1) = 'E';
end

% Assume constraint S*v = 0 if b not provided
if ~isfield(LPproblem,'b')
    warning('LP problem has no defined b in S*v=b. b should be defined, for now we assume b=0')
    LPproblem.b=zeros(size(LPproblem.A,1),1);
end

% Assume max c'v s.t. S v = b if osense not provided
if ~isfield(LPproblem,'osense')
    LPproblem.osense = -1;
end

%call the LP reformulate script by Michael and Yuekai
LPproblem = reformulate(LPproblem, BIG, printLevel);

if exist('fileName','var') && exist('directory','var')
    save([directory filesep 'L_' fileName '.mat'],'LPproblem');
end
