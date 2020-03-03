function model = readCbModel(fileName, varargin)
% Reads in a constraint-based model. If no arguments are passed to the function, the user will be prompted for a file name.
%
% USAGE:
%
%    model = readCbModel(fileName, varargin)
%
% 
% OPTIONAL INPUTS:
%    fileName:           File name for file to read in (char)
%    varargin:           Optional values as 'ParameterName',value pairs
%                        with the following available parameters:
%                        - fileType:  File type for input files: 'SBML', 'SimPheny',
%                          'SimPhenyPlus', 'SimPhenyText', 'Matlab', 'BiGG', 'BiGGSBML' or 'Excel' (Default = 'Matlab')
%                            * 'SBML' indicates a file in `SBML` format
%                            * 'SimPheny' is a set of three files in `SimPheny` simulation output format
%                            * 'SimPhenyPlus' is the same as 'SimPheny' except with
%                              additional files containing gene-protein-reaction
%                              associations andcompound information
%                            * 'SimPhenyText' is the same as 'SimPheny' except with
%                              additionaltext file containing gene-protein-reaction
%                              associations
%                            * Matlab will save the model as a matlab variable file.
%                            * BiGG and BIGGSBML indicate that the fileName is a BiGG
%                              Model identifier and that the model should
%                              be loaded from the BiGG database (requires
%                              an Internet connection). BiGG loads it from
%                              the BiGG Database mat file, BiGGSBML uses
%                              the SBML file.
%                            * Excel will save the model as a two sheet Excel Model.
%                        - modelDescription:    Description of model contents (char), default is the
%                          choosen filename
%                        - compSymbolList: Compartment Symbol List( cell array)
%                        - defaultBound: The default bound value (default 1000)
%                        - modelName: .mat file specific identifier, if
%                          provided, the specified model (if valid) will be
%                          loaded from the given mat file. If not given,
%                          the file will be scanned for models and all
%                          potential model structs will be provided as
%                          options to select from.
%                          (default: 'all')
%                       
%           
% OUTPUT:
%    model:               Returns a model in the COBRA format with at least the following fields:
%
%                           * .description - Description of model contents 
%                           * .rxns - Reaction names
%                           * .mets - Metabolite names
%                           * .S - Stoichiometric matrix
%                           * .lb - Lower bounds
%                           * .ub - Upper bounds
%                           * .c - Objective coefficients
%                           * .osenseStr - the objective sense ('max' or
%                           'min')
%                           * .csense - the constraint senses ('L' for
%                             lower than, 'G' - greated than, 'E' - equal)
%                           * .rules - Gene-reaction association rule in computable form
%                           * .genes - List of all genes
%
% EXAMPLES:
%
%    %1) Load a file to be specified in a dialog box:
%           model = readCbModel;
%
%    %2) Load model named 'iJR904' in SBML format with maximum flux set
%    %at 1000 (requires file named 'iJR904.xml' to exist)
%           model = readCbModel('iJR904','fileType','SBML','defaultBound', 1000);
%
%    %3) Load model named 'iJR904' in SimPheny format with maximum flux set
%    %at 500 (requires files named 'iJR904.rxn', 'iJR904.met', and 'iJR904.sto' to exist)
%           model = readCbModel('iJR904','fileType','SimPheny','defaultBound', 500);
%
%    %4) Load model named 'iJR904' in SimPheny format with gpr and compound information
%    %(requires files named 'iJR904.rxn', 'iJR904.met','iJR904.sto',
%    %'iJR904_gpr.txt', and 'iJR904_cmpd.txt' to exist)
%           model = readCbModel('iJR904','fileType','SimPhenyPlus');
%
% .. Authors:
%       - Markus Herrgard 7/11/06
%       - Richard Que 02/08/10 - Added inptus for compartment names and symbols
%       - Longfei Mao 26/04/2016 Added support for the FBCv2 format
%       - Thomas Pfau May 2017 Changed to parameter value pair, added excel IO and matlab flatfile IO.%
% NOTE:
%    The `readCbModel.m` function is dependent on another function
%    `io/utilities/readSBML.m` to use libSBML library
%    (http://sbml.org/Software/libSBML), to parse a SBML-FBCv2 file into a
%    COBRA-Matlab structure. The `readCbModel.m` function is backward
%    compatible with older SBML versions. A list of fields of a COBRA
%    structure is described in an Excel spreadsheet
%    `io/COBRA_structure_fields.xlsx`. While some fields are necessary for a
%    COBRA model, others are not.

optionalArgumentList = {'defaultBound', 'fileType', 'modelDescription', 'compSymbolList', 'compNameList', 'modelName'};
processedFileTypes = {'SBML', 'SimPheny', 'SimPhenyPlus', 'SimPhenyText', 'Excel', 'Matlab','BiGG','BiGGSBML'};

if numel(varargin) > 0
    % Check, whether we have an old style input. (i.e. varargins are not optional arguments
    if ischar(varargin{1}) && ~any(ismember(varargin{1}, optionalArgumentList))
        % We assume the old version to be used
        tempargin = cell(1, 2 * numel(varargin));
        % just replace the input by the options and replace varargin
        % accordingly
        for i = 1:numel(varargin)
            tempargin{2 * (i - 1) + 1} = optionalArgumentList{i};
            tempargin{2 * (i - 1) + 2} = varargin{i};
        end
        varargin = tempargin;
    end
end


[defaultCompSymbols, defaultCompNames] = getDefaultCompartmentSymbols();
parser = inputParser();
parser.addOptional('fileName', '', @(x) isempty(x) || ischar(x));
parser.addParamValue('defaultBound', 1000, @isnumeric);
parser.addParamValue('fileType', '', @(x) ischar(x) && any(strcmpi(processedFileTypes,x)));
parser.addParamValue('modelDescription', '', @ischar);
parser.addParamValue('compSymbolList', defaultCompSymbols, @iscell);
parser.addParamValue('compNameList', defaultCompNames, @iscell);
parser.addParamValue('modelName', 'all', @ischar);

if exist('fileName', 'var')
    parser.parse(fileName, varargin{:})
else
    parser.parse();
end

fileName = parser.Results.fileName;
defaultBound = parser.Results.defaultBound;
fileType = parser.Results.fileType;
modelDescription = parser.Results.modelDescription;
compSymbolList = parser.Results.compSymbolList;
compNameList = parser.Results.compNameList;
matlabModelName = parser.Results.modelName;
supportedFileExtensions = {'*.xml;*.sbml;*.sto;*.xls;*.xlsx;*.mat'};

% Open a dialog to select file
if ~exist('fileType', 'var') || isempty(fileType)
    % if no filename was provided, we open a UI window.
    if ~exist('fileName', 'var') || isempty(fileName)
        [fileName, pathName] = uigetfile([supportedFileExtensions, {'Model Files'}], 'Please select the model file');
        fileName = [pathName filesep fileName];
    end
    
    [~, ~, FileExtension] = fileparts(fileName);
    if isempty(FileExtension)
        % if we don't have a file extension, we try to see, which files
        % could match (only on the current directory, not on all the path).
        cfiles = dir(pwd);
        filenames = {cfiles.name};
        matchingFiles = filenames(~cellfun(@isempty, strfind(filenames, fileName)));
        % Check, whether one of those files matches any of the available
        % options
        filesToSelect = matchingFiles(~cellfun(@isempty, regexp(matchingFiles, [fileName, '\.[(?:' strjoin(strrep(supportedFileExtensions, '*.', ''), ')|(?:') ')]'])));
        % If we have more than one valid match, we will have to ask for a
        % selection via the gui.
        if numel(filesToSelect) > 1
            [fileName] = uigetfile([strrep(supportedFileExtensions, '*', fileName), {'Matching Models'}], 'Please select the model file');
        end
        if numel(filesToSelect) == 0

            [fileName] = uigetfile([strrep(supportedFileExtensions, '*', [fileName '*']), {'Matching Model Files'}], 'Please select the model file');
        end
        if numel(filesToSelect) == 1
            fileName = filesToSelect{1};
        end
        [~, ~, FileExtension] = fileparts(fileName);
    end
    switch lower(FileExtension)
        case '.xml'
            fileType = 'SBML';
        case '.sbml'
            fileType = 'SBML';
        case '.sto'
            % Determine which SimPheny Fiels are present...
            [folder, fileBase, ~] = fileparts(fileName);
            if exist([folder filesep fileBase '_gpra.txt'], 'file')
                fileType = 'SimPhenyText';
            else
                if exist([folder filesep fileBase '_gpr.txt'], 'file')
                    fileType = 'SimPhenyPlus';
                else
                    fileType = 'SimPheny';
                end
            end
        case '.xls'
            fileType = 'Excel';
        case '.xlsx'
            fileType = 'Excel';
        case '.mat'
            fileType = 'Matlab';
        otherwise
            error(['Cannot process files of type ' FileExtension]);
    end

end

switch fileType
    case 'SBML'
        % If the file is missing the .xml ending, we attach it, can happen
        % with .sbml saved files.
        if ~exist(fileName, 'file')
            if exist([fileName '.xml'], 'file')
                fileName = [fileName '.xml'];
            end
        end
        model = readSBML(fileName,defaultBound);
    case 'SimPheny'
        model = readSimPhenyCbModel(fileName, defaultBound, compSymbolList, compNameList);
    case 'SimPhenyPlus'
        model = readSimPhenyCbModel(fileName, defaultBound, compSymbolList, compNameList);
        model = readSimPhenyGprCmpd(fileName, model);
    case 'SimPhenyText'
        model = readSimPhenyCbModel(fileName, defaultBound, compSymbolList, compNameList);
        model = readSimPhenyGprText([fileName '_gpra.txt'], model);
    case 'Excel'
        model = xls2model(fileName, [], defaultBound);
    case 'Matlab'
        S = load(fileName);
        modeloptions = getModelOptions(S, matlabModelName);
        if size(modeloptions, 1) > 1
            fprintf('There were multiple models in the mat file. Please select the model to load from the variables below\n')
            disp(modeloptions(:, 2));
            varname = input('Type a variable name to select the model:', 's');
            modeloptions = {S.(varname), varname};
        end
        if size(modeloptions, 1) == 0
            error(['There were no valid models in the mat file.\n Please load the model manually via '' load ' fileName ''' and check it with verifyModel() to validate it']);
        end
        model = modeloptions{1, 1};
        if modeloptions{1, 3}
            model = convertOldStyleModel(model);
        end
    case 'BiGG'
        %This calls readCbModel again so the description is added.
        model = loadBiGGModel(fileName, 'mat',false);        
        modelDescription = model.description;
    case 'BiGGSBML'
        %This calls readCbModel again so the description is added.
        model = loadBiGGModel(fileName, 'sbml',false);
        modelDescription = model.description;
    otherwise
        error('Unknown file type');
end

% Check uniqueness of metabolite and reaction names
checkCobraModelUnique(model);

if isempty(modelDescription)
    [~,mfile,mextension] = fileparts(fileName);
    modelDescription = [mfile mextension];
end

if ~isfield(model, 'b')
    model.b = zeros(length(model.mets), 1);
end
model.description = modelDescription;

model = createDefaultFields(model);

model = orderModelFields(model);


function model = createDefaultFields(model,fileName)
% checks the model structure for a few fields, that are always generated
% from io, even if empty.
% We assume that the following fields are already present:
% rxns, mets, S, lb, ub, c

if ~isfield(model,'description')
    model.description = fileName;
end

if ~isfield(model,'genes')
    model.genes = {};
end

if ~isfield(model,'osenseStr')
    model.osenseStr = 'max';
end

if ~isfield(model,'csense')
    model.csense = repmat('E',size(model.mets));
end

if ~isfield(model,'rules')
    model.rules = repmat({''},size(model.rxns));
end


% End main function

%% Extract potential models from the given loaded mat file (i.e. a struct of matlab elements)
function models = getModelOptions(S, matlabModelName)
structFields = fieldnames(S);
modelNamePresent = ismember(structFields,matlabModelName);
if any(modelNamePresent)
    %Restrict to the selected model.
    structFields = structFields(modelNamePresent);
else
    if ~strcmp(matlabModelName,'all')
        error('The specified model name was not present in the mat file')
    end
end

models = cell(0, 3);
for i = 1:numel(structFields)
    cfield = S.(structFields{i});    
    if isstruct(cfield)
        try
            % lets see, if we have a valid model
            res = verifyModel(cfield, 'silentCheck', true);
            if ~isfield(res, 'Errors')
                % Convert an old Style model to the new Fields.
                cfieldConverted = convertOldStyleModel(cfield, 0);
                res = verifyModel(cfieldConverted, 'silentCheck', true);
                if isfield(res, 'Errors')
                    fprintf('There were some old style fields in the model which could not be converted. Loading the old model')
                    if ~isfield(cfield,'modelID')
                        cfield.modelID = structFields{i};
                    end
                    models{end + 1, 1} = cfield;
                    models{end, 2} = structFields{i};
                    models{end, 3} = false;
                else
                    if ~isfield(cfieldConverted,'modelID')
                        cfieldConverted.modelID = structFields{i};
                    end
                    models{end + 1, 1} = cfieldConverted;                    
                    models{end, 2} = structFields{i};
                    models{end, 3} = true;
                end
            else
                % We have errors. lets see if osense/csense are missing and
                % if, add them
                if isfield(res.Errors, 'missingFields') || isfield(res.Errors,'propertiesNotMatched')
                    % first, see if it contains an S matrix, only then will
                    % we add the fields.
                    if any(ismember(fieldnames(cfield), 'S'))
                        cfield = convertOldStyleModel(cfield, 0);
                        cfield = initFBAFields(cfield);
                    end
                    % if we reach this place, the conversion worked,
                    % so lets try the test again.
                    res = verifyModel(cfield, 'silentCheck', true);
                    if ~isfield(res, 'Errors')
                        if ~isfield(cfield,'modelID')
                            cfield.modelID = structFields{i};
                        end
                        models{end + 1, 1} = cfield;
                        models{end, 2} = structFields{i};
                        models{end, 3} = true;
                    end
                else
                    %There were no missing fields, but something else was
                    %wrong. lets try to correct it. 
                    cfield = convertOldStyleModel(cfield,0);
                                        % if we reach this place, the conversion worked,
                    % so lets try the test again.
                    res = verifyModel(cfield, 'silentCheck', true);
                    if ~isfield(res, 'Errors')
                        if ~isfield(cfield,'modelID')
                            cfield.modelID = structFields{i};
                        end
                        models{end + 1, 1} = cfield;
                        models{end, 2} = structFields{i};
                        models{end, 3} = true;
                    end
                end
            end
        catch ME
            % IF we are here, there was a problem in verifyModel or convertOldStyleModel, so this is
            % not a model.            
        end
    end
end


function model = readSimPhenyCbModel(baseName, defaultBound, compSymbolList, compNameList)
% readSimPhenyCbModel Read a SimPheny metabolic model
%
% model = readSimPhenyCbModel(baseName,defaultBound)
%
% baseName      Base filename for models
% vMax          Maximum flux through a reaction
%
% model.mets    Metabolite names
% model.rxns    Reaction names
% model.lb      Lower bound
% model.ub      Upper bound
% model.c       Objective coefficients
% model.S       Stoichiometric matrix
%
% Markus Herrgard 8/3/04

if (nargin < 2)
    defaultBound = 1000;
end

if ~(exist([baseName '.met'], 'file') & exist([baseName '.rxn'], 'file') & exist([baseName '.sto'], 'file'))
    error('One or more input files not found');
end

if isempty(compSymbolList)
    compSymbolList = {'c', 'm', 'v', 'x', 'e', 't', 'g', 'r', 'n', 'p'};
    compNameList = {'Cytosol', 'Mitochondria', 'Vacuole', 'Peroxisome', 'Extra-organism', 'Pool', 'Golgi Apparatus', 'Endoplasmic Reticulum', 'Nucleus', 'Periplasm'};
end

% Get the metabolite names
fid = fopen([baseName '.met']);
cnt = 0;
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    if (~isempty(regexp(tline, '^\d', 'once')))
        cnt = cnt + 1;
        fields = splitString(tline, '\t');
        mets{cnt} = fields{2};
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % mets{cnt} = strrep(mets{cnt}, '(', '[');
        % mets{cnt} = strrep(mets{cnt}, ')', ']');
        comp{cnt, 1} = fields{4};
        % compSymb = compSymbolList{strcmp(compNameList,comp{cnt})};
        compSymb = 0;
        TF = strcmp('comp{cnt}', compNameList);
            for n = 1:length(compNameList)
                if TF(n)
                    compSymb = compSymbolList{n};
                end
            end
        if (isempty(compSymb))
            compSymb = comp{cnt};
        end
        if (~isempty(regexp(mets{cnt}, '\(', 'once')))
            mets{cnt} = strrep(mets{cnt}, '(', '[');
            mets{cnt} = strrep(mets{cnt}, ')', ']');
        else
            mets{cnt} = [mets{cnt} '[' compSymb ']'];
        end
        metNames{cnt} = fields{3};
    end
end
fclose(fid);

mets = columnVector(mets);
metNames = columnVector(metNames);

% Get the reaction names, lower/upper bounds, and reversibility
fid = fopen([baseName '.rxn']);
cnt = 0;
startRxns = false;
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    if (regexp(tline, '^REACTION'))
        startRxns = true;
    end
    if (startRxns & ~isempty(regexp(tline, '^\d', 'once')))
        cnt = cnt + 1;
        fields = splitString(tline, '\t');
        rxns{cnt} = fields{2};
        rxnNames{cnt} = fields{3};
        revStr{cnt} = fields{4};
        lb(cnt) = str2num(fields{5});
        ub(cnt) = str2num(fields{6});
        c(cnt) = str2num(fields{7});
    end
end
fclose(fid);

revStr = columnVector(revStr);
rev = strcmp(revStr, 'Reversible');
rxns = columnVector(rxns);
rxnNames = columnVector(rxnNames);
lb = columnVector(lb);
ub = columnVector(ub);
c = columnVector(c);
lb(lb < -defaultBound) = -defaultBound;
ub(ub > defaultBound) = defaultBound;

% Get the stoichiometric matrix
fid = fopen([baseName '.sto']);
fid2 = fopen('load_simpheny.tmp', 'w');
while 1
    tline = fgetl(fid);
    if ~ischar(tline)
        break
    end
    % This here might give some problems, but it worked for the iJR904
    % model
    if (~isempty(regexp(tline, '^[-0123456789.]', 'once')))
        fprintf(fid2, [tline '\n']);
    else
        % For debugging
        % tline
    end
end
fclose(fid);
fclose(fid2);
S = load('load_simpheny.tmp');

% tmp = regexp(rxns,'deleted');
% sel_rxn = ones(length(rxns),1);
% for i = 1:length(tmp)
%     if (~isempty(tmp{i}))
%         sel_rxn(i) = 0;
%     end
% end
%
% tmp = regexp(mets,'deleted');
% sel_met = ones(length(mets),1);
% for i = 1:length(tmp)
%     if (~isempty(tmp{i}))
%         sel_met(i) = 0;
%     end
% end

% Store the variables in a structure
model.mets = mets;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
model.metComps = comp;

model.metNames = metNames;
model.rxns = removeDeletedTags(rxns);
model.rxnNames = rxnNames;
model.lb = lb;
model.ub = ub;
model.c = c;
model.S = sparse(S);

% Delete the temporary file
delete('load_simpheny.tmp');


function list = removeDeletedTags(list)
% removeDeletedTags Get rid of the [deleted tags in the SimPheny files
%
% list = removeDeletedTags(list)
%
% 5/19/05 Markus Herrgard

for i = 1:length(list)
    item = list{i};
    ind = strfind(item, ' [deleted');
    if (~isempty(ind))
        list{i} = item(1:(ind - 1));
    end
end


function model = readSimPhenyGprCmpd(baseName, model)
% Reads SimPheny GPRA and compound data and integrate it
% with the model
[rxnInfo, rxns, allGenes] = readSimPhenyGPR([baseName '_gpr.txt']);

nRxns = length(model.rxns);

% Construct gene to rxn mapping
rxnGeneMat = sparse(nRxns, length(allGenes));
showprogress(0, 'Constructing GPR mapping ...');
for i = 1:nRxns
    rxnID = find(ismember(rxns, model.rxns{i}));
    if (~isempty(rxnID))
        showprogress(i / nRxns);
        [tmp, geneInd] = ismember(rxnInfo(rxnID).genes, allGenes);
        rxnGeneMat(i, geneInd) = 1;
        rules{i} = rxnInfo(rxnID).rule;
        grRules{i} = rxnInfo(rxnID).gra;
        grRules{i} = regexprep(grRules{i}, '\s{2,}', ' ');
        grRules{i} = regexprep(grRules{i}, '( ', '(');
        grRules{i} = regexprep(grRules{i}, ' )', ')');
        subSystems{i} = {rxnInfo(rxnID).subSystem};
        for j = 1:length(geneInd)
            % rules{i} = strrep(rules{i},['x(' num2str(j) ')'],['x(' num2str(geneInd(j)) ')']);
            rules{i} = strrep(rules{i}, ['x(' num2str(j) ')'], ['x(' num2str(geneInd(j)) '_TMP_)']);
        end
        rules{i} = strrep(rules{i}, '_TMP_', '');
    else
        rules{i} = '';
        grRules{i} = '';
        subSystems{i} = '';
    end
end

% Read SimPheny cmpd output file
[metInfo, mets] = readSimPhenyCMPD([baseName '_cmpd.txt']);

baseMets = parseMetNames(model.mets);
nMets = length(model.mets);
showprogress(0, 'Constructing metabolite lists ...');
for i = 1:nMets
    if mod(i, 10) == 0
        showprogress(i / nMets);
    end
    metID = find(ismember(mets, baseMets{i}));
    if (~isempty(metID))
        metFormulas{i} = metInfo(metID).formula;
    else
        metFormulas{i} = '';
    end
end

model.rxnGeneMat = rxnGeneMat;
model.rules = columnVector(rules);
model.grRules = columnVector(grRules);
model.genes = columnVector(allGenes);
model.metFormulas = columnVector(metFormulas);
