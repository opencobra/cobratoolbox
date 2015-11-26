% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
%formula2mets 
%input rxn formula
%output list of metabolites
%uses parseRxnFormula.m (Cobra Toolbox)
%
%
% Stefan G. Thorleifsson August 2010

function metabolites = formula2mets(formula)

mets = parseRxnFormula(formula);
mets = mets{1};
metabs = {};
for i = 1:length(mets)
    met_i = mets{i};
    brack = regexpi(met_i,'[');
    if ~isempty(brack)
        metabs = [metabs met_i(1:brack-1)];
    end
end
metabolites = metabs;
