function varargout = loadBiGGModels( model_ids, format)
% Reads from url http://bigg.ucsd.edu/api/v2/models
%
% USAGE:
%
%    model = listBiGGModels(model_ids)
%
% OPTIONAL INPUTS:
%
%    model_ids:     The BiGG ID(s) of the model(s). If no ID is provided (either empty or no arguments) a gui
%                   will ask for the model to load.
%    format:        The format from Bigg to load. Either 'sbml' or ('mat').
%                   Default('mat')
% OUTPUT:
%    varargout:     The models in the order of the selected ids. If
%                   multiple models are selected in the dialog, a struct
%                   is provided with the models being fields of that
%                   struct.
%                   
%
%  
%
BIGG_FolderName = tempname;

finishup = onCleanup(@() rmdir(BIGG_FolderName,'s'));

if ~exist('format','var')
    format = 'mat';
end

if strcmp(format,'sbml')
    format = 'xml';
end

%Do not create a struct for multiple ids
structout = false;

modelfiles = {};
if nargin == 0 || isempty(model_ids)
    modelOptions = webread('http://bigg.ucsd.edu/api/v2/models');
    modelOptions = modelOptions.results;
    modelIDs = {modelOptions.bigg_id}';
    orgNames = cellfun(@(x,y) strcat(x,' [',y,']'), {modelOptions.organism}, {modelOptions.bigg_id}, 'UniformOutput',0)' ;
    [sortedNames, order] = sort(orgNames);
    maxNameSize = max(cellfun(@numel,orgNames));
    
    if usejava('desktop')
        [s,v] = listdlg('Name','Model Selection','PromptString','Select Model(s) to download',...
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
end

%If nothing is selected return nothing.
if numel(model_ids) == 0
       warning('No model selected.')
       varargout = {};
       return 
end


mkdir(BIGG_FolderName);

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
        fieldID = regexprep('[^a-zA-Z0-9_]','');
        if isempty(fieldID,'$[a-zA-Z]')
            fieldID = ['M_' fieldID];
        end
        outstruct.(fieldID) = varargout{i};
    end
    varargout = {outstruct};
end
