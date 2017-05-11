function [rxnEC, rxnReference] = parseSBMLAnnotationFieldRxn(annotationField)
%parseSBMLAnnotationFieldRxn Parse the annotation field of an SBML file to extract
%reaction information associations
%
% [rxnEC, rxnReference] = parseSBMLAnnotationFieldRxn(annotationField)
%
% Uri David Akavia 3-Nov-2016


rxnReference = '';
rxnEC = '';

tmpFields = regexp(annotationField,'<rdf:li rdf:resource="http://identifiers.org/([\w-]+)/(.*?)"/>','tokens');

for i=1:length(tmpFields)
    fieldStr = tmpFields{i}{1};
    fieldValue = tmpFields{i}{2};
    switch fieldStr
        case 'ec-code'
            rxnEC = fieldValue;
        case 'pubmed'
            tmpStr = '';
            if (~isempty(rxnReference)); tmpStr = ','; end
            rxnReference = strcat(rxnReference, tmpStr, 'PMID:', fieldValue);
        otherwise
            warning('Unrecognized field %s with value %s in reaction!', fieldStr, fieldValue);
    end
end