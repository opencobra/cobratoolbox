function mappedMedia = mapMediumData2AGORA(strainGrowth,inputMedia)
% This function extracts experimentally determined growth of species on 
% multiple media and converts the in silico minimal medium the strain can 
% grow on into an input fit for DEMETER. The input data was retrieved from 
% Tramontano et al., Nat Microbiol 2019 (PMID: 29556107).
%
% USAGE
%       mappedMedia = mapMediumData2AGORA(strainGrowth,inputMedia)
%
% INPUTS
% strainGrowth          Growth of strains on the different media reported  
%                       by Tramontano et al.  
% inputMedia            Growth media tested by Tramontano et al. converted
%                       into a computationally readable format
%
% OUTPUT
% mappedMedia           Data from Tramontano et al. converted into a format
%                       that can be added to GrowthRequirementsTable
%
% .. Author:
%       - Almut Heinken, 03/2020

% delete organisms that did not grow on any medium
rmStrain=[];
cnt=1;
for i=2:size(strainGrowth,1)
    if sum(str2double(strainGrowth(i,2:end)))==0
        rmStrain(cnt,1)=i;
        cnt=cnt+1;
    end
end
strainGrowth(rmStrain,:)=[];

mappedMedia(1,:) = inputMedia(1,:);
for i = 2:size(strainGrowth,1)
    mappedMedia{i,1} = strainGrowth{i,1};
    % find the media it can grow on
    canGrow=strainGrowth(1,find(strcmp(strainGrowth(i,:),'1')));
    inputMediaStrain=inputMedia;
    [C,IA]=setdiff(inputMediaStrain(:,1),canGrow);
    inputMediaStrain(IA(2:end),:)=[];
    for j=2:size(inputMediaStrain,2)
        if any(strcmp(inputMediaStrain(2:end,j),'-1'))
            mappedMedia{i,j} = '-1';
        else
            mappedMedia{i,j} = '0';
        end
    end
end

end