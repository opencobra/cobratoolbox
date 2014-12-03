function matchNew = reassignFwBwMatch(match,selVec)
%reassingFwBwMatch Reassing forward-backward matches when modifying an
%irreversible model
%
% matchNew = reassignFwBwMatch(match,selVec)
%
%INPUTS
% match     Forward-backwards mapping vector
% selVec    Selection vector marking reactions to remap
%
%OUTPUT
% matchNew  Modified forward-backwards mapping vector
%
% Markus Herrgard 11/3/05

% Create an index map from the old indices to new ones
% If selVec = [1 0 0 1 1]
% indexMap = [1 0 0 2 3];
indexMap = selVec*1.0;
indexMap(selVec==1) = [1:sum(selVec)];

matchNew = [];
for i = 1:length(match)
  if (selVec(i)==1)
        if (match(i) > 0)
            if (selVec(match(i)) == 1)
                matchNew(end+1) = indexMap(match(i));         
            else
                matchNew(end+1) = 0;
            end
        else
            matchNew(end+1) = 0;
        end
    end
end    
matchNew = matchNew';
