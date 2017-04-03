% The "readCbModel.m" function is dependent on another function
% "io/utilities/readSBML.m" to use libSBML library
% (http://sbml.org/Software/libSBML), to parse a SBML-FBCv2 file into a
% COBRA-Matlab structure. The "readCbModel.m" function is backward
% compatible with older SBML versions. A list of fields of a COBRA
% structure is described in an Excel spreadsheet
% "io/COBRA_structure_fields.xlsx". While some fields are necessary for a
% COBRA model, others are not.

function model = readCbModel(fileName,defaultBound,fileType,modelDescription,compSymbolList,compNameList)
%readCbModel Read in a constraint-based model
%
% model = readCbModel(fileName,defaultBound,fileType,modelDescription)
%
% If no arguments are passed to the function, the user will be prompted for
% a file name.
%
%OPTIONAL INPUTS
% fileName          File name for file to read in (optional)
% defaultBound      Default value for maximum flux through a reaction if
%                   not given in the SBML file (Default = 1000)
% fileType          File type for input files: 'SBML', 'SimPheny', or
%                   'SimPhenyPlus', 'SimPhenyText' (Default = 'SBML')
%                   * SBML indicates a file in SBML format
%                   * SimPheny is a set of three files in SimPheny
%                     simulation output format
%                   * SimPhenyPlus is the same as SimPheny except with
%                     additionalfiles containing gene-protein-reaction
%                     associations andcompound information
%                   * SimPhenyText is the same as SimPheny except with
%                     additionaltext file containing gene-protein-reaction
%                     associations
% modelDescription  Description of model contents
% compSymbolList    Compartment Symbol List
% compNameList      Name of compartments corresponding to compartment
%                   symbol list
%
%OUTPUT
% Returns a model in the COBRA format:
%
% model
%  description      Description of model contents
%  rxns             Reaction names
%  mets             Metabolite names
%  S                Stoichiometric matrix
%  lb               Lower bounds
%  ub               Upper bounds
%  rev              Reversibility vector
%  c                Objective coefficients
%  subSystems       Subsystem name for each reaction (opt)
%  grRules          Gene-reaction association rule for each reaction (opt)
%  rules            Gene-reaction association rule in computable form (opt)
%  rxnGeneMat       Reaction-to-gene mapping in sparse matrix form (opt)
%  genes            List of all genes (opt)
%  rxnNames         Reaction description (opt)
%  metNames         Metabolite description (opt)
%  metFormulas      Metabolite chemical formula (opt)
%
%EXAMPLES OF USE:
%
% 1)    Load a file to be specified in a dialog box:
%
%           model = readCbModel;
%
% 2)    Load model named 'iJR904' in SBML format with maximum flux set
%       at 1000 (requires file named 'iJR904.xml' to exist)
%
%           model = readCbModel('iJR904',1000,'SBML');
%
% 3)    Load model named 'iJR904' in SimPheny format with maximum flux set
%       at 500 (requires files named 'iJR904.rxn', 'iJR904.met', and 'iJR904.sto' to exist)
%
%           model = readCbModel('iJR904',500,'SimPheny');
%
% 4)    Load model named 'iJR904' in SimPheny format with gpr and compound information
%       (requires files named 'iJR904.rxn', 'iJR904.met','iJR904.sto',
%        'iJR904_gpr.txt', and 'iJR904_cmpd.txt' to exist)
%,
%           model = readCbModel('iJR904',500,'SimPhenyPlus');
%
% Markus Herrgard 7/11/06
%
% Richard Que 02/08/10 - Added inptus for compartment names and symbols
%
% Longfei Mao 26/04/2016 Added support for the FBCv2 format

%% Process arguments

if (nargin < 2)
    defaultBound = 1000;
else
    if (isempty(defaultBound))
        defaultBound = 1000;
    end
end
if (nargin < 3)
    fileType = 'SBML';
    if (isempty(fileType))
       fileType = 'SBML';
    end
end



