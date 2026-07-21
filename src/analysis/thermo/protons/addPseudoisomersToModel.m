function [model, nonphysicalMetBool, pKaErrorMetBool] = addPseudoisomersToModel(model, printLevel)
% Estimate metabolite pKa values with ChemAxon calculator plugins and determine all relevant pseudoisomers.
%
% USAGE:
%
%    [model, nonphysicalMetBool, pKaErrorMetBool] = addPseudoisomersToModel(model, printLevel)
%
% INPUTS:
%    model:         Model structure with following fields:
%                     * .mets - `m x 1` array of metabolite identifiers.
%                     * .metFormulas - `m x 1` cell array of metabolite formulas. Formulas for
%                       protons should be H, and formulas for water should be H2O.
%                     * .metCharges - `m x 1` numerical array of metabolite charges.
%                     * .metCompartments - optional `m x 1` array of metabolite compartment
%                       assignments. Not required if metabolite
%                       identifiers are strings of the format `ID[*]`
%                       where * is the appropriate compartment identifier.
%
%                   * .inchi - Structure containing four `m x 1` cell array's of
%                     IUPAC InChI strings for metabolites, with varying
%                     levels of structural detail.
%
%                   * .inchi.standard: m x 1 cell array of standard inchi
%                   * .inchi.standardWithStereo: m x 1 cell array of standard inchi with stereo
%                   * .inchi.standardWithStereoAndCharge: m x 1 cell array of standard inchi with stereo and charge
%                   * .inchi.nonstandard: m x 1 cell array of non-standard inchi
%
%    printLevel:    verbosity control; if > 0 prints progress, if > 1 lists
%                   metabolites whose formula hydrogen count matches no species
%                   
% OUTPUTS:
%    model:                    input model with an added field:
%
%                                * .pseudoisomers - `m x 1` structure array (one element per
%                                  metabolite) of acid-base pseudoisomers; fields are empty for
%                                  metabolites with no InChI. Each element has fields:
%
%                                    * .success - true where an InChI was available
%                                    * .pKas - `p x p` matrix; element `(i, j)` is the pKa of the
%                                      acid-base equilibrium between pseudoisomers `i` and `j`
%                                    * .zs - `p x 1` pseudoisomer charges
%                                    * .nHs - `p x 1` number of hydrogen atoms per pseudoisomer
%                                    * .majorMSpH7 - `p x 1` logical, true for the most abundant
%                                      pseudoisomer at pH 7
%    nonphysicalMetBool:       `m x 1` logical, true for metabolites whose formula hydrogen
%                              count matches none of the estimated pseudoisomer species
%    pKaErrorMetBool:          `m x 1` logical, true for metabolites where pKa estimation failed
% NOTE:
%    Writes MetStructures.sdf, an SDF containing all structures input to the
%    component contribution method for estimation of standard Gibbs energies.
%
% .. Author:
%       - Ronan M. T. Fleming, Sept. 2012, Version 1.0
%       - Hulda S. H., Dec. 2012, Version 2.0

[status,result] = system('cxcalc');
if status ~= 0
    if status==127
        disp(result)
        error('Check that ChemAxon Marvin Beans is working licence is working and cxcalc is on the system path.')
    else
        disp(result)
        setenv('PATH', [getenv('PATH') ':/usr/local/bin/chemaxon/bin'])%RF
        setenv('PATH', [getenv('PATH') ':/opt/ChemAxon/MarvinBeans/bin/'])
        setenv('CHEMAXON_LICENSE_URL',[getenv('HOME') '/.chemaxon/license.cxl'])
        [status,result] = system('cxcalc');
        if status ~= 0
            disp(result)
            error('Check that ChemAxon Marvin Beans is installed, licence is working and cxcalc is on the system path.')
        end
    end
end

%% Estimate metabolite pKa values with ChemAxon calculator plugins and determine all relevant pseudoisomers.
if printLevel>0
    fprintf('Estimating metabolite pKa values.\n');
end

% Number of acidic and basic pKa values to estimate
npKas = 20; 
% Estimate pKa for input tautomer. Input tautomer is assumed to be the major tautomer for the major microspecies at pH 7.
takeMajorTaut = false; 
% Estimate pKa and determine pseudoisomers
[pseudoisomers,pKaErrorMets] = estimate_pKa(model.mets,model.inchi.nonstandard,npKas,takeMajorTaut); 

mets = regexprep(model.mets,'(\[\w\])$','');
pKaErrorMetBool = ismember(mets,pKaErrorMets(:,1));

model.pseudoisomers = pseudoisomers;
model.pseudoisomers = rmfield(model.pseudoisomers,'met');

% Add number of hydrogens and charge for metabolites with no InChI
if any(~[model.pseudoisomers.success]) && printLevel>0
    fprintf('Assuming that metabolite species in model.metFormulas are representative for metabolites where pKa could not be estimated.\n');
end

nonphysicalMetBool = false(length(model.mets),1);
nonphysicalMetSpecies = {};
for i = 1:length(model.mets)
    if ~isempty(model.metFormulas{i})
        model_z = model.metCharges(i); % Get charge from model
        model_nH = numAtomsOfElementInFormula(model.metFormulas{i},'H'); % Get number of hydrogens from metabolite formula in model
        if ~model.pseudoisomers(i).success
            model.pseudoisomers(i).zs = model_z;
            model.pseudoisomers(i).nHs = model_nH;
            model.pseudoisomers(i).majorMSpH7 = true; % Assume species in model is the major (and only) metabolite species %RF: this seems dubious
        end
        if ~any(model.pseudoisomers(i).nHs == model_nH)
            nonphysicalMetBool(i) = true;
        end
    else
        %fail gracefully if no model.metFormulas
        model.pseudoisomers(i).zs = NaN;
        model.pseudoisomers(i).nHs = NaN;
        model.pseudoisomers(i).majorMSpH7 = NaN; % Assume species in model is the major (and only) metabolite species %RF: this seems dubious
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

if printLevel>0
    fprintf('%u%s\n',length(model.mets),' = number of model metabolites')
    fprintf('%u%s\n',nnz(nonphysicalMetBool),' = number of nonphysical model metabolites')
    fprintf('%u%s\n',nnz(pKaErrorMetBool),' = number of model metabolites with pKa error')
end