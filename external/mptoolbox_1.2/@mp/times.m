function out=times(x,y)


precAndSize

if ex==1, [xrval,xival]=getVals(x,1); end
if ey==1, [yrval,yival]=getVals(y,1); end

for ii=1:max(ex,ey)
 if ex==1
  [yrval,yival]=getVals(y,ii);
 elseif ey==1
  [xrval,xival]=getVals(x,ii);
 else
  [xrval,xival]=getVals(x,ii);
  [yrval,yival]=getVals(y,ii);
 end 
 if hasimag(xival) | hasimag(yival)
  [out_rval{ii},out_ival{ii}]=mpfr_mulc(precision,xrval,xival,yrval,yival);
 else
  out_rval{ii}=mpfr_mul(precision,xrval,yrval);
 end
end % for ii=1:max(ex,
out=class(struct('rval',out_rval,...
                  'ival',out_ival,...
                  'precision',precision),'mp');


%%%if isa(y,'mp')
%%% ymp=true; 
%%% precision=y(1).precision;
%%% if isa(x,'mp')
%%%  xmp=true;
%%% else
%%%  xmp=false;
%%% end
%%%else
%%% xmp=true;
%%% ymp=false;
%%% precision=x(1).precision;
%%%end
%%%sx=size(x);sy=size(y);ex=numel(x);ey=numel(y);elem=max(ex,ey);
%%%
%%%%%%if isreal(x) & isreal(y)
%%%%%% bothReal=true;
%%%%%%else
%%%%%% bothReal=false;
%%%%%%end
%%%
%%%if ex==1
%%% if xmp
%%%  [xrval,xival]=getVals(x,1);
%%% else
%%%  xrval=real(x);
%%%  xival=imag(x);
%%% end
%%%end
%%%if ey==1
%%% if ymp
%%%  [yrval,yival]=getVals(y,1);
%%% else
%%%  yrval=real(y);
%%%  yival=imag(y);
%%% end
%%%end
%%%
%%%if ex>=ey
%%% out_rval=cell(sx);
%%% out_ival=out_rval;
%%%else
%%% out_rval=cell(sy);
%%% out_ival=out_rval;
%%%end
%%%
%%%for ii=1:elem
%%% if ex==1
%%%  if ymp
%%%   [yrval,yival]=getVals(y,ii);
%%%  else
%%%   yrval=real(y(ii));
%%%   yival=imag(y(ii));
%%%  end
%%% elseif ey==1
%%%  if xmp
%%%   [xrval,xival]=getVals(x,ii);
%%%  else
%%%   xrval=real(x(ii));
%%%   xival=imag(x(ii));
%%%  end
%%% else
%%%  if ymp
%%%   [yrval,yival]=getVals(y,ii);
%%%  else
%%%   yrval=real(y(ii));
%%%   yival=imag(y(ii));
%%%  end
%%%  if xmp
%%%   [xrval,xival]=getVals(x,ii);
%%%  else
%%%   xrval=real(x(ii));
%%%   xival=imag(x(ii));
%%%  end
%%% end 
%%% if hasimag(xival) | hasimag(yival)
%%%  %if ~bothReal
%%%  if xmp & ymp
%%%   [out_rval{ii},out_ival{ii}]=mpfr_mulc(precision,xrval,xival,yrval,yival);
%%%  else
%%%   if xmp
%%%    [out_rval{ii},out_ival{ii}]=mpfr_mulc_d(precision,xrval,xival,yrval,yival)
%%%   else
%%%    [out_rval{ii},out_ival{ii}]=mpfr_mulc_d(precision,yrval,yival,xrval,xival);
%%%   end
%%%  end
%%% else
%%%  if xmp & ymp
%%%   out_rval{ii}=mpfr_mul(precision,xrval,yrval);
%%%  else
%%%   if xmp
%%%    out_rval{ii}=mpfr_mul_d(precision,xrval,yrval);
%%%   else
%%%    out_rval{ii}=mpfr_mul_d(precision,yrval,xrval);
%%%   end
%%%  end
%%% end
%%%end % for ii=1:max(ex,
%%%
%%%
%%%
%%%out=class(struct('rval',out_rval,...
%%%                  'ival',out_ival,...
%%%                  'precision',precision),'mp');


%%%if isreal(x)
%%% xReal=true;
%%%else
%%% xReal=false;
%%%end
%%%if isreal(y)
%%% yReal=true;
%%%else
%%% yReal=false;
%%%end
%%%if xReal & yReal
%%% bothReal=true;
%%%else
%%% bothReal=false;
%%%end





