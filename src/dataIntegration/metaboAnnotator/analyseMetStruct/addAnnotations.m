% add annotations
function [metabolite_structure] = addAnnotations(metabolite_structure,RAW,annotationSource,annotationType,annotationVerification)
%% function [metabolite_structure] = addAnnotations(metabolite_structure,RAW,annotationSource,annotationType)
% This function adds annotations (fields) to the metabolite_structure. It
% is generally used to populate the metabolite_structure with new
% metabolites from an xlsx sheet (RAW).
% 
% INPUT 
% metabolite_structure  	metabolite structure
% RAW                       data read in using the function xlsread, e.g.,
%                           [NUM,TXT,RAW]=xlsread('MetaboliteTranslationTable.xlsx');
%                           Note that the xlsx sheet has to have certain
%                           headers to be correctly read in.
% annotationSource          define annotation source (to track where the
%                           information came from, e.g., 'Recon3D'). If not
%                           specified, 'unknown' will be added
% annotation Type           type of annotation, e.g., 'automatic' (Default), 'manual'
% annotationVerification    verification of annotation, e.g., 'not verified' (Default), 'verified by curator', 'verified based on inchiKeys'
%
% OUTPUT
% metabolite_structure      updated metabolite structure 
% 
% Ines Thiele 2020/2021


if ~exist('annotationSource','var')
    annotationSource = 'unknown';
end
if ~exist('annotationType','var')
    annotationType = 'automatic';
end
if ~exist('annotationVerification','var')
    annotationVerification = 'not verified';
end
      
for i = 2 : size(RAW,1)
    if isempty(find(isnan(RAW{i,1})))

        RAW{i,1} = regexprep(RAW{i,1},'-','_minus_');
        RAW{i,1} = regexprep(RAW{i,1},'(','_parentO_');
        RAW{i,1} = regexprep(RAW{i,1},')','_parentC_');
        for j = 2:size(RAW,2)
            if (strcmp(RAW{1,j},'lmId'))
                RAW{1,j} = 'lipidmaps';
            elseif (strcmp(RAW{1,j},'cheBlId'))
                RAW{1,j} = 'cheBIId';
            end
            if isfield(metabolite_structure,(strcat('VMH_',RAW{i,1}))) && isfield(metabolite_structure.(strcat('VMH_',RAW{i,1})),RAW{1,j})
                if isempty(metabolite_structure.(strcat('VMH_',RAW{i,1})).(RAW{1,j})) || ~isempty(find(isnan(metabolite_structure.(strcat('VMH_',RAW{i,1})).(RAW{1,j})),1)) &&  isempty(find(isnan((RAW{i,j}))))
                    if ~strcmp(RAW{i,j},'NULL') && (~strcmp(RAW{i,j},'0') || strcmp(RAW{1,j},'charge'))  && ~strcmp(RAW{i,j},'null') && ~strcmp(RAW{i,j},'\N') && ~isempty(RAW{i,j})
                        metabolite_structure.(strcat('VMH_',RAW{i,1})).(RAW{1,j}) = RAW{i,j};
                        metabolite_structure.(strcat('VMH_',RAW{i,1})).([RAW{1,j},'_source']) = [annotationSource,':',annotationType,':',datestr(now)];
                    end
                end
            end
        end
    end
end
