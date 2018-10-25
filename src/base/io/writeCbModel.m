function outmodel = writeCbModel(model, varargin)
% Writes out COBRA models in various formats
%
% USAGE:
%
%    outmodel = writeCbModel(model, varargin)
%
% INPUTS:
%    model:             Standard COBRA model structure
%
% OPTIONAL INPUTS:
%    varargin:          Optional parameters in 'Parametername',value
%                       format. Available parameterNames are:
%                       * format:   File format to be used ('text', 'xls', 'mat'(default) 'expa' or 'sbml')
%                         text will only output data from required fields (with GPR rules converted to string representation)
%                         xls is restricted to the fields defined in the xls io documentation.
%                         expa will print all reactions with Exchangers being detected by findExcRxns
%                       * fileName: File name for output file (optional, default opens dialog box)
%                       * compSymbols: List of compartment symbols (Cell array)
%                       * compNames:   List of compartment names corresponding to `compSymbolList` (Cell array)
%
% OPTIONAL OUTPUTS:
%    outmodel:          Only useable with sbml export. Will return the sbml structure, otherwise the input COBRA model structure is returned.
%
% .. Authors:
%       - Ines Thiele 01/10 - Added more options for field to write in xls format
%       - Richard Que 3/17/10 -  Added ability to specify compartment names and symbols
%       - Longfei Mao 26/04/2016 -  Added support for the FBCv2 format
%       - Thomas Pfau May 2017  - Changed To Parameter/Value pairs and added flexibility
%
% EXAMPLES:
%
%    % Write a model in sbml format (a popup will ask for the name)
%    outmodel = writeCbModel(model, 'format','sbml')
%    % Write a model in the specified format with the given file name
%    outmodel = writeCbModel(model, 'format','mat', 'fileName', 'TestModel.mat')
%
% NOTE:
%    The `writeCbModel` function relies on another function
%    `io/utilities/writeSBML.m` to convert a COBRA-Matlab structure into
%    a libSBML-Matlab structure and then call `libSBML` to export a
%    FBCv2 file. The current version of the `writeSBML.m` does not require the
%    SBML toolbox (http://sbml.org/Software/SBMLToolbox).

newKeyWords = {'format', 'fileName', 'compSymbols', 'compNames'};

% set default values
supportedSBML = 3;
supportedSBMLv = 1;
fileName = '';

% We can assume, that the old syntax is not used, if there is no varargin
% i.e. if numel varargin == 0

legacySignature = false;

% check if the first argument of varargin is a keyword
if numel(varargin) > 0    
    if ischar(varargin{1})        
        if any(ismember(varargin{1}, newKeyWords))
            legacySignature = false;            
        else 
            if ~isempty(regexp(varargin{1},'\.','ONCE')) % this is a file name.
                varargin = {'fileName', varargin{1}, varargin{2:end}};
                legacySignature = false;            
            else
               legacySignature = true;            
            end
        end
    else
        %If its not a char, its not the old signature, as that signature
        %required format as second argument. So we can throw an error.
        error('Additional arguments have to be Parameter and Value pairs of the form ''ParameterName'', value ');
    end 
end

[compSymbols, compNames] = getDefaultCompartmentSymbols();
if isfield(model, 'comps')
    compSymbols = model.comps;
    compNames = compSymbols;
end

if isfield(model, 'compNames')
    compNames = model.compNames;
end

% convert model if certain fields are missing
results = verifyModel(model,'silentCheck',true);
if ~isempty(results)
    model = convertOldStyleModel(model);
end

% parse if there are more than 3 inputs
if legacySignature
    if ~isempty(varargin), format = varargin{1}; end
    if length(varargin) > 1, fileName = varargin{2}; end
    if length(varargin) > 2
        input.compSymbols = varargin{3};
    else
        input.compSymbols = compSymbols;
    end
    if length(varargin) > 3
        input.compNames = varargin{4};
    else
        input.compNames = compNames;
    end
    if length(varargin) > 4
        if varargin{5} ~= supportedSBML
            error(['Only SBML ', num2str(supportedSBML), ' is supported.']);
        end
    end
    if length(varargin) > 5
        if varargin{6} ~= 1
            error(['Only SBML version ', num2str(supportedSBMLv), ' is supported.']);
        end
    end
else
    parser = inputParser();
    
    parser.addRequired('model', @(x) verifyModel(model, 'simpleCheck', true));
    parser.addParamValue('format', 'toselect', @ischar);
    parser.addParamValue('fileName', '', @ischar);
    parser.addParamValue('compSymbols', compSymbols, @(x) isempty(x) || iscell(x));
    parser.addParamValue('compNames', compNames, @(x) isempty(x) || iscell(x));

    % We currently only support output in SBML 3
    parser.addParamValue('sbmlLevel', supportedSBML, @(x) isnumeric(x));
    parser.addParamValue('sbmlVersion', supportedSBMLv, @(x) isnumeric(x));

    parser.parse(model, varargin{:});
    input = parser.Results;
    format = input.format;
    fileName = input.fileName;
end
if nargout > 0
    outmodel = model;
end

% Assume constraint matrix is S if no A provided.
if ~isfield(model, 'A') && isfield(model, 'S')
    model.A = model.S;
else
    model.S = model.A;
end

% determine the number of reactions
nRxns = size(model.S, 2);

% Open a dialog to select file name
if isempty(fileName)
    switch format
        case 'xls'
            [fileNameFull, filePath] = uiputfile({'*.xls;*.xlsx'});
        case {'text', 'txt'}
            [fileNameFull, filePath] = uiputfile({'*.txt'});
        case 'sbml'
            [fileNameFull, filePath] = uiputfile({'*.xml'});
        case 'mat'
            [fileNameFull, filePath] = uiputfile({'*.mat'});
        case 'expa'
            [fileNameFull, filePath] = uiputfile({'*.expa'});
        case 'toselect'
            [fileNameFull, filePath] = uiputfile({'*.mat', 'Matlab File'; '*.xml' 'SBML Model'; '*.txt' 'Text Export'; '*.xls;*.xlsx' 'Excel Export'; '*.MPS' 'MPS Export'});
        otherwise
            [fileNameFull, filePath] = uiputfile({'*'});
    end
    if fileNameFull
        [folder, fileName, extension] = fileparts([filePath filesep fileNameFull]);
        fileName = [folder filesep fileName extension];
        format = getFormatFromExtension(extension);
    else
        return;
    end
else
    if strcmp(format,'toselect') % no format was given. try to detect from fileName.
        [~, ~, extension] = fileparts(fileName);
        format = getFormatFromExtension(extension);
    end        
end
% Use lower case
format = lower(format);
switch format
    %% Text file
    case {'text', 'txt'}
        fid = fopen(fileName, 'w');
        formulas = printRxnFormula(model, 'printFlag', 0);
        fprintf(fid, 'Rxn name\t');
        fprintf(fid, 'Formula\t');
        if isfield(model, 'rules')
            model = creategrRulesField(model);
            fprintf(fid, 'Gene-reaction association\t');
        end
        fprintf(fid, 'LB\tUB\tObjective\n');
        for i = 1:nRxns
            fprintf(fid, '%s\t', model.rxns{i});
            fprintf(fid, '%s\t', formulas{i});
            if (isfield(model, 'rules'))
                fprintf(fid, '%s\t', model.grRules{i});
            end
            fprintf(fid, '%6.2f\t%6.2f\t%6.2f\n', model.lb(i), model.ub(i), model.c(i));
        end
        fclose(fid);
        %% Excel file
    case {'xls', 'xlsx'}
        if isempty(strfind(fileName, format))
            model2xls(model, strcat(fileName, '.', format), input.compSymbols, input.compNames);
        else
            model2xls(model, fileName, input.compSymbols, input.compNames);
        end
        %% SBML
    case 'sbml'
        if (isunix && (strcmp(fileName, '~') || strncmp(fileName, '~/', 2)))
            if ~isempty(getenv('HOME'))
                fileName(1) = [];
                fileName = [getenv('HOME'), fileName];
            end
        end
        outmodel = writeSBML(model, fileName, input.compSymbols, input.compNames);
        %% Mat
    case 'mat'
        save(fileName, 'model')
        %% expa
    case 'expa'
        convertModelToEX(model,fileName,0,model.rxns(findExcRxns(model)));
        %% Uknown
    otherwise
        error('Unknown file format');
end


% Construct gene name string
function geneStr = constructGeneStr(geneNames)

geneStr = '';
for i = 1:length(geneNames)
    geneStr = [geneStr ' ' geneNames{i}];
end
geneStr = strtrim(geneStr);



function format = getFormatFromExtension(extension)
%Get the format from the file extension.
%
% INPUT: 
%
%    extension:     The file extension
%
% OUTPUT:
%    
%    format:        The file format

switch extension
    case '.MPS'
        format = 'mps';
    case {'.xls', '.xlsx'}
        format = 'xls';
    case '.txt'
        format = 'text';
    case '.xml'
        format = 'sbml';
    case '.mat'
        format = 'mat';
    case '.expa'
        format = 'expa';
    otherwise
        format = 'unknown';
end