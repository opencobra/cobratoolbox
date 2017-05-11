function restricedRowBool = getCorrespondingRows(S,rowBool,colBool,mode)
%returns a boolean vector that is true for a subset of the true rows in
%rowBool according to whether the rows 'exclusively' or 'inclusively'
%correspond to true entries in colBool
%
% Example
% S =
%     -1     0     0     0     0
%      2    -3     0     0     0
%      0     4    -5     0     0
%      0     0     6    -7     0
%      0     0     0     0     0
%
% rowBool = [1;1;1;1;1];
% colBool = [1;1;1;0;0];
%
% Therefore, the subset of rows and columns considered for inclusion are
%     -1     0     0
%      2    -3     0
%      0     4    -5
%      0     0     6
%      0     0     0
%
% If mode = 'exclusive' then restrictedRowBool corresponds to this subset
%     -1     0     0
%      2    -3     0
%      0     4    -5
% i.e subset of rowBool metabolites exclusively involved in the colBool
% reactions
%
% If mode = 'inclusive' then restrictedRowBool corresponds to this subset
%     -1     0     0
%      2    -3     0
%      0     4    -5
%      0     0     6
% i.e subset of rowBool metabolites involved in colBool reactions
%
% If mode ='partial' then restrictedRowBool corresponds to the extra rows
% with inclusive that are not present with exclusive.
%
%INPUT
% S         m x n stoichiometric matrix
% rowBool   m x 1 boolean vector 
% colBool   n x 1 boolean vector
% mode      'exclusive' or 'inclusive'
%
%OUTPUT
% restrictedRowBool     m x 1 boolean vector

%Ronan Fleming July 2016


if ~islogical(rowBool)
    error('rowBool must be a logical vector')
end
if ~islogical(colBool)
    error('colBool must be a logical vector')
end

[mlt,~]=size(S);
restricedRowBool=false(mlt,1);
switch mode
    case 'exclusive'
        %metatbolites exclusively involved in certain reactions
        restricedRowBool(rowBool)=     any(S(rowBool, colBool),2)...
                                    & ~any(S(rowBool,~colBool),2);
    case 'inclusive'
        %corresponding reactions involving certain metabolites
        restricedRowBool(rowBool) = any(S(rowBool, colBool),2);
    case 'partial'
        %metatbolites exclusively involved in certain reactions
        restricedRowBool(rowBool)=     any(S(rowBool, colBool),2)...
                                    & ~any(S(rowBool,~colBool),2);
                          
        %corresponding reactions involving certain metabolites
        restricedRowBool2=false(mlt,1);      
        restricedRowBool2(rowBool) = any(S(rowBool, colBool),2);
        %difference
        restricedRowBool= restricedRowBool2  & ~restricedRowBool;
end
        
 

