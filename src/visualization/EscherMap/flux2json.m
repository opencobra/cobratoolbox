function flux2json(model, FBAtype, outputFolder)
% Writes a model's predicted flux distribution to a json file for use with
% EscherMap (https://escher.github.io/#/) to visualise the flux
% distribution
%
% USAGE:
%
%    flux2json(model, FBAtype, outputFolder)
%
% INPUTS:
%    model:           COBRA model structure with fields:
%
%                       * .rxns - `n x 1` cell array of reaction identifiers
%                       * .rxnNames - `n x 1` cell array of reaction names
%
% OPTIONAL INPUTS:
%    FBAtype:         'FBA' to solve with `optimizeCbModel`, or 'EFBA' to
%                     solve with `entropicFluxBalanceAnalysis`
%    outputFolder:    Folder in which the `data.json` output file is
%                     written
%
% OUTPUT:
%    A `data.json` file with the reaction fluxes is written to
%    `outputFolder`
%
% .. Author: Yanjun Liu  26/04/2023

if ~exist("model", 'var')
    error('Input is missing')
end

if exist('FBAtype','var')
    switch FBAtype
        case 'FBA'
            solution = optimizeCbModel(model);
        case 'EFBA'
            param.solver = 'mosek';
            param.printLevel = 0;
            param = mosekParamSetEFBA(param);
            solution = entropicFluxBalanceAnalysis(model,param);
    end
end

if ~exist('outputFilename','var')
    outputFolder = pwd;
    %outputFilename = [outputFilename filesep 'flux.json'];
end

rxns = model.rxns;
rxnNames = model.rxnNames;
flux = solution.v;

T = table(rxns,rxnNames,flux);




% Extract the key-value pairs from the data
keys = table2array(T(:,1));
values = table2array(T(:,3));

% Convert the key-value pairs to a struct
jsonStruct = struct;
for i = 1:numel(keys)
    key = keys{i};
    value = values(i);
    try
        jsonStruct.(key) = value;
    catch
        if contains(key,'[')
            key = regexprep(key,'[\w\*]','');
        elseif contains(key,'-')
            key = regexprep(key,'-','');

        else
            key = ['x_',key];
            jsonStruct.(key) = value;
        end

    end
end
% Convert the struct to JSON format
jsonString = jsonencode(jsonStruct);

% Write the JSON string to a file
fid = fopen([outputFolder filesep 'data.json'], 'w');
if fid == -1
    error('Could not open file for writing');
end
fwrite(fid, jsonString, 'char');
fclose(fid);



end



