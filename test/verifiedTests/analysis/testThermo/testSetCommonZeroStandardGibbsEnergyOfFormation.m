% The COBRAToolbox: testSetCommonZeroStandardGibbsEnergyOfFormation.m
%
% Purpose:
%     - setCommonZeroStandardGibbsEnergyOfFormation(model, adjustedMetList) shifts, compartment
%       by compartment, the standard transformed Gibbs energies of formation (model.met(m).dGft0)
%       of Alberty's paired cofactors (fad/fadh2, nad/nadh, nadp/nadph, the coenzyme A set, ...)
%       that come from equilibrium data ('Keq') onto the group contribution baseline, and prints
%       the cofactor data before and after. Quarantined: no behaviour of
%       setCommonZeroStandardGibbsEnergyOfFormation is asserted until the defect below is fixed.
%
% Function under test:
%     src/analysis/thermo/reactantContribution/setCommonZeroStandardGibbsEnergyOfFormation.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - thermodynamic model manipulation, no solver; a test would use a hand-built model
%     with S, mets and met(m).dGft0 / dGft0Keq / dGft0GroupCont / dGft0Source /
%     albertyAbbreviation.
%
% Coverage exemptions:
%     every line - setCommonZeroStandardGibbsEnergyOfFormation is quarantined for the defect
%     below (feature 20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every call stops at getCompartment with Too many input arguments
%       SEVERITY: error
%       TRIGGER: any call, for example model.S = sparse([1 -1; -1 1]) and
%         model.mets = {'fad[c]'; 'fadh2[c]'}, setCommonZeroStandardGibbsEnergyOfFormation(model)
%       OBSERVED: MATLAB R2025a, 2026-11-16: "Too many input arguments." (MATLAB:TooManyInputs)
%         at line 58: getCompartment(model.mets, numChar) passes a second argument, but
%         src/analysis/thermo/vonBertalanffy/getCompartment.m, the only getCompartment on the
%         path, takes one input (mets)
%       EXPECTED: the cofactor baselines are adjusted and model is returned, as the help text says
%       LINES: 57-58
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSetCommonZeroStandardGibbsEnergyOfFormation'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
