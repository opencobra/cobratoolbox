function modelT = setupThermoModel(model,molfileDir,cid,T,cellCompartments,ph,is,chi,xmin,xmax,confidenceLevel)
% Estimates standard transformed reaction Gibbs energy and directionality
% at in vivo conditions in multicompartmental metabolic reconstructions.
% Has external dependencies on the COBRA toolbox, the component
% contribution method, Python (with numpy and Open Babel bindings),
% ChemAxon's Calculator Plugins, and Open Babel. See details on
% availability at the end of help text. 
% 
% modelT = setupThermoModel(model,molfileDir,cid,T,cellCompartments,ph,...
%                           is,chi,xmin,xmax,confidenceLevel) 
% 
% INPUTS
% model             Model structure with following fields:
% .S                m x n stoichiometric matrix.
% .mets             m x 1 array of metabolite identifiers.
% .rxns             n x 1 array of reaction identifiers.
% .metFormulas      m x 1 cell array of metabolite formulas. Formulas for
%                   protons should be H, and formulas for water should be
%                   H2O.
% .metCharges       m x 1 numerical array of metabolite charges.
% 
% CONDITIONALLY OPTIONAL INPUTS
% molfiledir                Path to a directory containing molfiles for the
%                           major tautomer of the major microspecies of
%                           each metabolite at pH 7. Molfiles should be
%                           named with the metabolite identifiers in
%                           model.mets (without compartment assignments).
%                           Not required if cid are specified.
% cid                       m x 1 cell array of KEGG Compound identifiers.
%                           Not required if molfiledir is specified.
% model.metCompartments     m x 1 array of metabolite compartment
%                           assignments. Not required if metabolite
%                           identifiers are strings of the format ID[*]
%                           where * is the appropriate compartment
%                           identifier.
% 
% OPTIONAL INPUTS
% T                 Temperature in Kelvin. 
% cellCompartments  c x 1 array of compartment identifiers. Should match
%                   the compartment identifiers in model.metCompartments.
% ph                c x 1 array of compartment specific pH values in the
%                   range 4.7 to 9.3.
% is                c x 1 array of compartment specific ionic strength
%                   values in the range 0 to 0.35 mol/L.
% chi               c x 1 array of compartment specific electrical
%                   potential values in mV. Electrical potential in cytosol
%                   is assumed to be 0 mV. Electrical potential in all
%                   other compartments are relative to that in cytosol.
% xmin              m x 1 array of lower bounds on metabolite
%                   concentrations in mol/L.
% xmax              m x 1 array of upper bounds on metabolite
%                   concentrations in mol/L.
% confidenceLevel   {0.50, 0.70, (0.95), 0.99}. Confidence level for
%                   standard transformed reaction Gibbs energies used to
%                   quantitatively assign reaction directionality. Default
%                   is 0.95, corresponding to a confidence interval of +/-
%                   1.96 * ur.
% 
% OUTPUTS
% model                 Model structure with following additional fields:
% .inchi                Structure containing four m x 1 cell array's of
%                       IUPAC InChI strings for metabolites, with varying
%                       levels of structural detail.
% .pKa                  m x 1 structure containing metabolite pKa values
%                       estimated with ChemAxon's Calculator Plugins.
% .DfG0                 m x 1 array of component contribution estimated
%                       standard Gibbs energies of formation.
% .covf                 m x m estimated covariance matrix for standard
%                       Gibbs energies of formation.
% .uf                   m x 1 array of uncertainty in estimated standard
%                       Gibbs energies of formation. uf will be large for
%                       metabolites that are not covered by component
%                       contributions.
% .DrG0                 n x 1 array of component contribution estimated
%                       standard reaction Gibbs energies.
% .ur                   n x 1 array of uncertainty in standard reaction
%                       Gibbs energy estimates.  ur will be large for
%                       reactions that are not covered by component
%                       contributions.
% .DfG0_pseudoisomers   p x 4 matrix with the following columns:
%                       1. Metabolite index.
%                       2. Estimated pseudoisomer standard Gibbs energy.
%                       3. Number of hydrogen atoms in pseudoisomer
%                       chemical formula.
%                       4. Charge on pseudoisomer.
% .DfGt0                m x 1 array of estimated standard transformed Gibbs
%                       energies of formation.
% .DrGt0                n x 1 array of estimated standard transformed
%                       reaction Gibbs energies.
% .DfGtMin              m x 1 array of estimated lower bounds on
%                       transformed Gibbs energies of formation.
% .DfGtMax              m x 1 array of estimated upper bounds on
%                       transformed Gibbs energies of formation.
% .DrGtMin              n x 1 array of estimated lower bounds on
%                       transformed reaction Gibbs energies.
% .DrGtMax              n x 1 array of estimated upper bounds on
%                       transformed reaction Gibbs energies.
% .quantDir             n x 1 array indicating quantitatively assigned
%                       reaction directionality. 1 for reactions that are
%                       irreversible in the forward direction, -1 for
%                       reactions that are irreversible in the reverse
%                       direction, and 0 for reversible reactions.
% 
% WRITTEN OUTPUTS
% MetStructures.sdf     An SDF containing all structures input to the
%                       component contribution method for estimation of
%                       standard Gibbs energies. 
% 
% DEPENDENCIES
% see initVonBertylanffy
% 
% Ronan M. T. Fleming, Sept. 2012   Version 1.0
% Hulda S. H., Dec. 2012            Version 2.0


%% Configure inputs
if ~isfield(model,'metCompartments')
    model.metCompartments = [];
end
if ~exist('T','var')
    T = [];
end
if ~exist('cellCompartments','var')
    cellCompartments = [];
end
if ~exist('ph','var')
    ph = [];
