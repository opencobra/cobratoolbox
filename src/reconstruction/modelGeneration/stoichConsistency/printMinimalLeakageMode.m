function printMinimalLeakageMode(model,minMetBool,minRxnBool,y,printLevel,fileName) 
%prints out the data on each leakage mode


if ~exist('fileName','var')
    fprintf('%6u\t%6u\t%s\n',nnz(minMetBool),nnz(minRxnBool),'leakage mode');
    if printLevel>1 && nnz(minRxnBool)<=10
        if printLevel>2
            fprintf('%6u\t%s\n',nnz(minMetBool), 'leaking metabolites...');
            for m=1:length(model.SIntMetBool)
                if minMetBool(m)
                    fprintf('%s\t%s\n',model.mets{m},model.metNames{m});
                end
            end
        end
        fprintf('%6u\t%s\n',nnz(minRxnBool), 'inconsistent reactions...');
        formulas = printRxnFormula(model,model.rxns(minRxnBool));
    end
    if any(minMetBool)
        %fprintf('%s%6u%s\n','Net mass exchange reaction from ',nnz(minRxnBool), ' active reactions...');
        [modelTmp,rxnIDexists] = addReaction(model,'Net_mass_exchange => ',model.mets(minMetBool),y(minMetBool));
        %formulas = printRxnFormula(model,'Mass_exchange');
    end
    fprintf('%s\n','-------')
else
    fprintf('%6u\t%6u\t%6s\t%15s\t%6g\t%6g\t%6g\t%6g\n',nnz(minMetBool),nnz(minRxnBool),'leakage mode');
    fprintf('%6u\t%s\n',nnz(minMetBool), 'Leaking metabolites...');
    for m=1:length(model.SIntMetBool)
        if minMetBool(m)
            fprintf(fid,'%s\t%s\n',model.mets{m},model.metNames{m});
        end
    end
    fprintf('%6u\t%s\n',nnz(minRxnBool), 'inconsistent reactions...');
    formulas = printRxnFormula(model,model.rxns(minRxnBool));
end
