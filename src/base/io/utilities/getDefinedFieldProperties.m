function [fields] = getDefinedFieldProperties(varargin)
%GETDEFINEDFIELDPROPERTIES returns the Fields defined in the COBRA Toolbox
%along with checks for their properties
%
% The returned Cell arrays are structured as follows:
% Default:
% X{:,1} are the field names
% X{:,2} are the associated fields for the first dimension (i.e.
%        size(model.(X{A,1}),1) == size(model.(X{A,2}),1) has to evaluate
%        to true
% X{:,3} are the associated fields for the second dimension (i.e.
%        size(model.(X{A,1}),2) == size(model.(X{A,2}),1) has to evaluate
%        to true
% X{:,4} are evaluateable statements, which have to evaluate to true for
%        the model to be valid, these mainly check the content types.
%        E.g.
%               x = model.(X{A,1});
%               eval(X{A,4}) has to return 1
%
% DataBaseFields:
% X{:,1} - database id
% X{:,2} - qualifier
% X{:,3} - model Field
% X{:,4} - model field reference (without s)
%
% USAGE [requiredFields,optionalFields] = getDefinedFieldProperties(varargin)
%
% OPTIONAL INPUT
% Descriptions:         Whether to obtain the field descriptions (default = false).
% SpecificFields:       Indication whether to only obtain definitions for a
%                       specific set of fields (default all).
% DataBaseFields:       Get the fields with specified Database relations.
%
%OUTPUTS
% requiredFields        The fields a model must have in order to be a valid
%                       COBRA Toolbox model
% optionalFields        The Fields which are supported by the COBRA
%                       Toolbox.
%


persistent CBT_PROG_FIELD_PROPS
persistent CBT_DESC_FIELD_PROPS
persistent CBT_DB_FIELD_PROPS

parser = inputParser();
parser.addParameter('Descriptions',false,@(x) isnumeric(x) | islogical(x))
parser.addParameter('SpecificFields',{},@iscell)
parser.addParameter('DataBaseFields',false,@(x) isnumeric(x) | islogical(x))

parser.parse(varargin{:})

desc = parser.Results.Descriptions;
spec = parser.Results.SpecificFields;
db = parser.Results.DataBaseFields;

if db && desc
    error('Cannot simultaneously return database and Description fields')
end



if db
    if isempty(CBT_DB_FIELD_PROPS)
        fileName = which('COBRA_structure_fields.xlsx');
        [~,~,raw] = xlsread(fileName,'Programatic Specification');
        %Get the indices for database, qualifier and reference.
        dbpos = find(cellfun(@(x) ischar(x) && strcmp(x,'database'),raw(1,:)));
        qualpos = find(cellfun(@(x) ischar(x) && strcmp(x,'qualifier'),raw(1,:)));
        reffieldPos = find(cellfun(@(x) ischar(x) && strcmp(x,'referenced Field'),raw(1,:)));
        fieldNamePos = find(cellfun(@(x) ischar(x) && strcmp(x,'Model Field'),raw(1,:)));
        relrows = cellfun(@(x) ischar(x) && ~isempty(x),raw(:,dbpos));
        %Ignore the first row, headers.
        relrows(1) = false;
        relarray = raw(relrows,[dbpos,qualpos,fieldNamePos,reffieldPos]);
        dbInfo = cell(0,4);
        for i = 1:size(relarray)
            fieldRef = relarray{4}(1:end-1);
            dbs = strsplit(relarray{i,1},';');
            for db = 1:length(dbs)
                quals = strsplit(relarray{i,2},';');
                for qual = 1:length(quals)
                    dbInfo(end+1,:) = {dbs{db},quals{qual},relarray{3},fieldRef};
                end
            end
        end
        CBT_DB_FIELD_PROPS = dbInfo;
    end
    fields = CBT_DB_FIELD_PROPS;
    return
end

if desc
    if isempty(CBT_DESC_FIELD_PROPS)
        fileName = which('COBRA_structure_fields.xlsx');
        [~,~,raw] = xlsread(fileName,'Field Specification');
        %Get the indices for database, qualifier and reference.
        dimPos = find(cellfun(@(x) ischar(x) && strcmp(x,'Dimension'),raw(1,:)));
        descPos = find(cellfun(@(x) ischar(x) && strcmp(x,'Field Description'),raw(1,:)));
        propPos = find(cellfun(@(x) ischar(x) && strcmp(x,'Property Description'),raw(1,:)));
        fieldNamePos = find(cellfun(@(x) ischar(x) && strcmp(x,'Model Field'),raw(1,:)));
        relrows = cellfun(@(x) ischar(x) && ~isempty(x),raw(:,fieldNamePos));
        relrows(1) = 0;
        relarray = raw(relrows,[fieldNamePos,dimPos,propPos,descPos]);
        dbInfo = cell(size(relarray,1),4);
        for i = 1:size(relarray)
            dbInfo(i,:) = { relarray{i,1},relarray{i,2},relarray{i,3},relarray{i,4}};
        end
        CBT_DESC_FIELD_PROPS = dbInfo;
    end
    fields = CBT_DESC_FIELD_PROPS;
    return
end

if isempty(CBT_PROG_FIELD_PROPS)
    fileName = which('COBRA_structure_fields.xlsx');
    [~,~,raw] = xlsread(fileName,'Programatic Specification');
    %Get the indices for database, qualifier and reference.
    xPos = find(cellfun(@(x) ischar(x) && strcmp(x,'Xdim'),raw(1,:)));
    yPos = find(cellfun(@(x) ischar(x) && strcmp(x,'Ydim'),raw(1,:)));
    evalPos = find(cellfun(@(x) ischar(x) && strcmp(x,'Evaluator'),raw(1,:)));
    fieldNamePos = find(cellfun(@(x) ischar(x) && strcmp(x,'Model Field'),raw(1,:)));
    relrows = cellfun(@(x) ischar(x) && ~isempty(x),raw(:,fieldNamePos));
    %Ignore the first row, headers.
    relrows(1) = false;
    relarray = raw(relrows,[fieldNamePos,xPos,yPos,evalPos]);
    dbInfo = cell(0,4);
    for i = 1:size(relarray)
        xval = relarray{i,2};
        if ~isnumeric(xval)
            xnumval = str2num(xval);
            if ~isempty(xnumval)
                xval = xnumval;
            end
        end
           yval = relarray{i,3};
        if ~isnumeric(yval)
            ynumval = str2num(yval);
            if ~isempty(ynumval)
                yval = ynumval;
            end
        end     
         dbInfo(i,:) = { relarray{i,1},xval,yval,relarray{i,4}};
    end
    CBT_PROG_FIELD_PROPS = dbInfo;
end
fields = CBT_PROG_FIELD_PROPS;

if ~isempty(spec)
    fields = fields(ismember(fields(:,1),spec),:);
end
% if
%     requiredFields = ...
%         {'S','mets','rxns','isnumeric(x) || issparse(x)','Sparse or Full Matrix of Double','The stoichiometric matrix containing the model structure (for large models a sparse format is suggested)';...
%         'b','mets',1,'isnumeric(x)','Column Vector of Doubles','The coefficients of the constraints of the metabolites.';...
%         'csense','mets',1,'ischar(x)','Column Vector of Chars','The sense of the constraints represented by b, each row is either E (equality), L(less than) or G(greater than)';...
%         'lb','rxns',1,'isnumeric(x)','Column Vector of Doubles','The lower bounds for fluxes through the reactions.';...
%         'ub','rxns',1,'isnumeric(x)','Column Vector of Doubles','The upper bounds for fluxes through the reactions.';...
%         'c','rxns',1,'isnumeric(x)','Column Vector of Doubles ', 'The objective coefficient of the reactions.';...
%         'osense',1,1,'isnumeric(x)','Double ', 'The objective sense either -1 for maximisation or 1 for minimisation';...
%         'rxns','rxns',1,'iscell(x) && ~any(cellfun(@isempty, x)) && all(cellfun(@(y) ischar(y) , x))','Column Cell Array of Strings ', 'Identifiers for the reactions.';...
%         'mets','mets',1,'iscell(x) && ~any(cellfun(@isempty, x)) && all(cellfun(@(y) ischar(y) , x))','Column Cell Array of Strings ', 'Identifiers of the metabolites';...
%         'genes','genes',1,'iscell(x) && ~any(cellfun(@isempty, x)) && all(cellfun(@(y) ischar(y) , x))',' Column Cell Array of Strings', 'Identifiers of the genes in the model';...
%         'rules','rxns',1,'iscell(x) && all(cellfun(@(y) ischar(y) , x))','Column Cell Array of Strings', 'GPR rules in evaluateable format for each reaction ( e.g. "x(1) &#124; x(2) & x(3)", would indicate the first gene or the second and third gene from genes)'
%         };
%     
%     
%     
%     optionalFields = ...
%         {'metCharges','mets',1,'isnumeric(x)','Column Vector of Double', 'The charge of the respective metabolite (NaN if unknown)';...
%         'metFormulas','mets',1,'iscell(x) && all(cellfun(@(y) ischar(y) , x))','Column Cell Array of Strings', 'Elemental formula for each metabolite';...
%         'metSmiles','mets',1,'iscell(x) && all(cellfun(@(y) ischar(y) , x))','Column Cell Array of Strings', 'Formula for each metabolite in SMILES Format';...
%         'metNames','mets',1,'iscell(x) && all(cellfun(@(y) ischar(y) , x))','Column Cell Array of Strings', 'Full name of each corresponding metabolite';...
%         'metNotes','mets',1,'iscell(x) && all(cellfun(@(y) ischar(y) , x))','Column Cell Array of Strings', 'Description of each corresponding metabolite';...
%         'metHMDBID','mets',1,'iscell(x) && all(cellfun(@(y) ischar(y) , x))','Column Cell Array of Strings', 'HMDBID of each corresponding metabolite';...
%         'metInChIString','mets',1,'iscell(x) && all(cellfun(@(y) ischar(y) , x))','Column Cell Array of Strings', 'InChI string of each corresponding metabolite';...
%         'metKEGGID','mets',1,'iscell(x) && all(cellfun(@(y) ischar(y) , x))','Column Cell Array of Strings', 'KEGG id of each corresponding metabolite';...
%         'description',NaN,NaN,'ischar(x) || isstruct(x)','String or Struct', 'Name of a file the model is loaded from' ;...
%         'modelVersion',NaN,NaN,'isstruct(x)',' Struct', 'Model Version/History';...
%         'geneNames','gene',1,'iscell(x) && all(cellfun(@(y) ischar(y) , x))','Column Cell Array of Strings', 'Full name of each corresponding gene';...
%         'grRules','rxns',1,'iscell(x) && all(cellfun(@(y) ischar(y) , x))','Column Cell Array of Strings', 'A string representation of the GPR rules defined in rules';...
%         'rxnGeneMat','rxns','genes','issparse(x) || isnumeric(x) || islogical(x)','Sparse or Full Matrix of Double or Boolean', 'A matrix that is 1 at position i,j if reaction i is associated with gene j';...
%         'rxnConfidenceScores','rxns',1,'isnumeric(x) || iscell(x) && isnumeric(cellfun(str2num,x))','Column Vector of double', 'Confidence scores for reaction presence (0-4, with 4 being the highest confidence)';...
%         'rxnNames','rxns',1,'iscell(x) && all(cellfun(@(y) ischar(y) , x))','Column Cell Array of Strings', 'Full name of each corresponding reaction';...
%         'rxnNotes','rxns',1,'iscell(x) && all(cellfun(@(y) ischar(y) , x))','Column Cell Array of Strings', 'Description of each corresponding reaction';...
%         'rxnECNumbers','rxns',1,'iscell(x) && all(cellfun(@(y) ischar(y) , x))','Column Cell Array of Strings', 'EC Number of each corresponding reaction';...
%         'rxnKEGGID','rxns',1,'iscell(x) && all(cellfun(@(y) ischar(y) , x))','Column Cell Array of Strings', 'KEGG ID of each corresponding reaction';...
%         'subSystems','rxns',1,'iscell(x) && all(cellfun(@(y) ischar(y) , x))','Column Cell Array of Strings', 'subSystem assignment for each reaction';...
%         'compNames','comps',1,'iscell(x) && all(cellfun(@(y) ischar(y) , x))',' Column Cell Array of Strings', 'Full names of the compartments';...
%         'comps','comps',1,'iscell(x) && all(cellfun(@(y) ischar(y) , x))','Column Cell Array of Strings', 'Identifiers of the compartments used in the metabolite names';...
%         'proteinNames','proteins',1,'iscell(x) && all(cellfun(@(y) ischar(y) , x))','Column Cell Array of Strings', 'Full name of each corresponding protein';...
%         'proteins','proteins',1,'iscell(x) && all(cellfun(@(y) ischar(y) , x))','Column Cell Array of Strings', 'ID for each protein'
%         };
%     
%     
%     function [fieldData] = addField(sourceList,fieldName,xdimension,ydimension,fieldCheck,fieldType,Description)
%     sourceList(end+1,:) = {fieldName,xdimension,ydimension,fieldCheck,fieldType,Description};
%     fieldData = sourceList;
