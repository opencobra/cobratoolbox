% Builds per-reaction metabolite-species and colour-code lists (`list_M_species`,
% `list_R`, `list_R_M`, `list_P`, `list_P_M`, `list_C_R`, `list_C_P`) used to
% highlight `CellDesigner` nodes, from workspace variables `list_M`,
% `parsed_fatty_acid_new`, `num`, `list_nodes`, `baseR`, `baseP`, `baseC_R`,
% and `baseC_P` produced by `colourNode`/`colourAll`-style scripts.

list_M_species={};

for i=1:2; % reaction
    for t=1:size(list_M(i,:),2) % nubmer of metabolites
        if ~isempty(list_M{i,t})
            met(i,t)=retrieveMet(parsed_fatty_acid_new,list_M(i,t))
            list_M_species(i,2*t-1)={met(i,t).speciesAlliens}

        end
    end
end


for i=1:length(num)

    for r=2:2:length(baseR.(list_nodes{i}))

        list_R(i,r/2)=baseR.(list_nodes{i})(r);
    end

    for d=1:2:length(baseR.(list_nodes{i}))-1
        list_R_M(i,(d+1)/2)=baseR.(list_nodes{i})(d)
    end


    for r=2:2:length(baseP.(list_nodes{i}))

        list_P(i,r/2)=baseP.(list_nodes{i})(r);
    end

    for d=1:2:length(baseP.(list_nodes{i}))-1
        list_P_M(i,(d+1)/2)=baseP.(list_nodes{i})(d)
    end




    for r=2:2:length(baseC_R.(list_nodes{i}))
        list_C_R(i,r/2)=baseC_R.(list_nodes{i})(r); % each reaction has the same color
    end

    for r=2:2:length(baseC_P.(list_nodes{i}))
        list_C_P(i,r/2)=baseC_P.(list_nodes{i})(r); % each reaction has the same color
    end


end
