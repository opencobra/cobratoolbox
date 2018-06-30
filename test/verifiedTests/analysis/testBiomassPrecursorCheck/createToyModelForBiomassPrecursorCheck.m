function model = createToyModelForBiomassPrecursorCheck()
% createToyModelForBiomassPrecursorCheck creates a toy model for
% the biomassPrecursorCheck (which allows testing for coupling.
% The model created looks as follows:
%
%         H   G  ^                  G    H 
%          \ /   |              1    \  /
%   <-> A ---- > B ---> C --> E ------------>
%        \         /       \     / 0.5
%         -----> D          -> F
%         
%         G --> H
%           
% Without checking coupling, The model would declare both F and E as
% producible during the check, while still being unable to produce biomass.
% With the check, it wont be able to do so.

model = createModel();
%Reactions in {Rxn Name, MetaboliteNames, Stoichiometric coefficient} format
reacIDs = {'Ex_A', 'Ex_B', 'R1','R2','R3','R4', 'R5', 'Biomass'};
mets = {'A','B','C','D','E','F', 'G', 'H'};
stoich = [ 1  0 -1  0  0 -1  0  0;...
           0 -1  1 -1  0  0  0  0;...
           0  0  0  1 -1  0  0  0;...
           0  0  0 -1  0  1  0  0;...
           0  0  0  0  1  0  0 -1;...
           0  0  0  0  1  0  0 -0.5;...
           0  0  1  0  0  0 -1 -1; ...
           0  0 -1  0  0  0  1  1];
lbs = zeros(8, 1);
lbs(2) = -1000;


%Add Exchangers
model = addMultipleMetabolites(model,mets);
model = addMultipleReactions(model,reacIDs,mets,stoich,'lb',lbs);
model = changeObjective(model,'Biomass',1);