% Open a dialog to select file
if (nargin < 1)
    [fileNameFull,filePath] = uigetfile({'*.xml';'*.sto'});
    if (fileNameFull)
        [t1,t2,t3,t4,tokens] = regexp(fileNameFull,'(.*)\.(\w*)');
        noPathName = tokens{1}{1};
        fileTypeTmp = tokens{1}{2};
        fileName = [filePath noPathName];
    else
        model = 0;
        return;
    end
    switch fileTypeTmp
        case 'xml'
            fileType = 'SBML';
        case 'sto'
            fileType = 'SimPheny';
        otherwise
            error('Cannot process this file type');
    end
end

if (nargin < 4)
    if (exist('filePath'))
        modelDescription = noPathName;
    else
        modelDescription = fileName;
    end
end

if (nargin < 5)
    compSymbolList = {};
    compNameList = {};
end

switch fileType
    case 'SBML',
        if isempty(regexp(fileName,'\.xml$', 'once'))
            model = readSBML([fileName '.xml'],defaultBound,compSymbolList,compNameList);
        else
            model = readSBML(fileName,defaultBound,compSymbolList,compNameList);
        end
    case 'SimPheny',
        model = readSimPhenyCbModel(fileName,defaultBound,compSymbolList,compNameList);
    case 'SimPhenyPlus',
        model = readSimPhenyCbModel(fileName,defaultBound,compSymbolList,compNameList);
        model = readSimPhenyGprCmpd(fileName,model);
    case 'SimPhenyText',
        model = readSimPhenyCbModel(fileName,defaultBound,compSymbolList,compNameList);
        model = readSimPhenyGprText([fileName '_gpra.txt'],model);
    otherwise,
        error('Unknown file type');
end

% Check reversibility
model = checkReversibility(model);

% Check uniqueness of metabolite and reaction names
checkCobraModelUnique(model);

model.b = zeros(length(model.mets),1);

model.description = modelDescription;

% End main function

%% Make sure reversibilities are correctly indicated in the model
function model = checkReversibility(model)

selRev = (model.lb < 0 & model.ub > 0);
model.rev(selRev) = 1;

%% the following chunk of code is depreciated (Longfei Mao 27/04/2016)

% readSBMLCbModel Read SBML format constraint-based model
% function model =  readSBMLCbModel(fileName,defaultBound,compSymbolList,compNameList)
%
% if ~(exist(fileName,'file'))
%     error(['Input file ' fileName ' not found']);
% end
%
% if isempty(compSymbolList)
%     compSymbolList = {'c','m','v','x','e','t','g','r','n','p'};
%     compNameList = {'Cytosol','Mitochondria','Vacuole','Peroxisome','Extra-organism','Pool','Golgi Apparatus','Endoplasmic Reticulum','Nucleus','Periplasm'};
% end
%
% % Read SBML
% validate=0;
% verbose=0;% Ronan Nov 24th 2014
% modelSBML = TranslateSBML(fileName,validate,verbose);
%
% % Convert
% model = convertSBMLToCobra(modelSBML,defaultBound,compSymbolList,compNameList);

%%
function model = readSimPhenyCbModel(baseName,defaultBound,compSymbolList,compNameList)
%readSimPhenyCbModel Read a SimPheny metabolic model
%
% model = readSimPhenyCbModel(baseName,defaultBound)
%
% baseName      Base filename for models
% vMax          Maximum flux through a reaction
%
% model.mets    Metabolite names
% model.rxns    Reaction names
% model.rev     Reversible (1)/Irreversible (0)
% model.lb      Lower bound
% model.ub      Upper bound
% model.c       Objective coefficients
% model.S       Stoichiometric matrix
%
% Markus Herrgard 8/3/04

if (nargin < 2)
    defaultBound = 1000;
end

if ~(exist([baseName '.met'],'file') & exist([baseName '.rxn'],'file') & exist([baseName '.sto'],'file'))
    error('One or more input files not found');
end

if isempty(compSymbolList)
    compSymbolList = {'c','m','v','x','e','t','g','r','n','p'};
    compNameList = {'Cytosol','Mitochondria','Vacuole','Peroxisome','Extra-organism','Pool','Golgi Apparatus','Endoplasmic Reticulum','Nucleus','Periplasm'};
end

% Get the metabolite names
fid = fopen([baseName '.met']);
cnt = 0;
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    if (~isempty(regexp(tline,'^\d', 'once')))
        cnt = cnt + 1;
        fields = splitString(tline,'\t');
        mets{cnt} = fields{2};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        mets{cnt} = strrep(mets{cnt}, '(', '[');
