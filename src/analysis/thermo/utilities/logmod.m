function y = logmod(x,base,signed)
% log modulus function, signed by default
%
% INPUT
% x     n x 1 real vector
%
% OPTIONAL INPUT
% logarithm base  exp(1),2,10
% signed = 1 returns a signed y (the default)

if ~exist('base','var')
    base=exp(1);
end
if ~exist('signed','var')
    signed=1;
end

if signed
    switch base
        case exp(1)
            y = sign(x).*log(1+abs(x));
        case 2
            y = sign(x).*log2(1+abs(x));
        case 10
            y = sign(x).*log10(1+abs(x));
        otherwise
            error('base not recognised')
    end

else

    switch base
        case exp(1)
            y = log(1+abs(x));
        case 2
            y = log2(1+abs(x));
        case 10
            y = log10(1+abs(x));
        otherwise
            error('base not recognised')
    end
end

end

