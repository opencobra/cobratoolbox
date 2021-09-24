function getSubsystemPresence(propertiesFolder,reconVersion)
% This function extracts the presence of subsystems for a resource of
% reconstructions that were refined through the semi-automatic refinement
% pipeline. Shown is the fraction of total reactions in each subsystem for
% each reconstruction in the resource. Requires the function 
% getreactionPresenceOnTaxonLevels to be run first.
%
% USAGE
%   getSubsystemPresence(propertiesFolder,reconVersion)
%
% INPUTS                                                                                                                                                                                       Folder with COBRA models to be analyzed
% propertiesFolder      Folder where the retrieved subsystem presences will
%                       be stored (default: current folder)
% reconVersion          Name assigned to the reconstruction resource
%
%   - AUTHOR
%   Almut Heinken, 11/2020

% Load all reactions in reconstruction resource
reactions = readInputTableForPipeline([propertiesFolder filesep 'Reactions_' reconVersion '.txt']);

% Load the reaction presence data for each reconstruction
reactionPresence = readInputTableForPipeline([propertiesFolder filesep 'ReactionMetabolitePresence' filesep 'reactionPresence_' reconVersion '.txt']);

allSubs = unique(reactions(:,11));
allSubs(find(strcmp(allSubs(:,1),'')),:)=[];
subsystemPresence(1,2:length(allSubs)+1)=allSubs;

subsystemPresence(1:size(reactionPresence,1),1) = reactionPresence(:,1);

% go through all subsystems and count the fraction of reactions in each
% reconstruction
for i=2:size(subsystemPresence,2)
    % get all reactions
    findRxns=reactions(find(strcmp(reactions(:,11),subsystemPresence{1,i})),1);
    % find all reactions in reaction presence file
    [~,findRxnInds]=intersect(reactionPresence(1,:),findRxns);
    for j=2:size(reactionPresence,1)
        if contains(version,'(R202') % for Matlab R2020a and newer
            subsystemPresence{j,i}=num2str(sum(cell2mat(reactionPresence(j,findRxnInds))))/length(findRxns);
        else
            subsystemPresence{j,i}=num2str(sum(str2double(reactionPresence(j,findRxnInds))))/length(findRxns);
        end
    end
end

writetable(cell2table(subsystemPresence),[propertiesFolder filesep 'ReactionMetabolitePresence' filesep 'SubsystemPresence_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');

end