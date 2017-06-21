function [compartmentMetabolites] = findMetFromCompartment(model, compartment)
% Finds all the metabolites and their identifiers in
% a compartment of interest.
%
% USAGE:
%
%    [compartmentMetabolites] = findMetFromCompartment(model,Compartment)
%
% INPUTS:
%    model:                     COBRA model strcture
%    compartment:               compartment of interest (e.g.: '[m]', '[n]', '[e]', etc.)
%
% OUTPUT:
%    compartmentMetabolites:    List of metabolites in the compartment of interest
%
% .. Authors:
%       - written by Diana El Assal 27/10/15

[metabolites]=[model.mets]; % Form a matrix with the metabolites and its identifiers
%Find the metabolites in the compartment of interest (e.g. '[m], '[n]')
compartmentMets=strfind(model.mets, compartment);
index=find(~cellfun(@isempty, compartmentMets));
compartmentMets=model.mets(index);

%Find all metabolite identifiers
for i=1:size(compartmentMets,1);
    num=find(ismember(metabolites(:,1),compartmentMets{i,1}));
    if ~isempty(num);
        compartmentMetabolites(i,:)=metabolites(num,:);
    end
end
