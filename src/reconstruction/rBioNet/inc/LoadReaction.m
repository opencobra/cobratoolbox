% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
%Inputs: handles.metab & handles.meta_compartment from ReconstructionTool
%and rxnline is all the data of the reaction. 
%Stefan G. Thorlefisson 2010.

function output = LoadReaction(rxnline,metab,meta_compartment,rxn_line)
output = [];
if nargin < 4
    rxn_line = '?';
else
    rxn_line = num2str(rxn_line);
end
% Breaking down the formula
formula = rxnline{3};
[mets, coefficients] = parseRxnFormula(formula);
k = length(mets);
meta_meta = cell(k,6);
for i = 1:k;
    met = mets{i};
    met_cnt = regexpi(met,'\[');
    met_cmp = met(met_cnt+1);
    met_tag = ['(' met_cmp ')'];
    
    name = met(1:met_cnt-1);
    line = strmatch(name,metab(:,1),'exact');
    
    if isempty(line)
        output = {'',rxnline{1},name}; % empty so addreaction.m will know it didn't work, rxn, metab
        %msgbox(['Metabolite: ' name ' from reaction ' rxnline{1} ' (line ' rxn_line ') is not identified in the metabolite database.'...
        %    ' Please add it to the database or remove the reaction.'],'Metabolite is missing.','help');
        return
        
    end
    meta_meta{i,1} = metab{line,1}; %Abbreviation
    meta_meta{i,2} = metab{line,2}; %Description
    meta_meta{i,6} = metab{line,4}; %Charged Formula
    meta_meta{i,7} = metab{line,5}; %Charge
    if coefficients(i) <= 0
        meta_meta{i,5} = 'Substrate'; %Side
    else
        meta_meta{i,5} = 'Product';
    end
    
    meta_meta{i,3} = abs(coefficients(i)); %Coefficients
    
    compartments = meta_compartment;
    
    cmp = strfind(compartments,met_tag);
    
    for l = 1:length(cmp);
        if ~isempty(cmp{l})
            meta_meta{i,4} = compartments{l}; %Compartment
        end
    end
    
    if isempty(meta_meta{i,4})
        msgbox(['Compartment ' met_tag ' was not recognized.']...
            ,'Compartment not recognized.','warn')
        return
    end
end

output = meta_meta;
