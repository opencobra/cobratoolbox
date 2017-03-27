function model = createToyModel(unknownMetabolite, unbalancedCharge,imbalancedReaction)
%createToyModel generates a minimal Toy model that has the requested properties
%
%model = createToyModel(unknownMetabolite,unbalancedCharge,imbalancedReaction)
%
%INPUTS
% unknownMetabolite     Indicates whether at least one metabolite should not
%                       have a formula in the model
% unbalancedCharge      Indicates whether the charge balance of at least
%                       one reaction should be wrong (by altering the
%                       charge of a metabolite
% imbalancedReaction    Indicates that at least one reaction should have an
%                       imbalance (created by changing the stoichiometry
%
%OUTPUT
% model                 A Model with the requested properties
%                       The model will be a simple toy model based on the
%                       following reactions:
%                       -> A
%                       A -> B
%                       A -> C
%                       B + C -> D
%                       D ->
%                       With A, B and C having a formula of CHO and a
%                       charge of -1 while and D has a formula of C2H2O2
%                       and a charge of -2
%
% v1  Thomas Pfau 09/02/2017

model.S = sparse([-1 -1 -1 0 0; 0 1 0 -1 0; 0 0 1 -1 0; 0 0 0 1 -1]);

model.mets = {'A[c]', 'B[c]', 'C[c]', 'D[c]'}';
model.rxns = {'Ex_A', 'R2', 'R3', 'R4', 'Ex_D'}';
model.rev = [1, 0, 0, 0, 1]';
model.rxnNames = model.rxns;
model.metFormulas = {'CHO', 'CHO', 'CHO', 'C2H2O2'};
model.metCharges = [-1, -1, -1, -2]';
model.b = [0, 0, 0, 0]';
model.c = [0, 0, 0, 0, 1]';
model.lb = [ -1000, 0, 0, 0, 0]';
model.ub = [ 0, 1000, 1000, 1000, 1000]';
model.metNames = strrep(model.mets, '[c]', '');
model.genes = {'G1', 'G2'}';
model.rules = {'', '', 'x(1) & x(2)', 'x(2) | x(1)', ''}';
model.grRules = {'', '', 'G1 and G2', 'G2 or G1', ''}';

if unknownMetabolite
    model.metFormulas{2} = '';
end

if imbalancedReaction
    model.S(2,4) = -3;
end

if unbalancedCharge
    model.metCharges(3) = 1;
end
