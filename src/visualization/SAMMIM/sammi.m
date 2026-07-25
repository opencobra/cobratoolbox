function sammi(model, parser, data, secondaries, options)
% Visualize the given model, set of reactions, and/or data using SAMMI.
% Documentation at: https://sammim.readthedocs.io/en/latest/index.html
%
% Citation: Schultz, A., & Akbani, R. (2019). SAMMI: A Semi-Automated
% Tool for the Visualization of Metabolic Networks. Bioinformatics.
%
% USAGE:
%
%    sammi(model, parser, data, secondaries, options)
%
% INPUTS:
%    model:           COBRA model to be visualized. Fields used:
%
%                       * .rxns - reaction identifiers
%                       * .subSystems - subsystem assigned to each
%                         reaction; read when `parser` names a model
%                         field used to split the model into subgraphs
%
% OPTIONAL INPUTS:
%    parser:          How the model is to be parsed. Default empty
%                     array. One of four forms:
%
%                       * Empty array - all reactions in the model are
%                         loaded in a single map. Not advisable for
%                         large maps.
%                       * Char array - either the path to a SAMMI map
%                         (JSON file downloaded from a previous
%                         instance of SAMMI), in which case the given
%                         map is used, or the name of a field in the
%                         model struct, in which case that field is
%                         used to parse the model into subgraphs.
%                       * Cell array - a cell array of reaction ID
%                         strings; only these reactions are included
%                         in a single SAMMI map.
%                       * Struct array of length `n` - the model is
%                         parsed into `n` subgraphs. Each element
%                         should contain two required fields plus one
%                         optional field:
%
%                           * .name - name of the subgraph
%                           * .rxns - reactions to be included in the
%                             subgraph
%                           * .flux - optional; data to be mapped as
%                             reaction color
%
%    data:            Data to be mapped onto the model. Struct of
%                     length `n`. Defaults to an empty array where no
%                     data is mapped. Each element should contain two
%                     fields:
%
%                       * .type - a cell array of two strings; the
%                         first is `rxns`, `mets`, or `links`,
%                         indicating which type of data is mapped, and
%                         the second is `color` or `size`, indicating
%                         how the data is mapped (`links` only
%                         supports `size`, since link color follows
%                         the associated reaction)
%                       * .data - a table object; `VariableNames` are
%                         translated into condition names, and
%                         `RowNames` should be reaction IDs for
%                         `rxns`/`links` data and metabolite IDs for
%                         `mets` data. `NaN` values are not mapped
%
%    secondaries:     Cell array of regular-expression strings. All
%                     metabolites, in all subgraphs, matching any of
%                     the regular expressions are shelved. Defaults to
%                     an empty array where no metabolites are shelved.
%    options:         Struct with the following fields:
%
%                       * .htmlName - name of the html file to be
%                         written and opened for the visualization.
%                         Defaults to `index_load`. Change this field
%                         to write to a different html file that will
%                         not be overwritten by the default option
%                       * .load - load the html file in a new tab upon
%                         writing the file. Defaults to true. If a new
%                         tab should not open, set this field to false
%                         and refresh a previously opened window; use
%                         the `openSammi` function to open a new
%                         window without re-running `sammi`
%                       * .jscode - string, defaults to an empty
%                         string. Additional JavaScript code to run
%                         after loading the map. Can be any code to
%                         modify the loaded map
%
% OUTPUT:
%    No MATLAB output. Opens a browser window with the SAMMI visualization.
%
% EXAMPLES:
%
%    %1 Open model in single map
%    sammi(model)
%
%    %2 Open model as multiple subgraphs divided by subSystems
%    sammi(model,'subSystems')
%
%    %3 Open model as multiple subgraphs divided by subSystems, load two
%    %conditions with randomly generated data, and shelve hydrogen, water,
%    %and O2 upon loading.
%    rxntbl = array2table(randn(length(model.rxns),2),...
%        'VariableNames', {'condition1','condition2'},...
%        'RowNames', model.rxns);
%    data(1).type = {'rxns' 'color'};
%    data(1).data = rxntbl;
%    data(2).type = {'rxns' 'size'};
%    data(2).data = rxntbl;
%    secondaries = {'^h\[.\]$','^h20\[.\]$','^o2\[.\]$'};
%    sammi(model,'subSystems',data,secondaries)

if nargin < 2
    parser = [];
end
if nargin < 3
    data = [];
end
if nargin < 4
    secondaries = [];
end
if nargin < 5 || ~isfield(options,'htmlName')
    options.htmlName = 'index_load.html';
elseif isempty(regexp(options.htmlName,'\.html$'))
    options.htmlName = [options.htmlName '.html'];
end
if nargin < 5 || ~isfield(options,'load')
    options.load = true;
end
if nargin < 5 || ~isfield(options,'jscode')
    options.jscode = '';
end

