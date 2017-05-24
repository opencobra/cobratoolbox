function outmodel = writeCbModel(model,varargin)
%writeCbModel Write out COBRA models in various formats
%
% USAGE:
%
%    outmodel = writeCbModel(model)
%    outmodel = writeCbModel(model,format)
%    outmodel = writeCbModel(model,format,fileName)
%    outmodel = writeCbModel(model,format,fileName, varargin)
%
% INPUTS:
%    model:             Standard COBRA model structure
%
% OPTIONAL INPUTS:
%    format:            File format to be used ('text','xls', 'mat'(default) or 'sbml')
%                       text will only output data from required fields (with GPR rules converted to string representation)
%                       xls is restricted to the fields defined in the xls io documentation.
%    fileName:          File name for output file (optional, default opens
%                       dialog box)
%    compSymbolList:    List of compartment symbols (Cell array)
%    compNameList:      List of compartment names corresponding to
%                       compSymbolList (Cell array)
%
% OPTIONAL OUTPUTS:
%    outmodel:          Only useable with sbml export. Will return the sbml structure, otherwise the input COBRA model structure is returned.
%
% .. Authors:
%       - Ines Thiele 01/10 - Added more options for field to write in xls format
%       - Richard Que 3/17/10 -  Added ability to specify compartment names and symbols
%       - Longfei Mao 26/04/2016 -  Added support for the FBCv2 format
%       - Thomas Pfau May 2017  - Changed To Parameter/Value pairs and
%                                 added flexibility
% NOTE:
%    The `writeCbModel` function relies on another function
%    `io/utilities/writeSBML.m` to convert a COBRA-Matlab structure into
%    a libSBML-Matlab structure and then call `libSBML` to export a
%    FBCv2 file. The current version of the `writeSBML.m` does not require the
%    SBML toolbox (http://sbml.org/Software/SBMLToolbox).


optionalInputs = {'compSymbols','compNames','sbmlLevel','sbmlVersion'}; %For backward compatability, we are checking whether the old signature is used.

%We can assume, that the old syntax is only used if varargin does not start
%with a optional argument.
if numel(varargin) > 2
    %This is only relevant, if we have more than 2 non Required input
    %variables.
    %if this is apparent, we need to check the following:
    %1. is the 3rd vararginargument a cell array and is the second argument
    %NOT compSymbols or compNames, if the second argument is NOT a char,
    if ~ischar(varargin{3}) || ~any(ismember(varargin{3},optionalInputs))
        %We assume the old version to be used
        tempargin = varargin(1:2);
        %just replace the input by the options and replace varargin
        %accordingly
        for i = 3:numel(varargin)
            if ~isempty(varargin{i})
                tempargin = [tempargin, optionalInputs{i-2}, varargin{i}];
            end
        end
        varargin = tempargin;
    end
end
[compSymbols,compNames] = getDefaultCompartmentSymbols();
if isfield(model,'comps')
    compSymbols = model.comps;
    compNames = compSymbols;
end

if isfield(model,'compNames')
    compNames = model.compNames;
end


parser = inputParser();

parser.addRequired('model',@(x) verifyModel(model,'simpleCheck'));
parser.addOptional('format','toselect',@ischar);
parser.addOptional('fileName',[],@ischar);
parser.addParameter('compSymbols' ,compSymbols ,@(x) isempty(x) || iscell(x));
parser.addParameter('compNames',compNames, @(x) isempty(x) || iscell(x));
%We currently only support output in SBML 3
parser.addParameter('sbmlLevel',3, @(x) isnumeric(x));
parser.addParameter('sbmlVersion',1, @(x) isnumeric(x));

parser.parse(model,varargin{:});
input = parser.Results;
format = input.format;
fileName = input.fileName;

outmodel = model;

% Assume constraint matrix is S if no A provided.
if ~isfield(model,'A') && isfield(model,'S')
    model.A = model.S;
else
    model.S = model.A;
end

[nMets,nRxns] = size(model.S);
%formulas = printRxnFormula(model,model.rxns,false,false,false,1,false);

%% Open a dialog to select file name
if (isempty(fileName))
    switch format
        case 'xls'
            [fileNameFull,filePath] = uiputfile({'*.xls;*.xlsx'});
        case {'text','txt'}
            [fileNameFull,filePath] = uiputfile({'*.txt'});
        case 'sbml'
            [fileNameFull,filePath] = uiputfile({'*.xml'});
        case 'mat'
            [fileNameFull,filePath] = uiputfile({'*.mat'});
        case 'toselect'
            [fileNameFull,filePath] = uiputfile({'*.mat','Matlab File';'*.xml' 'SBML Model';'*.txt' 'Text Export';'*.xls;*.xlsx' 'Excel Export'; '*.MPS' 'MPS Export'});
        otherwise
            [fileNameFull,filePath] = uiputfile({'*'});
    end
    if (fileNameFull)
        [folder,fileName,extension] = fileparts([filePath filesep fileNameFull]);
        fileName = [folder filesep fileName extension];
        switch extension
            case '.MPS'
                format = 'mps';
            case '.xls'
                format = 'xls';
            case '.xlsx'
                format = 'xls';
            case '.txt'
                format = 'text';
            case '.xml'
                format = 'sbml';
            case '.mat'
                format = 'mat';
            otherwise
                format = 'unknown';
        end
    else
        return;
    end
end
%Use lower case
format = lower(format);
switch format
    %% Text file
    case {'text', 'txt'}
        fid = fopen(fileName,'w');
        formulas = printRxnFormula(model, 'printFlag',0);
        fprintf(fid,'Rxn name\t');
        fprintf(fid,'Formula\t');
        if (isfield(model,'rules'))
            model = creategrRulesField(model);
            fprintf(fid,'Gene-reaction association\t');
        end
        fprintf(fid,'LB\tUB\tObjective\n');
        for i = 1:nRxns
            fprintf(fid,'%s\t',model.rxns{i});            
            fprintf(fid,'%s\t',formulas{i});
            if (isfield(model,'rules'))
                fprintf(fid,'%s\t',model.grRules{i});
            end
            fprintf(fid,'%6.2f\t%6.2f\t%6.2f\n',model.lb(i),model.ub(i),model.c(i));
        end
        fclose(fid);
        %% Excel file
    case 'xls'
        formulas = printRxnFormula(model,'printFlag',0);
        tmpData{1,1} = 'Abbreviation';
        tmpData{1,2} = 'Description';
        baseInd = 3;
        tmpData{1,baseInd} = 'Reaction';
        tmpData{1,baseInd+1} = 'GPR';
        tmpData{1,baseInd+2} = 'Subsystem';
        tmpData{1,baseInd+3} = 'Lower bound';
        tmpData{1,baseInd+4} = 'Upper bound';
        tmpData{1,baseInd+5} = 'Objective';
        tmpData{1,baseInd+6} = 'Confidence Score';
        tmpData{1,baseInd+7} = 'EC Number';
        tmpData{1,baseInd+8} = 'Notes';
        tmpData{1,baseInd+9} = 'References';
        tmpData{1,baseInd+10} = 'KEGG ID';
        model = creategrRulesField(model);
        for i = 1:nRxns
            tmpData{i+1,1} = chopForExcel(model.rxns{i});
            if (isfield(model,'rxnNames'))
                tmpData{i+1,2} = chopForExcel(model.rxnNames{i});
            else
                tmpData{i+1,2} =  '';
            end
            tmpData{i+1,baseInd} = chopForExcel(formulas{i});
            if (isfield(model,'grRules'))
                tmpData{i+1,baseInd+1} = chopForExcel(model.grRules{i});
            else
                tmpData{i+1,baseInd+1} = '';
            end
            if (isfield(model,'subSystems'))
                tmpData{i+1,baseInd+2} = chopForExcel(char(model.subSystems{i}));
            else
                tmpData{i+1,baseInd+2} = '';
            end
            tmpData{i+1,baseInd+3} = model.lb(i);
            tmpData{i+1,baseInd+4} = model.ub(i);
            tmpData{i+1,baseInd+5} = model.c(i);
            if (isfield(model,'rxnConfidenceScores'))
                tmpData{i+1,baseInd+6} =  chopForExcel(num2str(model.confidenceScores{i}));
            else
                tmpData{i+1,baseInd+6} = '';
            end
            %Needs to be reworked with new annotations.
            if (isfield(model,'rxnECNumbers'))
                tmpData{i+1,baseInd+7} = chopForExcel(model.rxnECNumbers{i});
            else
                tmpData{i+1,baseInd+7} = '';
            end
            if (isfield(model,'rxnNotes'))
                tmpData{i+1,baseInd+8} = chopForExcel(char(model.rxnNotes{i}));
            else
                tmpData{i+1,baseInd+8} = '';
            end
            if (isfield(model,'rxnReferences'))
                tmpData{i+1,baseInd+9} = chopForExcel(char(model.rxnReferences{i}));
            else
                tmpData{i+1,baseInd+9} = '';
            end
            %TODO: Add KEGG Id once new annotations are set up.
        end
        %keyboard
        xlswrite(fileName,tmpData,'Reaction List');
        tmpMetData{1,1} = 'Abbreviation';
        tmpMetData{1,2} = 'Description';
        tmpMetData{1,3} = 'Charged formula';
        tmpMetData{1,4} = 'Charge';
        tmpMetData{1,5} = 'Compartment';
        tmpMetData{1,6} = 'KEGG ID';
        tmpMetData{1,7} = 'PubChem ID';
        tmpMetData{1,8} = 'ChEBI ID';
        tmpMetData{1,9} = 'InChI String';
        tmpMetData{1,10} = 'SMILES';
        tmpMetData{1,11} = 'HMDB ID';
        for i = 1:nMets
            tmpMetData{i+1,1} = chopForExcel(model.mets{i});
            tmpMetData{i+1,2} = chopForExcel(model.metNames{i});
            if isfield(model,'metFormulas')
                tmpMetData{i+1,3} = chopForExcel(model.metFormulas{i});
            else
                tmpMetData{i+1,3} = '';
            end
            if isfield(model,'metCharge')
                tmpMetData{i+1,4} = chopForExcel(model.metCharge(i));
            else
                tmpMetData{i+1,4} = '';
            end
            metComp = regexp(model.mets{i},['.*\[(' strjoin(input.compSymbols,'|') ')\]$'],'tokens');
            if ~isempty(metComp)
                compartment = input.compNames(ismember(input.compSymbols,metComp{1}));
                tmpMetData{i+1,5} = chopForExcel(compartment);
            else
                tmpMetData{i+1,5} = '';
            end
            %This all needs to be reworked for the new annotations.
            if isfield(model,'metKEGGID')
                tmpMetData{i+1,6} = chopForExcel(model.metKEGGID{i});
            else
                tmpMetData{i+1,6} = '';
            end
            if isfield(model,'metPubChemID')
                if iscell(model.metPubChemID(i))
                    tmpMetData{i+1,7} = chopForExcel(model.metPubChemID{i});
                else
                    tmpMetData{i+1,7} = chopForExcel(model.metPubChemID(i));
                end
            else
                tmpMetData{i+1,7} = '';
            end
            if isfield(model,'metChEBIID')
                
                tmpMetData{i+1,8} = chopForExcel(model.metChEBIID(i));
            else
                tmpMetData{i+1,8} = '';
            end
                if isfield(model,'metInChIString')
                    tmpMetData{i+1,10} = chopForExcel(model.metInChIString{i});
            else
                tmpMetData{i+1,9} = '';
            end
            if isfield(model,'metSmiles')
                tmpMetData{i+1,10} = chopForExcel(model.metSmiles{i});
            else
                tmpMetData{i+1,10} = '';
            end
        end
        xlswrite(fileName,model.mets,'Metabolite List');
        %% SBML
    case 'sbml'
        outmodel = writeSBML(model,fileName,input.compSymbols,input.compNames);
        %% Mat
    case 'mat'
        save(fileName,'model')
        %% Uknown
    otherwise
        error('Unknown file format');
end


%% Chop strings for excel output
function strOut = chopForExcel(str)

if (length(str) > 5000)
    strOut = str(1:5000);
    fprintf('String longer than 5000 characters - truncated for Excel output\n%s\n',str);
else
    strOut = str;
end

%% Construct gene name string
function geneStr = constructGeneStr(geneNames)

geneStr = '';
for i = 1:length(geneNames)
    geneStr = [geneStr ' ' geneNames{i}];
end
geneStr = strtrim(geneStr);
