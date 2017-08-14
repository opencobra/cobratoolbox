function adjustedAlberty2006 = adjustBaselinesInAlberty2006(Alberty2006, computedSpeciesData)
% Adjusts baseline for metabolites in Alberty's tables whose standard
% formation energies were not determined relative to the elements in their
% standard states. Sets baseline to group contribution estimate.
%
% USAGE:
%
%    adjustedAlberty2006 = adjustBaselinesInAlberty2006(Alberty2006, computedSpeciesData)
%
% INPUTS:
%    Alberty2006:
%    computedSpeciesData:
%
% OUTPUT:
%     adjustedAlberty2006:

includedMets = cell(length(computedSpeciesData),1);
for n = 1:length(computedSpeciesData)
   includedMets{n} = computedSpeciesData(n).abbreviation;
end

% Groups of metabolites with common baselines in Alberty
coas = {'coA', 'acetoacetylcoA', 'acetylcoA', 'coAglutathione', 'malylcoA', 'methylmalonylcoA', 'oxalylcoA', 'propanoylcoA', 'succinylcoA'};
fads = {'fadox', 'fadred', 'fadenzox', 'fadenzred'};
fmns = {'fmnox', 'fmnred'};
gthds = {'glutathioneox', 'glutathionered'};
nads = {'nadox', 'nadred', 'nicotinamideribonucleotide', 'nadpox', 'nadpred'};
rets = {'retinal', 'retinol'};
qs = {'ubiquinoneox', 'ubiquinonered'};

adjustedAlberty2006 = Alberty2006;

% Adjust coas
coaGCbasicdata = computedSpeciesData(1,strcmp(includedMets,'coa')).basicData;

for n = 1:length(adjustedAlberty2006)
    if strcmp(adjustedAlberty2006(1,n).abbreviation,'coA')
        albertyBasicSpeciesRow = find(adjustedAlberty2006(1,n).basicData(:,1) == 0);
        gcBasicSpecies = coaGCbasicdata((coaGCbasicdata(:,3) == -5),1);
        nHAdjustment = coaGCbasicdata((coaGCbasicdata(:,3) == -5),4) - adjustedAlberty2006(1,n).basicData(albertyBasicSpeciesRow,4);
        zAdjustment = coaGCbasicdata((coaGCbasicdata(:,3) == -5),3) - adjustedAlberty2006(1,n).basicData(albertyBasicSpeciesRow,3);

        for m = 1:size(adjustedAlberty2006(1,n).basicData,1)
            adjustedAlberty2006(1,n).basicData(m,1) = adjustedAlberty2006(1,n).basicData(m,1) + gcBasicSpecies;
            adjustedAlberty2006(1,n).basicData(m,2) = nan;
            adjustedAlberty2006(1,n).basicData(m,4) = adjustedAlberty2006(1,n).basicData(m,4) + nHAdjustment;
            adjustedAlberty2006(1,n).basicData(m,3) = adjustedAlberty2006(1,n).basicData(m,3) + zAdjustment;

        end

    end

end

for n = 2:length(coas)
    for m = 1:length(adjustedAlberty2006)
        if  strcmp(adjustedAlberty2006(1,m).abbreviation, coas{n})
            for k = 1:size(adjustedAlberty2006(1,m).basicData,1)
                adjustedAlberty2006(1,m).basicData(k,1) = adjustedAlberty2006(1,m).basicData(k,1) + gcBasicSpecies;
                adjustedAlberty2006(1,m).basicData(k,2) = nan;
                adjustedAlberty2006(1,m).basicData(k,4) = adjustedAlberty2006(1,m).basicData(k,4) + nHAdjustment;
                adjustedAlberty2006(1,m).basicData(k,3) = adjustedAlberty2006(1,m).basicData(k,3) + zAdjustment;

            end

        end

    end

end


% Adjust fads
fadGCbasicdata = computedSpeciesData(1,strcmp(includedMets,'fad')).basicData;