%Read in index. The SAMMI web-app template and its assets are vendored under
%external/visualization/SAMMIM/ (relocated out of src/); resolve them from the
%toolbox root rather than beside this wrapper.
sfolder = regexprep(which('sammi'),'sammi.m$','');   % SAMMI wrapper dir (default output location)
sammiExternal = [fileparts(which('initCobraToolbox')) filesep 'external' filesep 'visualization' filesep 'SAMMIM' filesep];
html = fileread([sammiExternal 'index.html']);
%Point the template's local asset references at the relocated external/ copy so the
%generated HTML resolves them regardless of where the output file is written.
localAssets = {'sammi.css','helpfunctions.js','uploaddownload.js','simulationfunctions.js'};
for iAsset = 1:numel(localAssets)
    html = strrep(html, ['''' localAssets{iAsset} ''''], ['''' sammiExternal localAssets{iAsset} '''']);
    html = strrep(html, ['"' localAssets{iAsset} '"'], ['"' sammiExternal localAssets{iAsset} '"']);
end

%Define options
if isstruct(parser)
    jsonstr = structParse(model,parser);
elseif ischar(parser) && exist(parser,'file') == 2 && ~isempty(regexp(parser,'\.json$','ONCE'))
    %Read map
    jsonstr = fileread(parser);
    jsonstr = strrep(jsonstr,'\','\\');
    %Add graph
    jsonstr = strcat('e = ',jsonstr,';\nreceivedTextSammi(JSON.stringify(e));');
elseif ischar(parser) && isfield(model,parser)
    ss = unique(model.(parser));
    if length(model.(parser)) == length(model.rxns)
        for i = 1:length(ss)
            dat(i).name = ss{i};
            dat(i).rxns = model.rxns(ismember(model.subSystems,ss{i}));
        end
    else
        for i = 1:length(ss)
            dat(i).name = ss{i};
            dat(i).rxns = model.rxns(sum(model.S(ismember(model.(parser),ss{i}),:)) ~= 0);
        end
    end
    jsonstr = structParse(model,dat);
elseif iscell(parser) || isempty(parser)
    if iscell(parser)
        %Keep only reactions we want
        model = removeRxns(model,model.rxns(~ismember(model.rxns,parser)));
    end
    %Convert model to sammi JSON string
    jsonstr = makeSAMMIJson(model);
    %Add graph
    jsonstr = strcat('e = ',jsonstr,';\nreceivedJSONwrapper(e)');
end

%Add data
for i = 1:length(data)
    if isequal(data(i).type{1},'rxns')
        if isequal(data(i).type{2},'color')
            datastring = makeSAMMIdataString(data(i).data);
            jsonstr = strcat(jsonstr,';\ndat = ',datastring,...
                ';\nreceivedTextFlux(dat)');
        elseif isequal(data(i).type{2},'size')
            datastring = makeSAMMIdataString(data(i).data);
            jsonstr = strcat(jsonstr,';\ndat = ',datastring,...
                ';\nreceivedTextSizeRxn(dat)');
        end
    end
    if isequal(data(i).type{1},'mets')
        if isequal(data(i).type{2},'color')
            datastring = makeSAMMIdataString(data(i).data);
            jsonstr = strcat(jsonstr,';\ndat = ',datastring,...
                ';\nreceivedTextConcentration(dat)');
        elseif isequal(data(i).type{2},'size')
            datastring = makeSAMMIdataString(data(i).data);
            jsonstr = strcat(jsonstr,';\ndat = ',datastring,...
                ';\nreceivedTextSizeMet(dat)');
        end
    end
    if isequal(data(i).type{1},'links')
        if isequal(data(i).type{2},'size')
            datastring = makeSAMMIdataString(data(i).data);
            jsonstr = strcat(jsonstr,';\ndat = ',datastring,...
                ';\nreceivedTextWidth(dat)');
        end
    end
end

%Shelve secondaries
if ~isempty(secondaries)
    secondaries = strrep(secondaries,'\','\\\\');
    jsonstr = strcat(jsonstr,';\nshelveList("(?:',strjoin(secondaries,')|(?:'),')");');
end

%Add last bit of code
jsonstr = strcat(jsonstr,';',options.jscode);

%Replace in html
html = strrep(html,'//MATLAB_CODE_HERE//',jsonstr);

%Account for speial characters
html = strrep(html,'%','%%');

% Determine output path from options.htmlName
[outputFolder, name, ext] = fileparts(options.htmlName);
if isempty(ext)
    ext = '.html';
end
if isempty(outputFolder)
    outputPath = fullfile(sfolder, [name ext]);
else
    outputPath = fullfile(outputFolder, [name ext]);
end

% Ensure the directory exists
if ~exist(outputFolder, 'dir') && ~isempty(outputFolder)
    mkdir(outputFolder);
end

% Write to file
fid = fopen(outputPath, 'w');
if fid == -1
    error('Could not open file %s for writing.', outputPath);
end
fprintf(fid, html);
fclose(fid);

% Open in browser
if options.load
    web(outputPath, '-browser');
end
end

function jsonstr = structParse(model,parser)
    %Get only reactions we are using
    rx = {};
    for i = 1:length(parser); rx = unique(cat(1,rx,parser(i).rxns)); end
    model = removeRxns(model,model.rxns(~ismember(model.rxns,rx)));
    %Convert model to sammi JSON file
    jsonstr = makeSAMMIJson(model);
    %Add graph
    jsonstr = strcat('graph = ',jsonstr);
    %Make conversion vector
    convvec = makeSAMMIparseVector(parser);
    %Add parssing line
    jsonstr = strcat(jsonstr,';\ne = ',convvec,';\nfilterWrapper(e)');
end
