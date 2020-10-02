function out=eps(x)
%eps: Floating point relative accuracy (as defined in matlab R14).

one=mp(1);%automatically inherit default precision
two=one+one;
if isempty(x)
    out=one*power(two,-one.precision*one);%automatically inherit data type
else
    out=abs(x)*power(two,-x(1).precision*one);
end