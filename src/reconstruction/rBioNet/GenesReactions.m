function list = GenesReactions(genelist,rxns)
% Returns genes in model and the associative reactions.
%
% USAGE:
%
%    list = GenesReactions(genelist, rxns)
%
% INPUTS:
%    genelist:    list of genes
%    rxns:        reactions
%
% OUTPUT:
%    list:        genes in model and the associative reactions
%
% .. Author: - Stefan G. Thorleifsson 2011
%
% .. rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% .. Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% .. reconstructing high-quality biochemical networks, Bioinformatics, Accepted.
% .. rbionet@systemsbiology.is

GPRs = rxns(:,6);
Sg = size(genelist);
list = cell(Sg(1),2);
list(:,1) = genelist;
S = size(rxns);

for i = 1:S(1)
    genes = GPR2Genes({GPRs{i}});
    if ~isempty(genes)
        SG = size(genes);
        for k = 1:SG(2)
            line = find(strcmp(genes{k},genelist));
            if isempty(line)
                msgbox(['Gene ' genes{k} ' is not in genelist....' rxns{i,2}],...
                    'My bad....the programmer.','help');
            else
                if isempty(list{line,2})
                    list{line,2} = rxns{i,2};
                else
                    rxn = list{line,2};
                    list{line,2} = [rxn ', ' rxns{i,2}];
                end
            end
        end
    end
end
