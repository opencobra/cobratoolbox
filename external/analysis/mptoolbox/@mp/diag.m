function out=diag(in,K)
if isempty(in),out=in;return;end
precision=in(1).precision;
zero=mp(0,precision);
if nargin==1,K=0;end
s=size(in);
switch min(s)
 case 1 %a vector, either row or column
  N=length(in);
  out=zeros(mp(N),mp(N));
  SS.type='()';SS.subs={1:(N+1):(N*N)};
  out=subsasgn(out,SS,in);
 otherwise %a matrix
  out=zero*[];
  for ii=1:size(in,1)
   if (ii+K)<=size(in,2)
    %Force column vector
    out(ii,1)=in(ii,(ii+K));
   end
  end
end
