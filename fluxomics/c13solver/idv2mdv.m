function [out] = idv2mdv(n, fragment)
% returns transofmation matrix from idv's (either Jennie's or Jan's order).
% MDV = idv2mdv(log2(length(idv)))*idv;
% 
% fragment (optional):  a vector of carbons to be included.  [ 0, 0, 1,1,1]' = last 3 carbons.
global pseudohash1 pseudohash2

if isempty(pseudohash1)
    pseudohash1 = sparse(15, 2048);
    pseudohash2 = {};
end

if nargin == 1
    out = sparse(1);
    for i = 1:n
        out = [[out;sparse(1, size(out,2))] [sparse(1, size(out,2));out]];
    end
    return;
end

if length(fragment) ~= n
    display('error in fragment length');
    return;
end

ncarbons = sum(fragment)+1;
out = sparse(ncarbons, 2^n);
fragment = fragment(n:-1:1); % reverse order fragment... faster than reversing order of idv's.

m = memoize(n, fragment);
if ~isempty(m)
    out = m;
    return;
end
for i = 0:(2^n-1)
    t = dec2bin(i,n);
    t(logical(fragment));
    i2 = sum(t(logical(fragment)) == '1');
    out(i2+1,i+1) = 1;
end
memoize(n, fragment, out);
return

function [matrix] = memoize(n, fragment, matrix)
    global pseudohash1 pseudohash2
    fragmentindex = 0;
    for i = 1:length(fragment)
        fragmentindex = fragmentindex*2;
        fragmentindex = fragment(i) + fragmentindex;
    end
    
    tindex = pseudohash1(n, fragmentindex);
    if tindex == 0
        if nargin < 3
            matrix = [];
            return;
        else % assign
            tindex = length(pseudohash2)+1;
            pseudohash1(n, fragmentindex) = tindex;
            pseudohash2{tindex} = matrix;
        end
    else
        matrix = pseudohash2{tindex};
        return;
    end
return
    