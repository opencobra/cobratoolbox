function varargout = loadBiGGModel( model_ids, format, multichoice)
% Reads from url http://bigg.ucsd.edu/api/v2/models
%
% USAGE:
%
%    model = listBiGGModel(model_ids)
%
% OPTIONAL INPUTS:
%
%    model_ids:     The BiGG ID(s) of the model(s). If no ID is provided (either empty or no arguments) a gui
%                   will ask for the model to load.
%    format:        The format from Bigg to load. Either 'sbml' or ('mat').
%                   Default('mat')
%    multichoice:   Whether multiple models can be loaded if no ids are
%                   given. (Default: true)
% OUTPUT:
%    varargout:     The models in the order of the selected ids. If
%                   multiple models are selected in the dialog, a struct
%                   is provided with the models being fields of that
%                   struct.
%                   
% EXAMPLES:
%
%    1) Load a specific model from the mat file of the BiGG database
%           model = loadBiGGModel('e_coli_core');
%
%    2) Load several models from the BiGG database at once        
%           [model1, model2, ... = loadBiGGModel({'bigg_id1','bigg_id2',...});
%
%    3) Load model from the BiGG database sbml files
%           model = loadBiGGModel('iJR904','sbml');
%
%
% .. Authors:
%       - Thomas Pfau Sep 2017 

BIGG_FolderName = tempname;
mkdir(BIGG_FolderName);
finishup = onCleanup(@() rmdir(BIGG_FolderName,'s'));

if ~exist('format','var')
    format = 'mat';
end

if ~exist('multichoice','var')
    multichoice = true;
end
if multichoice
    selectionMode = 'multichoice';
else
    selectionMode = 'single';
end

if strcmp(format,'sbml')
    format = 'xml';
end

%Do not create a struct for multiple ids
structout = false;

modelfiles = {};

modelOptions = webread('http://bigg.ucsd.edu/api/v2/models');
modelOptions = modelOptions.results;
modelIDs = {modelOptions.bigg_id}';

if nargin == 0 || isempty(model_ids)
    orgNames = cellfun(@(x,y) strcat(x,' [',y,']'), {modelOptions.organism}, {modelOptions.bigg_id}, 'UniformOutput',0)' ;
    [sortedNames, order] = sort(orgNames);
    maxNameSize = max(cellfun(@numel,orgNames));
    
    if usejava('desktop')
        [s,v] = listdlg('Name','Model Selection','PromptString','Select Model(s) to download','SelectionMode',selectionMode, ...
                    'OKString','Load', 'ListString', sortedNames, 'ListSize', [maxNameSize*7,160] );
    else
        for i = 1:numel(sortedNames)
            fprintf('%i: %s\n',i,sortedNames{i});
        end
        s = input(['Please select a model (e.g. type 3 for ' sortedNames{3} '):'],'s');        
        s = str2num(s);
    end
   
    model_ids = modelIDs(order(s)); 
    if numel(model_ids) > 1
        structout = true;
    end
else
    if ~iscell(model_ids)
        model_ids = {model_ids};
    end
    
    present = ismember(model_ids,modelIDs);
    if any(~present)
        nonpresent = model_ids(~present);
        model_ids = model_ids(present);
        fprintf('Could not find the following model ids in BiGG:\n');
        for i = 1:numel(nonpresent)
            fprintf('%s\n',nonpresent{i});
        end
    end
end

%If nothing is selected return nothing.
if numel(model_ids) == 0
       warning('No model selected.')
       varargout = {};
       return 
end

varargout = cell(numel(model_ids),1);
for i = 1:numel(model_ids)
    filename = [BIGG_FolderName filesep model_ids{i} '.' format];
    url = ['http://bigg.ucsd.edu/static/models/' model_ids{i} '.' format];
    websave(filename,url);
    varargout{i} = readCbModel(filename);
end

if structout
    outstruct = struct();
    for i = 1:numel(model_ids)
        fieldID = regexprep(model_ids{i},'[^a-zA-Z0-9_]','');
        if isempty(regexp(fieldID,'^[a-zA-Z]'))
            fieldID = ['M_' fieldID];
        end
        outstruct.(fieldID) = varargout{i};
    end
    varargout = {outstruct};
end
