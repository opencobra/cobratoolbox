function model = mapKEGGID2Model(model,Dictionary)

% this function matches the compound abreviation in model and from CompAbr
% and connects with the model metabolite the corresponding KEGGID
%
% model      model structure
% CompAbr    List of compounds abreviation (non-compartelized)
% KEGGID     List of KEGGIDs for compounds in CompAbr
%
% 11-09-07 IT
CompAbr = Dictionary(:, 1);
KEGGID = Dictionary(:, 2);
for i = 1 : length(model.mets)
    % finds compartment of model metabolite
    MetTmp=regexprep(model.mets(i),'[','-');
    MetTmp=regexprep( MetTmp,']','-');
    if (length(strfind(char(MetTmp),'-c-'))>0)
        MetTmp=regexprep(MetTmp,'-c-','');
        KEGGComp='[c]';
    elseif (length(strfind(char(MetTmp),'-p-'))>0)
        MetTmp=regexprep(MetTmp,'-p-','');
        KEGGComp='[p]';
    elseif(length(strfind(char(MetTmp),'-e-'))>0)
        MetTmp=regexprep(MetTmp,'-e-','');
        KEGGComp='[e]';
    else
        MetTmp = model.mets(i); % assuming that no compartment is associated with compound
    end
    
    Match=strmatch(MetTmp, CompAbr,'exact');
    if (length(Match)==1 && length(KEGGID{Match})>0)
        % associates KEGGID with model metabolte - KEGGID is compartment
        % dependent!
        KEGGTmp=[char(KEGGID(Match)) char(KEGGComp)];
        model.KEGGID{i,1}=KEGGTmp;
    elseif (length(Match)>1 && length(KEGGID{Match})>0)
        model.KEGGID{i,1}=[];
        warning(['multiple matchings for' char(model.mets(i))]);
    else
   
        model.KEGGID{i,1}=[];
    end
    clear MetTmp KEGGTmp
end