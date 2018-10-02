function [indNumb, sampName, organisms] = getIndividualSizeName(abunFilePath)
% This function automatically detects organisms, names and number of individuals present
% in the study.
%
% USAGE:
%
%   [indNumb, sampName, organisms] = getIndividualSizeName(abunFilePath)
%
% INPUTS:
%   abunFilePath:        char with path and name of file from which to retrieve information
%
% OUTPUTS:
%   indNumb:             number of individuals in the study
%   sampName:            nx1 cell array cell array with names of individuals in the study
%   organisms:           nx1 cell array cell array with names of organisms in the study
%
% .. Author: Federico Baldini 2017-2018

[sampName] = readtable(abunFilePath, 'ReadVariableNames', false);
% Creating array to compare with first column 
fcol=table2cell(sampName(2:height(sampName),1));
if  ~isa(fcol{2,1},'char')
     fcol=cellstr(num2str(cell2mat(fcol))); 
end
spaceColInd=strmatch(' ',fcol);
if length(spaceColInd)>0
   fcol(spaceColInd)=strrep(fcol(spaceColInd),' ','');
end
pIndex=cellstr(num2str((1:(height(sampName)-1))'));
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
   sampName=horzcat((cell2table(addIndex)),sampName);
end
oldSampName=sampName;
s = size(sampName);
s = s(1, 2);
sampName = sampName(1, 3:s);
sampName = table2cell(sampName);
sampName = sampName';
%Cheching that names are valid matlab ids
for i=1:length(sampName)
    if isvarname(sampName{i,1})==0
       warning('It looks like the name of your samples is not a valid Matlab name. Most probably you have names starting with numbers. I will convert names in Matlab valid names to avoid problems during export into csv. Plese, consider changing the names of samples.')
       sampName(i,1)=cellstr(matlab.lang.makeValidName(sampName{i,1}));
   end
end

for i=1:length(sampName)
   if isvarname(sampName{i,1})==0
       error('ERROR:I tried with no success to change your samples names into Matlab valid names. Please change your samples (observations) names and try running again mgPipe.')
   end
end

indNumb = length(sampName);  % number of individuals
% getting info on present strains
organisms = oldSampName(2:height(oldSampName), 2);  
organisms = table2cell(organisms);  % extracted names of models
end
