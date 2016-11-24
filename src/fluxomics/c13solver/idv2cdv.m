function [out] = idv2cdv(n)
% returns transformation to go from idv to cumomers.
% cdv = idv2cdv(log2(length(idv)))*idv;

if n <= 0
    out = [1];
    return;
end

T = idv2cdv(n-1);
out = [T,T;zeros(size(T)),T];
