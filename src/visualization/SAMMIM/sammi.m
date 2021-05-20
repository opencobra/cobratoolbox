function sammi(model, parser, data, secondaries, options)
% Visualize the given model, set of reactions, and/or data using SAMMI.
% Documentation at: https://sammim.readthedocs.io/en/latest/index.html
% 
% Citation: Schultz, A., & Akbani, R. (2019). SAMMI: A Semi-Automated 
%     Tool for the Visualization of Metabolic Networks. Bioinformatics.
% 
% USAGE:
% sammi(model,parser,data,secondaries,options)
% 
% INPUT:
%   model: COBRA model to be visualized
% 
% OPTIONAL INPUTS:
%   parser: How the model is to be parsed. There are four possible 
%   options for this parameter. Default empty array.
%       *empty array: If this parameter is an empty arrray, all reaction 
%       in the model will be loaded in a single map. Not advisable for
%       large maps.
%       *string: If this parameter is a characters array there are two
%       options. Either the parameter defines the path to a SAMMI map (JSON
%       file downloaded from a previous instance of SAMMI), in which case
%       the given map will be used, or the parameter defines a field in the
%       model struct, in which case this field will be used to parse the
%       model into subgraphs.
%       *cell array: If this parameter is a cell array, it should be a cell
%       array of strings containing reaction IDs. Only these reactions will
%       be included in a single SAMMI map.
%       *struct: If this model is a struct of length n, the model will be
%       parsed into n subgraphs. Each element of the struct should contain
%       two fields plus an additional optional one:
%           name: Name of the subgraph.
%           rxns: Reactions to be included in the subgraph.
%           flux: Optional field. Data to be mapped as reaction color.
%   data: Data to be mapped onto the model. Struct of length n. Defaults 
%   to an empty array where no data is mapped. Element of the struct should 
%   contain two fields:
%       type: A cell array of two strings. The firt string should be
%       either 'rxns', 'mets', or 'links' indicating which type of data
%       is to be mapped. The second string should be either 'color' or
%       'size', indicating how the data is to  be mapped. 'links' only
%       work with 'size', since link color is the same as the one of
%       the reaction it is assciated with.
%       data: a table object. VariableNames will be translated into 
%       condition names, and RowNames should be reaction IDs for 'rxns'
%       and 'links' data, and metabolite IDs for 'mets' data. NaN values
%       will not be mapped.
%   secondaries: Cell array of strings of regular expressions. All 
%   metabolites, in all subgraphs, matching any of the regular expressions
%   will be shelved. Default to empty array where no metabolites are
%   shelved.
%   options: Struct with the following fields:
%       htmlName: Name of the html file to be written and opened for the
%       visualization. Defaults to 'index_load'. Change this options to
%       write to a different html file that will not be overwritten by the
%       default option.
%       load: Load the html file in a new tab upon writing the file.
%       Default to true. If you would not like a new tab to open, set
%       this parameter to false and refresh a previously opened window. To
%       open a new window without re-running SAMMI use the openSammi
%       function.
%       jscode: String. Defaults to empty string. Additional JavaScript 
%       code to run after loading the map. Can be any code to modify the
%       loaded map.
% 
% OUTPUT:
%   No MATLAB output. Opens a browser window with the SAMMI visualization.
% 
% EXAMPLES:
%   %1 Open model in single map
%   sammi(model)
% 
%   %2 Open model as multiple subgraphs divided by subSystems
%   sammi(model,'subSystems')
% 
%   %3 Open model as multiple subgraphs divided by subSystems, load two
%   %conditions with randomly generated data, and shelve hydrogen, water,
%   %and O2 upon loading.
%   rxntbl = array2table(randn(length(model.rxns),2),...
%       'VariableNames', {'condition1','condition2'},...
%       'RowNames', model.rxns);
%   data(1).type = {'rxns' 'color'};
%   data(1).data = rxntbl;
%   data(2).type = {'rxns' 'size'};
%   data(2).data = rxntbl;
%   secondaries = {'^h\[.\]$','^h20\[.\]$','^o2\[.\]$'};
%   sammi(model,'subSystems',data,secondaries)

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

%Read in index
sfolder = regexprep(which('sammi'),'sammi.m$','');
html = fileread([sfolder 'index.html']);

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

%Write to file
fid = fopen([sfolder options.htmlName],'w');
fprintf(fid,html);
fclose(fid);

%Open window
if options.load
    web([sfolder options.htmlName],'-browser')
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
