function [neg, zer, nd, pos] = convertGene2PathwayInteractions(E, epSys, uSys)
% This function was written to find out the type of epistatic interactions
% that either exist between two different or within same subsystem
%
% USAGE:
%
%     [neg,zer,nd,pos] = convertGene2PathwayInteractions(E,epSys,uSys)
%
% INPUT:
%    E:     A square epistatic interaction matrix (or genes or reactions)
%    epSys: Subsystems belonging to the gene at that index (a second
%           order cell array) Each cell array may contain one or more
%           subsystems.
%           e.g. for first gene or reaction in E:
%           epCmpt{1,1} = {'Glycolysis';'TCA cycle'}
%    uSys:  Unique Subsystems in the epCmpt (use this arguments if
%           interested in interactions between selected subsystems in the epSys)
%
% OUTPUTS:
%    neg:            matrix of number of aggravating (negative) pathway-pair interactions
%    zer:            matrix of number of no-epistatic interactions pathway-pair interactions
%    nd:             matrix of number of non-decisive interactions pathway-pair interactions
%    pos:            matrix of number of buffering (positive) interactions pathway-pair interactions
%
% NOTE:
%    See figures in following publication:
%    Joshi CJ and Prasad A, 2014, "Epistatic interactions among metabolic genes
%    depend upon environmental conditions", Mol. BioSyst., 10, 2578-2589.
%
% .. Authors:
%     - Chintan Joshi 10/26/2018

if (nargin < 3)
    uSys = unique(convertMyCell2List(epSys, 2));
end

negE = (E < -0.25);
zerE = (E >= -0.25) & (E < 0.25);
ndE = (E >= 0.25) & (E < 0.85);
posE = (E >= 0.85);
g1 = 0;
g2 = 0;
pos = zeros(length(uSys), length(uSys)); neg = pos; nd = pos; zer = pos;
for i = 1:length(uSys)
    index1 = cellfun(@strcmp, epSys, repmat(uSys(i), length(epSys), 1));
    for j = 1:length(uSys)
        index2 = cellfun(@strcmp, epSys, repmat(uSys(j), length(epSys), 1));
        pos(i, j) = sum(sum(posE(index1, index2)));
        neg(i, j) = sum(sum(negE(index1, index2)));
        nd(i, j) = sum(sum(ndE(index1, index2)));
        zer(i, j) = sum(sum(zerE(index1, index2)));
    end
end

function B = convertMyCell2List(A, dimSense)

% This function linearizes a cell array if some of the cells in the array are another embbedded cell arrays.
% (hence, two degrees of cell array)

% This will only work for atmost two degrees of cell array.

% A=cell array to be linearized.
% dimSense=determines if inner cells are row (dimSense=1) vectors or columns (dimSense=2, default)

cnt = 0;
if nargin < 2
    dimSense = 2;
end
for i = 1:length(A)
    for j = 1:length(A{i, 1})
        cnt = cnt + 1;
        if dimSense == 1
            B{cnt, 1} = A{i, 1}{1, j};
        elseif dimSense == 2
            B{cnt, 1} = A{i, 1}{j, 1};
        end
    end
end
