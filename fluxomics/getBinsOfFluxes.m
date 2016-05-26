function [output] = getBinsOfFluxes(samp,numfluxes,numbins)

% take a samp.points fluxes and bin them by numfluxes (remainder not used)
%     or divide up in to bins of fluxes by numbins (remainder not used)
%  sample each bin of fluxes and compare the differences between them.
%
% Wing Choi 3/7/08

output = 0;

if (nargin < 1)
    disp '[output] = compareBinsOfFluxes(samp,numfluxes,numbins)'
    return;
end

if (nargin < 2)
    % default to numfluxes to 100
    numfluxes = 100;
    numbins = [];
end

if (nargin < 3)
    % default to numbins to empty
    numbins = [];
end

npoints = size(samp.points,2);
disp (sprintf('found %d samples in input',npoints));
if (npoints < 200)
    disp 'must have at least 200 points in sample for processing';
    return;
end

if (isempty(numfluxes))
    % use numbins by default here.
    numfluxes = 0;
    if (isempty(numbins))
        disp 'neither numfluxes and numbins params defined, setting numbins to 2';
        numbins = 2;        
    end
    if (numbins < 2) 
        disp 'numbins param invalid, setting numbins to 2';
        numbins = 2;
    end
else
    if (numfluxes <= 0)
        disp 'numfluxes param invalid, using numbins = 2 instead';
        numfluxes = 0;
        numbins = 2;
    else
        % use numfluxes by default here.
        if (numfluxes*numbins > npoints )
            disp 'both numfluxes and numbins params defined, using numfluxes param by default';
            numbins = 0;
        end
    end    
end


if (numbins < 2)
    numbins = 2;
end
  
if (numfluxes > 0)
    % divide by numfluxes
    if (numfluxes*numbins > npoints)
        numbins = floor(npoints/numfluxes);
    end
    if (numbins < 2)
        numbins = 2;
        numfluxes = floor(npoints/numbins);
        disp (sprintf('the number of bins is less than 2 for %d numfluxes and %d points in sample',numfluxes,npoints));
        disp (sprintf('setting the numfluxes to %d for 2 bins total',numfluxes));
    end
else
    % divide by numbins
    numfluxes = floor(npoints/numbins);
    if (numfluxes < 100)
        numfluxes = 100;
        numbins = floor(npoints/numfluxes);
        disp (sprintf('given %d numbins for %d points, there are less than 100 numfluxes per bin',numbins,npoints));
        disp (sprintf('setting the numfluxes to 100 for %d bins total',numbins));
    end
end

disp (sprintf('numfluxes: %d',numfluxes));
disp (sprintf('numbins  : %d',numbins));

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

xGlc = idv2cdv(6)*xGlc;

samps = [];

count = 1;
for c = 1:numfluxes:(numfluxes*numbins)
    disp (sprintf('column %d',c));
    samps(count,1).points = samp.points(:,c:c+numfluxes-1);
    count = count+1;
end

%s = [];
%s(1,1).points = samp.points(:,1:4000);
%[totalz,zscore,mdvs] = compareMultSamp(xGlc,x,samps);

%[totalz] = compareTwoSamp(xGlc,x,samp1,samp2,metabolite);
output.samps = samps;
%output.mdvs = mdvs;

return
end