function [modelUpdated] = populateModelwithRxnIDs(model)

[~,~,RAW] = xlsread('C:\Users\0123322S\Dropbox\Studies\VMH\VMH_reactionList.xlsx');

%  model field reactionList column header
translate={
    'rxnECNumbers' 'ecnumber'
    'rxnKEGGID' 'keggId'
    'rxnMetaNetXID' 'metanetx'
    'rxnSEEDID' 'seed'
    'rxnRheaID' 'rhea'
    };
modelUpdated = model;
% based on VMH data
for i = 1 : length(modelUpdated.rxns)
    row = find(ismember(RAW(:,2),modelUpdated.rxns{i}));
    for j = 1 : size(translate,1)
        if ~isempty(row) % reaction does  exist in VMH
            % I overwrite existing IDs
            col = find(ismember(RAW(1,:),translate{j,2}));
            
            if length(find(isnan(RAW{row,col})))==0 && ~strcmp(RAW{row,col}, '\N')
                if isnumeric(RAW{row,col})
                    modelUpdated.(translate{j,1}){i,1} = num2str(RAW{row,col});
                else
                    modelUpdated.(translate{j,1}){i,1} = RAW{row,col};
                end
            else
                modelUpdated.(translate{j,1}){i,1} = '';
            end
        else
            modelUpdated.(translate{j,1}){i,1} = '';
        end
    end
end

% based on demeter data (as present in https://github.com/opencobra/COBRA.papers/blob/master/2021_demeter/input/)

translateSeed = readtable('ReactionTranslationTable.txt'); % seed ID first col, VMH ID 2nd col
translateSeed = table2cell( translateSeed); 
for i = 1 : length(modelUpdated.rxns)
    row =  find(ismember(translateSeed(:,2),modelUpdated.rxns{i}));
    if ~isempty(row)
        modelUpdated.rxnSEEDID{i} = translateSeed{row,1};
    end
end