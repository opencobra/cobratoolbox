function boundsToFiles(model)
%print out the model bounds as a tab delimited text file
%
% IMPUT
% model
%
% Ronan M.T. Fleming

[nMet,nRxn]=size(model.S);

fid=fopen('model_met_bounds.txt','w');
for m=1:nMet
    fprintf(fid,'%s\t%g\t%g\n',model.met(m).abbreviation,model.met(m).concMin,model.met(m).concMax);
end
fclose(fid);

fid=fopen('model_rxn_bounds.txt','w');
for m=1:nRxn
    fprintf(fid,'%s\t%g\t%g\n',model.rxn(m).abbreviation,model.lb(m),model.ub(m));
end
fclose(fid);
