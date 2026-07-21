function y = logmod(x, base, signed)
% Log modulus function, signed by default
%
% Returns a smooth, sign-preserving logarithm `sign(x) .* log(1 + abs(x))`,
% which behaves like a logarithm for large magnitudes but is defined at zero.
%
% USAGE:
%
%    y = logmod(x, base, signed)
%
% INPUTS:
%    x:         `n x 1` real vector
%
% OPTIONAL INPUTS:
%    base:      logarithm base, one of exp(1), 2 or 10 (default: exp(1))
%    signed:    when 1 (default) return a signed `y`; when 0 return the
%               unsigned log modulus
%
% OUTPUTS:
%    y:         `n x 1` log modulus of `x`

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

