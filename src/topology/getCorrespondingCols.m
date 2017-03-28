function restrictedColBool = getCorrespondingCols(S,rowBool,colBool,mode)
%returns a boolean vector that is true for a subset of the true cols in
%colBool according to whether the cols 'exclusively' or 'inclusively'
%correspond to true entries in rowBool
%
% Example
% S =
%     -1     0     0     0     0
%      2    -3     0     0     0
%      0     4    -5     0     0
%      0     0     6    -7     0
%      0     0     0     0     0
%
% rowBool = [1;1;1;0;0];
% colBool = [1;1;1;1;1];
%
% Therefore, the subset of rows and columns considered for inclusion are
%     -1     0     0     0     0
%      2    -3     0     0     0
%      0     4    -5     0     0
%
% If mode = 'exclusive' then restrictedColBool corresponds to this subset
%     -1     0
%      2    -3
%      0     4
% i.e. subset of colBool reactions exclusively involving rowBool metabolites
%
% If mode = 'inclusive' then restrictedColBool corresponds to this subset
%     -1     0     0
%      2    -3     0
%      0     4    -5
% i.e. subset of colBool reactions involving at least one rowBool metabolite
%
% If mode ='partial' then restrictedColBool corresponds to the extra cols
% with inclusive that are not present with exclusive.
%
%INPUT
% S         m x n stoichiometric matrix
% rowBool   m x 1 boolean vector
% colBool   n x 1 boolean vector
% mode      'exclusive' or 'inclusive' or 'partial'
%
%OUTPUT
% restrictedColBool     n x 1 boolean vector

%Ronan Fleming July 2016

if ~islogical(rowBool)
    error('rowBool must be a logical vector')
end
if ~islogical(colBool)
    error('colBool must be a logical vector')
end

[~,nlt]=size(S);
restrictedColBool=false(nlt,1);
switch mode
    case 'exclusive'
        %corresponding reactions exclusively involving certain metabolites
        restrictedColBool(colBool)=    any(S( rowBool,colBool),1)'...
                                    & ~any(S(~rowBool,colBool),1)';
    case 'inclusive'
        %corresponding reactions involving certain metabolites
        restrictedColBool(colBool)=any(S( rowBool,colBool),1)';

    case 'partial'
        %metatbolites exclusively involved in certain reactions
        restrictedColBool(colBool)=    any(S( rowBool,colBool),1)'...
                                    & ~any(S(~rowBool,colBool),1)';

        %corresponding reactions involving certain metabolites
        restricedColBool2=false(nlt,1);
        restricedColBool2(colBool)=any(S( rowBool,colBool),1)';
        %difference
        restrictedColBool= restricedColBool2  & ~restrictedColBool;
end
