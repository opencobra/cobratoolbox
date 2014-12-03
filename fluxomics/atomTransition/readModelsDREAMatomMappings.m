function [atomMappings,missingBool]=readModelsDREAMatomMappings(model,rxnFilePath,modelName)
%read atom mapping data for all internal reactions in a model
%
%INPUT
% model         stoichiometricModel
% rxnFilePath   path to DREAM .rxn output files for each internal reaction in the model
%
%OUTPUT
% atomMappings                           #mappings x 1 structure array with fields (j = 1 ... #mappings):
%
% atomMappings(j).reactantMapping        #reactants x 1 struct array with fields (i = 1 ... #reactants):
%
% atomMappings(j).reactantMapping(i).nAtoms         #atoms in ith reactant
%
% atomMappings(j).reactantMapping(i).nBonds         #bonds in ith reactant
%
% atomMappings(j).reactantMapping(i).atomBlock      #atom x 5 cell array with columns:
%                                                   atomic symbol;atom number; x position, y position, z position
%
% atomMappings(j).reactantMapping(i).bondBlock      #bond x 3 numeric array with columns:
%                                                   first atom number, second atom number, bond type
%
% atomMappings(j).reactantMapping.numSubstrates     #substrates in reaction (ignoring hydrogen)
% atomMappings(j).reactantMapping.numProducts       #products in reaction (ignoring hydrogen)
% atomMappings(j).rxn                               model.rxns{n}
% atomMappings(j).name                              [model.rxns{n} '_map1']

if ~isfield(model,'SIntRxnBool')
    model = findSExRxnInd(model);
end

if ~exist('rxnFilePath')
    rxnFilePath=pwd;
end

[nMet,nRxn]=size(model.S);

missingBool=false(nnz(model.SIntRxnBool),1);
k=1;
for n=1:nRxn
    if model.SIntRxnBool(n)==1
        filename=[model.rxns{n} '.rxn'];
        if ~exist([rxnFilePath filename],'file')
            missingBool(n)=1;
        else
            if strcmp(modelName,'DA')
                atomMappings(k,1).reactantMapping=readDREAMrxnFile_DA(filename,rxnFilePath);
            else
                atomMappings(k,1).reactantMapping=readDREAMrxnFile(filename,rxnFilePath);
            end
            atomMappings(k,1).rxn=model.rxns{n};
            atomMappings(k,1).name=[model.rxns{n} '_map1']; %TODO generalise to multiple mappings per rxn
            k=k+1;
        end
    end
end
%                   


