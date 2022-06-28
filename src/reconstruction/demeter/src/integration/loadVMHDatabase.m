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
%       - Bronson R. Weston, 06/2022

global additionalSecretionRxns additionalUptakeRxns

metaboliteDatabase=table2cell(readtable('MetaboliteDatabase.txt'));
if contains(version,'(R202') % for Matlab R2020a and newer
metaboliteDatabase((cellfun(@isnan,metaboliteDatabase(:,7))),7) = {[]};
metaboliteDatabase((cellfun(@isnan,metaboliteDatabase(:,8))),8) = {[]};
end

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


%Update database function to account for any Secretion or Uptake reactions
%not in the database.
if ~isempty(additionalSecretionRxns) 
    fNames=fields(additionalSecretionRxns);
    for r=1:length(fNames)
        rxn=additionalSecretionRxns.(fNames{r}){1};
        if ~any(strcmp(database.reactions(:,1),rxn))
            metab=regexprep(rxn,'\(e\)','');
            metab=regexprep(metab,'EX_','');
            if ~any(ismember(database.metabolites(:,1),metab))
                if any(ismember(lower(database.metabolites(:,1)),metab))
                    metab=database.metabolites{find(ismember(lower(database.metabolites(:,1)),metab)),1};
                    rxn=['EX_' metab '(e)'];
                    additionalSecretionRxns.(fNames{r})={rxn};
                    if any(strcmp(database.reactions(:,1),rxn))
                        continue
                    end
                else
                    error(['Invalid metabolite ' metab])
                end
            end
            RxnForm=[metab '[e]  <=> '];
            database.reactions=[database.reactions;{rxn,[metab ' transport, extracellular'],RxnForm,1,0,'Added with mismatching IDs from resource and original VMH database', nan, nan, nan, nan, 'Transport, extracellular','Transport'}];
        end
    end
end

if ~isempty(additionalUptakeRxns) 
    fNames=fields(additionalUptakeRxns);
    for r=1:length(fNames)
        rxn=additionalUptakeRxns.(fNames{r}){1};
        if ~any(strcmp(database.reactions(:,1),rxn))
            metab=regexprep(rxn,'\(e\)','');
            metab=regexprep(metab,'EX_','');
            if ~any(ismember(database.metabolites(:,1),metab))
                if any(ismember(lower(database.metabolites(:,1)),metab))
                    metab=database.metabolites{find(ismember(lower(database.metabolites(:,1)),metab)),1};
                    rxn=['EX_' metab '(e)'];
                    additionalUptakeRxns.(fNames{r})={rxn};
                    if any(strcmp(database.reactions(:,1),rxn))
                        continue
                    end
                else
                    error(['Invalid metabolite ' metab])
                end
            end
            RxnForm=[metab '[e]  <=> '];
            database.reactions=[database.reactions;{rxn,[metab ' transport, extracellular'],RxnForm,1,0,'Added with mismatching IDs from resource and original VMH database', nan, nan, nan, nan, 'Transport, extracellular','Transport'}];
        end
    end
end

end