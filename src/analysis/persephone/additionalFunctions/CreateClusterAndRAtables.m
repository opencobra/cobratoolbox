relAbun = readtable("WBM_relative_abundances.csv", 'preserveVariableNames', true);
regressionCoef = readtable("flux_results.xlsx", "Sheet","Table_15", "preserveVariableNames", true);
fluxValues = readtable('processed_fluxes.csv', "preserveVariableNames", true);

% Create clusters and their respective rel abund tables

rxns = {'DM_but[bc]'};


rxnInterest = [regressionCoef(:,1), regressionCoef(:, rxns)];

top = 5;

saveData = struct();
for i = 2:size(rxnInterest,2)
    regCoeff = rxnInterest(:, [1, i]);
    regCoeff = sortrows(regCoeff, 2,"descend");
    regCoeff(isnan(regCoeff.(2)),:) = [];

    topMicrobes = regCoeff(1:top,:);
    allMicrobes = topMicrobes{:,1};

    allComb = cell(0,5);

    % Make clusters
    for k = 2:top

        n = length(allMicrobes);
        aux = dec2base(0:n^k-1,n);
        aux2 = aux-'A';
        ind = aux2<0;
        aux2(ind) = aux(ind)-'0';
        aux2(~ind) = aux2(~ind)+10;

        aux2= aux2(all(diff(sort(aux2,2),[],2),2),:);
        [~,idx] = unique(sort(aux2,2),'first','rows');
        aux2 = aux2(idx,:);

        words = allMicrobes(aux2+1);
        if size(words,2) == 1
            words = words';
        end
        allComb(end+1:end+size(words,1), 1:size(words,2)) = words;
    end
    allComb = [cellstr(strcat('cluster',string(1:size(allComb,1))))',allComb];
    clusterAbundances = [];

    for n = 1:size(allComb,1)
        singleCombination = allComb(n,:);
        for m = 2:size(singleCombination,2)
            microbeInCombination = singleCombination{1,m};
            if ~isempty(microbeInCombination)
                abundance = relAbun.(string(microbeInCombination));
                abundance(isnan(abundance)) = 0;
            end
            if m == 2
                clusterAbundances(:, end+1) = abundance;
            else
                clusterAbundances(:, end) = clusterAbundances(:, end) + abundance;
            end
        end
    end
    name = matlab.lang.makeValidName(rxnInterest.Properties.VariableNames{i});
    saveData.(name) = clusterAbundances;
    saveData.(strcat(name,'clusterAbundance')) = allComb;
end

%% Perform regressions

fluxMicrobeCorr = {};

for i=1:size(rxns,1)
    rxnSpecificClusters = saveData.(matlab.lang.makeValidName(rxns{i}));
    for j=1:size(allComb,1)

        % Obtain flux value for rxn i ( rxn of interset)
        flux = fluxValues.(rxns{i});

        % Obtain relative abundances for taxon j
        singleClusterAbn = rxnSpecificClusters(:,j);


        % Perform linear regression on flux and relative abundances
        fit_microbe = fitlm(flux, singleClusterAbn);

        % Add R2 values to table
        fluxMicrobeCorr{i,j} = fit_microbe.Rsquared.Ordinary;
    end

end
%%
fluxMicrobeCorr = cell2table([allComb(:,1),fluxMicrobeCorr']);

fluxMicrobeCorr.Properties.VariableNames(2:end) = rxns;
fluxMicrobeCorr.Properties.VariableNames(1) = {'Species'};

%%
generateFluxMetBarPlots(fluxMicrobeCorr, rxns(2), 0, 'test', 'test2')
