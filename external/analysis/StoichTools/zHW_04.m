%% zHW: Stoichiometric Matrix
%
% Using the list of species from HW_03, verify that the columns of the
% stoichiometric matrix are in the null space of the atomic matrix.


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

%% Atomic Matrix
%
% Element a(i,j) of the atomic matrix A is the number of atoms of element i
% that appear in a molecule of species j.

atomic(species);

%% Stoichiometric Matrix
%
% Element v(j,k) of the stoichiometric matrix V is the number of molecules
% of species j that participate in reaction k.  The stoichiometric
% coefficient is negative if species j is a reactant, or positive if
% species j is a product of the reaction.

V = stoich(species);
disp('V = ');
disp(V);

%% Product of the Atomic and Stoichiometric Matrices
%
% In principle, each matrix element b(i,k) of the product of the atomic and
% stoichiometric matrices, B = A*V, would the net number of atoms of atomic
% element j produced (if positive) or consumed (if negative) by reaction k.
% However, atoms are neither produced or consumed in a balanced reaction.
% Therefore the product A*V ought to be zero.  Stated in terms of linear
% algebra, the columns of V are in the null space of A.

A = atomic(species);
V = stoich(species);

disp('Product of Atomic & Stoichiometric Matrices = ');
disp(' ');
disp(A*V)