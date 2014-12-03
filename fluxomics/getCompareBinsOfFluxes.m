function [output] = getCompareBinsOfFluxes(xglc,model,samplo,samphi,metabolites)

% compares the bins of fluxes between samplo and samphi
% calls compareBinsOfFluxes(xglc,model,sammin,sammax,metabolites)
%  samplo and samphi each contain samples in x.points
% Wing Choi 3/7/08

output = 0;

if (nargin < 4)
    disp '[output] = getCompareBinsOfFluxes(xglc,model,samplo,samphi,metabolites)'
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

% specify the #fluxes and #bins to work with.
bins = [ 100 40 ; 125 32 ; 200 20 ; 250 16 ; 300 13 ; 400 10 ; 1000 4 ];

for i = 1:7
    nflux = bins(i,1);
    nbins = bins(i,2);
    ol = getBinsOfFluxes(samplo,nflux,nbins);
    ou = getBinsOfFluxes(samphi,nflux,nbins);
    ome = compareBinsOfFluxes(xglc,model,ol,ou,metabolites);
    name = sprintf('n%d',nbins);
    output.data(i,1:length(ome.totalz)) = ome.totalz';
    output.atotalz(i,1) = mean(ome.totalz);
    output.std(i,1) = std(ome.totalz);
end

% get the single bin of 4000 run for compare.
sl.samps(1,1).points = samplo.points(:,1:4000);
su.samps(1,1).points = samphi.points(:,1:4000);
ome = compareBinsOfFluxes(xglc,model,sl,su,metabolites);
output.data(8,1) = ome.totalz(1,1);
output.atotalz(8,1) = ome.totalz(1,1);
output.std(8,1) = 0;
%[totalz,zscore,mdvs] = compareMultSamp(xGlc,x,samps);

%[totalz] = compareTwoSamp(xGlc,x,samp1,samp2,metabolite);

return
end