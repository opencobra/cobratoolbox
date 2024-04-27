function flux2json(model,FBAtype,outputFolder)
%This function print predicted fluxes to a json file used
%for escher map. The json file generated here could be directly used in EshcerMap https://escher.github.io/#/
%to visualise the flux distribution
%

% INPUT
%   model:     (the following fields are required - others can be supplied)
%
%                         * S  - `m x n` Stoichiometric matrix
%                         * c  - `n x 1` Linear objective coefficients
%                         * lb - `n x 1` Lower bounds on net flux
%                         * ub - `n x 1` Upper bounds on net flux
%                         * mets - `m x 1` Metabolite IDs
%                         * rxns - `n x 1` Reaction IDs

%   FBAtype:   'FBA' or 'EFBA'
%   outputFolder: 


% OUTPUT
%   A json file

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



