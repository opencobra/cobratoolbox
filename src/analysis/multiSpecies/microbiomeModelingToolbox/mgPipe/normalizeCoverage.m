function [normalizedCoverage,normalizedCoveragePath] = normalizeCoverage(abunFilePath,cutoff)
% This functions normalizes the coverage in a given file with organism
% coverages such that they sum up to 1 for each sample.
%
% USAGE
%   [normalizedCoverage,normalizedCoveragePath] = normalizeCoverage(abunFilePath,cutoff)
%
% INPUT
% abunFilePath           	Path to table with not yet normalized relative 
%                           coverages
%
% OPTIONAL INPUT
% cutoff                    Cutoff for normalized coverages that are
%                           considered below detection limit, respective
%                           organisms will be removed from the samples
%                           (default: 0.0001)
%
% OUTPUTS
% normalizedCoverage        Table with normalized coverages
% normalizedCoveragePath    Path to csv file with normalized coverages
%
% .. Author:
%       - Almut Heinken, 01/2021

tol = 0.000001;

if nargin == 1
    % define default cutoff
    cutoff=0.0001;
end

coverage = readInputTableForPipeline(abunFilePath);
coverage{1,1}='ID';

% adapt IDs if neccessary
coverage(1,2:end) = strrep(coverage(1,2:end),'-','_');

% summarize duplicate entries
[uniqueA,i,j] = unique(coverage(:,1));
n  = accumarray(j(:),1);
Dupes=uniqueA(find(n>1));
delArray=[];
cnt=1;
for i=1:length(Dupes)
    indexToDupes = find(strcmp(coverage(:,1),Dupes{i}));
    for j=2:length(indexToDupes)
        for k=2:size(coverage,2)
            if contains(version,'R202') % for Matlab R2020a and newer
                coverage{indexToDupes(1),k}=coverage{indexToDupes(1),k}+coverage{indexToDupes(j),k};
            else
                coverage{indexToDupes(1),k}=num2str(cell2mat(coverage{indexToDupes(1),k})+cell2mat(coverage{indexToDupes(j),k}));
            end
        end
        delArray(cnt,1)=indexToDupes(j);
        cnt=cnt+1;
    end
end
coverage(delArray,:)=[];

% delete samples that are all zeros (if applies)
if contains(version,'R202') % for Matlab R2020a and newer
    totalAbun=sum(cell2mat(coverage(2:end,2:end)),1);
else
    totalAbun=sum(str2double(coverage(2:end,2:end)),1);
end
allzero=find(totalAbun<0.0000001);
if ~isempty(allzero)
    for i=1:length(allzero)
        allzero(i)=allzero(i)+1;
    end
    coverage(:,allzero)=[];
end

coverageNew = coverage;

for i=2:size(coverage,2)
    % first summarize all
    sumAll=0;
    for j=2:size(coverage,1)
        if contains(version,'R202') % for Matlab R2020a and newer
            sumAll=sumAll + coverage{j,i};
        else
            sumAll=sumAll + str2double(coverage{j,i});
        end
    end
    % then normalize the coverages
    for j=2:size(coverage,1)
        if contains(version,'R202') % for Matlab R2020a and newer
            coverageNew{j,i}=coverage{j,i}/sumAll;
        else
            coverageNew{j,i}=str2double(coverage{j,i})/sumAll;
        end
    end
end

% verify that numbers add up to 1
for i=2:size(coverageNew,2)
    summedUp = sum(cell2mat(coverageNew(2:end,i)));
    if summedUp > 1 + tol || summedUp < 1 - tol
        error('Normalized coverages do not sum up to 1!')
    end
end

% cut out organisms with coverages considered below detection limit
for i=2:size(coverageNew,1)
    for j=2:size(coverageNew,2)
        if coverageNew{i,j} < cutoff
            coverageNew{i,j} = 0;
        end
    end
end

% remove organisms that are no longer in any sample
cnt=1;
delArray=[];
for i=2:size(coverageNew,1)
    if sum(cell2mat(coverageNew(i,2:end))) < tol
        delArray(cnt)=i;
        cnt=cnt+1;
    end
end
coverageNew(delArray,:) = [];

cell2csv([pwd filesep 'normalizedCoverage.csv'],coverageNew)

normalizedCoverage = coverageNew;
normalizedCoveragePath = [pwd filesep 'normalizedCoverage.csv'];
end
