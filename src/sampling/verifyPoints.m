function [errorsA, errorsLUB, stuckPoints] = verifyPoints(sampleStruct)
% Verify that a set of points are in the solutoin space of `sampleStruct`.
% Typically, this method would be called to check a set of warmup points or
% points generated via `gpSampler`. Also verifies if points moved from
% warmup points.
%
% USAGE:
%
%    [errorsA, errorsLUB, stuckPoints] = verifyPoints(sampleStruct)
%
% INPUT:
%    sampleStruct:      LPProblem containing points and warmup points
%
% OUTPUTS:
%    errorsA:           Row index of the constraint in `sampleStruct` that
%                       is not consistent with the given points
%    errorsLUB:         Upper and lower bounds of the constraint + tolerance
%    stuckPoints:       Index of points which did not move.
%
% .. Authors:
%       - Ellen Tsai 2007
%       - Richard Que 12/1/09 Combined with checkWP.m

[warmupPts, points] = deal(sampleStruct.warmupPts, sampleStruct.points);
%above a check to see if warmup points moved
n=size(points,2);
len=size(n,1);
stuckPoints=zeros(0,1);

for i=1:n
    len(i,1)=norm(warmupPts(:,i)-points(:,i));
    if len(i,1)<10
        stuckPoints=[stuckPoints; i];
    end
end
minL = min(len);

%check to see if points are within solution space
[A,b,csense]=deal(sampleStruct.A,sampleStruct.b,sampleStruct.csense);
t=.01; %tolerance
npoints = size(points, 2);

LHS = A*points;
EIndex = (csense == 'E');
LIndex = (csense == 'L');
GIndex = (csense == 'G');

[errorsL(:,1), errorsL(:,2)] = find(LHS(LIndex,:) - b(LIndex)* ones(1, npoints) > t);
[errorsG(:,1), errorsG(:,2)] = find(b(GIndex)* ones(1, npoints) - LHS(GIndex,:)   > t);
[errorsE(:,1), errorsE(:,2)] = find( abs(LHS(EIndex,:) - b(EIndex)* ones(1, npoints))   > t);

errorsUB = find(points > sampleStruct.ub*ones(1,npoints) + t);
errorsLB = find(points < sampleStruct.lb*ones(1,npoints) - t);

errorsA = [errorsL; errorsG; errorsE];
errorsLUB = [errorsLB; errorsUB];

end
