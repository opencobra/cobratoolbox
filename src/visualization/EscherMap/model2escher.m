function [model] = model2escher(model)
% Prepares a model to draw an EscherMap
%
% EscherMap only accepts a model in json format. Some reaction IDs in
% Recon3D start with a number, which causes an issue when converted into
% json. This function adds 'A_' to reaction IDs starting with a number,
% and replaces the compartment brackets in metabolite IDs with an
% underscore (e.g. `atp[c]` becomes `atp_c`)
%
% USAGE:
%
%    model = model2escher(model)
%
% INPUT:
%    model:    COBRA model structure with fields:
%
%                * .rxns - `n x 1` cell array of reaction identifiers
%                * .mets - `m x 1` cell array of metabolite identifiers
%
% OUTPUT:
%    model:    COBRA model structure with fields:
%
%                * .rxns - reaction identifiers, prefixed with `A_` where
%                  the original identifier started with a digit
%                * .mets - metabolite identifiers with compartment
%                  brackets replaced by an underscore
%
% .. Author: - Yanjun Liu, Nov 2023

tmp = regexp(model.rxns,'^\d');
bool = ~cellfun(@isempty,tmp);
idxs = find(bool);
for i = 1:length(idxs)
    model.rxns{idxs(i)} = ['A_',model.rxns{idxs(i)}];
end

model.mets = regexprep(model.mets, '\[(\w+)\]', '_$1');