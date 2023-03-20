function [summaryConc, outliers] = summaryConcentrations(cleanedData, param)
% function to summarise metabolite concentrations per group/perturbation
% (calculate mean and SD), function can detect and remove outliers before
% data is summarised (param.removeOutliers). Furthermore, function can map
% metabolite names into model IDs using either user specified metabolite
% lookup table (param.metLookupTable) or/and model structure (param.model).
%
% Required inputs:
%  cleanedData.Properties:
%  cleanedData.Properties.Properties:
%  cleanedData.Properties.VariableNames:
%  cleanedData.group:   
%  cleanedData.perturbation:
%  cleanedData.compound:
%  cleanedData.sample: 
%  cleanedData.concentration:
%       cleanedData          - metabolomics data in long format (output from
%                              mzQuality, required columns: sample, type,
%                              compound, concentration, cellLine or group,
%                              perturbation)
%
% Optional inputs:
%       param.model          - cobra model used to map metabolite to metss
%       param.metLookupTable - table with metabolite names and model
%                              identifiers to be mapped onto (required
%                              columns: ChemicalName, AlternativeName,
%                              Mets(containing metss)
%       param.excludeGroup   - specifies any groups to be excluded from the
%                              analysis (default: none)
%       param.group          - specify which groups are to be analysed (default:
%                              all unique groups specified in the cleanedData)
%       param.printLevel     - specifies if plots with median concentration
%                              values should be printed (0)
%       param.perturbation   - specifies perturbations to that should be
%                              summarised separately (default: all unique
%                              perturbations specified in the cleanedData)
%       param.removeOutliers - should outliers be found and removed from
%                              the dataset (0)
%   2021/12 Aga Wegrzyn

if ~isfield(param,'group') && ismember('group', cleanedData.Properties.VariableNames)
    param.group = unique(cleanedData.group);
end

if ~isfield(param,'perturbation') && ismember('perturbation', cleanedData.Properties.VariableNames)
    param.perturbation = unique(cleanedData.perturbation);
end

if ~isfield(param,'printLevel')
    param.printLevel = 0;
end

if ~isfield(param,'removeOutliers')
    param.removeOutliers = 0;
end

if isfield(param, 'excludeGroup')
    param.group = param.group(~ismember(param.group, param.excludeGroup));
end

sumConc = table(unique(cleanedData.compound));
sumConc.Properties.VariableNames(1) = "metabolite_bmfl";

% map metabolite names to (model) mets if metLookupTable and/or model are
% provided

if isfield(param, 'model') || isfield(param, 'metLookupTable')
    sumConc.mets = strings(length(sumConc.metabolite_bmfl),1);
    if isfield(param, 'model')
        model = param.model;
        mets = unique(sumConc.metabolite_bmfl);
        for i = 1:length(mets)
            ID = find(contains(sumConc.metabolite_bmfl, mets{i}));
            if ismember(lower(mets{i}), lower(model.metNames))
                allCompartments = model.mets(ismember(lower(model.metNames), lower(mets{i})));
                if any(contains(allCompartments, '[e]'))
                    sumConc.mets(ID) = allCompartments(contains(allCompartments, '[e]'));
                end
            elseif ismember(lower(regexprep(mets{i}, 'L-|D-|i-|-H2O', '', 'ignorecase')), lower(model.metNames))
                allCompartments = model.mets(ismember(lower(model.metNames), lower(regexprep(mets{i}, 'L-|D-|i-|-H2O', '', 'ignorecase'))));
                if any(contains(allCompartments, '[e]'))
                    sumConc.mets(ID) = allCompartments(contains(allCompartments, '[e]'));
                end
            else
                sumConc.mets(ID) = {''};
            end
        end
    end
    
    if isfield(param,'metLookupTable')
        metLookupTable = param.metLookupTable;
        mets = unique(sumConc.metabolite_bmfl);
        for i = 1:length(mets)
            ID = find(strcmp(sumConc.metabolite_bmfl, mets{i}));
            if isempty(sumConc.mets{ID}) && ismember(lower(regexprep(mets{i}, 'L-|D-|i-|-H2O', '', 'ignorecase')), lower(metLookupTable.ChemicalName))
                sumConc.mets(ID) = metLookupTable.Mets(ismember(lower(metLookupTable.ChemicalName), lower(regexprep(mets{i}, 'L-|D-|i-|-H2O', '', 'ignorecase'))));
                if ~ismember(sumConc.mets(ID), model.mets)
                    sumConc.mets(ID) = {''};
                end
            elseif isempty(sumConc.mets{ID}) && ismember(lower(regexprep(mets{i}, 'L-|D-|i-|-H2O', '', 'ignorecase')), lower(metLookupTable.AlternativeName))
                sumConc.mets(ID) = metLookupTable.Mets(ismember(lower(metLookupTable.AlternativeName), lower(regexprep(mets{i}, 'L-|D-|i-|-H2O', '', 'ignorecase'))));
                if ~ismember(sumConc.mets(ID), model.mets)
                    sumConc.mets(ID) = {''};
                end
            end
        end
    end
end

% if desired remove outlier samples (per group+perturbation) and plot median of all metabolite
% concentrations per sample
if param.removeOutliers
    outliers = [];
    medianTemp = table();
    medianTemp.sampleList = unique(cleanedData.sample);
    for i = 1:length(medianTemp.sampleList)
        IDs = find(cleanedData.sample == medianTemp.sampleList(i));
        medianTemp.group(i) = unique(cleanedData.group(IDs));
        medianTemp.perturbation(i) = unique(cleanedData.perturbation(IDs));
        medianTemp.median(i) = median(cleanedData.concentration(IDs),'omitnan');
    end
    
    for i=1:length(param.group)
        for j=1:length(param.perturbation)
            idx = find(medianTemp.perturbation == param.perturbation(j) & ...
                medianTemp.group == param.group(i));
            if ~isempty(idx)
                samples = medianTemp.sampleList(idx);
                out = isoutlier(log2(medianTemp.median(idx)));
                figure
                if any(out)
                    disp('Warning: following outlier samples detected and excluded from the summary:')
                    disp(samples(out))
                    outliers = [outliers; samples(out)];
                    idx2 = idx(out);
                    if param.printLevel == 1
                        x = 1:length(samples);
                        set(0, 'DefaultTextInterpreter','none')
                        plot(x,medianTemp.median(idx), "x",  ...
                            x(out),medianTemp.median(idx2), "o")
                        text(x(out),medianTemp.median(idx2), samples(out))
                        title(strcat('median metabolite concentration(log2 scale) in group ', ' ' , param.group(i), ' and perturbation ', ' ', param.perturbation(j)))
                        ylabel('log2(median concentration)')
                        xlabel('sample order')
                    end
                else
                    if param.printLevel == 1
                        x = 1:length(samples);
                        set(0, 'DefaultTextInterpreter','none')
                        plot(x,medianTemp.median(idx), "x")
                        title(strcat('median metabolite concentration(log2 scale) in group ', ' ', param.group(i), ' and perturbation ', ' ', param.perturbation(j)))
                        ylabel('log2(median concentration)')
                        xlabel('sample order')
                    end
                end
            end
        end
    end
    if ~isempty(outliers)
        cleanedData(ismember(cleanedData.sample, outliers), :) = [];
    end
end
tempConc = sumConc;
for i=1:length(param.group)
    for j=1:length(param.perturbation)
        for z=1:length(sumConc.metabolite_bmfl)
            IDs = find((cleanedData.group == param.group(i)) & ...
                (cleanedData.compound == sumConc.metabolite_bmfl(z)) & ...
                (cleanedData.perturbation == param.perturbation(j)));
            data = cleanedData.concentration(IDs);
            mean_param(z,1) = mean(data,'omitnan');
            sd_param(z,1) = std(data,'omitnan');
        end
        tempConc.(strcat('avr_',param.perturbation(j))) = mean_param;
        tempConc.(strcat('sd_',param.perturbation(j))) = sd_param;
    end
    summaryConc.(strcat('avr_',param.group(i))) = tempConc;
end

