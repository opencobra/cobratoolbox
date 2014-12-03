function selMat = selMatrix(selVec)
%selMatrix Create selection matrix from a selection vector
%
% selMat = selMatrix(selVec)
%
% If selVec = [1 0 0 1 0 0]
%
% selMat = [1 0 0 0 0 0
%            0 0 0 1 0 0]
%
% For reversible selections
%
% If selVec = [1 0 0 1 -1 0]
%
% selMat = [1 0 0 0  0 0
%            0 0 0 1 -1 0]
%
% Markus Herrgard 3/28/03

nVar = length(selVec);
if (sum(selVec == -1) == 0)
    
    nSel = sum(selVec);
    isel = [1:nSel];
    jsel = find(selVec);
    selMat = sparse(isel,jsel,ones(nSel,1),nSel,nVar);
    
else
    
    selFwInd = find(selVec == 1);
    selMat = sparse(length(selFwInd),nVar);
    for i = 1:length(selFwInd)
        selFwID = selFwInd(i);
        if (selVec(selFwID+1) == -1)
            selMat(i,selFwID) = 1;
            selMat(i,selFwID+1) = -1;
        else
            selMat(i,selFwID) = 1;    
        end
    end
    selMat = sparse(selMat);
    
end