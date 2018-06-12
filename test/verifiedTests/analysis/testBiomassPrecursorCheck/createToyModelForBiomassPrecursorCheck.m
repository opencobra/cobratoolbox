function model = createToyModelForBiomassPrecursorCheck()
% createToyModelForBiomassPrecursorCheck creates a toy model for
% the biomassPrecursorCheck (which allows testing for coupling.
% The model created looks as follows:
%
%                           1
%   <-> A -> B ---> C --> E ----->
%        \     /       \     / 0.5
%         -> D          -> F
%                       
%           
% Without checking coupling, The model would declare both F and E as
% producible during the check, while still being unable to produce biomass.
% With the check, it wont be able to do so.

model = createModel();
%Reactions in {Rxn Name, MetaboliteNames, Stoichiometric coefficient} format
reacIDs = {'Ex_A','R1','R2','R3','R4','Biomass'};
mets = {'A','B','C','D','E','F'};
stoich = [ 1 -1  0  0 -1  0;...
           0  1 -1  0  0  0;...
           0  0  1 -1  0  0;...
           0  0 -1  0  1  0;...
           0  0  0  1  0 -1;...
           0  0  0  1  0 -0.5];
lbs = zeros(6,1);       


%Add Exchangers
model = addMultipleMetabolites(model,mets);
model = addMultipleReactions(model,reacIDs,mets,stoich,'lb',lbs);
model = changeObjective(model,'Biomass',1);