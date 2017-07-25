function model = assignQualDir(model)
% Assigns a qualitative direction to each reaction based on the upper and
% lower bounds
%
% USAGE:
%
%    model = assignQualDir(model)
%
% INPUTS:
%    model:    structure with fields:
%
%                * model.lb
%                * model.ub
%
% OUTPUTS:
%    model:    structure with fields:
%
%                * model.quantDir - Quantitative directionality assignments.
%
%                  * quantDir = 1 for reactions that are irreversible in the forward direction.
%                  * quantDir = -1 for reactions that are irreversible in the reverse direction.
%                  * quantDir = 0 for reversible reactions.

[mlt,nlt]=size(model.S);

model.qualDir=false(nlt,1);

if any(model.lb>model.ub)
    error('Model bounds are inconsistent');
end

model.qualDir(model.lb>=0 & model.ub>=0)=1;
model.qualDir(model.lb<0 & model.ub<0)=-1;
model.qualDir(model.lb<0 & model.ub>0)=0;

end
