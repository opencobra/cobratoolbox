function [metabolite_structure,IDsAdded] = acceptIDsSuggested(metabolite_structure,IDsSuggested, annotationSource)
%% function [metabolite_structure,IDsAdded] = acceptIDsSuggested(metabolite_structure,IDsSuggested)
% This function accepts suggested IDs as provided in the list IDsSuggested
% and adds them to the metabolite_structure. Note each row in IDsSuggested that shall be
% accepted must have an entry in the 6th column specifying that the entry
% in the 2nd column shall be accepted for the metabolite in the 1st column.
% Note that at this stage the annotation/curation level will be raised to
% curated, so it is imperative that each row and suggested ID will be carefully evaluated before being accepted.
%
% INPUT
% metabolite_structure  metabolite structure
% IDsSuggested          list of suggested IDs, each row to be accepted
%                       must have 'accepted' in the 6th column
% annotationSource      source of annotation, e.g. 'curator (name)'
% OUTPUT
% metabolite_structure  updated metabolite structure
% IDsAdded              List of added IDs
%
% Ines Thiele, 01/2021

if ~exist('annotationSource','var')
    annotationSource = 'curator (IT)';
end
annotationType = 'manual';
annotationVerification = 'verified';
a = 1;
IDsAdded = '';
for i = 1 : length(IDsSuggested)
    if strcmp(IDsSuggested(i,6),'accepted')
        suggestion = split(IDsSuggested{i,3},':');
        metabolite_structure.(IDsSuggested{i,1}).(suggestion{1}) = suggestion{2};
        metabolite_structure.(IDsSuggested{i,1}).([suggestion{1},'_source']) = [annotationSource,':',annotationType,':',annotationVerification,':',datestr(now)];
        IDsAdded{a,1} = IDsSuggested{i,1};
        IDsAdded{a,2} = suggestion{1};
        IDsAdded{a,3} = suggestion{2};
        IDsAdded{a,4} = 'added based on accepted suggestion';
    end
end
