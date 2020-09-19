%% zHW: Complete Combustion of Octane
%
% Find the balanced reaction for the complete combuston of octane to carbon
% dioxide and water. 
%
% *Octane*
%
%            H   H   H   H   H   H   H   H
%            |   |   |   |   |   |   |   |
%        H - C - C - C - C - C - C - C - C - H
%            |   |   |   |   |   |   |   |
%            H   H   H   H   H   H   H   H
%

%% Chemical Formulas
% 
% Four species participate in the combustion reaction: octane, oxygen,
% carbon dioxide, and water.  The first step is to construct a cell array
% with the formula for these species.  Displaying the molecular weights is
% a convenient way to verify that the formulas are correctly entered.

species = {'CH3(CH2)6CH3','O2','CO2','H2O'};
molweight(species);

%% Stoichiometric Coefficients
%
% Stoichiometric coefficients for the balanced reaction (or balanced
% reactions, if more than one independent reaction is possible) is computed
% with |stoich|. Reactants have a negative stoichiometric coefficient,
% products have positive coefficients.

V = stoich(species);
disp(' ');
disp('Stoichiometric Matrix V = ');
disp(V);

%% Display Balanced Reactions
%
% The balanced reaction displayed as follows. Notice that stoichiometric
% coefficients are converted to integers for the displayed reaction. The
% balanced reaction is displayed in several different notations. 

disp_reaction(V,species);
disp_reaction(V,hillformula(species));
disp_reaction(V,{'Octane','Oxygen','Carbon Dioxide','Water'});
