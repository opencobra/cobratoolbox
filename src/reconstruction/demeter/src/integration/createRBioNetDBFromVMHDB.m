function createRBioNetDBFromVMHDB(varargin)
% This function creates an input fit for rBioNet from the VMH metabolite
% and reaction database and builds a new database settings file. It enables
% using the VMH database to modify or build reconstructions.
%
% USAGE:
%
%   createRBioNetDBFromVMHDB('rBioNetDBFolder',rBioNetDBFolder)
%
% OPTIONAL INPUT:
%   rBioNetDBFolder          Path where to save the created database and
%                            database settings file. Default: current path
%
% .. Author: Almut Heinken, 06/2020

parser = inputParser();
parser.addParameter('rBioNetDBFolder', pwd, @ischar);
parser.parse(varargin{:});
rBioNetDBFolder = parser.Results.rBioNetDBFolder;

% get VMH reaction and metabolite database
metaboliteDatabase = readtable('MetaboliteDatabase.txt', 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011'], 'ReadVariableNames', false);
metaboliteDatabase=table2cell(metaboliteDatabase);
for i=1:size(metaboliteDatabase,1)
    metaboliteDatabase{i,5}=num2str(metaboliteDatabase{i,5});
    metaboliteDatabase{i,12}=datestr(metaboliteDatabase{i,12});
end
metab=cell(metaboliteDatabase);

reactionDatabase = readtable('ReactionDatabase.txt', 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011']);
reactionDatabase=table2cell(reactionDatabase);
for i=1:size(reactionDatabase,1)
    if isempty(reactionDatabase{i,9})
        reactionDatabase{i,9}=cell2mat(reactionDatabase{i,9});
    end
    % treat differently when time stamp is missing
    if ~isnat(reactionDatabase{i,10})
      reactionDatabase{i,10}=datestr(reactionDatabase{i,10});
    else
         reactionDatabase{i,10}=reactionDatabase{i,10};
    end
end
% remove the subsystem column since rBioNet does not account for that
reactionDatabase(:,end)=[];
rxn=cell(reactionDatabase);

% load the file with compartment definition
try
    load('compartments.mat');
    save([rBioNetDBFolder filesep 'compartments.mat'],'compartments');
end
save([rBioNetDBFolder filesep 'rxn.mat'],'rxn');
save([rBioNetDBFolder filesep 'metab.mat'],'metab');

met_path=[rBioNetDBFolder filesep 'metab.mat'];
rxn_path=[rBioNetDBFolder filesep 'rxn.mat'];
comp_path=[rBioNetDBFolder filesep 'compartments.mat'];

save([rBioNetDBFolder filesep 'rBioNetSettingsDB.mat'],'comp_path','met_path','rxn_path');
addpath(rBioNetDBFolder)
savepath

end