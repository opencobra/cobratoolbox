function [v_out] = substrateFinder(metabolites, directions, metabolic_model)

metabolites = metabolites{1}
directions = cell2mat(directions)
metabolic_model = char(metabolic_model)

changeCobraSolver('glpk');
load (metabolic_model);
v_out = zeros(1,length(metabolites));

for i = 1:length(metabolites)
    
    if directions(i) == 0
        v_out(i) = 0;
        
    else
        for j = 1:length(metabolites)
            if directions(j) ~= 0
                if directions(j) == 1
                    model = changeRxnBounds(model, metabolites{j}, 0, 'l');
                else
                    model = changeRxnBounds(model, metabolites{j}, 0, 'u');
                end
                
            end   
            
        end
        
        if directions(i) == 1
            model = changeRxnBounds(model, metabolites{i}, -20, 'l');
        else if directions(i) == -1
                model = changeRxnBounds(model, metabolites{i}, 20, 'u');
            end
            
        end

        try
            s = optimizeCbModel(model);
            miu = s.f;
            v_out(i) = miu;
        catch
            v_out(i) = 0;
        end
        
    end
 
end

v_out

end

