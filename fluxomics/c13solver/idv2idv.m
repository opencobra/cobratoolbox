function [out] = idv2idv(n)
% input n = size of matrix (2^n x 2^n)
% outputs a transformation matrix for changing from forward to reverse
% order.
% order 1 (Jennie's)
% 000, 001, 010, 011, 100, 101, 110, 111
% order 2 (mine)
% 000, 100, 010, 110, 001, 101, 011, 111
% 
warning('are you sure you want to call this function?');

if n <= 0
    out = 1;
    return;
end

out = sparse(2^n,2^n);
for i = 0:(2^n-1)
    t = dec2bin(i,n);
    t2 = t(end:-1:1);
    i2 = bin2dec(t2);
    out(i+1,i2+1) = 1;
end
