function database=loadVMHDatabase
% This function loads the database with reactions and metabolites in 
% Virtual Metabolic Human (https://www.vmh.life/) nomenclature.
%
% USAGE:
%
%    database=loadVMHDatabase
%
% OUTPUT
% database  Structure with reaction and metabolite database
%
% .. Author:
%       - Almut Heinken, 09/2021


metaboliteDatabase=table2cell(readtable('MetaboliteDatabase.txt'));
metaboliteDatabase((cellfun(@isnan,metaboliteDatabase(:,7))),7) = {[]};
metaboliteDatabase((cellfun(@isnan,metaboliteDatabase(:,8))),8) = {[]};

database.metabolites=metaboliteDatabase;
for i=1:size(database.metabolites,1)
    database.metabolites{i,5}=num2str(database.metabolites{i,5});
    database.metabolites{i,7}=num2str(database.metabolites{i,7});
    database.metabolites{i,8}=num2str(database.metabolites{i,8});
end
reactionDatabase=readtable('ReactionDatabase.txt');
reactionDatabase=[reactionDatabase.Properties.VariableNames;table2cell(reactionDatabase)];
database.reactions=reactionDatabase;

% convert data types if necessary
database.metabolites(:,7)=strrep(database.metabolites(:,7),'NaN','');
database.metabolites(:,8)=strrep(database.metabolites(:,8),'NaN','');

end