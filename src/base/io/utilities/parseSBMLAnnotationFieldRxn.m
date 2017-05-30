function [rxnEC, rxnReference] = parseSBMLAnnotationFieldRxn(annotationField)
% Parses the annotation field of an SBML file to extract reaction information associations
%
% USAGE:
%
%    [rxnEC, rxnReference] = parseSBMLAnnotationFieldRxn(annotationField)
%
% INPUT:
%    annotationField:       annotation filed of an SBML fileBase
%
% OUTPUTS:
%    rxnEC,rxnReference:    only one of them is not empty depending on `annotationField`
%
% .. Author: - Uri David Akavia 3-Nov-2016

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
