%% zHW: Combusion of Ammonia in Air
%
% Ammonia, NH3, is burned in air, produces nitrogen and water by the
% *unbalanced* reaction 
%
% $$ NH3 + O2  \longrightarrow N2 + H2O $$
% 
% Given that you started with 51.0 g of NH3, how many g of water will be produced?

%% Prepare list of Species
%
% As usual for these problems, begin by specifying the list of species
% involved in the reaction.  We record the position of ammonia and water in
% this list using their chemical formulas as Matlab variables.

species = {'NH3','O2','N2','H2O'};

% Record for later use the position of NH3 and H2O in this list

NH3 = 1;
H2O = 4;

molweight(species);

%% Balance Reaction
% 
% The balanced reaction is computed using stoich and displayed using
% disp_reaction. disp_reaction returns integer stoichiometric coefficients,
% which we use for subsequent calculations.

V = stoich(species);
V = disp_reaction(V,species);

%% Convert Starting Mass of Ammonia to Moles
%
% The the mass of ammonia to moles.

nNH3 = 51.0/molweight('NH3');
fprintf('\nStarting amount of Ammonia = %g [moles]\n',nNH3);

%% Calculate Moles of Water Produced
%
% The key concept behind this problem is that consuming V(H20) moles of
% water are produced for every -V(NH3) moles of ammonia reacted.

nH2O = - (V(H2O)/V(NH3))*nNH3;
fprintf('\nWater Produced = %g [moles]\n',nH2O);


%% Convert Moles of Water to Mass

fprintf('\nMass of Water Produced = %g [g]\n\n', nH2O*molweight('H2O'));




