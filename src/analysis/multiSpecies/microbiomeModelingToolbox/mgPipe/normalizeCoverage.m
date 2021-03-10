function [normalizedCoverage,normalizedCoveragePath] = normalizeCoverage(abunFilePath,cutoff)
% This functions normalizes the coverage in a given file with organism
% abundances such that they sum up to 1 for each sample.
%
% USAGE
%   [normalizedCoverage,normalizedCoveragePath] = normalizeCoverage(abunFilePath,cutoff)
%
% INPUT
% abunFilePath           	Path to table with not yet normalized relative 
%                           abundances
%
% OPTIONAL INPUT
% cutoff                    Cutoff for normalized abundances that are
%                           considered below detection limit, respective
%                           organisms will be removed from the samples
%                           (default: 0.0001)
%
% OUTPUTS
% normalizedCoverage        Table with normalized abundances
% normalizedCoveragePath    Path to csv file with normalized abundances
%
% .. Author:
%       - Almut Heinken, 01/2021

tol = 0.000001;

if nargin == 1
    % define default cutoff
    cutoff=0.0001;
end

coverage = table2cell(readtable(abunFilePath,'ReadVariableNames',false));
coverage{1,1}='ID';
abundanceNew = coverage;

for i=2:size(coverage,2)
    % first summarize all
    sumAll=0;
    for j=2:size(coverage,1)
        sumAll=sumAll + str2double(coverage{j,i});
    end
    % then normalize the abundances
    for j=2:size(coverage,1)
        abundanceNew{j,i}=str2double(coverage{j,i})/sumAll;
    end
end

% verify that numbers add up to 1
for i=2:size(abundanceNew,2)
    summedUp = sum(cell2mat(abundanceNew(2:end,i)));
    if summedUp > 1 + tol || summedUp < 1 - tol
        error('Normalized abundances do not sum up to 1!')
    end
end

% cut out organisms with abundances considered below detection limit
for i=2:size(abundanceNew,1)
    for j=2:size(abundanceNew,2)
        if abundanceNew{i,j} < cutoff
            abundanceNew{i,j} = 0;
        end
    end
end

% remove organisms that are no longer in any sample
cnt=1;
delArray=[];
for i=2:size(abundanceNew,1)
    if sum(cell2mat(abundanceNew(i,2:end))) < tol
        delArray(cnt)=i;
        cnt=cnt+1;
    end
end
abundanceNew(delArray,:) = [];

cell2csv([pwd filesep 'normalizedCoverage.csv'],abundanceNew)

normalizedCoverage = abundanceNew;
normalizedCoveragePath = [pwd filesep 'normalizedCoverage.csv'];
end
