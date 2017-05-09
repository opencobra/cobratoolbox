function out=mtimes(x,y)

precisionx=0;   precisiony=0;
xmp=isa(x,'mp');
if xmp
 precisionx=x(1).precision;
 ymp=isa(y,'mp');
else
 ymp=true;
end
if ymp
 precisiony=y(1).precision;
end
precision=max(precisionx,precisiony);
ex=numel(x);
ey=numel(y);

if ex==1 | ey==1
 if ~xmp,  x=mp(x);  end
 if ~ymp,  y=mp(y);  end
 if ex==1
  out_rval=cell(size(y));
  out_ival=out_rval;

  
  [xrval,xival]=getVals(x,1);
  %xrval=x(1).rval;  xival=x(1).ival;  if isempty(xival), xival='0'; end
  
  xReal=hasimag(xival);
  for ii=1:ey
   [yrval,yival]=getVals(y,ii);
   %yrval=y(ii).rval;  yival=y(ii).ival;  if isempty(yival), yival='0'; end
   if xReal | hasimag(yival)
    [out_rval{ii},out_ival{ii}]=mpfr_mulc(precision,xrval,xival,yrval,yival);
   else
    %if isempty(xrval),  'xxxxxxxxxxxx',kb, end
    out_rval{ii}=mpfr_mul(precision,xrval,yrval);
   end
  end
 else
  out_rval=cell(size(x));
  out_ival=out_rval;
  [yrval,yival]=getVals(y,1);
  yReal=hasimag(yival);
  for ii=1:ex
   [xrval,xival]=getVals(x,ii);
   if hasimag(xival) | yReal
    [out_rval{ii},out_ival{ii}]=mpfr_mulc(precision,xrval,xival,yrval,yival);
   else
    out_rval{ii}=mpfr_mul(precision,xrval,yrval);
   end
  end
 end
 out=class(struct('rval',out_rval,...
                  'ival',out_ival,...
                  'precision',precision),'mp');
else %%% out=x*y;
 sx=size(x);
 sy=size(y);
 if sx(2)~=sy(1)
  disp(['size of matrix 1 => ',num2str(sx(1)),'x',num2str(sx(2))]);
  disp(['size of matrix 2 => ',num2str(sy(1)),'x',num2str(sy(2))]);
  error('array size mismatch for mtimes')
 else
  out=mp(zeros(sx(1),sy(2)),precision);
  for ii=1:sx(1)
   for jj=1:sy(2)
    out(ii,jj)=sum(x(ii,1:end).*y(1:end,jj).');
   end
  end
 end
end