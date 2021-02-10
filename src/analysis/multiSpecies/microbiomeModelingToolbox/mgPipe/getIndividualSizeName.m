function [sampNames, organisms] = getIndividualSizeName(abunFilePath)
% This function automatically detects organisms, names and number of individuals present
% in the study.
%
% USAGE:
%
%   [sampNames, organisms] = getIndividualSizeName(abunFilePath)
%
% INPUTS:
%   abunFilePath:        char with path and name of file from which to retrieve information
%
% OUTPUTS:
%   sampNamess:          nx1 cell array cell array with names of individuals in the study
%   organisms:           nx1 cell array cell array with names of organisms in the study
%
% .. Author: Federico Baldini 2017-2018
%            Almut Heinken, 03/2021: simplified inputs

[sampNames] = readtable(abunFilePath, 'ReadVariableNames', false);
% Creating array to compare with first column 
fcol=table2cell(sampNames(2:height(sampNames),1));
if size(fcol,1)>1
    if  ~isa(fcol{2,1},'char')
        fcol=cellstr(num2str(cell2mat(fcol)));
    end
end
spaceColInd=strmatch(' ',fcol);
if length(spaceColInd)>0
   fcol(spaceColInd)=strrep(fcol(spaceColInd),' ','');
end
pIndex=cellstr(num2str((1:(height(sampNames)-1))'));
spaceInd=strmatch(' ',pIndex);
pIndexN=pIndex;
if length(spaceInd)>0
    pIndexN(spaceInd)=strrep(pIndex(spaceInd),' ','');
end
% Adding index column if needed
if isequal(fcol,pIndexN)
    disp('Index fashion input file detected');
else
   disp('Plain csv input format: adding index for internal purposes');
   addIndex=['Index';pIndex];
   sampNames=horzcat((cell2table(addIndex)),sampNames);
end
oldsampNames=sampNames;
s = size(sampNames);
s = s(1, 2);
sampNames = sampNames(1, 3:s);
sampNames = table2cell(sampNames);
sampNames = sampNames';
%Cheching that names are valid matlab ids
for i=1:length(sampNames)
    if isvarname(sampNames{i,1})==0
       warning('It looks like the name of your samples is not a valid Matlab name. Most probably you have names starting with numbers. I will convert names in Matlab valid names to avoid problems during export into csv. Plese, consider changing the names of samples.')
       sampNames(i,1)=cellstr(matlab.lang.makeValidName(sampNames{i,1}));
   end
end

for i=1:length(sampNames)
   if isvarname(sampNames{i,1})==0
       error('ERROR:I tried with no success to change your samples names into Matlab valid names. Please change your samples (observations) names and try running again mgPipe.')
   end
end

% getting info on present strains
organisms = oldsampNames(2:height(oldsampNames), 2);  
organisms = table2cell(organisms);  % extracted names of models
end
