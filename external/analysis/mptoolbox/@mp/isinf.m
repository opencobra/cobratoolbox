function out=isinf(x)

%%%precision=x(1).precision;
%%%out=zeros(size(x));
%%%
%%%for ii=1:numel(x)
%%% imag=false;
%%% [xrval,xival]=getVals(x,ii);
%%% if hasimag(xival), imag=true; end
%%% if imag
%%%  temp=mpfr_isinf(precision,xrval);
%%%  if temp~=0, out(ii)=1; end
%%%  temp=mpfr_isinf(precision,xival);
%%%  if temp~=0, out(ii)=1; end 
%%% else
%%%  out(ii)=mpfr_isinf(precision,xrval);
%%%  if out(ii)~=0, out(ii)=1; end
%%% end
%%%end % for ii=1:max(ex,

out=x==inf;

