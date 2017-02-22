% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011

%Program used to get neigbor reactions and set up correct format for the
%Reconstruction analyzer. 
%Stefan G. Thorleifsson March 2011

function data = neighborRxn2data(model,rxn_numb)
%get info for first reaction.
%database is logical
%   0 - do not check database.
%   1 - check database
[rxns, genes, mets] = findNeighborRxns(model,model.rxns{rxn_numb});
data = [];

%findNeighborRxns has some strange return values sometimes, so I use this
%doubble return statement.
if isempty(rxns)
    return;
end
if isempty(rxns{1})
    return;
end

data_rxn = []; %all the reactions
for i = 1:size(rxns,2)
    data_rxn = [data_rxn; rxns{i}];
end

load rxn;
%delete reactions that is checked for
rxn(strcmp(model.rxns{rxn_numb},rxn(:,1)),:) = '';

%Put metabolites in data_met when they occur.  
data_rxn = unique(data_rxn);
%data_met = cell(size(data_rxn));
%data_form = cell(size(data_rxn));
% 1. reactions
% 2. metabolites
% 3. formula
% 4. true/false in model
% 5. ec number
% 6. keggid
data_model = cell(size(data_rxn,1),6); 
data_model(:,1) = data_rxn;
%This loop is just silly, performance should be improved drasticly. For every reaction it goes through the reaction lists by
%metabolites and adds the metabolites. 

for i =1:size(data_rxn,1)%For all neighbor rxn
    %delete reaction from rxn if it is in model.
    rxn(strcmp(data_rxn{i},rxn(:,1)),:) = ''; %Potential remove this line and use setdiff instead.
    form = printRxnFormula(model,data_rxn{i});
    data_model{i,3} = form{1}; %formula
    for k = 1:size(rxns,2) %Go through reaction that have metabolite K. 
        if any(strcmp(data_rxn{i},rxns{k}))
            if isempty(data_model{i,2})
                data_model{i,2} = mets{k};
                data_model{i,4} = true;
                data_model{i,5} = model.ecNumbers{strcmp(data_rxn{i},model.rxns)};
                if isfield(model,'rxnKeggID')
                    data_model{i,6} = model.rxnKeggID{strcmp(data_rxn{i},model.rxns)};
                else
                    data_model{i,6} = '';
                end
            else
                data_model{i,2} = [data_model{i,2} ', ' mets{k}];
            end
        end
    end
end



%database neighbors (heavy duty for big databases)


% exclude common mets (atp, adp, h, h2o, pi) ** make this an input option
%same list as in findNeighborRxns (March 2011).
 popular = {'atp[c]','atp[p]','adp[c]','adp[p]','h[c]','h2o[c]',...
     'h2o[p]','pi[c]','pi[p]'};

data_db = cell(size(rxn,1),6);

%1.rxn
%2.met
%3.formula
%4.in model true/false
%5.ec number
%6.keggID
%data_db = cell(1,6);
%db_rxn = {};
%db_met = {};
%db_form = {};
%db_model = {};
cnt = 0;
for i = 1:size(rxn,1)
    form = parseRxnFormula(rxn{i,3});
    form = setdiff(form,popular);
    if ~isempty(form)
        
        for k = 1:size(form,2)
            if any(strcmp(form{k},mets))
                match = find(strcmp(rxn{i,1},data_db(:,1)));
                if isempty(match)
                    data_db{i-cnt,1} = rxn{i,1};
                    data_db{i-cnt,2} = form{k};
                    data_db{i-cnt,3} = rxn{i,3};
                    data_db{i-cnt,4} = false;
                    data_db{i-cnt,5} = rxn{i,8};
                    data_db{i-cnt,6} = rxn{i,9};
                    
                else
                    data_db{match,2} = [data_db{match,2} ', ' form{k}];
                end
            end
        end
    end
    
    if isempty(data_db{i-cnt,1})
        data_db(i-cnt,:) = '';
        cnt = cnt + 1;
    end
end


data = [data_model;data_db];

            
            
            
            
            
    
    
