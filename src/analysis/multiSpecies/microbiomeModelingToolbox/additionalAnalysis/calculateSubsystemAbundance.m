function subsystemAbundance = calculateSubsystemAbundance(reactionAbundancePath)
% Computes the subsystem abundance in microbiome models that were generated
% through the mgPipe pipeline from the calculated reaction abundances. The 
% subsystem abundance is shown as the fraction of the highest possible
% subsystem abundance that could be achieved, which would be every reaction
% in the subsystem being in the microbiome model at a total abundance of 1.
%
% USAGE: subsystemAbundance = calculateSubsystemAbundance(reactionAbundancePath)
%
% INPUT
% reactionAbundancePath     Path to spreadsheet or text file with
%                           calculated reaction abundances for one or more 
%                           microbiome models
% OUTPUT
% subsystemAbundance        Table with calculated subsystem abundances
% 
% AUTHOR
%       - Almut Heinken, 08/2020

reactionDatabase = readtable('ReactionDatabase.txt', 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011'], 'ReadVariableNames', false);
reactionDatabase=table2cell(reactionDatabase);

reactionAbundance = readtable(reactionAbundancePath, 'ReadVariableNames', false);
reactionAbundance = table2cell(reactionAbundance);

% remove biomass reaction
reactionAbundance(find(strncmp(reactionAbundance(:,1),'bio',3)),:)=[];

% remove reactions not in dataset
[C,IA]=setdiff(reactionDatabase(:,1),reactionAbundance(:,1));
reactionDatabase(IA,:)=[];

% get and calculate all subsystems
subs=unique(reactionDatabase(:,11));
subs(find(strcmp(subs(:,1),'')),:)=[];

subsystemAbundance(1,:)=reactionAbundance(1,:);
subsystemAbundance{1,1}='Subsystems';

for i=1:length(subs)
    subsystemAbundance{i+1,1}=subs{i};
    rxns=reactionDatabase(find(strcmp(reactionDatabase(:,11),subs{i})),1);
    % use the fraction of abundance for all reactions in this subsystem
    % taken together
    abunTmp=zeros(1,size(reactionAbundance,2));
    for j=1:length(rxns)
        rxnInd=find(strcmp(reactionAbundance(:,1),rxns{j}));
        for k=2:size(reactionAbundance,2)
            abunTmp(k)=abunTmp(k) + str2double(reactionAbundance{rxnInd,k});
        end
    end
    for k=2:size(reactionAbundance,2)
        subsystemAbundance{i+1,k}=abunTmp(k)/length(rxns);
    end
end

end