function [v_out] = eat (metabolites, directions, v_in, metabolic_model, time, c_in)

disp('-----------------------------')
try
metabolites = metabolites{1}
directions = cell2mat(directions)
c_in = cell2mat(c_in)
v_in = cell2mat(v_in)
metabolic_model = char(metabolic_model)
time = cell2mat(time)
% The Michaelis–Menten kinetic equation proposed for substrate by (Bauer et al., 2017)
% v_in=-7.56*c_in/(0.01+c_in)

changeCobraSolver('glpk');
load (metabolic_model);

v_out = zeros(1, length(v_in) + 1);

for i = 1:length(v_in)
    if directions(i) == 0
        v_out(i) = 0;
    else
        if directions(i) == 1
            model = changeRxnBounds(model, metabolites{i}, v_in(i), 'l');
        else if directions(i) == -1
                v_in(i);
                model = changeRxnBounds(model, metabolites{i}, v_in(i), 'u');
            end
            
        end
        
    end
    
end

s = optimizeCbModel(model);
printFluxVector(model,s.x,true,true)

for j = 1:length(v_in)
    if directions(j) ~=0
        v_out(j) = s.x(findRxnIDs(model, metabolites{j}));
        v_out(j);
    end
    
end 
miu = s.f;
v_out(length(v_out)) = miu
v_out
catch ME
    ME.identifier
end

end