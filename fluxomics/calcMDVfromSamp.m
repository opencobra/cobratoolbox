function [output] = calcMDVfromSamp(glc,points,experiment)

npoints = size(points,2);
fprintf('found %d samples in input\n',npoints);

% hard set for # of samples we will convert to mdv.
% npoints = 2;
fprintf('processing %d samples\n',npoints);

output = struct;
mdv = [];

if isempty(glc)
    glc = experiment.inputfrag;
else
    glc = convert_input(glc);
end
if isempty(experiment)
    o = slvrEMU_fast(points(:,1), glc);
    names = fields(o);
else
    names = fields(experiment.fragments);
end

parfor c = 1:npoints 
    o = slvrEMU_fast(points(:,c), glc);
    tmdv = zeros(0,1);
    if ~ isempty(experiment)
        for l = 1:length(names)
            name = names{l};
            tname = experiment.fragments.(name).metfrag;
            tresult = o.(tname);
            tmdv = [tmdv; tresult];
        end
    else
        for l = 1:length(names)
            tresult = o.(names{l});
            tmdv = [tmdv; tresult];
        end
    end
    mdv(:,c) = tmdv;
end

o = slvrEMU_fast(points(:,1), glc);
mdvnames = {};
k = 1;
for l = 1:length(names)
    name = names{l};
    if isempty(experiment)
        tname = name; 
    else
        tname = experiment.fragments.(name).metfrag;
    end
    tresult = o.(tname);
    for i = 1:length(tresult)
        newname = strcat(name, num2str(i-1));
        mdvnames{k,1} = newname;
        k = k+1;
    end
end
            

%Here's what the function does.
%Apply slvrEMU_fast to each point
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
%I'm going to rewrite part of slvrEMU_fast.m so it doesn't return every metabolite 
% but only those we can actually measure, but for now just make it generic.

%calculate mean and stdev for each metabolite
ave = mean(mdv,2);
stdev = std(mdv,0,2);
   
output.mdv = mdv;
output.names = mdvnames;
output.ave = ave;
output.stdev = stdev;
if ~isempty(experiment)
    output.xglc = experiment.input;
end

return
end