function mergedData=mergeTextDataAndData(textdata,data,headings)
%merge textdata and data imported from .xls file assuming that the first
%row of textdata is column headings
%
% mergedData=mergeTextDataAndData(textdata,data)
%
%INPUT
% textdata      cell array from .xls import
% data          matrix with numeric data from .xls import
%
%OPTIONAL INPUT
% headings      {(1),0}, zero if no column headings
%
%OUTPUT
% mergedData    merged cell array with all data from .xls import
%
% Ronan Fleming 29/10/2008

%check for headings
if ~exist('headings','var');
    headings=1;
    fprintf('%s\n','Assuming there were headings in the original xls file');
end
if headings==1
    start=2;
else
    start=1;
end

%checking for exceptions in otherwise data columns
fprintf('%s\n','Checking for exceptions in otherwise numeric columns, e.g. NaN');
fprintf('%s\n','Checking for exceptions in otherwise numeric columns, e.g. -');
fprintf('%s\n','Checking for exceptions in otherwise numeric columns, e.g. Not calculated');
fprintf('%s\n','Checking for exceptions in otherwise numeric columns, e.g. #N/A');
fprintf('%s\n','Checking for empty cells in otherwise numeric columns, e.g. []');
[ylt,xlt]=size(textdata);
for y=1:ylt
    for x=1:xlt
        if strcmp(textdata{y,x},'NaN')
            textdata{y,x}='';
        end
    end
end
for y=1:ylt
    for x=1:xlt
        if strcmp(textdata{y,x},'-')
            textdata{y,x}='';
        end
    end
end
for y=1:ylt
    for x=1:xlt
        if strcmp(textdata{y,x},'Not calculated')
            textdata{y,x}='';
        end
    end
end
for y=1:ylt
    for x=1:xlt
        if strcmp(textdata{y,x},'#N/A')
            textdata{y,x}='';
        end
    end
end
%replace empty cells with blank string
for y=1:ylt
    for x=1:xlt
        if isempty(textdata{y,x})
            textdata{y,x}='';
        end
    end
end
%preallocate
mergedData=textdata;
dataCol=1; 
beginData=0;
for x=1:xlt 
    %check for blank column
    if min(strcmp(textdata(start:ylt,x),''))==1
        beginData=1;
        fprintf('%s\n',['Merging numerical data into column ' int2str(x)]);
        for y=start:ylt
            if (y-start+1)>size(data,1)
                %if the last rows are NaN then this is needed as data will
                %be too short
                mergedData{y,x}=NaN;
            else
                mergedData{y,x}=data(y-start+1,dataCol); 
            end
        end
        dataCol=dataCol+1;
        if dataCol>size(data,2)
            break
        end
    else
        %data can have empty columns corresponding to textdata columns
        if beginData==1
            dataCol=dataCol+1;
        end
    end 
end
%data column might be the last column of original xls file
if dataCol<size(data,2)+1
    p=1;
    while dataCol<size(data,2)+1
        for y=start:ylt
            mergedData{y,x+p}=data(y-start+1,dataCol);
        end
        p=p+1;
        dataCol=dataCol+1;
    end
end
    
    
% for x=1:137 gMW{x,1}=iCore.genes{x}; for y=1:5300 if
% strncmp(iCore.genes{x},mergedData{y,1},length(iCore.genes{x})) gMW{x,2}=d(y); end; end; end;
