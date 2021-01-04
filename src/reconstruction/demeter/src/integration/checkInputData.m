function [checkedData,addedStrains,removedStrains,duplicateStrains] = checkInputData(inputData,strainInformation)
% This function checks for duplicate and removed strains in the input data
% files and removes them.

% delete strains no longer in input data because name changed or it was
% removed
[C,IA] = setdiff(inputData(1:end,1),strainInformation(1:end,1),'stable');
removedStrains=C;
inputData(IA(2:end),:)=[];

% find and remove duplicate rows
[C,IA,IB]  = unique(inputData(:,1));
repeatedStr = C(histc(IB,1:max(IB))>1);
duplicateStrains=repeatedStr;
delArray=[];
cnt=1;
if ~isempty(repeatedStr)
    for i=1:length(repeatedStr)
        countdata=[];
        findintable=find(strcmp(inputData(:,1),repeatedStr{i}));
        % delete the one with less or no data
        for j=1:length(findintable)
            countdata(j)=sum(str2double(inputData(findintable(j),2:end)));
        end
        % entry with most data points will not be deleted (or first one is
        % kept if all are zero)
        [M,I]=max(countdata);
        findintable(I)=[];
       for j=1:length(findintable)
           delArray(cnt,1)=findintable(j);
           cnt=cnt+1;
       end
    end
end
inputData(delArray,:)=[];

% add any strains not yet in the input data
[C,IA] = setdiff(strainInformation(2:end,1),inputData(2:end,1));
addedStrains=C;
rowLength=size(inputData,1);
for i=1:length(C)
    inputData{rowLength+i,1}=char(C{i});
    inputData(rowLength+i,2:end)=cellstr(num2str(zeros));
end

% remove zeros from the reference columns
refCols=find(strncmp(inputData(1,:),'Ref',3));
for i=1:length(refCols)
    if length(inputData{1,refCols(i)})>6
        refCols(i)=[];
    end
end
% sort and properly arrange the references
if ~isempty(refCols)
    for j=2:size(inputData,1)
        allExp=unique(inputData(j,refCols));
        allExp(isempty(allExp))=[];
        allExp(strcmp(allExp,'0'))=[];
        allExp(strcmp(allExp,''))=[];
        inputData(j,refCols(1):refCols(end))={''};
        inputData(j,refCols(1):refCols(1)+length(allExp)-1)=allExp;
    end
end

checkedData = inputData;

end