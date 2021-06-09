function y = logmod(x,base)
% log modulus function
%
% INPUT
% x     n x 1 real vector
%
% OPTIONAL INPUT
% base  exp(1),2,10
if ~exist('base','var')
    y = sign(x).*log1p(abs(x));
else
    switch base
        case exp(1)
            y = sign(x).*log1p(abs(x));
        case 2
            y = sign(x).*log2(1+abs(x));
        case 10
            y = sign(x).*log10(1+abs(x));
        otherwise
            error('base not recognised')
    end
end

end

