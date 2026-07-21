function [metFormulaNeutral, metFormulaCharged, metCharge] = getInchiString2ChargedFormula(metList, inchiStringList)
% Computes the charged formula and metabolite charge at pH 7 from InChI strings
%
% It requires ChemAxon and Open Babel. The provided InChI string is assumed to
% describe the neutral metabolite; if it does not, metFormulaNeutral instead
% reflects the formula provided with the InChI string.
%
% USAGE:
%
%    [metFormulaNeutral, metFormulaCharged, metCharge] = getInchiString2ChargedFormula(metList, inchiStringList)
%
% INPUTS:
%    metList:            List of metabolite abbreviations
%    inchiStringList:    List of InChI strings (same order as metList)
%
% OUTPUTS:
%    metFormulaNeutral:     Neutral metabolite formula (as provided in the InChI string)
%    metFormulaCharged:     Charged metabolite formula (at pH 7)
%    metCharge:             Metabolite charge (double, at pH 7)
%
% .. Author: - Ines Thiele, 09/2021


% create dummy model

for i = 1 : length(metList)
    % create mol (sdf) file from inchiString using openBabel
    system(['obabel -:"' inchiStringList{i} '" --gen3D -i inchi -o sdf -O '  metList{i,1} '[c].sdf']);
    
    % create model structure with new metabolite to allow the other
    % functions to work, which require model structure
    model = createModel({'R1'},{'fake rxn'},{['1 ' metList{i,1} ' -->']});
    % add neutral formula
    try
        [model.metFormulas{1}, nH, model.metCharges] = getFormulaAndChargeFromInChI(inchiStringList{i});
        inchiFormula = model.metFormulas{1};
        if model.metCharges == 0
            metFormulaNeutral = model.metFormulas{1};
        else
            metFormulaNeutral = NaN;
        end
    catch 
                    metFormulaNeutral = NaN;
    end
    % define inchis
    model.inchi.standard{1} = [];
    model.inchi.standardWithStereo{1} = [];
    model.inchi.standardWithStereoAndCharge{1} = [];
    model.inchi.nonstandard{1} = inchiStringList{i};
    % calculate major pseudoisomer
    % Number of acidic and basic pKa values to estimate
    npKas = 20;
    % Estimate pKa for input tautomer. Input tautomer is assumed to be the major tautomer for the major microspecies at pH 7.
    takeMajorTaut = false;
    % Estimate pKa and determine pseudoisomers
    try
        [pseudoisomers,pKaErrorMets] = estimate_pKa(model.mets,model.inchi.nonstandard,npKas,takeMajorTaut);
        metFormulaCharged = regexprep(inchiFormula,'H\d+',['H' num2str(pseudoisomers.nHs(pseudoisomers.majorMSpH7))]);
        metCharge = ((pseudoisomers.zs(pseudoisomers.majorMSpH7)));
    catch
        metFormulaCharged = '';
        metCharge = [];
    end
    % delete sdf file generated above as not needed anymore
      delete([metList{i,1} '[c].sdf']);
end