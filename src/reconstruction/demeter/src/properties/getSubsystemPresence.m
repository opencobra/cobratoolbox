function getSubsystemPresence(propertiesFolder,reconVersion)
% This function extracts the presence of subsystems for a resource of
% reconstructions that were refined through the semi-automatic refinement
% pipeline. Shown is the fraction of total reactions in each subsystem for
% each reconstruction in the resource. Requires the function 
% getReactionPresenceOnTaxonLevels to be run first.
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
if ~any(contains(propertiesFolder,{[filesep 'Draft'],[filesep 'Refined']}))
    reactions = readtable([propertiesFolder filesep 'Reactions_' reconVersion '_refined.txt'], 'ReadVariableNames', false);
else
    reactions = readtable([propertiesFolder filesep 'Reactions_' reconVersion '.txt'], 'ReadVariableNames', false);
end
Reactions = table2cell(reactions);

% Load the reaction presence data for each reconstruction
reactionPresence = readtable([propertiesFolder filesep 'ReactionMetabolitePresence' filesep 'ReactionPresence_' reconVersion '.txt'], 'ReadVariableNames', false);
ReactionPresence = table2cell(reactionPresence);

allSubs = unique(Reactions(:,11));
subsystemPresence(1,2:length(allSubs)+1)=allSubs;

subsystemPresence(2:size(ReactionPresence,1),1) = ReactionPresence(2:end,1);

% go through all subsystems and count the fraction of reactions in each
% reconstruction
for i=2:size(subsystemPresence,2)
    % get all reactions
    findRxns=Reactions(find(strcmp(Reactions(:,11),subsystemPresence{1,i})),1);
    % find all reactions in reaction presence file
    [~,findRxnInds]=intersect(ReactionPresence(1,:),findRxns);
    for j=2:size(ReactionPresence,1)
        subsystemPresence{j,i}=(sum(str2double(ReactionPresence(j,findRxnInds))))/length(findRxns);
    end
end

writetable(cell2table(subsystemPresence),[propertiesFolder filesep 'ReactionMetabolitePresence' filesep 'SubsystemPresence_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');

end