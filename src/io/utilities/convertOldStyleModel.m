function model = convertOldStyleModel(model)
%CONVERTOLDSTYLEMODEL converts several old fields to their replacement.
%INPUT 
% model     a COBRA Model (potentially with old field names)
%OUPUT
% model     a COBRA model with old field names replaced by new ones and
%           duplicated fields merged.


%Move confidenceScores to rxnConfidenceScores
if (isfield(model,'confidenceScores'))
    if ~isfield(model,'rxnConfidenceScores')
        model.rxnConfidenceScores = model.confidenceScores;
    else
        %if we have contradicting data, take the larger
        model.rxnConfidenceScores = max(model.rxnConfidenceScores,model.confidenceScores);
    end    
    model = rmfield(model,'confidenceScores');
end
    
%Move metChare to metCharges

if (isfield(model,'metCharge'))
    if ~isfield(model,'metCharges')
        model.metCharges = model.metCharge;
    else
        %use the old field for those not defined in the new one.
        model.metCharges(isnan(model.metCharges)) = model.metCharge(isnan(model.metCharges));
    end
    model = rmfield(model,'metCharge');
end
   
%ecNumbers -> rxnECNumbers
if (isfield(model,'ecNumbers'))
    if ~isfield(model,'rxnECNumbers')
        model.rxnECNumbers = model.ecNumbers;
    else
        %use the old field for those not defined in the new one.
        model.rxnECNumbers(cellfun(@isempty, model.rxnECNumbers)) = model.ecNumbers(cellfun(@isempty, model.rxnECNumbers));
    end
    model = rmfield(model,'ecNumbers');
end
%KEGGID -> metKEGGID
if (isfield(model,'KEGGID'))
    if ~isfield(model,'metKEGGID')
        model.metKEGGID = model.KEGGID;
    else
        %use the old field for those not defined in the new one.
        model.metKEGGID(cellfun(@isempty, model.metKEGGID)) = model.KEGGID(cellfun(@isempty, model.metKEGGID));
    end
    model = rmfield(model,'KEGGID');
end

%metKeggID -> metKEGGID
if (isfield(model,'metKeggID'))
    if ~isfield(model,'metKEGGID')
        model.metKEGGID = model.metKeggID;
    else
        %use the old field for those not defined in the new one.
        model.metKEGGID(cellfun(@isempty, model.metKEGGID)) = model.metKeggID(cellfun(@isempty, model.metKEGGID));
    end
    model = rmfield(model,'metKeggID');
end
%rxnKeggID -> rxnKEGGID
if (isfield(model,'rxnKeggID'))
    if ~isfield(model,'rxnKEGGID')
        model.rxnKEGGID = model.rxnKeggID;
    else
        %use the old field for those not defined in the new one.
        model.rxnKEGGID(cellfun(@isempty, model.rxnKEGGID)) = model.rxnKeggID(cellfun(@isempty, model.rxnKEGGID));
    end
    model = rmfield(model,'rxnKeggID');
end

%metInchiString -> metInChIString

if (isfield(model,'metInchiString'))
    if ~isfield(model,'metInChIString')
        model.metInChIString = model.metInchiString;
    else
        %use the old field for those not defined in the new one.
        model.metInChIString(cellfun(@isempty, model.metInChIString)) = model.metInchiString(cellfun(@isempty, model.metInChIString));
    end
    model = rmfield(model,'metInchiString');
end