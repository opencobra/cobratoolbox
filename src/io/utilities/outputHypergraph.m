function outputHypergraph(model,weights,fileName)
%outputHypergraph Outputs a metabolic reaction network hypergraph with
%weights in reactions
%
% outputHypergraph(model,weights,fileName)
%
%INPUTS
% model         Standard model structure
% weights       Weights for each reaction
% fileName      Output filename
%
%OUTPUT
% Output format: Rxn metabolite_1 metabolite_2 ... metabolite_n rxnWeight
%
% Markus Herrgard

fid = fopen(fileName,'w');

for i = 1:length(model.rxns)
    metInd = find(model.S(:,i)~= 0);
    fprintf(fid,'%d ',i);
    for j = 1:length(metInd)
        fprintf(fid,'%d ',metInd(j));
    end
    fprintf(fid,'%6.4f ',weights(i));
    fprintf(fid,'\n');
end

fclose(fid);