%        mets{cnt} = strrep(mets{cnt}, ')', ']');

        comp{cnt,1} = fields{4};
%        compSymb = compSymbolList{strcmp(compNameList,comp{cnt})};
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
        if (~isempty(regexp(mets{cnt},'\(', 'once')))
            mets{cnt} = strrep(mets{cnt},'(','[');
            mets{cnt} = strrep(mets{cnt},')',']');
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
    if (regexp(tline,'^REACTION'))
        startRxns = true;
    end
    if (startRxns & ~isempty(regexp(tline,'^\d', 'once')))
        cnt = cnt + 1;
        fields = splitString(tline,'\t');
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
rev = strcmp(revStr,'Reversible');
rxns = columnVector(rxns);
rxnNames = columnVector(rxnNames);
lb = columnVector(lb);
ub = columnVector(ub);
c = columnVector(c);
lb(lb < -defaultBound) = -defaultBound;
ub(ub > defaultBound) = defaultBound;

% Get the stoichiometric matrix
fid = fopen([baseName '.sto']);
fid2 = fopen('load_simpheny.tmp','w');
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    % This here might give some problems, but it worked for the iJR904
    % model
    if (~isempty(regexp(tline,'^[-0123456789.]', 'once')))
        fprintf(fid2,[tline '\n']);
    else
        % For debugging
        %tline
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
model.rev = rev;
model.lb = lb;
model.ub = ub;
model.c = c;
model.S = sparse(S);

% Delete the temporary file
delete('load_simpheny.tmp');

%%
function list = removeDeletedTags(list)
%removeDeletedTags Get rid of the [deleted tags in the SimPheny files
%
% list = removeDeletedTags(list)
%
% 5/19/05 Markus Herrgard

for i = 1:length(list)
    item = list{i};
    ind = strfind(item,' [deleted');
    if (~isempty(ind))
        list{i} = item(1:(ind-1));
    end
end

%% readSimPhenyGprCmpd Read SimPheny GPRA and compound data and integrate it
% with the model
function model = readSimPhenyGprCmpd(baseName,model)

[rxnInfo,rxns,allGenes] = readSimPhenyGPR([baseName '_gpr.txt']);

nRxns = length(model.rxns);

% Construct gene to rxn mapping
rxnGeneMat = sparse(nRxns,length(allGenes));
showprogress(0,'Constructing GPR mapping ...');
for i = 1:nRxns
    rxnID = find(ismember(rxns,model.rxns{i}));
    if (~isempty(rxnID))
        showprogress(i/nRxns);
        [tmp,geneInd] = ismember(rxnInfo(rxnID).genes,allGenes);
        rxnGeneMat(i,geneInd) = 1;
        rules{i} = rxnInfo(rxnID).rule;
        grRules{i} = rxnInfo(rxnID).gra;
        grRules{i} = regexprep(grRules{i},'\s{2,}',' ');
        grRules{i} = regexprep(grRules{i},'( ','(');
        grRules{i} = regexprep(grRules{i},' )',')');
        subSystems{i} = rxnInfo(rxnID).subSystem;
        for j = 1:length(geneInd)
            %rules{i} = strrep(rules{i},['x(' num2str(j) ')'],['x(' num2str(geneInd(j)) ')']);
            rules{i} = strrep(rules{i},['x(' num2str(j) ')'],['x(' num2str(geneInd(j)) '_TMP_)']);
        end
        rules{i} = strrep(rules{i},'_TMP_','');
    else
        rules{i} = '';
        grRules{i} = '';
        subSystems{i} = '';
    end
end

%% Read SimPheny cmpd output file
[metInfo,mets] = readSimPhenyCMPD([baseName '_cmpd.txt']);

baseMets = parseMetNames(model.mets);
nMets = length(model.mets);
showprogress(0,'Constructing metabolite lists ...');
for i = 1:nMets
    if mod(i,10) == 0
        showprogress(i/nMets);
    end
    metID = find(ismember(mets,baseMets{i}));
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
model.subSystems = columnVector(subSystems);
