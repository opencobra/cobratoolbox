function LPproblem = addCConstraintsToLPProblem(LPproblem,model,Sstart)
% Adds constraints stored in the model to the given LPproblem.
% The constraints are of the Form: C * v dsense d
% USAGE:
%    LPproblem = addCConstraintsToLPProblem(LPproblem,model,Sstart)
%
% INPUTS:
%
%    LPproblem:     The problem to add the constraints to. Must have at
%                   least the following fields:
%                   * csense : Constraint senses.
%                   * b : Right hand side values.
%                   * A : Constraint Matrix.
%    model:         The model to extract the constraints from. The model
%                   must have all of the following fields:
%                   * model.C : The constraint matrix must have the
%                               following properties: 
%                               size(model.C,2) <= size(LPproblem.A,2) - (SStart - 1)
%                   * model.d : The right hand side vector of the constraint
%                   * model.dsense : A char vector for the the directionality of the constraint
%                   * model.ctrs : A cell array of identifiers of the constraints
% OPTIONAL INPUTS:
%    
%    Sstart:        The Column at which the Constraints should be inserted
%                   The Constraint matrix will be added starting in this column
%                   and not extending over end of the A matrix. (Default 1)
%
%

modelfields = fieldnames(model);
ConstraintFields = {'C','d','dsense','ctrs'}; %All or none have to be present.
if ~all(ismember(ConstraintFields,modelfields))
    
    if any(ismember(ConstraintFields,modelfields))
        error('If any field for additional linear Constraints (%s) is present, all of those fields have to be present. For a explanation of those fields please Refer to the %s.\nYou can use verifyModelFields to determine what exactly is wrong.',...
            strjoin(ConstraintFields,'; '), hyperlink('https://opencobra.github.io/cobratoolbox/docs/COBRAModelFields.html','Model Field Definitions') );            
    end 
    %If there is no Constraint field, just return. Nothing to do.
    return;
else
    %So we have all Constraint fields. Now check that the sizes are
    %correct.
    res = verifyModel(model,'restrictToFields',ConstraintFields,'simpleCheck',true,'silentCheck',true);
    if ~res
        error('Constraint fields (%s) were inconsistent with the %s.\nYou can use verifyModelFields to determine what exactly is wrong.',...
            strjoin(ConstraintFields,'; '), hyperlink('https://opencobra.github.io/cobratoolbox/docs/COBRAModelFields.html','Model Field Definitions'));
    end
end


if ~exist('SStart','var')
    SStart = 1;
end
[nCtrs,nCtrCols] = size(model.C);
[nRows,nCols] = size(LPproblem.A);
if ~(nCtrCols <= nCols - (SStart - 1))
    error('Cannot add a constraint matrix that is larger than the A matrix.')
end
ToAdd = sparse(nCtrs,nCols);
ToAdd(:,SStart:(SStart + nCtrCols -1)) = model.C;
LPproblem.A = [LPproblem.A;ToAdd];
LPproblem.b = [LPproblem.b; model.d];
LPproblem.csense = [LPproblem.csense;model.dsense];