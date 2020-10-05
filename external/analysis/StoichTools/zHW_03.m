%% zHW: Multiple Independent Reactions
%
% Formaldehyde is produced on an industrial scale by the incomplete
% oxidation of methanol in air. Principle by-products include formic acid,
% carbon dioxide, and carbon monoxide. Find a set of independent reactions
% for this reaction system.


%% Chemical Species
%
% The first step is to provide a list of all chemical species partcipating
% in the reaction system. Use molweight to verify correct entry of this
% list of species.

species = { ...
    'CH3OH', ...     % Methanol
    'O2', ...        % Oxygen
    'CH2O', ...      % Formaldehyde
    'CHOOH', ...     % Formic Acid
    'CO', ...        % Carbon Monoxide
    'CO2', ...       % Carbon Dioxide
    'H2O'};          % Water

molweight(species);

%% Independent Reactions
%
% The rank of the stoichiometric matrix indicates the number of independent
% reactions that are possible.

V = stoich(species);
disp(' ');
disp('V = ');
disp(V);
fprintf('\nNumber of Independent Reactions = %g\n',rank(V));

%% Displaying the Independent Reactions

disp_reaction(V,species);