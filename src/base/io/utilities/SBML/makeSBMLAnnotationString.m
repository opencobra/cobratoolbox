function [annotationString,notes] = makeSBMLAnnotationString(model,id,fieldentries,position)
% makeSBMLAnnotationString gives the annotationString for an SBML based on the fields in the model
%
% USAGE:
%
%       [annotationString, notes] = makeSBMLAnnotationString(model,id,fieldentries,position)
%
% INPUT:
%    model:            the model to extract the data
%    id:               the ID of the entity
%    fieldentries:     either a char indicating the field
%                      (prot,met,rxn,comp,gene), or a cell array with X{:,1}
%                      being field IDs and X{:,2} being bioql qualiiers to
%                      annotate for the field.
%    position:         the position in the model to extract the data.
%
% OUTPUT:
%
%   annotationString: The annotation String to be put into the SBML.
%   notes:            A 2*x cell array of fields which did not contain
%                     valid identifiers (according to the pattern check.
%
% .. Authors:
%       - Thomas Pfau May 2017 



allQualifiers = getBioQualifiers();

if ischar(fieldentries)
    fieldentries = {fieldentries, allQualifiers};
end
annotationString = '';
modelFields = fieldnames(model);
%Only look at the relevant fields.
tmp_note = '';
notes = cell(0,2);
bagindentlevel = '      ';
for pos = 1:size(fieldentries,1)        
    field = fieldentries{pos,1};
    if isempty(fieldentries{pos,2})
        allowedQualifiers = allQualifiers;
    else
        allowedQualifiers = fieldentries{pos,2};
    end
    fieldMappings = getDatabaseMappings(field);
    [~,upos,~] = unique(fieldMappings(:,3));
    fieldMappings = fieldMappings(upos,:);
    
    relfields = modelFields(cellfun(@(x) strncmp(x,field,length(field)),modelFields));
    
    for i = 1:numel(allowedQualifiers)
        annotationsFields = relfields(cellfun(@(x) strncmp(x,[field allowedQualifiers{i}],length([field allowedQualifiers{i}])),relfields));
        knownFields = fieldMappings(cellfun(@(x) strcmp(x,allowedQualifiers{i}),fieldMappings(:,2)),:);
        dbnote = '';
        for fieldid = 1:numel(annotationsFields)
            if isempty(model.(annotationsFields{fieldid}){position})
                continue
            end
            ids = strsplit(model.(annotationsFields{fieldid}){position},';');
            
            
            dbname = convertSBMLID(regexprep(annotationsFields{fieldid},[field allowedQualifiers{i} '(.*)' 'ID$'],'$1'),false);
            dbrdfstring = [bagindentlevel '    <rdf:li rdf:resource="http://identifiers.org/' dbname '/'];
            dbstring = strjoin(strcat(dbrdfstring,ids,sprintf('%s\n','"/>')),sprintf('\n'));
            dbnote = [dbnote, dbstring];
        end
        knownExistentFields = knownFields(ismember(knownFields(:,3),modelFields),:);
        
        for fieldid = 1:size(knownExistentFields,1)
            if isempty(model.(knownExistentFields{fieldid,3}){position})
                continue
            end
            ids = strtrim(strsplit(model.(knownExistentFields{fieldid,3}){position},';'));
            correctids = ~cellfun(@isempty, regexp(ids,knownExistentFields{fieldid,5}));            
            %If we have correct ids, we will annotate those.
            if any(correctids)
                dbname = knownExistentFields{fieldid,1};
                dbrdfstring = [bagindentlevel '    <rdf:li rdf:resource="http://identifiers.org/' dbname '/'];
                dbstring = strjoin(strcat(dbrdfstring,ids(correctids),sprintf('%s\n','"/>')),sprintf('\n'));
                dbnote = [dbnote, dbstring];
            end
            %if we have incorrect ids, we will add this data to the notes
            %of the reaction.
            if any(~correctids)
                notes(end+1,:) = {knownExistentFields{fieldid,3}, model.(knownExistentFields{fieldid,3}){position}};
            end
        end
        
        if ~isempty(dbnote)
            %Make specification for this bag
            specstring = ['<bqbiol:' allowedQualifiers{i} ' xmlns:bqbiol="http://biomodels.net/biology-qualifiers/">' ];
            specend = ['</bqbiol:' allowedQualifiers{i} '>'];
            
            specification_string = sprintf('%s%s\n%s  %s\n%s%s\n',bagindentlevel,specstring,bagindentlevel,'<rdf:Bag/>',bagindentlevel,specend);                        
             
            tmp_note=[specification_string, tmp_note, bagindentlevel, '<bqbiol:', allowedQualifiers{i}, sprintf('%s\n%s  %s\n','>', bagindentlevel,'<rdf:Bag>')];
            tmp_note = [tmp_note, dbnote ];
            tmp_note = [ tmp_note, sprintf('\n  %s%s\n%s%s\n',bagindentlevel,'</rdf:Bag>',bagindentlevel, ['</bqbiol:' allowedQualifiers{i} '>'])]; % ending syntax
        end
        
    end
end
if ~isempty(tmp_note)
    annotopentag = '<annotation xmlns:sbml="http://www.sbml.org/sbml/level3/version1/core">';
    rdfOpenTag = '<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#" xmlns:vCard4="http://www.w3.org/2006/vcard/ns#" xmlns:bqbiol="http://biomodels.net/biology-qualifiers/" xmlns:bqmodel="http://biomodels.net/model-qualifiers/">';
    annotationString = sprintf('%s\n  %s\n    ',annotopentag,rdfOpenTag);   
    annotationString = [ annotationString '<rdf:Description rdf:about="#',id,'">'];
    annotationString = [annotationString sprintf('\n')];
    annotationString = [annotationString, tmp_note, sprintf('    %s\n  %s\n%s','</rdf:Description>', '</rdf:RDF>', '</annotation>')];
end
end
