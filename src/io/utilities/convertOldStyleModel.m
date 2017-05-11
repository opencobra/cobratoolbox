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
    
if (isfield(model,'ecNumbers'))
    if ~isfield(model,'rxnECNumbers')
        model.rxnECNumbers = model.ecNumbers;
    else
        %use the old field for those not defined in the new one.
        model.rxnECNumbers(cellfun(@isempty, model.rxnECNumbers)) = model.ecNumbers(cellfun(@isempty, model.rxnECNumbers));
    end
    model = rmfield(model,'ecNumbers');
else