end
if ~exist('is','var')
    is = [];
end
if ~exist('chi','var')
    chi = [];
end
if ~exist('xmin','var')
    xmin = [];
end
if ~exist('xmax','var')
    xmax = [];
end
if ~exist('confidenceLevel','var')
    confidenceLevel = [];
end

% Store original identifiers
omets = model.mets;
orxns = model.rxns;
ometCompartments = model.metCompartments;
ocellCompartments = cellCompartments;

model = configureSetupThermoModelInputs(model,T,cellCompartments,ph,is,chi,xmin,xmax,confidenceLevel);


%% Get metabolite structures

% Retreive molfiles from KEGG if KEGG ID are given. Otherwise use molfiles
% in molfileDir.
if ~exist('cid','var')
    cid = [];
end
if ~isempty(cid)
    molfileDir = 'molfilesFromKegg';
    fprintf('\nRetreiving molfiles from KEGG.\n');
    takeMajorMS = true; % Convert molfile from KEGG to major tautomer of major microspecies at pH 7
    pH = 7;
    takeMajorTaut = true;
    kegg2mol(cid,molfileDir,model.mets,takeMajorMS,pH,takeMajorTaut); % Retreive mol files
end

fprintf('\nCreating MetStructures.sdf from molfiles.\n')
sdfFileName = 'MetStructures.sdf';
includeRs = 0; % Do not include structures with R groups in SDF
sdfMetList = mol2sdf(model.mets,molfileDir,sdfFileName,includeRs);

fprintf('Converting SDF to InChI strings.\n')
model.inchi = createInChIStruct(model.mets,sdfFileName);
compositeBool = ~cellfun('isempty',regexp(model.inchi.nonstandard,'\.')); % Remove InChI for composite compounds as they cause problems later.
model.inchi.standard(compositeBool) = cell(sum(compositeBool),1);
model.inchi.standardWithStereo(compositeBool) = cell(sum(compositeBool),1);
model.inchi.standardWithStereoAndCharge(compositeBool) = cell(sum(compositeBool),1);
model.inchi.nonstandard(compositeBool) = cell(sum(compositeBool),1);


%% Estimate metabolite pKa values with ChemAxon calculator plugins and determine all relevant pseudoisomers.
fprintf('\nEstimating metabolite pKa values.\n');
npKas = 20; % Number of acidic and basic pKa values to estimate
takeMajorTaut = false; % Estimate pKa for input tautomer. Input tautomer is assumed to be the major tautomer for the major microspecies at pH 7.
model.pKa = estimate_pKa(model.mets,model.inchi.nonstandard,npKas,takeMajorTaut); % Estimate pKa and determine pseudoisomers
model.pKa = rmfield(model.pKa,'met');

% Add number of hydrogens and charge for metabolites with no InChI
if any(~[model.pKa.success]);
    fprintf('\nAssuming that metabolite species in model.metFormulas are representative for metabolites where pKa could not be estimated.\n');
end
nonphysicalMetSpecies = {};
for i = 1:length(model.mets)
    model_z = model.metCharges(i); % Get charge from model
    model_nH = numAtomsOfElementInFormula(model.metFormulas{i},'H'); % Get number of hydrogens from metabolite formula in model
    if ~model.pKa(i).success
        model.pKa(i).zs = model_z;
        model.pKa(i).nHs = model_nH;
        model.pKa(i).majorMSpH7 = true; % Assume species in model is the major (and only) metabolite species
    end
    if ~any(model.pKa(i).nHs == model_nH)
        nonphysicalMetSpecies = [nonphysicalMetSpecies; model.mets(i)];
    end
end
if ~isempty(nonphysicalMetSpecies)
    nonphysicalMetSpecies = unique(regexprep(nonphysicalMetSpecies,'\[\w\]',''));
    fprintf(['\nWarning: Metabolite species given in model.metFormulas does not match any of the species calculated from the input structure for metabolites:\n' sprintf('%s\n',nonphysicalMetSpecies{:})]);
end


%% Call the component contribution method to estimate standard Gibbs energies with uncertainties
fprintf('\nEstimating standard Gibbs energies with the component contribution method.\n');
model = addThermoToModel(model);

% Check for imbalanced reactions
fprintf('\nChecking mass- and charge balance.\n');
model_tmp=findSExRxnInd(model);
[massImbalance,imBalancedMass,imBalancedCharge,imBalancedBool] = checkMassChargeBalance(model_tmp);
if any(imBalancedBool)
    fprintf(['\nWarning: Uncertainty in reaction Gibbs energy estimates will be set to %.2e for the following imbalanced reactions:\n' sprintf('%s\n',model.rxns{imBalancedBool})],max(model.ur));
else
    fprintf('\nAll reactions are mass- and charge balanced');
end


%% Estimate standard transformed Gibbs energies
fprintf('\nEstimating standard transformed Gibbs energies.\n');
model = estimateDGt0(model);


%% Estimate transformed Gibbs energies
fprintf('\nEstimating bounds on transformed Gibbs energies.\n');
confidenceLevel = model.confidenceLevel;
model = estimateDGt(model,confidenceLevel);


%% Determine quantitative directionality assignments
fprintf('\nQuantitatively assigning reaction directionality.\n');
model.quantDir = assignQuantDir(model.DrGtMin,model.DrGtMax);


%% Configure outputs

% Output original identifiers
model.mets = omets;
model.rxns = orxns;
if length(model.cellCompartments) == length(ocellCompartments)
    model.cellCompartments = ocellCompartments;
end
if length(model.metCompartments) == length(ometCompartments)
    model.metCompartments = ometCompartments;
end

% Rename output model
modelT = model;
