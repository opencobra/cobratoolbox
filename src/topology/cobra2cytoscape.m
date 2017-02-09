% cobra2cytoscape builds a metabolite centric directed graph from a COBRA model
% and outputs a source-target graph in a table format ready 
% to use for cytoscape
% 
% USAGE cobra2cytoscape(model)
% Ex: A + B -> C (hypergraph)
% becomes A -> C; B -> C (directed graph) 
% 
%INPUT
% model    a COBRA structured model
%OUTPUT
% csv file containing the graph
%
% Marouen BEN GUEBILA 20/01/2016

function cobra2cytoscape(model)
    %number of reactions
    n = length(model.rxns);
    %create graph source-target matrix
    linksTable = zeros(500000,2);
    
    l=1;
    for i=1:n
        % cleans the graph from biomass reactions, objective functions
        biomassRxn = strfind(model.rxns{i},'biomass');
        objRxn = strfind(model.rxns{i},'objective');
        if isequal(biomassRxn,[]) && isequal(objRxn,[])
            biomassRxn=0;
        else
            biomassRxn=1;
        end
        if biomassRxn
            continue
        else
            metPos = find(model.S(:,i) > 0);
            metNeg = find(model.S(:,i) < 0);
            %cleans the graph from demand and sink reactions
            if isequal(metPos,zeros(0,1)) || isequal(metNeg,zeros(0,1))
                continue
            end
            for j=1:length(metNeg)
                %cleans the graph from slack metabolites
                if ~isequal(strfind(model.mets{metNeg(j)},'slack_'),[])
                    model.mets{metNeg(j)}
                    continue
                end
                for k=1:length(metPos)
                    if ~isequal(strfind(model.mets{metPos(k)},'slack_'),[])
                        model.mets(metPos(k))
                        continue
                    end
                    linksTable(l,1) = metNeg(j);
                    linksTable(l,2) = metPos(k);
                    l=l+1;
                    if (model.rev(i) == 1)
                        %takes into account reaction reversibility
                        linksTable(l,1) = metPos(k);
                        linksTable(l,2) = metNeg(j);
                        l=l+1;
                    end
                end
            end
        end

    end
    
    %delete zeros
    linksTable = vec2mat(find(linksTable),2);
    %save table as csv
    csvwrite('GraphMetCentric.csv',linksTable);
end