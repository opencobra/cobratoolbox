function [fields] = getDefinedFieldProperties(varargin)
% Returns the fields defined in the COBRA Toolbox along with checks for their properties
%
% USAGE:
%
%    [fields] = getDefinedFieldProperties(varargin)
%
% OPTIONAL INPUT:
%    varargin:             The following parameter/value pairs can be used:
%                          * Descriptions:         Whether to obtain the field descriptions (default = false).
%                          * SpecificFields:       Indication whether to only obtain definitions for a
%                            specific set of fields (default all).
%                          * DataBaseFields:       Get the fields with specified Database relations (true, if requested).
%
% OUTPUTS:
%    fields:               All fields and their properties as requested, if
%                          fields without definitions are requested, they
%                          will not be contained in the result.
%
% NOTE:
%
%    The optional inputs are to be provided as parameter/value pairs.
%    The returned Cell arrays are structured as follows:
%    Default:
%
%      * X{:,1} are the field names
%      * X{:,2} are the associated fields for the first dimension (i.e. size(model.(X{A,1}),1) == size(model.(X{A,2}),1) has to evaluate to true
%      * X{:,3} are the associated fields for the second dimension (i.e. size(model.(X{A,1}),2) == size(model.(X{A,2}),1) has to evaluate to true
%      * X{:,4} are evaluateable statements, which have to evaluate to true for the model to be valid, these mainly check the content types.
%      * X{:,5} are default values (or evaluateable strings for cell arrays)
%      * X{:,6} are logical values indicating  whether the field is a basic field
%      * X{:,7} are chars indicating the value type of the field (e.g. numeric, logical, char cell etc)
%      * X{:,8} are logical values indicating  whether the field is a field required for FBA
%      * X{:,9} are logical values indicating  whether the field is a type field
%      * X{:,10} are more descriptive long names for the fields
%        
%    E.g.
%
%      `x = model.(X{A, 1})`;
%
%      `eval(X{A, 4})` has to return 1
%
%    DataBaseFields:
%
%      * X{:, 1} - database id
%      * X{:, 2} - qualifier
%      * X{:, 3} - model Field
%      * X{:, 4} - model field reference (without s)
%      * X{:, 5} - Patterns for ids from the respecive database.
%
% .. Author: - Thomas Pfau May 2017

persistent CBT_PROG_FIELD_PROPS
persistent CBT_DESC_FIELD_PROPS
persistent CBT_DB_FIELD_PROPS

parser = inputParser();
parser.addParamValue('Descriptions',false,@(x) isnumeric(x) | islogical(x))
parser.addParamValue('SpecificFields',{},@iscell)
parser.addParamValue('DataBaseFields',false,@(x) isnumeric(x) | islogical(x))

parser.parse(varargin{:})

desc = parser.Results.Descriptions;
spec = parser.Results.SpecificFields;
db = parser.Results.DataBaseFields;

if db && desc
    error('Cannot simultaneously return database and Description fields')
end

if db
    if isempty(CBT_DB_FIELD_PROPS)
        fileName = which('COBRA_structure_fields.csv');
        [raw] = descFileRead(fileName);

        fields = fieldnames(raw);
        for i = 1:numel(fields)
            %Convert everything to strings.
            raw.(fields{i}) = cellstr(raw.(fields{i}));
        end
        %Get the indices for database, qualifier and reference.
        relrows = cellfun(@(x) ischar(x) && ~isempty(x),raw.databaseid);
        relarray = [raw.databaseid(relrows),raw.qualifier(relrows),raw.Model_Field(relrows), raw.referenced_Field(relrows),raw.DBPatterns(relrows),raw.qualifierType(relrows)];
        dbInfo = cell(0,6);
        for i = 1:size(relarray)
            fieldRef = relarray{i,4}(1:end-1);
            dbs = strsplit(relarray{i,1},';');
            for db = 1:length(dbs)
                quals = strsplit(relarray{i,2},';');
                for qual = 1:length(quals)
                    dbInfo(end+1,:) = {dbs{db},quals{qual},relarray{i,3},fieldRef,relarray{i,5},relarray{i,6}};
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
        fileName = which('COBRA_structure_fields.csv');
        [raw] = descFileRead(fileName);

        fields = fieldnames(raw);
        for i = 1:numel(fields)
            %Convert everything to strings.
            raw.(fields{i}) = cellstr(raw.(fields{i}));
            if strcmp(fields{i},'Ydim') || strcmp(fields{i},'Xdim')
                raw.(fields{i}) = strrep(raw.(fields{i}),'rxns','n');
                raw.(fields{i}) = strrep(raw.(fields{i}),'genes','g');
                raw.(fields{i}) = strrep(raw.(fields{i}),'mets','m');
                raw.(fields{i}) = strrep(raw.(fields{i}),'comps','c');
                raw.(fields{i}) = strrep(raw.(fields{i}),'NaN','');
            end
        end

        %Get the indices for database, qualifier and reference.
        relrows = cellfun(@(x) ischar(x) && ~isempty(x),raw.Model_Field);
        fieldDimensions = regexprep(strcat(raw.Xdim(relrows),{' x '},raw.Ydim(relrows)),'^ x $','');
        relarray = [raw.Model_Field(relrows),fieldDimensions,raw.Property_Description(relrows), raw.Field_Description(relrows)];
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
     fileName = which('COBRA_structure_fields.csv');
     [raw] = descFileRead(fileName);
     
     fields = fieldnames(raw);
     for i = 1:numel(fields)
         %Convert everything to strings.
         raw.(fields{i}) = cellstr(raw.(fields{i}));
     end
    %Get the indices for database, qualifier and reference.
    relrows = cellfun(@(x) ischar(x) && ~isempty(x),raw.Model_Field);
    relarray = [raw.Model_Field(relrows),raw.Xdim(relrows),raw.Ydim(relrows),raw.Evaluator(relrows),raw.Default_Value(relrows),raw.BasicFields(relrows),raw.FieldBasisType,raw.FBAFields(relrows),raw.TypeFields(relrows), raw.LongName(relrows)];
    progInfo = cell(0,10);
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
        default = relarray{i,5};
        if ischar(default)
            if ~isempty(str2num(default))
                default = str2num(default);
            end
        end
        basic = eval(eval(relarray{i,6}));        
        FieldType = relarray{i,7};  
        FBA = eval(eval(relarray{i,8}));        
        Types = eval(eval(relarray{i,9}));   
        LongNames = relarray{i,10};  
        progInfo(i,:) = { relarray{i,1},xval,yval,relarray{i,4}, default,basic,FieldType,FBA,Types, LongNames};
    end
    CBT_PROG_FIELD_PROPS = progInfo;
end
fields = CBT_PROG_FIELD_PROPS;

if ~any(ismember(parser.UsingDefaults,{'SpecificFields'}))
    [fieldPres,fieldpos] = ismember(spec,fields(:,1));
    if ~all(fieldPres)
        error('The following requesteds fields have no Specifications:\n%s\n',strjoin(spec(~fieldPres),',\n'));
    end
    fields = fields(fieldpos(fieldPres),:);
end
