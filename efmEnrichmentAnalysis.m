function efmEnrichmentAnalysis(EFMRxns, model, exprData, GSCFileName, GSSFileName)
% This function performs preprocessing for EFM enrichment. 
% Two input files will be generated:
% Gene Set Collection (GSC) file:  The gene set collection should describe the grouping of reactions into EFMs. 
%                                  A two-column (space-separated) file: <EFM name or number> and <reaction ID> will be generated.
% Gene Set Statistics (GSS) file:  The gene set collection should contain a p-value and expression value for each reaction. 
%                                  Gene level statistics will be mapped from genes onto the reactions using the GPR rules defined in the model. 
%                                  A three-column (space-separated) file: <reaction ID> <fold change> <p value> will be generated.
%
% USAGE:
%    efmEnrichmentAnalysis(EFMRxns, model, exprData, GSCFileName, GSSFileName)
%
% INPUTS:
%    EFMRxns:        matlab array containing reactions in EFMs (each row is an EFM and every entry indicates the reaction IDs in the EFM) 
%    model:          COBRA model structure
%    exprData:       mRNA expression data structure
%       .gene               	cell array containing GeneIDs in the same
%                               format as model.genes
%       .value                  Vector containing corresponding expression
%                               value (FPKM/RPKM)
%       .sig                    Vector containing corresponding significance values
%    GSCFileName:    file name of GSC file
%    GSSFileName:    file name of GSS file
% 
% OUTPUTS:
%    Two files GSC File and GSS File are written in the working directory
%
% .. Author: Last modified: Chaitra Sarathy, 1 Oct 2019


generateGSC(EFMRxns, 1:length(EFMRxns), model, GSCFileName);

% Generate GSS file
expressionRxns = mapExpressionToReactions_efmviz(model, exprData, false);
expressionRxns.rxnExp(expressionRxns.rxnExp==-1)=0;

writetable(table(model.rxns, expressionRxns.rxnExp, expressionRxns.rxnSig), GSSFileName,'Delimiter',' ');

end

function rxnTab = generateGSC(EFMRxns, EFMNum, model, GSCFileName)
% input
% output - 'rxn set1'

temp = 1;

for jj = 1:size(EFMRxns,1)
    for kk = 1:size(EFMRxns,2)

        if (EFMRxns(jj,kk) ~= 0)
            rxnTab(jj,kk) = model.rxns(EFMRxns(jj,kk)); 
            rxn(temp,:) = model.rxns(EFMRxns(jj,kk));
            set(temp,:) = cellstr('EFM');
            setNum(temp,:) = cellstr(num2str(EFMNum(jj)));
            temp = temp + 1;
        else 
            rxnTab(jj,kk) = cellstr('');
        end
    end
end

gsc = [rxn, set, setNum];

fi = fopen(GSCFileName, 'w');
for row = 1:size(gsc,1)
    fprintf(fi, '%s %s%s\n', gsc{row,:});
end
fclose(fi);
end