function model = setupThermoModel(model, confidenceLevel)
% Estimates standard transformed reaction Gibbs energy and directionality
% at in vivo conditions in multicompartmental metabolic reconstructions.
% Has external dependencies on the COBRA toolbox, the component
% contribution method, Python (with numpy and Open Babel bindings),
% ChemAxon's Calculator Plugins, and Open Babel. See details on
% availability at the end of help text.
%
% USAGE:
%
%    model = setupThermoModel(model, confidenceLevel)
%
% INPUTS:
%    model:              Model structure with following fields:
%
%                          * .S - `m x n` stoichiometric matrix.
%                          * .mets - `m x 1` array of metabolite identifiers.
%                          * .rxns - `n x 1` array of reaction identifiers.
%                          * .metFormulas - `m x 1` cell array of metabolite formulas. Formulas for
%                            protons should be H, and formulas for water should be H2O.
%                          * .metCharges - `m x 1` numerical array of metabolite charges.
%                          * .T - Temperature in Kelvin.
%                          * .compartments - `c x 1` array of compartment identifiers. Should match
%                            the compartment identifiers in model.metComps.
%                          * .ph - `c x 1` array of compartment specific pH values in the
%                            range 4.7 to 9.3.
%                          * .is - `c x 1` array of compartment specific ionic strength
%                            values in the range 0 to 0.35 mol/L.
%                          * .chi - `c x 1` array of compartment specific electrical
%                            potential values in mV. Electrical potential in cytosol
%                            is assumed to be 0 mV. Electrical potential in all
%                            other compartments are relative to that in cytosol.
%                          * .concMin - `m x 1` array of lower bounds on metabolite
%                            concentrations in mol/L.
%                          * .concMax - `m x 1` array of upper bounds on metabolite
%                            concentrations in mol/L.
%
%    confidenceLevel:    {0.50, 0.70, (0.95), 0.99}. Confidence level for
%                        standard transformed reaction Gibbs energies used to
%                        quantitatively assign reaction directionality. Default
%                        is 0.95, corresponding to a confidence interval of `+/- 1.96 * ur`.
%
% OUTPUT:
%    model:              Model structure with following additional fields:
%
%                          * .inchi - Structure containing four `m x 1` cell array's of
%                            IUPAC InChI strings for metabolites, with varying
%                            levels of structural detail.
%                          * .pKa - `m x 1` structure containing metabolite pKa values
%                            estimated with ChemAxon's Calculator Plugins.
%                          * .DfG0 - `m x 1` array of component contribution estimated
%                            standard Gibbs energies of formation.
%                          * .covf - `m x m` estimated covariance matrix for standard
%                            Gibbs energies of formation.
%                          * .DfG0_Uncertainty - `m x 1` array of uncertainty in estimated standard
%                            Gibbs energies of formation. Will be large for
%                            metabolites that are not covered by component contributions.
%                          * .DrG0 - `n x 1` array of component contribution estimated
%                            standard reaction Gibbs energies.
%                          * .DrG0_Uncertainty - `n x 1` array of uncertainty in standard reaction
%                            Gibbs energy estimates.  Will be large for
%                            reactions that are not covered by component contributions.
%                          * .DfG0_pseudoisomers   `p x 4` matrix with the following columns:
%
%                            1. Metabolite index.
%                            2. Estimated pseudoisomer standard Gibbs energy.
%                            3. Number of hydrogen atoms in pseudoisomer chemical formula.
%                            4. Charge on pseudoisomer.
%                          * .DfGt0 - `m x 1` array of estimated standard transformed Gibbs
%                            energies of formation.
%                          * .DrGt0 - `n x 1` array of estimated standard transformed
%                            reaction Gibbs energies.
%                          * .DfGtMin - `m x 1` array of estimated lower bounds on
%                            transformed Gibbs energies of formation.
%                          * .DfGtMax - `m x 1` array of estimated upper bounds on
%                            transformed Gibbs energies of formation.
%                          * .DrGtMin - `n x 1` array of estimated lower bounds on
%                            transformed reaction Gibbs energies.
%                          * .DrGtMax - `n x 1` array of estimated upper bounds on
%                            transformed reaction Gibbs energies.
%
% Written output - MetStructures.sdf - An SDF containing all structures input to the
% component contribution method for estimation of standard Gibbs energies.
%
%  .. Author: - Ronan M. T. Fleming, Hulda S. H.,

if isfield(model,'R') %stupid to have R as gas constant when it could be used for a matrix
    model.gasConstant=8.3144621e-3; % Gas constant in kJ/(K*mol)
    model=rmfield(model,'R');
end
if isfield(model,'F')
    %Faraday Constant (kJ/kmol)
    model.faradayConstant=96.485/1000; %kJ/kmol
    model=rmfield(model,'R');
end


%% Estimate standard transformed Gibbs energies of formation
fprintf('\nEstimating standard transformed Gibbs energies of formation.\n');
model = estimateDfGt0(model,confidenceLevel);


%% Estimate standard transformed reaction Gibbs energies
fprintf('\nEstimating bounds on transformed Gibbs energies.\n');
model = estimateDrGt0(model,confidenceLevel);
