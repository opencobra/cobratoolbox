function Bout = mapAontoBOld(Akey, Bkey, Ain, Bin)
% Map the values in `Ain` (keyed by `Akey`) onto the ordering of `Bkey`
%
% For each element of `Bkey` that is a member of `Akey`, the corresponding
% value of `Ain` is placed at the matching position of the output. `ismember`
% returns `LIBkey` (true where `Bkey` is in `Akey`) and `LOCAkey` (the lowest
% index in `Akey` of each matched element of `Bkey`, 0 otherwise).
%
% USAGE:
%
%    Bout = mapAontoBOld(Akey, Bkey, Ain, Bin)
%
% INPUTS:
%    Akey:    array of source keys
%    Bkey:    array of target keys defining the ordering of the output
%    Ain:     array of values corresponding to `Akey` (cell, double, logical or int64)
%
% OPTIONAL INPUT:
%    Bin:     pre-existing output array to fill in; if omitted, an empty array
%             of the same class as `Ain` and the size of `Bkey` is created
%
% OUTPUT:
%    Bout:    array the size of `Bkey`, with values of `Ain` mapped onto the
%             positions where `Bkey` is a member of `Akey`

[LIBkey,LOCAkey] = ismember(Bkey,Akey);

if exist('Bin','var')
    Bout = Bin;
else
    classAin = class(Ain);
    switch classAin
        case 'cell'
            Bout=cell(length(Bkey),1);
        case 'double'
            Bout=sparse(length(Bkey),1)*NaN;
        case 'logical'
            Bout=false(length(Bkey),1);
        case 'int64'
            Bout=sparse(length(Bkey),1)*NaN;   
        otherwise
            error('unrecognised class')
    end
end

Bout(LIBkey) =  Ain(LOCAkey(LOCAkey~=0));

end