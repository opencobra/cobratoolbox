function specificData = preprocessingOmicsModel(inputData, setMinActiveFlux, setMaxActiveFlux, specificData, TolMaxBoundary)
% Prepare data for the omicsModelGeneration function
%
% USAGE:
%
%    specificData = preprocessingOmicsModel(inputData)
%
% INPUT:
%    inputData:       Location of the file containing the optional
%                     variables where the first row of each column
%                     represents the name of the optional variables and the
%                     following rows represent the data on them.
%
% OPTIONAL INPUT:
%   setMinActiveFlux  {0}, 1 - change the LB of forced
%                     active reactions based on the (primal) feasibility
%                     tolerance (feasTol*100)
%   setMaxActiveFlux  {0}, 1 - change the UB of forced
%                     active reactions based on the (primal) feasibility
%                     tolerance (based on param.TolMaxBoundary, feasTol*1e9 if not provided)
%    specificData:         Structure containing the optional variables to
%                     generate a context-specific omics model
%    TolMaxBoundary:  The reaction boundary's maximum value (Default: feasTol*1e9).
%
% OUTPUT:
%    specificData:         Structure containing the additional optional variables to
%                          generate a context-specific omics model
%

if nargin < 2 || isempty(setMinActiveFlux)
    setMinActiveFlux = 0;
end
if nargin < 3 || isempty(setMaxActiveFlux)
    setMaxActiveFlux = 0;
end
if nargin < 4 || isempty(specificData)
    specificData = struct();
end
feasTol = getCobraSolverParams('LP', 'feasTol');
if nargin < 5 || isempty(TolMaxBoundary)
    TolMaxBoundary = feasTol * 1e9;
end

specificData.inputData = inputData;


fprintf('%s%s\n','Reading inputData from : ', inputData) 
% Indentify all sheets
[~, sheets] = xlsfinfo(inputData);

% Create a table for each of the sheets
for i = 1:length(sheets)
    fprintf('%s%s\n','Reading sheet: ', sheets{i})
    switch sheets{i}
        case 'activeGenes'
            data = readtable(inputData, 'Sheet', 'activeGenes');
            specificData.activeGenes = data.genes;
        case 'activeReactions'
            data = readtable(inputData, 'Sheet', 'activeReactions');
            specificData.activeReactions = data.rxns;
        case 'inactiveGenes'
            data = readtable(inputData, 'Sheet', 'inactiveGenes');
            specificData.inactiveGenes = data.genes;
        case 'rxns2add'
            specificData.rxns2add = readtable(inputData, 'Sheet', 'rxns2add');
            if ismember('geneRule', specificData.rxns2add.Properties.VariableNames)
                %convert each entry to a cell array of characters
                if isnumeric(specificData.rxns2add.geneRule)
                    geneRule = arrayfun(@num2str,specificData.rxns2add.geneRule,'UniformOutput',false);
                    geneRule = strrep(geneRule,'NaN','');
                    specificData.rxns2add.geneRule=geneRule;
                end
            end
        otherwise
            eval(sprintf('specificData.%s = readtable(inputData, ''Sheet'', ''%s'');', sheets{i}, sheets{i}));
    end
end
    
if isfield(specificData, 'rxns2constrain')
    
    if setMinActiveFlux == 1 && ismember('constraintDescription', specificData.rxns2constrain.Properties.VariableNames)
        specificData.rxns2constrain.lb(ismember(specificData.rxns2constrain.constraintDescription, 'Force activity')) = feasTol * 100;
    end
    
    if setMaxActiveFlux == 1  && ismember('constraintDescription', specificData.rxns2constrain.Properties.VariableNames)
        specificData.rxns2constrain.ub(ismember(specificData.rxns2constrain.constraintDescription, 'Force activity')) = TolMaxBoundary;
    end
end

% Growth media data
% This script use the concentrations (uM/L) and cell culture data to
% calculate the fluxes of media metabolites
% Note: Can data scaled based on this
% function
% ~/work/sbgCloud/programReconstruction/projects/exoMetDN/code/exometabolomics/2019_conc2fluxes/cellNumberToCellProtein.m
if isfield(specificData, 'mediaData') && isfield(specificData, 'cellCultureData')
       
    % Cell culture data
    volume = specificData.cellCultureData.volume; %(L)
    interval = specificData.cellCultureData.interval; %(hr)
    averageProteinConcentration = specificData.cellCultureData.averageProteinConcentration; %(g/L)
    assayVolume = specificData.cellCultureData.assayVolume; %(L)
    proteinFraction = specificData.cellCultureData.proteinFraction; %dimensionless
    uptakeSign = specificData.cellCultureData.uptakeSign; %dimensionless
    
    specificData.mediaData = table(specificData.mediaData.rxns, ...
        specificData.mediaData.mediumConcentrations, specificData.mediaData.mediumConcentrations, ...
        'VariableNames', {'rxns', 'mediumMaxUptake','mediumConcentrations'});
    
    for i = 1:length(specificData.mediaData.rxns)
        % specificData.mediumConcentrations(i) *
        % (uptakeSign * volume(L) * proteinFraction) /
        % (interval (hr) * averageProteinConcentration (gDW/L) * assayVolume(L))
        specificData.mediaData.mediumMaxUptake(i) =...
            specificData.mediaData.mediumConcentrations(i) * ...
            (uptakeSign * volume * proteinFraction) / ...
            (interval * averageProteinConcentration * assayVolume);
    end
end

end