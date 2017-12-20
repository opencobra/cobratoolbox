function Genes = GPR2Genes(GPR)
% Input is a list of GPRs and output is a unique list of genes.
%
% USAGE:
%
%    Genes = GPR2Genes(GPR)
%
% INPUT:
%    GPR:    list of GPRs
%
% OUTPUT:
%    Genes:  unique list of genes
%
% .. Author: - Stefan G. Thorleifsson ugust 2010
%
% .. rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% .. Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% .. reconstructing high-quality biochemical networks, Bioinformatics, Accepted.
% .. rbionet@systemsbiology.is
Gen = {};
S = size(GPR);
for i = 1:S(1)

    % 2011/03/28 Stefan G. Thorleifsson new simpler system
    gpr = GPR{i};
    filter = strrep(gpr,'(','');
    filter = strrep(filter,')','');
    filter = strrep(filter,'and','');
    filter = strrep(filter,'AND','');
    filter = strrep(filter,'or','');
    filter = strrep(filter,'OR',''); 
    split = regexpi(filter,' ', 'split');
    cnt = 0;
    for k = 1:length(split)
        if isempty(split{k-cnt})
            split(k-cnt) = '';
            cnt = cnt + 1;
        end
    end
    Gen = [Gen split];
end
Genes = unique(Gen);
