function [unannotatedRxns] = getUnannotatedReactionsFromPubSeedSpreadsheets(spreadsheetFolder)
% Prepares input file for the comparative genomics part
% Gets all the reactions that were not found in the respective organism
% through comparative genomics to remove them from the draft
% reconstructions

% load reactions
reactions=readtable('InReactions.txt', 'ReadVariableNames', false,'FileType','text','delimiter','tab');
reactions = table2cell(reactions);

% get all spreadsheets
dInfo = dir(spreadsheetFolder);
fileList={dInfo.name};
fileList=fileList';
fileList(find(strcmp(fileList(:,1),'.')),:)=[];
fileList(find(strcmp(fileList(:,1),'..')),:)=[];

% get AGORA2 IDs
infoFile = readtable('AGORA2_infoFile.xlsx', 'ReadVariableNames', false);
infoFile=table2cell(infoFile);

unannotatedRxns={};
cnt=1;

for i=1:length(fileList)
    i
    spreadsheet=readtable([spreadsheetFolder filesep fileList{i}], 'ReadVariableNames', false,'FileType','text','delimiter','tab');
    spreadsheet = table2cell(spreadsheet);
    for j=2:size(spreadsheet,1)
        % replace PubSeed with AGORA Model IDs
        % some entries in the comparative genomics spreadsheet have no
        % reconstruction -> skip
        if ~isempty(find(strcmp(infoFile(:,2),spreadsheet{j,1})))
            spreadsheet{j,1}=infoFile{find(strcmp(infoFile(:,2),spreadsheet{j,1})),1};
            for k=2:size(spreadsheet,2)
                % get the ones that are empty so genoem annotation was not
                % found
                % no drug genes with many associated reactions
                if isempty(spreadsheet{j,k}) && ~any(strcmp(spreadsheet{1,k},{'eUidA','cUidA','UidB','UidP','UidABC'}))
                    getRxns=reactions(find(strcmp(reactions(:,1),spreadsheet{1,k})),2);
                    for r=1:length(getRxns)
                        unannotatedRxns{cnt,1}=spreadsheet{j,1};
                        unannotatedRxns{cnt,2}=getRxns{r};
                        cnt=cnt+1;
                    end
                end
            end
        end
    end
end

% remove duplicate reactions for organisms, gap-filled reactions present in
% comparative genomics spreadsheets
% remove reactions not present in KBase translation table to avoid deleting
% comparative genomic reactions from AGORA1
genomeAnnotation = readtable('gapfilledGenomeAnnotation.txt', 'ReadVariableNames', false, 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011']);
genomeAnnotation = table2cell(genomeAnnotation);

translateRxns = readtable('ReactionTranslationTable.txt', 'Delimiter', '\t');
translateRxns=table2cell(translateRxns);

delArray=[];
cnt=1;
orgs=unique(unannotatedRxns(:,1));
for i=1:length(orgs)
    i
    getRxns=unannotatedRxns(find(strcmp(unannotatedRxns(:,1),orgs{i})),2);
    getRxnInds=find(strcmp(unannotatedRxns(:,1),orgs{i}));
    [uniqueRxns, ~, J]=unique(getRxns);
    cntRxns = histc(J, 1:numel(uniqueRxns));
    duplRxns=uniqueRxns(cntRxns>1);
    if ~isempty(duplRxns)
        for j=1:length(duplRxns)
            findInds=getRxnInds(find(strcmp(getRxns(:,1),duplRxns{j})),1);
            for k=2:length(findInds)
                delArray(cnt,1)=findInds(k);
                cnt=cnt+1;
            end
        end
    end
    annRxns=genomeAnnotation(find(strcmp(orgs{i},genomeAnnotation(:,1))),2);
    [~,keptRxnInd]=intersect(getRxns,annRxns);
    for j=1:length(keptRxnInd)
        delArray(cnt,1)=getRxnInds(keptRxnInd(j));
        cnt=cnt+1;
    end
    [~,notTranslated]=setdiff(getRxns,translateRxns(:,2));
    for j=1:length(notTranslated)
        delArray(cnt,1)=getRxnInds(notTranslated(j));
        cnt=cnt+1;
    end
end
unannotatedRxns(delArray,:)=[];

end
