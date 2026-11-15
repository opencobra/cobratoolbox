% The COBRAToolbox: testPlotMoleFraction.m
%
% Purpose:
%     - plotMoleFraction plots the equilibrium mole fractions of the species of a reactant (from
%       Alberty's data) against the pH, one line per species with the legend
%       "<metabolite abbreviation><charge>". The test plots a hand-built two-species acid on an
%       invisible figure and checks the axes: the pH grid, the mole fractions (expected values
%       from the Henderson-Hasselbalch relation, as in testMoleFraction), the legend and the axis
%       labels.
%
% Function under test:
%     src/analysis/thermo/protons/plotMoleFraction.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs; one invisible figure, closed at the end.
%
% Coverage exemptions:
%     Lines 48-57 (the else branch of "if 1": grids over ionic strength, potential and
%     temperature) and line 77 (inside "if 0": the conversion to real pH with realpH) are never
%     reached: both are dead code in the source.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPlotMoleFraction'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% figures are created invisibly and closed at the end
defaultVisible = get(groot, 'DefaultFigureVisible');
set(groot, 'DefaultFigureVisible', 'off');
figuresBefore = findall(groot, 'Type', 'figure');

% Alberty data with two reactants. 'hf' is an acid with two species, listed from the least to the
% most protonated (rows [dGf0 (kJ/mol), dHf0 (kJ/mol), charge, number of H]): A- (charge -1) and HA
% (charge 0), with dGf0(HA) - dGf0(A-) = -39.95; a NaN row pads it as in Alberty's tables and is
% not a species. 'other' is a second reactant that must not be picked up.
albertyData = struct('abbreviation', {'other', 'hf'}, ...
    'basicData', {[0 0 -2 0; -50 0 -1 1], [0 0 -1 0; -39.95 0 0 1; NaN NaN NaN NaN]});
metAbbrAlbertyAbbr = {'y', 'oth[c]', 'other'; 'x', 'ha[c]', 'hf'};   % [id, metabolite, Alberty]
gasConstant = 8.314472e-3;                      % kJ/(K mol), the value used by acidDissociationConstant
temperature = 298.15;
pKa = 39.95 / (gasConstant * temperature * log(10));

%% one pH unit below the pKa, at the pKa and one unit above: one line per species

% ionic strength and potential are 0 and the temperature is 298.15 K over the whole range
plotMoleFraction('ha[c]', albertyData, metAbbrAlbertyAbbr, pKa - 1, pKa + 1, 0, 0, 0, 0, ...
    temperature, temperature, 3);
newFigure = setdiff(findall(groot, 'Type', 'figure'), figuresBefore);
assert(numel(newFigure) == 1);
plotAxes = findall(newFigure, 'Type', 'axes');
assert(numel(plotAxes) == 1);
plotLines = findall(plotAxes, 'Type', 'line');
% two species (the NaN row is not one)
assert(numel(plotLines) == 2);

% the legend names each species by the metabolite abbreviation and its charge
plotLegend = findall(newFigure, 'Type', 'legend');
assert(isequal(sort(plotLegend.String), {'ha[c]-1', 'ha[c]0'}));
assert(strcmp(plotAxes.XLabel.String, 'pH') && strcmp(plotAxes.YLabel.String, 'mole fraction'));

% the pH grid is linspace(PHmin, PHmax, N); 1e-12 allows for the rounding of linspace
deprotonated = findobj(plotLines, 'DisplayName', 'ha[c]-1');
protonated = findobj(plotLines, 'DisplayName', 'ha[c]0');
assert(norm(deprotonated.XData - [pKa - 1, pKa, pKa + 1]) < 1e-12);
assert(norm(protonated.XData - deprotonated.XData) < 1e-12);

% Henderson-Hasselbalch: [A-]/[HA] = 10^(pH - pKa), so A- has the fractions 1/11, 1/2 and 10/11.
% calcdGHT uses R = 8.31451e-3 and acidDissociationConstant 8.314472e-3, which differ by 5e-6
% relative, so the fractions agree with the relation to about 2e-5 (tolerance 1e-4)
tol = 1e-4;
assert(norm(deprotonated.YData - [1/11, 1/2, 10/11]) < tol);
assert(norm(protonated.YData - [10/11, 1/2, 1/11]) < tol);
% the fractions of the two species add up to 1 at every pH
assert(norm(deprotonated.YData + protonated.YData - 1) < 1e-12);

% close the figures of this test and restore the default visibility
close(newFigure);
set(groot, 'DefaultFigureVisible', defaultVisible);

% change the directory
cd(currentDir)
