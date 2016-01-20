function [output] = compareBinsOfFluxes(xglc,model,sammin,sammax,metabolites)

% takes the overall sammin and sammax samples, bins them into
%   separate bin sizes and compares them, then compares the
%   results to the largest bin size.
% calls
% [totalz,zscore,mdv1,mdv2] =
% compareTwoSamp(xglc,model,samp1,samp2,measuredMetabolites)
%  sammin and sammax each contain bins of fluxes in x.samps(r,1).points
% Wing Choi 3/7/08

output = 0;

if (nargin < 4)
    disp '[output] = compareBinsOfFluxes(xglc,model,samplo,samphi,metabolites)'
    return;
end

if (nargin < 5)
    metabolites = [];
end

if (isempty(xglc))
    % random glucose
    %xglc = rand(64,1);
    %xglc = xglc/sum(xglc);
    %xglc = idv2cdv(6)*xglc;
    
    glucose = rand(8,1);
    glucose = glucose/sum(glucose);
    %glc = idv2cdv(6)*glc;

    % glc 1-6 = carbon 1-6
    % glc 7 = carbon 1+2 (really 5 and 6)
    % glc 8 = unlabeled
    % glc 9 = fully labeled
    glc = zeros(64,9);
    glc(1+1,1) = 1;
    glc(2+1,2) = 1;
    glc(4+1,3) = 1;
    glc(8+1,4) = 1;
    glc(16+1,5) = 1;
    glc(32+1,6) = 1;
    glc(32+16+1,7) = 1;
    glc(0+1,8) = 1;
    glc(63+1,9) = 1;

    xGlc = zeros(64,1);
    for i = 1:8
        xGlc = xGlc + glucose(i)*glc(:,i);
    end

    xglc = idv2cdv(6)*xGlc;

end

nbins = size(sammin.samps,1);
npoints = size(sammin.samps(1,1).points,2);

disp (sprintf('found %d samples in input',npoints));
disp (sprintf('numbins  : %d',nbins));

for bin = 1:nbins
    samp1.points = sammin.samps(bin,1).points;
    samp2.points = sammax.samps(bin,1).points;
    [totalz,zscore,mdv1,mdv2] = compareTwoSamp(xglc,model,samp1,samp2,metabolites);
    output.totalz(bin,1) = totalz;
end

return
end