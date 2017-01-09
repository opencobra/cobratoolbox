function model = createToyModel(unknownmetabolites, unbalancedCharge,imbalancedreactions)
%This is a simple function to create a small toy model with so
%The Reactions are: -> A ; A -> B ; A -> C ; B + C -> D ; D ->
%It also has 
model.S = sparse([-1 -1 -1 0 0; 0 1 0 -1 0;0 0 1 -1 0; 0 0 0 1 -1]);

model.mets = {'A[c]','B[c]','C[c]','D[c]'}';
model.rxns = {'Ex_A','R2','R3','R4','Ex_D'}';
model.rev = [1,0,0,0,1]';
model.rxnNames = model.rxns;
model.metFormulas = {'CHO','CHO','CHO','C2H2O2'};
model.metCharges = [ -1 -1 -1 -2]';
model.b = [0,0,0,0]';
model.c = [0,0,0,0,1]';
model.lb = [ -1000,0,0,0,0];
model.ub = [ 0,1000,1000,1000,1000];
model.metNames = strrep(model.mets,'[c]','');
model.genes = {'G1','G2'}';
model.rules = {'','','x(1) & x(2)','x(2) | x(1)',''}';
model.grRules = {'','','G1 and G2','G2 or G1',''}';


if unknownmetabolites
    model.metFormulas{2} = '';
end

if imbalancedreactions
    model.S(2,4) = -3;
end

if unbalancedCharge
    model.metCharges(3) = 1;
end