for n = 1:length(adjustedAlberty2006)
    if strcmp(adjustedAlberty2006(1,n).abbreviation,'fadox')
        albertyBasicSpeciesRow = find(adjustedAlberty2006(1,n).basicData(:,1) == 0);
        gcBasicSpecies = fadGCbasicdata((fadGCbasicdata(:,3) == adjustedAlberty2006(1,n).basicData(albertyBasicSpeciesRow,3)),1);
        nHAdjustment = fadGCbasicdata((fadGCbasicdata(:,3) == adjustedAlberty2006(1,n).basicData(albertyBasicSpeciesRow,3)),4) - adjustedAlberty2006(1,n).basicData(albertyBasicSpeciesRow,4);

        for m = 1:size(adjustedAlberty2006(1,n).basicData,1)
            adjustedAlberty2006(1,n).basicData(m,1) = adjustedAlberty2006(1,n).basicData(m,1) + gcBasicSpecies;
            adjustedAlberty2006(1,n).basicData(m,2) = nan;
            adjustedAlberty2006(1,n).basicData(m,4) = adjustedAlberty2006(1,n).basicData(m,4) + nHAdjustment;

        end

    end

end

for n = 2:length(fads)
    for m = 1:length(adjustedAlberty2006)
        if  strcmp(adjustedAlberty2006(1,m).abbreviation, fads{n})
            for k = 1:size(adjustedAlberty2006(1,m).basicData,1)
                adjustedAlberty2006(1,m).basicData(k,1) = adjustedAlberty2006(1,m).basicData(k,1) + gcBasicSpecies;
                adjustedAlberty2006(1,m).basicData(k,2) = nan;
                adjustedAlberty2006(1,m).basicData(k,4) = adjustedAlberty2006(1,m).basicData(k,4) + nHAdjustment;

            end

        end

    end

end


% Adjust fmns
fmnGCbasicdata = computedSpeciesData(1,strcmp(includedMets,'fmn')).basicData;

for n = 1:length(adjustedAlberty2006)
    if strcmp(adjustedAlberty2006(1,n).abbreviation,'fmnox')
        albertyBasicSpeciesRow = find(adjustedAlberty2006(1,n).basicData(:,1) == 0);
        gcBasicSpecies = fmnGCbasicdata((fmnGCbasicdata(:,3) == adjustedAlberty2006(1,n).basicData(albertyBasicSpeciesRow,3)),1);
        nHAdjustment = fmnGCbasicdata((fmnGCbasicdata(:,3) == adjustedAlberty2006(1,n).basicData(albertyBasicSpeciesRow,3)),4) - adjustedAlberty2006(1,n).basicData(albertyBasicSpeciesRow,4);


        for m = 1:size(adjustedAlberty2006(1,n).basicData,1)
            adjustedAlberty2006(1,n).basicData(m,1) = adjustedAlberty2006(1,n).basicData(m,1) + gcBasicSpecies;
            adjustedAlberty2006(1,n).basicData(m,2) = nan;
            adjustedAlberty2006(1,n).basicData(m,4) = adjustedAlberty2006(1,n).basicData(m,4) + nHAdjustment;

        end

    end

end

for n = 2:length(fmns)
    for m = 1:length(adjustedAlberty2006)
        if  strcmp(adjustedAlberty2006(1,m).abbreviation, fmns{n})
            for k = 1:size(adjustedAlberty2006(1,m).basicData,1)
                adjustedAlberty2006(1,m).basicData(k,1) = adjustedAlberty2006(1,m).basicData(k,1) + gcBasicSpecies;
                adjustedAlberty2006(1,m).basicData(k,2) = nan;
                adjustedAlberty2006(1,m).basicData(k,4) = adjustedAlberty2006(1,m).basicData(k,4) + nHAdjustment;

            end

        end

    end

end


