function model = setupComponentContribution(model, molFileDir, cid, printLevel)
% Estimates standard transformed reaction Gibbs energy and directionality
% at in vivo conditions in multicompartmental metabolic reconstructions.
% Has external dependencies on the COBRA toolbox, the component
% contribution method, Python (with numpy and Open Babel bindings),
% ChemAxon's Calculator Plugins, and Open Babel.
%
% USAGE:
%
%    model = setupComponentContribution(model, molFileDir, cid, printLevel)
%
% INPUTS:
%    model:         Model structure with the following fields:
%
%                     * .mets - `m x 1` array of metabolite identifiers
%                     * .metFormulas - `m x 1` cell array of metabolite formulas;
%                       formulas for protons should be H, and for water H2O
%                     * .metCharges - `m x 1` numerical array of metabolite charges
%
% OPTIONAL INPUTS:
%    molFileDir:    path to a directory containing molfiles for the major
%                   tautomer of the major microspecies of each metabolite at
%                   pH 7. Molfiles should be named with the metabolite
%                   identifiers in `model.mets` (without compartment
%                   assignments). Not required if `cid` is specified.
%    cid:           `m x 1` cell array of KEGG Compound identifiers. Not
%                   required if `molFileDir` is specified.
%    printLevel:    verbosity level (default 1)
%
% OUTPUTS:
%    model:         Model structure with the following additional fields:
%
%                     * .inchi - structure containing four `m x 1` cell arrays of
%                       IUPAC InChI strings for metabolites, with varying levels
%                       of structural detail
%                     * .pseudoisomers - `p x 4` matrix with columns: metabolite
%                       index; estimated pseudoisomer standard Gibbs energy;
%                       number of hydrogen atoms in the pseudoisomer chemical
%                       formula; charge on the pseudoisomer
%
% NOTE:
%    Writes MetStructures.sdf, an SDF containing all structures input to the
%    component contribution method for estimation of standard Gibbs energies.
%
% .. Author: - Ronan M. T. Fleming, Sept. 2012, Version 1.0
% ..           Hulda S. H., Dec. 2012, Version 2.0


%% Configure inputs
% Retreive molfiles from KEGG if KEGG ID are given. Otherwise use molfiles
% in molfileDir.
if ~exist('cid','var')
    cid = [];
end
if ~exist('printLevel','var')
    printLevel = 1;
end
%% Get metabolite structures
if ~isempty(cid)
    molFileDir = 'molfilesFromKegg';
    fprintf('\nRetreiving molfiles from KEGG.\n');
    takeMajorMS = true; % Convert molfile from KEGG to major tautomer of major microspecies at pH 7
    pH = 7;
    takeMajorTaut = true;
    kegg2mol(cid,molFileDir,model.mets,takeMajorMS,pH,takeMajorTaut); % Retreive mol files
end

if printLevel>0
fprintf('Creating MetStructures.sdf from molfiles.\n')
end

sdfFileName = 'MetStructures.sdf';
includeRs = 0; % Do not include structures with R groups in SDF
[sdfMetList,noMolMetList] = mol2sdf(model.mets,molFileDir,sdfFileName,includeRs);

if printLevel>0
fprintf('Converting SDF to InChI strings.\n')
end
model.inchi = createInChIStruct(model.mets,sdfFileName);
compositeBool = ~cellfun('isempty',regexp(model.inchi.nonstandard,'\.')); % Remove InChI for composite compounds as they cause problems later.
model.inchi.standard(compositeBool) = cell(sum(compositeBool),1);
model.inchi.standardWithStereo(compositeBool) = cell(sum(compositeBool),1);
model.inchi.standardWithStereoAndCharge(compositeBool) = cell(sum(compositeBool),1);
model.inchi.nonstandard(compositeBool) = cell(sum(compositeBool),1);

%% Estimate metabolite pKa values with ChemAxon calculator plugins and determine all relevant pseudoisomers.
if printLevel>0
fprintf('Estimating metabolite pKa values.\n');
end
npKas = 20; % Number of acidic and basic pKa values to estimate
takeMajorTaut = false; % Estimate pKa for input tautomer. Input tautomer is assumed to be the major tautomer for the major microspecies at pH 7.
model.pseudoisomers = estimate_pKa(model.mets,model.inchi.nonstandard,npKas,takeMajorTaut); % Estimate pKa and determine pseudoisomers
model.pseudoisomers = rmfield(model.pseudoisomers,'met');

% Add number of hydrogens and charge for metabolites with no InChI
if any(~[model.pseudoisomers.success]) && printLevel>0
    fprintf('Assuming that metabolite species in model.metFormulas are representative for metabolites where pKa could not be estimated.\n');
end
nonphysicalMetSpecies = {};
for i = 1:length(model.mets)
    model_z = model.metCharges(i); % Get charge from model
    model_nH = numAtomsOfElementInFormula(model.metFormulas{i},'H'); % Get number of hydrogens from metabolite formula in model
    if ~model.pseudoisomers(i).success
        model.pseudoisomers(i).zs = model_z;
        model.pseudoisomers(i).nHs = model_nH;
        model.pseudoisomers(i).majorMSpH7 = true; % Assume species in model is the major (and only) metabolite species %RF: this seems dubious
    end
    if ~any(model.pseudoisomers(i).nHs == model_nH)
        nonphysicalMetSpecies = [nonphysicalMetSpecies; model.mets(i)];
    end
end
if ~isempty(nonphysicalMetSpecies)
    nonphysicalMetSpecies = unique(regexprep(nonphysicalMetSpecies,'\[\w\]',''));
    if printLevel>1
        fprintf('%s\n','#H in model.metFormulas does not match any of the species calculated mol file for metabolites:')
        for n=1:length(nonphysicalMetSpecies)
            fprintf('%s\n',nonphysicalMetSpecies{n});%,model.metFormulas{m});
        end
    end
end
