function writeNewtExperiment(model,metData,metSampleNames,fileName,param)
%writes out an experimental data file for an model exported to SBML and
%imported into newteditor

% version\t1.0
% name\tsample experiment data
% description\tAdenoid Cystic Carcinoma 2014 vs 2019
% color\t0\t#FFFFFF\t100\t#FF0000
% gene\t2014\t2019
% RB1\t36\t12
% TP53\t36\t72
% CDKN2A\t0\t14
% MDM2\t0\t5
% CCNE\t0\t7

[nNodes,nSamples]=size(metData);
[nMets,nRxns]=size(model.S);
if nNodes ~= nMets
    error('size(metData,1) must equal size(model.S,1)')
end

if ~exist('fileName','var')
    fileName = [pwd filesep 'newtExpData.txt'];
end

fid = fopen(fileName,'w');

if ~exist('param','var')
    param=struct;
end

if ~isfield(param,'version')
    param.version = datestr(now,30);
end

if ~isfield(param,'name')
    if isfield(model,'modelID')
        param.name = model.modelID;
    else
        param.name = 'aModel';
    end
end

if ~isfield(param,'description')
    if isfield(model,'description')
        param.description = model.description;
    else
        param.description = 'aDescription';
    end
end

% color\t0\t#FFFFFF\t100\t#FF0000
%color -100  0 #00FF00 100 #0000FF
if ~isfield(param,'color')
   param.color.minValue = -100;
   param.color.minColor = '#FF0000';
   param.color.zeroValue = 0;
   param.color.zeroColor = '#FF0000';
   param.color.maxValue =  100;
   param.color.maxColor = '#0000FF';
%    if ~isfield(param.color,'string')
%         param.color.string = [param.color.minValue '\t' param.color.minColor '\t' param.color.zeroValue '\t' param.color.zeroColor '\t' param.color.maxValue '\t' param.color.maxColor];
%    end
end


%fprintf('name\tsample experiment data\r\ndescription\tAdenoid Cystic Carcinoma 2014 vs 2019\r\nel\t2014\t2019\r\nRB1\t36\t12\r\nTP53\t36\t72\r\nCDKN2A\t0\t14\r\nMDM2\t0\t5\r\nCCNE\t0\t7\r')


%header
fprintf(fid,'%s\t%s\n','version', param.version);
fprintf(fid,'%s\t%s\n','name', param.name);
fprintf(fid,'%s\t%s\n','description', param.description);
fprintf(fid,'%s\t%i\t%s\t%i\t%s\t%i\t%s\n','color', param.color.minValue,param.color.minColor,param.color.zeroValue,param.color.zeroColor,param.color.maxValue ,param.color.maxColor);

%experiment names
fprintf(fid,'%s\t','node');
if ~exist('metSampleNames','var')
    for n=1:nSamples
        if n~=nSamples
            fprintf(fid,'%s\t',['exp' int2str(n)]);
        else
            fprintf(fid,'%s',['exp' int2str(n)]);
        end
    end
    fprintf(fid,'\n');
else
    if ischar(metSampleNames)
        metSampleNames={metSampleNames};
    end
    for n=1:nSamples
        if n~=nSamples
            fprintf(fid,'%s\t',metSampleNames{n});
        else
            fprintf(fid,'%s',metSampleNames{n});
        end
    end
    fprintf(fid,'\n');
end

%assume that the map in newt was exported via an sbml file, in which case
%the node ids are in sbml format
convertedMets = convertSBMLID(model.mets);

%experimental data
useM=0;
for i=1:nMets
    if useM
        fprintf(fid,'%s',['M_' convertedMets{i}]);
    else
        fprintf(fid,'%s\t',model.metNames{i});
    end
    
    for j=1:nSamples
        if j~=nSamples
            fprintf(fid,'%i\t', full(metData(i,j)));
        else
            fprintf(fid,'%i', full(metData(i,j)));
        end
    end
    fprintf(fid,'\n') ;
end

fclose(fid);
