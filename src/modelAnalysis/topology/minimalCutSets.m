function [output] = minimalCutSets(targets, varargin)
% Computes minimal cut sets for paths/cycles/elementary modes with Berge algorithm
% (equivalent to hypergraph transversal) by the CNA software package.
%
% USAGE:
%
%    output = minimialCutSets(targets, varargin)
%
% INPUT:
%    targets (mandatory): a binary matrix that row-wise contains the
%                         target paths/cycles/elementary modes; a '1' in
%                         the i-th row and j-th column in targets indicates
%                         participation of element (reaction) j in mode i;
%
%    mcsmax:              maximal size of cutsets to be calculated; must
%                         be a value grater 0; Inf means no size limit
%                         (default: Inf)
%
%    names:               a char matrix; its rows are names corresponding
%                         to the columns of 'targets'; used for diagnostics
%                         in preprocessing (default:[]; the matrix is then
%                         constructed with 'I1,',I2',....)
%
%    sets2save:           (default: []) struct array with sets of (desired)
%                         modes/paths/cycles that should be preserved (not
%                         be hit by the cut sets computed). Should have the
%                         following fields:
%
%                         * sets2save(k).tabl2save = k-th matrix containing
%                           row-wise 'desired' sets (desired paths/cycles/
%                           modes) that should not be hit by the cut sets
%                           to be computed. be saved A '1' in the i-th row
%                           and j-th column of sets2save(k) indicates
%                           participation of element j in mode i in set k
%                           of desired modes. These matrics must have the
%                           same number of columns (reactions) as 'targets'.
%
%                         * sets2save(k).min2save = specifies the minimum
%                           number of desired paths/cycles/modes in
%                           sets2save(k).tabl2save that should not be
%                           hit by the cut sets computed.
%
% earlycheck:             whether the test checking for the fulfillment
%                         of constraints in sets2save should be caried
%                         out during (1) or after (0) computation
%                         of cut sets [default: 1; makes only sense
%                         in combination with sets2save]
%
% OUTPUT:
%    cutsets:             matrix that contains the (constrained) cutsets
%                         row-wise; a '1' means that the reaction
%                         /interaction is part of the cutset, 0 means the
%                         element/reaction/interaction is not involved.
%                         Each cutset hits all modes stored in "targets"
%                         while it does not hit at least
%                         "sets2save(k).min2save" many modes in
%                         "sets2save(k).tabl2save"
%
% .. Author: Susan Ghaderi, LCSB, 06.06.2017

mcsmax = Inf;
names = [];
sets2save = [];
earlycheck = 1;

%% varargin checking
if numel(varargin) > 1
    for i = 1:2:numel(varargin)
        key = varargin{i};
        value = varargin{i + 1};
        switch key
            case 'mcsmax'
                mcsmax = value;
            case 'names'
                names = value;
            case 'sets2save'
                sets2save = value;
            case 'earlycheck'
                earlycheck = value;
            otherwise
                msg = sprintf('Unexpected key %s', key)
                error(msg);
        end

    end
end
%%
cutsets = CNAcomputeCutsets(targets, mcsmax, names, ...
                            sets2save, earlycheck)

%% OUTPUT :
output.cutsets = cutsets;
end
