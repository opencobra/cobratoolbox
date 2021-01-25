function [translatedRxns]=propagateKBaseMetTranslationToRxns(toTranslatePath)
% This functions replaced already translated metabolites in reactions with
% KBase/Model SEED nomenclature that are not yet translated. The function
% creates an output fit for the ReconstructionTool interface in rBioNet
% that can be used to check if the reactions already exist in the VMH
% database.
%
% USAGE:
%
%   [translatedRxns]=propagateKBaseMetTranslationToRxns(toTranslatePath)
%
% INPUT:
%   toTranslatePath           String containing the path to xlsx, csv, or 
%                             txt file with reaction IDs in KBase/ModelSEED
%                             nomenclature to translate (e.g., rxn00001)
%
% OUTPUTS:
%   translatedRxns            Table with reactions with already translated
%                             metabolite IDs replaced that can serve as 
%                             input for rBioNet to check if the reactions
%                             already exist in the VMH database.
%
% .. Author: Almut Heinken, 06/2020

% read in the reactions to translate
toTranslate=readtable(toTranslatePath);
toTranslate=table2cell(toTranslate);
toTranslate=toTranslate(:,1);

% remove already translated reactions
translateRxns = table2cell(readtable('ReactionTranslationTable.txt', 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011']));
[C,IA]=intersect(toTranslate,translateRxns(:,1));
if ~isempty(C)
    warning('Already translated reactions were removed.')
    toTranslate(IA)=[];
end

% get the associated formulas from KBase/Model SEED reaction database on
% ModelSEED GitHub
system('curl -LJO https://raw.githubusercontent.com/ModelSEED/ModelSEEDDatabase/master/Biochemistry/reactions.tsv');

KBaseRxns = table2cell(readtable('reactions.tsv', 'ReadVariableNames', false,'FileType','text'));
nameCol=find(strcmp(KBaseRxns(1,:),'name'));
formCol=find(strcmp(KBaseRxns(1,:),'equation'));
delArray=[];
cnt=1;
for i=1:size(toTranslate,1)
    % need to make some adjustments so IDs can be matched
    if strncmp(toTranslate{i,1},'EX_',3)
        buildForm=strrep(toTranslate{i,1},'EX_','');
        toTranslate{i,2}=toTranslate{i,1};
        toTranslate{i,3}=[buildForm '[1]  <=> '];
    elseif ~isempty(find(strcmp(KBaseRxns(:,1),toTranslate{i,1})))
        toTranslate{i,2}=KBaseRxns{find(strcmp(KBaseRxns(:,1),toTranslate{i,1})),nameCol};
        toTranslate{i,3}=KBaseRxns{find(strcmp(KBaseRxns(:,1),toTranslate{i,1})),formCol};
    else
        delArray(cnt)=i;
        cnt=cnt+1;
    end
end
% remove reactions that could not be found in the table
toTranslate(delArray,:)=[];

% get already translated metabolites
translateMets = readtable('MetaboliteTranslationTable.txt', 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011']);
translateMets=table2cell(translateMets);

for i=1:size(translateMets,1)
    toTranslate(:,3)=strrep(toTranslate(:,3),translateMets{i,1},[translateMets{i,2},'[c]']);
end

toTranslate(:,3)=strrep(toTranslate(:,3),'(','');
toTranslate(:,3)=strrep(toTranslate(:,3),')','');
toTranslate(:,3)=strrep(toTranslate(:,3),'[0]','[c]');
toTranslate(:,3)=strrep(toTranslate(:,3),'[1]','[e]');
toTranslate(:,3)=strrep(toTranslate(:,3),'[c][c]','[c]');
toTranslate(:,3)=strrep(toTranslate(:,3),'[c][e]','[e]');
toTranslate(:,3)=strrep(toTranslate(:,3),'=>','->');
toTranslate(:,3)=strrep(toTranslate(:,3),'<->','<=>');

% if the reaction is written in reverse
for i=1:size(toTranslate,1)
    if contains(toTranslate{i,3},' <= ')
        form=strsplit(toTranslate{i,3},' <= ');
        toTranslate{i,3}=[form{1,2} ' -> ' form{1,1}];
    end
end

% remove columns that still have untranslated metabolites in them and/or
% are not from bacteria
toRemove={'cpd','[m]','[m0]','[v]','[v0]','[r]','[r0]','[n]','[n0]','[g]','[g0]','[x]','[x0]'};
for i=1:length(toRemove)
    findUntrl=strfind(toTranslate(:,3),toRemove{i});
    toTranslate(find(~cellfun(@isempty,findUntrl)),:)=[];
end

translatedRxns=toTranslate;
writetable(cell2table(translatedRxns),'translatedRxns.txt','FileType','text','WriteVariableNames',false,'Delimiter','tab');

end