% Adjust gthds
gthdGCbasicdata = computedSpeciesData(1,strcmp(includedMets,'gthox')).basicData;

for n = 1:length(adjustedAlberty2006)
    if strcmp(adjustedAlberty2006(1,n).abbreviation,'glutathioneox')
        albertyBasicSpeciesRow = find(adjustedAlberty2006(1,n).basicData(:,1) == 0);
        gcBasicSpecies = gthdGCbasicdata((gthdGCbasicdata(:,3) == adjustedAlberty2006(1,n).basicData(albertyBasicSpeciesRow,3)),1);
        nHAdjustment = gthdGCbasicdata((gthdGCbasicdata(:,3) == adjustedAlberty2006(1,n).basicData(albertyBasicSpeciesRow,3)),4) - adjustedAlberty2006(1,n).basicData(albertyBasicSpeciesRow,4);


        for m = 1:size(adjustedAlberty2006(1,n).basicData,1)
            adjustedAlberty2006(1,n).basicData(m,1) = adjustedAlberty2006(1,n).basicData(m,1) + gcBasicSpecies;
            adjustedAlberty2006(1,n).basicData(m,2) = nan;
            adjustedAlberty2006(1,n).basicData(m,4) = adjustedAlberty2006(1,n).basicData(m,4) + nHAdjustment;

        end

    end

end

for n = 2:length(gthds)
    for m = 1:length(adjustedAlberty2006)
        if  strcmp(adjustedAlberty2006(1,m).abbreviation, gthds{n})
            for k = 1:size(adjustedAlberty2006(1,m).basicData,1)
                adjustedAlberty2006(1,m).basicData(k,1) = (adjustedAlberty2006(1,m).basicData(k,1) + gcBasicSpecies)/2;
                adjustedAlberty2006(1,m).basicData(k,2) = nan;
                adjustedAlberty2006(1,m).basicData(k,4) = adjustedAlberty2006(1,m).basicData(k,4) + nHAdjustment;

            end

        end

    end

end


% Adjust nads
nadGCbasicdata = computedSpeciesData(1,strcmp(includedMets,'nad')).basicData;

for n = 1:length(adjustedAlberty2006)
    if strcmp(adjustedAlberty2006(1,n).abbreviation,'nadox')
        albertyBasicSpeciesRow = find(adjustedAlberty2006(1,n).basicData(:,1) == 0);
        gcBasicSpecies = nadGCbasicdata((nadGCbasicdata(:,3) == adjustedAlberty2006(1,n).basicData(albertyBasicSpeciesRow,3)),1);
        nHAdjustment = nadGCbasicdata((nadGCbasicdata(:,3) == adjustedAlberty2006(1,n).basicData(albertyBasicSpeciesRow,3)),4) - adjustedAlberty2006(1,n).basicData(albertyBasicSpeciesRow,4);

        for m = 1:size(adjustedAlberty2006(1,n).basicData,1)
            adjustedAlberty2006(1,n).basicData(m,1) = adjustedAlberty2006(1,n).basicData(m,1) + gcBasicSpecies;
            adjustedAlberty2006(1,n).basicData(m,2) = nan;
            adjustedAlberty2006(1,n).basicData(m,4) = adjustedAlberty2006(1,n).basicData(m,4) + nHAdjustment;

        end

    end

end

for n = 2:length(nads)
    for m = 1:length(adjustedAlberty2006)
        if  strcmp(adjustedAlberty2006(1,m).abbreviation, nads{n})
            for k = 1:size(adjustedAlberty2006(1,m).basicData,1)
                adjustedAlberty2006(1,m).basicData(k,1) = adjustedAlberty2006(1,m).basicData(k,1) + gcBasicSpecies;
                adjustedAlberty2006(1,m).basicData(k,2) = nan;
                adjustedAlberty2006(1,m).basicData(k,4) = adjustedAlberty2006(1,m).basicData(k,4) + nHAdjustment;

            end

        end

    end

end


