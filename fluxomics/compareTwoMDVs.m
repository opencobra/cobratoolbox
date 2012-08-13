function [totalz,zscore] = compareTwoMDVs(mdv1,mdv2)
   
% Compare the 2 sets of mdvs
%
% totalz is the sum of all zscores
% zscore is the calculated difference for each mdv element distributed
%       across all the points
% mdv1,mdv2 each containing fields:
%        - mdv - the calculated mdv distribution converted from the idv
%        solved from each point contained in their respective samples sampX
%        - names - the names of the metabolites 
%        - ave - the average of each mdv element across all of the points
%        - stdev - the standard dev for each mdv element across all points
% Wing Choi 2/11/08



if (nargin < 2)
    disp '[totalz,zscore] = compareTwoMDVs(mdv1,mdv2)';
    return;
end

%Compute the mean and standard deviation of each mdv and then get a z-score 
% between them (=(mean1-mean2)/(sqrt(sd1^2+sd2^2))). 
%Add up all the z-scores (their absolute value) and have this function return 
% that value.

names = mdv1.names;
ave1 = mdv1.ave;
std1 = mdv1.stdev;
ave2 = mdv2.ave;
std2 = mdv2.stdev;
zscore = [];

%zscore = (ave1-ave2)./(sqrt(std1.^2+std2.^2));
a1 = zeros(length(ave1),1);
a1 = (a1+.02).^2;
zscore = (ave1-ave2)./(sqrt(std1.^2+std2.^2+a1));

% for l = 1:length(names)        
%     % sometimes we end up with zeroes for stdev if the mdvs are all exactly the same: i.e. zeroes.
%     if (isnan(zscore(l,1)))
%         disp(sprintf('nan found at %d th name',l));
%         disp('replacing it with a -1');
%         zscore(l,1) = -1;
%         mdv1
%         mdv1.names
%         mdv2
%         pause;
%     end
% end
totalz = sum(abs(zscore));
if isnan(totalz)
    totalz = -1;
end
%disp(sprintf('total Z-score is: %d',totalz));

return
end