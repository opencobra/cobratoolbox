function exportFluxForSimpheny(modelT,flux,filename)
%export a tab delimited file with rxn abbreviation, simpheny id, and net
%flux
%
%INPUT
%modelT.rxns                Reaction abbreviation
%modelT.rxnSimphenyID       Simpheny ID
%flux                       flux vector
%


fid=fopen(filename,'w');
for n=1:length(modelT.rxns)
    if ~isempty(modelT.rxnSimphenyID(n))
        fprintf(fid,'%s\t%d\t%f\n',modelT.rxns{n},modelT.rxnSimphenyID(n),flux(n));
    else
        error([modelT.rxns{n} ' has no Simpheny ID'])
    end
end
fclose(fid);