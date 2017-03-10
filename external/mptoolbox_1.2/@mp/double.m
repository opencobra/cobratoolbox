function out=double(x)

ex=numel(x);
precision=x(1).precision;

out=zeros(size(x));
for ii=1:ex
 [xrval,xival]=getVals(x,ii);
 outr=mpfr_get_d(precision,xrval);
 if isempty(xival),xival='0'; end
 outi=mpfr_get_d(precision,xival);
 out(ii)=outr+outi*i;
end % for ii=1:ex
