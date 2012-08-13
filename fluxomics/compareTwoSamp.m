function [totalz,zscore,mdv1,mdv2] = compareTwoSamp(xglc,model,samp1,samp2,measuredMetabolites)
   
% Compare the 2 sets of samples
% xglc is optional, a random sugar distribution is calculated if empty
% expects samp1 and samp2 to have a field named points containing
%      an array of sampled points
% expects model.rxns to contain a list of rxn names
% measuredMetabolites is an optional parameter fed to calcMDVfromSamp.m
%      which only calculates the MDVs for the metabolites listed in this
%      array.  e.g.
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

%glc = zeros(62,1);
%glc = [.2 ;.8 ;glc];

if (nargin < 4)
    disp '[totalz,zscore,mdv1,mdv2] = compareTwoSamp(xglc,model,samp1,samp2,measuredMetabolites)';
    return;
end

if (nargin < 5)
    measuredMetabolites = [];
end

if (isempty(xglc))
    % random glucose
    xglc = rand(64,1);
    xglc = xglc/sum(xglc);
    xglc = idv2cdv(6)*xglc;
end

    % generate the translation index array
    %   can shave time by not regenerating this array on every call.
    xltmdv = zeros(1,4096);    
    for i = 1:4096
        xltmdv(i) = length(strrep(dec2base(i-1,2),'0',''));
    end

% calculate mdv for samp1 and samp2
[mdv1] = calcMDVfromSamp(samp1.points,measuredMetabolites);
[mdv2] = calcMDVfromSamp(samp2.points,measuredMetabolites);
[totalz,zscore] = compareTwoMDVs(mdv1,mdv2);

return
end

    
%Here's what the function does.
%Apply slvrXXfast to each point
%for each field in the output, apply iso2mdv to get a much shorter vector. 
%store all the mdv's for each point and for each metabolite in both sets.
%
%Compute the mean and standard deviation of each mdv and then get a z-score 
% between them (=(mean1-mean2)/(sqrt(sd1^2+sd2^2))). 
%Add up all the z-scores (their absolute value) and have this function return 
% that value.
%
%Intuitively what we're doing here is comparing the two sets based on 
% how different the mdv's appear. 
%We're going to see if different glucose mixtures result in different values. 
%I'm going to rewrite part of slvrXXfast so it doesn't return every metabolite 
% but only those we can actually measure, but for now just make it generic.
     
function mdv = myidv2mdv (idv,xltmdv)
 
    % generate the mdv
    len = length(idv);
    %disp(sprintf('idv is %d long',len));
    mdv = zeros(1,xltmdv(len)+1);
    %disp(sprintf('mdv is %d long',length(mdv)));
    for i = 1:len
        idx = xltmdv(i) + 1;
        %disp(sprintf('idx is %d, currently on %d',idx,i));
        mdv(idx) = mdv(idx) + idv(i); 
    end
    
return
end