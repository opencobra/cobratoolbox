function [out] = cdv2idv(n)
% Transformation matrix to transform cumomers to idv's.
% `idv = cdv2idv(log2(length(cdv)))*cdv`;
% Employs memoization.
%
% USAGE:
%
%    [out] = cdv2idv(n)
%
% INPUT:
%    n:      cdv
%
% OUTPUT:
%    out:    idv

global CDV2IDVSAV

if ~isempty(CDV2IDVSAV)
    if length(CDV2IDVSAV) >= n
        if ~isempty(CDV2IDVSAV{n})
            out =  CDV2IDVSAV{n};
            return;
        end
    end
end

out = speye(1,1);

for i = 1:n
    out = [out, -out;  sparse([],[],[],length(out),length(out),0), out];
    CDV2IDVSAV{n} = out;
end
return;