% Adjust rets
retGCbasicdata = computedSpeciesData(1,strcmp(includedMets,'retinal')).basicData;

for n = 1:length(adjustedAlberty2006)
    if strcmp(adjustedAlberty2006(1,n).abbreviation,'retinal')
        albertyBasicSpeciesRow = find(adjustedAlberty2006(1,n).basicData(:,1) == 0);
        gcBasicSpecies = retGCbasicdata((retGCbasicdata(:,3) == adjustedAlberty2006(1,n).basicData(albertyBasicSpeciesRow,3)),1);
        nHAdjustment = retGCbasicdata((retGCbasicdata(:,3) == adjustedAlberty2006(1,n).basicData(albertyBasicSpeciesRow,3)),4) - adjustedAlberty2006(1,n).basicData(albertyBasicSpeciesRow,4);

        for m = 1:size(adjustedAlberty2006(1,n).basicData,1)
            adjustedAlberty2006(1,n).basicData(m,1) = adjustedAlberty2006(1,n).basicData(m,1) + gcBasicSpecies;
            adjustedAlberty2006(1,n).basicData(m,2) = nan;
            adjustedAlberty2006(1,n).basicData(m,4) = adjustedAlberty2006(1,n).basicData(m,4) + nHAdjustment;

        end

    end

end

for n = 2:length(rets)
    for m = 1:length(adjustedAlberty2006)
        if  strcmp(adjustedAlberty2006(1,m).abbreviation, rets{n})
            for k = 1:size(adjustedAlberty2006(1,m).basicData,1)
                adjustedAlberty2006(1,m).basicData(k,1) = adjustedAlberty2006(1,m).basicData(k,1) + gcBasicSpecies;
                adjustedAlberty2006(1,m).basicData(k,2) = nan;
                adjustedAlberty2006(1,m).basicData(k,4) = adjustedAlberty2006(1,m).basicData(k,4) + nHAdjustment;

            end

        end

    end

end


% Adjust qs
qGCbasicdata = computedSpeciesData(1,strcmp(includedMets,'q10')).basicData;

for n = 1:length(adjustedAlberty2006)
    if strcmp(adjustedAlberty2006(1,n).abbreviation,'ubiquinoneox')
        albertyBasicSpeciesRow = find(adjustedAlberty2006(1,n).basicData(:,1) == 0);
        gcBasicSpecies = qGCbasicdata((qGCbasicdata(:,3) == adjustedAlberty2006(1,n).basicData(albertyBasicSpeciesRow,3)),1);
        nHAdjustment = qGCbasicdata((qGCbasicdata(:,3) == adjustedAlberty2006(1,n).basicData(albertyBasicSpeciesRow,3)),4) - adjustedAlberty2006(1,n).basicData(albertyBasicSpeciesRow,4);

        for m = 1:size(adjustedAlberty2006(1,n).basicData,1)
            adjustedAlberty2006(1,n).basicData(m,1) = adjustedAlberty2006(1,n).basicData(m,1) + gcBasicSpecies;
            adjustedAlberty2006(1,n).basicData(m,2) = nan;
            adjustedAlberty2006(1,n).basicData(m,4) = adjustedAlberty2006(1,n).basicData(m,4) + nHAdjustment;

        end

    end

end

for n = 2:length(qs)
    for m = 1:length(adjustedAlberty2006)
        if  strcmp(adjustedAlberty2006(1,m).abbreviation, qs{n})
            for k = 1:size(adjustedAlberty2006(1,m).basicData,1)
                adjustedAlberty2006(1,m).basicData(k,1) = adjustedAlberty2006(1,m).basicData(k,1) + gcBasicSpecies;
                adjustedAlberty2006(1,m).basicData(k,2) = nan;
                adjustedAlberty2006(1,m).basicData(k,4) = adjustedAlberty2006(1,m).basicData(k,4) + nHAdjustment;

            end

        end

    end

end

end
