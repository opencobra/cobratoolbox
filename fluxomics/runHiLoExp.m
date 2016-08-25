function [experiment] = runHiLoExp(experiment)
% runHiLoExp
%   takes an experiment with the following structure 
%       and splits the sample space at the median of a target flux
%       solves the two spaces with a given sugar and compares the
%       resulting mdvs to provide a z-score.
%
%   experiment -      
%   model - S     = the stoichiometric matrix
%         - rxns  = array of reaction names, corresponding the S
%         - c     = optimization target 1, or -1
%         - ub,lb = upper and lower bounds of reactions
%   points = a #fluxes X #samples (~2000) array of the solution space
%         if missing or empty, will generate a sample
%   glcs = an array of sugars in isotopomer format, each column a separate sugar.
%           Should not be in MDV format.  Conversion is done automatically.
%         will default to generate 1 random sugar if set to []
%   targets = an array of cells with string for the reaction to 
%         split on the solution space, defaults to 'PGL'
%   thresholds = # targets X 1 array of thresholds
%   metabolites = an optional parameter fed to calcMDVfromSamp.m
%      which only calculates the MDVs for the metabolites listed in this
%      array.  e.g.
%      - optionally, metabolites can also be a structure of fragments
%   hilo = a #targets X #samples array of 0/1's, 0 id's the sample of
%      fluxes as the lo side and 1 id's the sample for the hi side.
%      hilo will only be calculated/recalculated if it's missing or 
%      if the targets have been replaced using the param list
%   mdvs = structure of mdv results
%        - (name) = name of the run = t + glc#
%                  e.g. t1, t2, glc# refers to the glc in the glcs array
%                 - mdv = array of mdv results
%                 - zscore = array of zscores from comparison btw the two mdvs
%                 - totalz
%        Note that the split of mdvs are not stored,
%           also since the only time mdvs should be regen'd is when glcs
%           has changed, but we have no way of knowing when this happens,
%           the user will have to manually empty out mdvs to have it
%           regenerated.
%   zscores = array of zscores from each run, targets X glcs
%   rscores = array of ridge scores from each run, targets X glcs
%
%   target is an optional string for a specific rxn to target.
%       if supplied, it will override and replace the targets field in the
%       experiment structure.
%   threshold is an optional number to apply on the solution space fluxes
%       if supplied, it will be applied to the hilo field and replace the
%       hilo splits.
%
%
%   outputs the experiment array.
%
%  basically, this code will loop thru one experiment
%   per sugar, per target
%
% Wing Choi 3/14/08

if (nargin < 1)
    disp '[experiment] = runHiLoExp(experiment,target,threshold)';
    return;
end

runzscore = true;      %binary flag for z-scores
runrscore = false;      %binary flag for r-scores
runkscore = false;      %binary flag for k-scores


%% if no model, exit with error.
% if model exists, but no points
%   then points are generated
%   existing mdvs in experiment, if any, are wiped
if (not(isfield(experiment,'model')))
    disp 'ERROR: input structure experiment lacks the requisite model in the model field';
    return;
end

model = experiment.model;
points = [];

if (isfield(experiment,'points'))
    points = experiment.points;
end

if (isempty(points))
    disp 'WARN: experiment.points is empty or missing';
    disp ' generating a sample and empty out mdvs';
    pointSample = generateRandomSample(model,2000);

    points = pointSample.point; 
    experiment.mfrac = pointSample.mf; 
    %points = m.points;
    experiment.points = points;
    %experiment.mfrac = mf;
    % recalculate the mdvs since we have new points.
    experiment.mdvs = [];
end


%% if the rxns array is inverted
%    display error message indicating that rxns array is inverted
dr = size(model.rxns,2);
if (dr > 1),
    disp 'ERROR: rxns array is inverted';
    return;
end

if (isfield(experiment,'metabolites'))
    metabolites = experiment.metabolites;
else
    metabolites = [];
end
    
