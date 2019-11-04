function model = convertOldCouplingFormat(model, printLevel)
%Converts an old style model implementation of coupling constraints to a
%new style
%
% INPUT:
%    model:     model with model.A but without model.d   
% 
% OPTIONAL INPUT:
%    printLevel:    The verbosity level (0 (default) no messages >=1 warnings)
% OUTPUT:
%    model:     A COBRA model structure with the following fields
%
%                * `.S` - The stoichiometric matrix
%                * `.c` - Objective coeff vector
%                * `.lb` - Lower bound vector
%                * `.ub` - Upper bound vector              
%                  * `.b`: accumulation/depletion vector (default 0 for each metabolite).
%                  * `.C`: the Constraint matrix;
%                  * `.d`: the right hand side vector for C;
%                  * `.dsense`: the constraint sense vector;

if nargin < 2
    printLevel = 0;
end

 if isfield(model,'A') && isfield(model,'S')
    if printLevel >=1
        warning('The inserted Model contains an old style coupling matrix (A). The MAtrix will be converted into a Coupling Matrix (C) and fields will be adapted.')
    end
    nMets = size(model.S,1);
    % get the Constraint data
    C = model.A(nMets+1:end,:);     
    ctrs = columnVector(model.mets(nMets+1:end));    
    dsense =  columnVector(model.csense(nMets+1:end));
    d = columnVector(model.b(nMets+1:end));
    % set the constraint data
    model.C = C;
    model.ctrs = ctrs;
    model.dsense = dsense;
    model.d = d;
    % now, we assume, that those are the only modified fields, if not,
    % something is seriously broken.    
    model.mets = columnVector(model.mets(1:nMets));
    model.b = columnVector(model.b(1:nMets));
    model.csense = columnVector(model.csense(1:nMets));
    model = rmfield(model,'A');

end 