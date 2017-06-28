function compareMetaboliteFormulae(modelT)
%print out a tab delimited file with the abbreviations, reconstruction
%metabolite formluae, and group contribution metabolite formulae.
%
%INPUT
%modelT     output of setupThermoModel
%
%
fid=fopen('metaboliteFormulae.txt','w');

[nMet,nRxn]=size(modelT.S);

for m=1:nMet
    fprintf(fid,'%20s%20s\t%20s\n',modelT.mets{m},modelT.metFormulas{m},modelT.met(m).formulaMarvin);
end
fclose(fid);



