% The "writeCbModel" function relies on another function
% "io/utilities/writeSBML.m" to convert a COBRA-Matlab structure into
% a libSBML-Matlab structure and then call libSBML to export a
% FBCv2 file. The current version of the "writeSBML.m" does not require the
% SBML toolbox (http://sbml.org/Software/SBMLToolbox).

function outmodel = writeCbModel(model,format,fileName,compSymbolList,compNameList,sbmlLevel,sbmlVersion)
%writeCbModel Write out COBRA models in various formats
%
% writeCbModel(model,format,fileName,compSymbolList,compNameList,sbmlLevel,sbmlVersion)
%
%INPUTS
% model             Standard COBRA model structure
% format            File format to be used ('text','xls' or 'sbml')
%
% OPTIONAL OUTPUTS
% outmodel          Only useable with sbml export. Will return the sbml structure, otherwise the input COBRA model structure is returned.
%
%OPTIONAL INPUTS
% fileName          File name for output file (optional, default opens
%                   dialog box)
% compSymbolList    List of compartment symbols
% compNameList      List of compartment names corresponding to compSymbolList
% sbmlLevel         SBML Level (default = 2)
% sbmlVersion       SBML Version (default = 1)
%
% Markus Herrgard 2/5/07
% Ines Thiele 01/10 - Added more options for field to write in xls format
% Richard Que (3/17/10) Added ability to specify compartment names and
%                       symbols
%
% Longfei Mao 26/04/2016 Added support for the FBCv2 format

if ~exist('compSymbolList','var') || isempty(compSymbolList)
    compSymbolList = {'c','m','v','x','e','t','g','r','n','p','l','y'};
    compNameList = {'Cytoplasm','Mitochondrion','Vacuole','Peroxisome','Extracellular','Pool','Golgi','Endoplasmic_reticulum','Nucleus','Periplasm','Lysosome','Glycosome'};
end
 
if nargin < 6
    sbmlLevel = 2;
    sbmlVersion = 1;
end
outmodel = model;
[nMets,nRxns] = size(model.S);

formulas = printRxnFormula(model,model.rxns,false,false,false,1,false);

%% Open a dialog to select file name
if (nargin < 3 & ~strcmp(format,'sbml'))
    switch format
        case 'xls'
            [fileNameFull,filePath] = uiputfile({'*.xls'});
        case {'text','txt'}
            [fileNameFull,filePath] = uiputfile({'*.txt'});
        case 'xml'
            [fileNameFull,filePath] = uiputfile({'*.xml'});
        otherwise
            [fileNameFull,filePath] = uiputfile({'*'});
    end
    if (fileNameFull)
        [t1,t2,t3,t4,tokens] = regexp(fileNameFull,'(\w*)\.(\w*)');
        fileName = [filePath tokens{1}{1}];
        switch tokens{1}{2}
            case 'xls'
                format = 'xls';
            case 'txt'
                format = 'text';
                fileName = [fileName '.txt'];
            case 'xml'
                format = 'sbml';
%                 fprintf('Note that you will be asked to supply the file name again (this is a feature, not a bug)');
            otherwise
                format = 'unknown';
        end
    else
        return;
    end
end
switch format
    %% Text file
    case {'text','txt'}
        fid = fopen(fileName,'w');
        fprintf(fid,'Rxn name\t');
        if (isfield(model,'rxnNames'))
            fprintf(fid,'Rxn description\t');
        end
        fprintf(fid,'Formula\t');
        if (isfield(model,'grRules'))
            fprintf(fid,'Gene-reaction association\t');
        end
        fprintf(fid,'Reversible\tLB\tUB\tObjective\n');
        for i = 1:nRxns
            fprintf(fid,'%s\t',model.rxns{i});
            if (isfield(model,'rxnNames'))
                fprintf(fid,'%s\t',model.rxnNames{i});
            end
            fprintf(fid,'%s\t',formulas{i});
            if (isfield(model,'grRules'))
                fprintf(fid,'%s\t',model.grRules{i});
            end
            fprintf(fid,'%d\t%6.2f\t%6.2f\t%6.2f\n',model.rev(i),model.lb(i),model.ub(i),model.c(i));
        end
        fprintf(fid,'Metabolite name\tMetabolite description\tMetabolite formula\n');
        for i = 1:nMets
            fprintf(fid,'%s',model.mets{i});
            if isfield(model,'metNames')
                fprintf(fid,'\t%s',model.metNames{i});
            end
            if isfield(model,'metFormulas')
                fprintf(fid,'\t%s',model.metFormulas{i});
            end
            fprintf(fid,'\n');
        end
        fclose(fid);
        %% Excel file
    case 'xls'
        tmpData{1,1} = 'Abbreviation';
        tmpData{1,2} = 'Description';
        baseInd = 3;
        tmpData{1,baseInd} = 'Reaction';
        tmpData{1,baseInd+1} = 'GPR';
        tmpData{1,baseInd+2} = 'Genes';
        tmpData{1,baseInd+3} = 'Proteins';
        tmpData{1,baseInd+4} = 'Subsystem';
        tmpData{1,baseInd+5} = 'Reversible';
        tmpData{1,baseInd+6} = 'Lower bound';
        tmpData{1,baseInd+7} = 'Upper bound';
        tmpData{1,baseInd+8} = 'Objective';
        tmpData{1,baseInd+9} = 'Confidence Score';
        tmpData{1,baseInd+10} = 'EC Number';
        tmpData{1,baseInd+11} = 'Notes';
        tmpData{1,baseInd+12} = 'References';
        for i = 1:nRxns
            tmpData{i+1,1} = chopForExcel(model.rxns{i});
            if (isfield(model,'rxnNames'))
                tmpData{i+1,2} = chopForExcel(model.rxnNames{i});
            else
                tmpData{i+1,2} =  '';
            end
            
            tmpData{i+1,baseInd} = chopForExcel(formulas{i});
            if (isfield(model,'geneNameRules'))
                tmpData{i+1,baseInd+1} = chopForExcel(model.geneNameRules{i});
            elseif (isfield(model,'grRules'))
                tmpData{i+1,baseInd+1} = chopForExcel(model.grRules{i});
            else
                tmpData{i+1,baseInd+1} = '';
            end
            if (isfield(model,'geneNames'))
                geneNames = model.geneNames(model.rxnGeneMat(i,:) == 1);
                tmpData{i+1,baseInd+2} = constructGeneStr(geneNames);
            elseif (isfield(model,'genes'))
                geneNames = model.genes(model.rxnGeneMat(i,:) == 1);
                tmpData{i+1,baseInd+2} = constructGeneStr(geneNames);
            else
                tmpData{i+1,baseInd+2} = '';
            end
            if (isfield(model,'proteins'))
                tmpData{i+1,baseInd+3} = chopForExcel(model.proteins{i});
            else
                tmpData{i+1,baseInd+3} = '';
            end
            if (isfield(model,'subSystems'))
                tmpData{i+1,baseInd+4} = chopForExcel(char(model.subSystems{i}));
            else
                tmpData{i+1,baseInd+4} = '';
            end
            tmpData{i+1,baseInd+5} = model.rev(i)*1.0;
            tmpData{i+1,baseInd+6} = model.lb(i);
            tmpData{i+1,baseInd+7} = model.ub(i);
            tmpData{i+1,baseInd+8} = model.c(i);
            if (isfield(model,'confidenceScores'))                
                tmpData{i+1,baseInd+9} =  chopForExcel(num2str(model.confidenceScores{i}));           
            else
                tmpData{i+1,baseInd+9} = '';
            end
            if (isfield(model,'rxnECNumbers'))
                tmpData{i+1,baseInd+10} = chopForExcel(model.rxnECNumbers{i});
            else
                tmpData{i+1,baseInd+10} = '';
            end
            if (isfield(model,'rxnNotes'))
                tmpData{i+1,baseInd+11} = chopForExcel(char(model.rxnNotes{i}));
            else
                tmpData{i+1,baseInd+11} = '';
            end
            if (isfield(model,'rxnReferences'))
                tmpData{i+1,baseInd+12} = chopForExcel(char(model.rxnReferences{i}));
            else
                tmpData{i+1,baseInd+12} = '';
            end
        end
        %keyboard
        xlswrite(fileName,tmpData,'Reaction List');
        if isfield(model,'metNames')
            tmpMetData{1,1} = 'Abbreviation';
            tmpMetData{1,2} = 'Description';
            tmpMetData{1,3} = 'Neutral formula';
            tmpMetData{1,4} = 'Charged formula';
            tmpMetData{1,5} = 'Charge';
            tmpMetData{1,6} = 'Compartment';
            tmpMetData{1,7} = 'KEGG ID';
            tmpMetData{1,8} = 'PubChem ID';
            tmpMetData{1,9} = 'ChEBI ID';
            tmpMetData{1,10} = 'InChI String';
            tmpMetData{1,11} = 'SMILES';
            for i = 1:nMets
                tmpMetData{i+1,1} = chopForExcel(model.mets{i});
                tmpMetData{i+1,2} = chopForExcel(model.metNames{i});
                if isfield(model,'metFormulasNeutral')
                    tmpMetData{i+1,3} = chopForExcel(model.metFormulasNeutral{i});
                else
                    tmpMetData{i+1,3} = '';
                end
                if isfield(model,'metFormulas')
                    tmpMetData{i+1,4} = chopForExcel(model.metFormulas{i});
                else
                    tmpMetData{i+1,4} = '';
                end
                if isfield(model,'metCharge')
                    tmpMetData{i+1,5} = chopForExcel(model.metCharge(i));
                else
                    tmpMetData{i+1,5} = '';
                end
                if isfield(model,'metCompartment')
                    tmpMetData{i+1,6} = chopForExcel(model.metCompartment{i});
                else
                    tmpMetData{i+1,6} = '';
                end
                if isfield(model,'metKEGGID')
                    tmpMetData{i+1,7} = chopForExcel(model.metKEGGID{i});
                else
                    tmpMetData{i+1,7} = '';
                end
                if isfield(model,'metPubChemID')
                    if iscell(model.metPubChemID(i))                        
                    tmpMetData{i+1,8} = chopForExcel(model.metPubChemID{i});
                    else
                    tmpMetData{i+1,8} = chopForExcel(model.metPubChemID(i));
                    end
                else
                    tmpMetData{i+1,8} = '';
                end
                if isfield(model,'metChEBIID')
                 
                    tmpMetData{i+1,9} = chopForExcel(model.metChEBIID(i));
                else
                    tmpMetData{i+1,9} = '';
                end
                if isfield(model,'metInchiString')
                    tmpMetData{i+1,10} = chopForExcel(model.metInchiString{i});
                else
                    tmpMetData{i+1,10} = '';
                end
                if isfield(model,'metSmiles')
                    tmpMetData{i+1,11} = chopForExcel(model.metSmiles{i});
                else
                    tmpMetData{i+1,11} = '';
                end
            end
            xlswrite(fileName,tmpMetData,'Metabolite List');
        else
            xlswrite(fileName,model.mets,'Metabolite List');
        end
        %% SBML
    case 'sbml'
        % sbmlModel = convertCobraToSBML(model,sbmlLevel,sbmlVersion,compSymbolList,compNameList);
        outmodel = writeSBML(model,fileName,compSymbolList,compNameList)
%         if exist('fileName','var')&&~isempty(fileName)
%             OutputSBML(sbmlModel,fileName);
%         else
%             OutputSBML(sbmlModel);
%         end
        %% Unknown
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
