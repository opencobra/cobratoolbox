function writeNewtExperiment(model, metData, metSampleNames, fileName, param)
% Writes out an experimental data file for a model exported to SBML and
% imported into newteditor
%
% USAGE:
%
%    writeNewtExperiment(model, metData, metSampleNames, fileName, param)
%
% INPUTS:
%    model:             COBRA model structure with fields:
%
%                         * .S - `m x n` stoichiometric matrix
%                         * .mets - `m x 1` array of metabolite identifiers
%                         * .metNames - `m x 1` array of metabolite names
%                         * .modelID - (optional) model identifier, used as
%                           the default experiment name
%                         * .description - (optional) model description,
%                           used as the default experiment description
%    metData:           `m x nSamples` matrix of metabolite data to write,
%                        where `m` equals `size(model.S, 1)`
%
% OPTIONAL INPUTS:
%    metSampleNames:    Cell array (or single string) of sample names, one
%                        per column of `metData` (default: `exp1`, `exp2`, ...)
%    fileName:          Path of the newt experiment data file to write
%                        (default: `newtExpData.txt` in the current folder)
%    param:             Structure with fields:
%
%                         * .version - version string written to the file
%                           header (default: current timestamp)
%                         * .name - experiment name (default:
%                           `model.modelID` if present, otherwise `aModel`)
%                         * .description - experiment description (default:
%                           `model.description` if present, otherwise
%                           `aDescription`)
%                         * .color - structure with fields `.minValue`,
%                           `.minColor`, `.zeroValue`, `.zeroColor`,
%                           `.maxValue`, `.maxColor` defining the color scale
%                           (default: red-to-blue scale)
%
% EXAMPLE:
%
%    % excerpt of the tab-delimited experiment data file format written by
%    % this function
%    version    1.0
%    name    sample experiment data
%    description    Adenoid Cystic Carcinoma 2014 vs 2019
%    color    0    #FFFFFF    100    #FF0000
%    gene    2014    2019
%    RB1    36    12
%    TP53    36    72
%    CDKN2A    0    14
%    MDM2    0    5
%    CCNE    0    7

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
