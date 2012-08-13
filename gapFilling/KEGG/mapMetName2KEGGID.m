function model = mapMetName2KEGGID(model, Dictionary)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%Hash all KEGG ID's
HTABLE = java.util.Hashtable;
CompAbr = Dictionary(:, 1);
KEGGID = Dictionary(:, 2);
for i = 1:length(KEGGID);
    if strcmp(KEGGID{i}, ''),continue,end
    if HTABLE.get(KEGGID{i}) ~= 0
        if HTABLE.get(KEGGID{i}) > 0
            disp(strcat('multiple matches    ', KEGGID{i}))
        end
        HTABLE.put(KEGGID{i},-1);
    else
        HTABLE.put(KEGGID{i},i);
    end
end

model.KEGGID = model.mets;
for i = 1 : length(model.mets)
    % finds compartment of model metabolite
    MetTmp=regexprep(model.mets(i),'[','-');
    MetTmp=regexprep( MetTmp,']','-');
    if (~isempty(strfind(char(MetTmp),'-c-')))
        MetTmp=regexprep(MetTmp,'-c-','');
        KEGGComp='[c]';
    elseif (~isempty(strfind(char(MetTmp),'-p-')))
        MetTmp=regexprep(MetTmp,'-p-','');
        KEGGComp='[p]';
    elseif(~isempty(strfind(char(MetTmp),'-e-')))
        MetTmp=regexprep(MetTmp,'-e-','');
        KEGGComp='[e]';
    else
        MetTmp = model.mets(i); % assuming that no compartment is associated with compound
    end
    
    %Match =strmatch(MetTmp, KEGGID,'exact')
    Match = HTABLE.get(MetTmp{1});

    
    if (~isempty(Match) && Match > 0 && ~isempty(CompAbr{Match}))
        % associates KEGGID with model metabolte - KEGGID is compartment
        % dependent!
        
        KEGGTmp=[char(CompAbr(Match)) char(KEGGComp)];
        model.metsAbr{i,1}=KEGGTmp;
    elseif (length(Match) < 0) %&& length(CompAbr{Match})>0)
        model.metsAbr{i,1}=[];
        disp(strcat('multiple matches ', MetTmp))
        
        %warning(['multiple matchings for' MetTmp]);
            pause;
    else
   
        model.metsAbr{i,1}=[];
    end
    clear MetTmp KEGGTmp
end
end

