function [model] = model2escher(model)
% this function prepare the model to draw escher map
%
% EscherMap only accept model in Json format. Some reaction IDs in Recon3D
% are started with number,which generating issue when converted into Json
% file. The function here add 'A_' to the reaction IDs starting with number

% Yanjun Liu   Nov,2023

tmp = regexp(model.rxns,'^\d');
bool = ~cellfun(@isempty,tmp);
idxs = find(bool);
for i = 1:length(idxs)
    model.rxns{idxs(i)} = ['A_',model.rxns{idxs(i)}];
end

model.mets = regexprep(model.mets, '\[(\w+)\]', '_$1');