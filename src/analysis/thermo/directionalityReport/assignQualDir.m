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
%                * .S - `m x n` stoichiometric matrix
%                * .lb - `n x 1` lower flux bounds
%                * .ub - `n x 1` upper flux bounds
%
% OUTPUTS:
%    model:    structure with added field:
%
%                * .qualDir - `n x 1` qualitative directionality assignment:
%                  1 for reactions that are irreversible in the forward direction,
%                  -1 for reactions that are irreversible in the reverse direction,
%                  0 for reversible reactions

[mlt,nlt]=size(model.S);

model.qualDir=false(nlt,1);

if any(model.lb>model.ub)
    error('Model bounds are inconsistent');
end

model.qualDir(model.lb>=0 & model.ub>=0)=1;
model.qualDir(model.lb<0 & model.ub<0)=-1;
model.qualDir(model.lb<0 & model.ub>0)=0;

end