%% if no sugar, generate a random one and warn the user.
%    existing mdvs are wiped
glcs = [];
if (isfield(experiment,'glcs'))
    glcs = experiment.glcs;
end
if (isempty(glcs))
    disp 'WARN: glcs not found, will generate 1 random sugar for experiment and empty out mdvs';
    glcs = getRandGlc();
    experiment.glcs = glcs;
    experiment.mdvs = [];
end

%% set glucose mixture name description;
glcsnames = {};
for i = 1:size(glcs,2)
    glcsnames{1,i} = '';
    glci = glcs(:,i);
    fglc = find(glci);
    for j = 1:length(fglc)
        if j ~=1
            glcsnames{1,i} = strcat(glcsnames{1,i}, '+');
        end
        if round(100*glci(fglc(j))) < 100
            glcsnames{1,i} = strcat(glcsnames{1,i}, num2str(round(100*glci(fglc(j)))), '% ');
        end
        if fglc(j)-1 == 0 % not labeled
            glcsnames{1,i} = strcat(glcsnames{1,i}, 'C0');
        elseif abs(log2(fglc(j)-1) - round(log2(fglc(j)-1)))<1e-8 % if it's a perfect power
            glcsnames{1,i} = strcat(glcsnames{1,i}, 'C', num2str(6-round(log2(fglc(j)-1))) );
        elseif fglc(j)-1 == 32+16 % C12
            glcsnames{1,i} = strcat(glcsnames{1,i}, 'C12');
        elseif fglc(j)-1 == 63 % fully labeled
            glcsnames{1,i} = strcat(glcsnames{1,i}, 'CU');
        else
            glcsnames{1,i} = strcat(glcsnames{1,i}, '#', dec2bin(fglc(j)-1, 6));
        end
    end
end
experiment.glcsnames = glcsnames;


%% if hilo is defined in experiment 
%    then inform user and error out
if (not(isfield(experiment,'hilo')))
    disp 'ERROR: hilo field not found in input structure experiment';
    return;
else
    hilo = experiment.hilo;
end

ntarget = size(hilo,1);
nglc = size(glcs,2);


%% we don't care about the thresholds field from this point on
if (not(isfield(experiment,'mdvs')))
    experiment.mdvs = [];
end
mdvs = experiment.mdvs;
if (isempty(mdvs))
    disp('no mdvs found, recalculating mdvs and emptying out zscores');
    mdvs = struct;
    for iglc = 1:nglc
        fprintf('MDVS on glucose %d of %d\n',iglc, nglc);
        glc = glcs(:,iglc);
        % translate sugar from isotopomer to cuomer format
        if abs(sum(glc)-1)>1e-6 || any(glc <0)
            display('invalid glc.  needs to be idv');
            disp(iglc)
            glc
            pause;
        end

        mdv = calcMDVfromSamp(glc,experiment.points,metabolites);
        
        name = sprintf('t%d',iglc);
        mdvs.(name) = mdv;
    end
    experiment.mdvs = mdvs;
    experiment.zscores = [];
end

%% regen the zscores
if (not(isfield(experiment,'zscores')))
    experiment.zscores = [];
end
zscores = experiment.zscores;
if (isempty(zscores) && runzscore)
    disp('calculating zscores');
    for iglc = 1:nglc     
        fprintf('z-scores on glucose %d of %d\n',iglc, nglc);
        for itgt = 1:ntarget
%             target = char(targets(itgt));
            hl = hilo(itgt,:);
            name = sprintf('t%d',iglc);
            mdv = mdvs.(name);
            [hiset,loset] = splitMDVbyTarget(mdv,hl);
%             if ((size(loset,1)) ~= (size(hiset,1)))
%                 zscores(itgt,iglc) = -1;
%                 disp('problem with the hi or lo set, cannot calculate zscore');
%                 continue;
%             end
            mdv1.names = mdv.names;
            mdv1.ave = mean(loset,2);
            mdv1.stdev = std(loset,0,2);
            mdv2.ave = mean(hiset,2);
            mdv2.stdev = std(hiset,0,2);

            [totalz,zscore] = compareTwoMDVs(mdv1,mdv2);
            zscores(itgt,iglc) = totalz;
        end
    end
    experiment.zscores = zscores;
