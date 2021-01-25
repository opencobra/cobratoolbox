function [translatedMets]=propagateKBaseMetsTranslation(toTranslatePath)
% This functions replaced already translated metabolites in reactions with
% KBase/Model SEED nomenclature that are not yet translated. The function
% creates an output fit for the ReconstructionTool interface in rBioNet
% that can be used to check if the reactions already exist in the VMH
% database.
%
% USAGE:
%
%   [translatedMets]=propagateKBaseMetTranslation(toTranslatePath)
%
% INPUT:
%   toTranslatePath         String containing the path to xlsx, csv, or 
%                           txt file with metabolite IDs in KBase/ModelSEED
%                           nomenclature to translate (e.g., cpd00001)
%
% OUTPUTS:
%   translatedMets          Table with KBase metabolite IDs that could be
%                           matched to VMH metabolite IDs
%
% .. Author: Almut Heinken, 01/2021

% read in the reactions to translate
toTranslateMets=table2cell(readtable(toTranslatePath));

% remove already translated metabolites
translateMets = table2cell(readtable('MetaboliteTranslationTable.txt', 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011']));
[C,IA]=intersect(toTranslateMets,translateMets(:,1));
if ~isempty(C)
    warning('Already translated metabolites were removed.')
    toTranslateMets(IA)=[];
end

% prepare the table
toTranslate={'KBase_ID','KBase_name','KBase_formula','KBase_charge','VMH_ID','VMH_name','VMH_formula','VMH_charge'};
toTranslate(2:size(toTranslateMets,1)+1,1)=toTranslateMets;

% get the VMH metabolite database
metaboliteDatabase = readtable('MetaboliteDatabase.txt', 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011'], 'ReadVariableNames', false);
metaboliteDatabase=table2cell(metaboliteDatabase);

% get the KBase/Model SEED metabolite database on ModelSEED GitHub
system('curl -LJO https://raw.githubusercontent.com/ModelSEED/ModelSEEDDatabase/master/Biochemistry/compounds.tsv');

KBaseMets = table2cell(readtable('compounds.tsv', 'ReadVariableNames', false,'FileType','text'));
% get some columns that can be used to match IDs
kbaseNameCol=find(strcmp(KBaseMets(1,:),'name'));
kbaseBiGGCol=find(strcmp(KBaseMets(1,:),'abbreviation'));
kbaseSmileCol=find(strcmp(KBaseMets(1,:),'smiles'));
kbaseAltNameCol=find(strcmp(KBaseMets(1,:),'aliases'));

for i=2:size(toTranslate,1)
    % get the available information on this metabolite from the KBase
    % database
    metRow=find(strcmp(KBaseMets(:,1),toTranslate{i,1}));
    metName=KBaseMets{metRow,kbaseNameCol};
    biggID=KBaseMets{metRow,kbaseBiGGCol};
    smileID=KBaseMets{metRow,kbaseSmileCol};
    altNames=strsplit(KBaseMets{metRow,kbaseAltNameCol},';');
    
    % try to match with IDs from VMH database
    findVMH=find(strcmp(metaboliteDatabase(:,2),metName));
    if isempty(findVMH) && ~isempty(biggID)
        findVMH=find(strcmp(metaboliteDatabase(:,1),biggID));
    end
    if isempty(findVMH) && ~isempty(smileID)
        findVMH=find(strcmp(metaboliteDatabase(:,10),smileID));
    end
    if isempty(findVMH)
        for j=1:length(altNames)
            findVMH=find(strcmp(metaboliteDatabase(:,2),altNames{j}));
            if ~isempty(findVMH)
                break
            end
        end
    end
    if ~isempty(findVMH)
        % fill in the information from KBase
        toTranslate{i,2}=metName;
        toTranslate{i,3}=KBaseMets{metRow,4};
        toTranslate{i,4}=KBaseMets{metRow,8};
        
        % fill in the information from the matched VMH metabolite
        toTranslate{i,5}=metaboliteDatabase{findVMH,1};
        toTranslate{i,6}=metaboliteDatabase{findVMH,2};
        toTranslate{i,7}=metaboliteDatabase{findVMH,4};
        toTranslate{i,8}=metaboliteDatabase{findVMH,5};
    end
end

% remove untranslated metabolites
toTranslate(cellfun('isempty', toTranslate(:,5)),:)=[];
translatedMets=toTranslate;
writetable(cell2table(translatedMets),'translatedMets.txt','FileType','text','WriteVariableNames',false,'Delimiter','tab');

end