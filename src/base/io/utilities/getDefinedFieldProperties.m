function [fields] = getDefinedFieldProperties(varargin)
% Returns the fields defined in the COBRA Toolbox
% along with checks for their properties
%
% USAGE:
%
%    [requiredFields, optionalFields] = getDefinedFieldProperties(varargin)
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
%      * X{:,2} are the associated fields for the first dimension (i.e.
%        size(model.(X{A,1}),1) == size(model.(X{A,2}),1) has to evaluate
%        to true
%      * X{:,3} are the associated fields for the second dimension (i.e.
%        size(model.(X{A,1}),2) == size(model.(X{A,2}),1) has to evaluate
%        to true
%      * X{:,4} are evaluateable statements, which have to evaluate to true for
%        the model to be valid, these mainly check the content types.
%      * X{:,4} are evaluateable statements, which have to evaluate to true for
%        the model to be valid, these mainly check the content types.
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
%
% .. Author: - Thomas Pfau May 2017

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
        dbpos = find(cellfun(@(x) ischar(x) && strcmp(x,'databaseid'),raw(1,:)));
        qualpos = find(cellfun(@(x) ischar(x) && strcmp(x,'qualifier'),raw(1,:)));
        reffieldPos = find(cellfun(@(x) ischar(x) && strcmp(x,'referenced Field'),raw(1,:)));
        fieldNamePos = find(cellfun(@(x) ischar(x) && strcmp(x,'Model Field'),raw(1,:)));
        relrows = cellfun(@(x) ischar(x) && ~isempty(x),raw(:,dbpos));
        %Ignore the first row, headers.
        relrows(1) = false;
        relarray = raw(relrows,[dbpos,qualpos,fieldNamePos,reffieldPos]);
        dbInfo = cell(0,4);
        for i = 1:size(relarray)
            fieldRef = relarray{i,4}(1:end-1);
            dbs = strsplit(relarray{i,1},';');
            for db = 1:length(dbs)
                quals = strsplit(relarray{i,2},';');
                for qual = 1:length(quals)
                    dbInfo(end+1,:) = {dbs{db},quals{qual},relarray{i,3},fieldRef};
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
    defaultPos = find(cellfun(@(x) ischar(x) && strcmp(x,'Default Value'),raw(1,:)));
    relrows = cellfun(@(x) ischar(x) && ~isempty(x),raw(:,fieldNamePos));
    %Ignore the first row, headers.
    relrows(1) = false;
    relarray = raw(relrows,[fieldNamePos,xPos,yPos,evalPos,defaultPos]);
    dbInfo = cell(0,5);
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
         dbInfo(i,:) = { relarray{i,1},xval,yval,relarray{i,4}, relarray{i,5}};
    end
    CBT_PROG_FIELD_PROPS = dbInfo;
end
fields = CBT_PROG_FIELD_PROPS;

if ~isempty(spec)
    fields = fields(ismember(fields(:,1),spec),:);
end
