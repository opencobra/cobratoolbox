function [out,outp]=max(x,y,dim)

if isa(x,'mp')
 precision=x(1).precision;
 if exist('y')==1
  if ~isa(y,'mp')
   y=mp(y,precision);
  end
 end
else
 precision=y(1).precision;
 if ~isa(x,'mp')
  x=mp(x,precision);
 end 
end

% can only handle up to 2 dimensions
sx=size(x);
if nargin==1
 % if ANY are complex, use abs on all (even real negativeones)
 xo=x;
 if ~isempty(find(isreal(x)==0)), x=abs(x); end
 if any(sx==1)
  [out,outp]=maxOfVector(x);
  out=xo(outp);
 else
  out=mp(zeros(1,sx(2)),precision);
  outp=zeros(1,sx(2));
  for jj=1:sx(2)
   [out(jj),outp(jj)]=maxOfVector(x(:,jj));
   out(jj)=xo(outp(jj),jj);
  end
 end
elseif nargin==2
 precAndSize
 xo=x; yo=y;
 if ~isempty(find(isreal(x)==0)) | ~isempty(find(isreal(y)==0))
  x=abs(x);
  y=abs(y);
 end
 if ex==1
  xo=ones(size(y))*xo;
  x=ones(size(y))*x;
 elseif ey==1
  yo=ones(size(x))*yo;
  y=ones(size(x))*y;  
 end
 ex=numel(x); ey=numel(y);
 out=mp(zeros(size(x)),precision);
 for ii=1:ex
  if x(ii)>y(ii)
   out(ii)=xo(ii);
  else
   out(ii)=yo(ii);
  end
 end
elseif nargin==3
 if ~isempty(y)
  error('max must have an empty 2nd arg if there are 3 input args')
 else
  if dim==1
   [out,outp]=max(x);
  elseif dim==2
   [out,outp]=max(x.');
   out=out.';
   outp=outp.';
  end
 end
end




%find positions!

function [out,outp]=maxOfVector(in)

inLen=length(in);
if inLen==1
 out=in;
 outp=1;
 return
end
[out,outp]=maxOfTwo(in(1),1,in(2),2);
for ii=3:length(in)
 [out,outp]=maxOfTwo(out,outp,in(ii),ii);
end



function [out,outp]=maxOfTwo(in1,in1p,in2,in2p)

if in1>in2
 out=in1;
 outp=in1p;
else
 out=in2;
 outp=in2p;
end