end


%% regen the ridge score

if (not(isfield(experiment,'rscores')))
    experiment.rscores = [];
end
rscores = experiment.rscores;
if (isempty(rscores) && runrscore)
    disp('calculating ridge scores');
    for iglc = 1:nglc        
        fprintf('r-scores on glucose %d of %d\n',iglc, nglc);
        for itgt = 1:ntarget
            hl = hilo(itgt,:)';
            name = sprintf('t%d',iglc);
            mdv = mdvs.(name).mdv;
            rscore = score_ridge(mdv,hl);
            rscores(itgt,iglc) = rscore;
        end
    end
    experiment.rscores = rscores;
end

%% regen the KS score
if (not(isfield(experiment,'kscores')))
    experiment.kscores = [];
end
kscores = experiment.kscores;
if (isempty(kscores) && runkscore)
    disp('calculating KS scores');
    for iglc = 1:nglc        
        fprintf('KS-scores on glucose %d of %d\n',iglc, nglc);
        for itgt = 1:ntarget
            hl = hilo(itgt,:)';
            name = sprintf('t%d',iglc);
            mdv = mdvs.(name).mdv;
            kscore = score_KS(mdv,hl);
            kscores(itgt,iglc) = kscore;
        end
    end
    experiment.kscores = kscores;
end

return;

end


%% findIndexToTarget
%
% function [targetind] = findIndexToTarget(model,target)
% 
% % Given a model, find the index to the target in the model.rxns
% 
% d = size(model.c);
% %find index to target flux
% found = false;
% for r = 1:d(1),
%     if ~isempty(findstr(char(model.rxns(r)),target))
%         found = true;
%         break;
%     end
% end
% if (~found)
%     disp(sprintf('could not locate %s flux',target));
%     targetind = -1;
%     return;
% end
% targetind = r;
% disp(sprintf('found target flux for %s at: %d',target,targetind));
% 
% return
% end

%% splitMDVbyTarget
%
function [hiset,loset] = splitMDVbyTarget(mdv,hilo)

% Given an mdv set and a hilo discriminator, split the 
%   mdvset into 2 sets: a lo and hi set each with numinset cols.
hiset = mdv.mdv(:,hilo==1);
loset = mdv.mdv(:,~hilo);
return;
% nmdv = size(mdv.mdv,2);
% 
% hisetcount = 0;
% losetcount = 0;
% hiset = [];
% loset = [];
% mdva = mdv.mdv;
% mdvnan = mdv.mdvnan;
% cnan = size(mdvnan,2);
% 
% % if ((2*numinset) > nmdv)
% %     disp('WARN: insufficient number of points to cover split into hi and lo set');
% % end
% 
% 
% 
% for i = 1:nmdv
%     if (cnan >= i)
%         % do nan check only if nan array is larger than i index
%         if (sum(isnan(mdvnan(:,i))) > 1)
%             continue;
%         end
%     end
%     if (hilo(1,i) == 1)
%         if (hisetcount <= numinset)
%             hisetcount = hisetcount + 1;
%             hiset(:,hisetcount) = mdva(:,i);
%         end
%     else
%         if (losetcount <= numinset)
%             losetcount = losetcount + 1;
%             loset(:,losetcount) = mdva(:,i);
%         end
%     end
%     if ((hisetcount >= numinset) && (losetcount >= numinset))
%         break;
%     end
% end
%     
% % might have read thru the entire set but lots of nan for mdv's
% if ((hisetcount < numinset) || (losetcount < numinset))
%     disp(sprintf('WARN: hisetcount = %d, losetcount = %d',hisetcount,losetcount));
% end

end