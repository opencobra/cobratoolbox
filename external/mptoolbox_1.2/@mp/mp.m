function out=mp(x,y)
%MP multiple precision class constructor.
%   p = mp(x,y) creates a mp object from the matrices x and y,
%   where x contains the double to be converted into an mp object
%         y contains the precision
% Special calls to mp include:
%   mp('pi',precision) => returns pi to precision (precision is optional)

maxDoublePrec=16; %digits
if nargin == 0
 out.rval=[];
 out.ival=[];
 out.precision=[];
 out=class(out,'mp');
elseif isa(x,'mp')
 %out=x;
 if nargin==1
  out=x;
 else
  for ii=1:numel(x)
   out(ii)=mp(x(ii).rval,y(min(numel(y),ii)));
   if ~isreal(x(ii))
    out(ii)=out(ii)+mp(x(ii).ival,y(min(numel(y),ii)))*i;
   end
  end
 end % if nargin==2
else
 mp_defaults
 precision=default_precision;
 out_rval=cell(size(x));
 out_ival=cell(size(x));
 if nargin==2
  precision=double(y(1));
 end % if nargin==2
 if isa(x,'double')
  for ii=1:numel(x)
   [str,exponent]=mpfr_construct_dd(real(x(ii)),precision);
   % throw away anything past maxDoublePrec, set to 0's
   if length(str)>maxDoublePrec
    str(maxDoublePrec+1:end)='0';
   end
   out_rval{ii}=mpExpForm(mpAddDecimal(str),exponent);
   if ~isreal(x(ii))
    [str,exponent]=mpfr_construct_dd(imag(x(ii)),precision);
    % throw away anything past maxDoublePrec, set to 0's
    if length(str)>maxDoublePrec
     str(maxDoublePrec+1:end)='0';
    end
    out_ival{ii}=mpExpForm(mpAddDecimal(str),exponent);
   end
  end % for ii=1:size(x,
 elseif isa(x,'cell')
  for ii=1:numel(x)
   [str,exponent]=mpfr_construct_cd(x{ii},precision);
   out_rval{ii}=mpExpForm(mpAddDecimal(str),exponent);
  end % for ii=1:size(x,
 elseif isa(x,'char')
  out_rval=cell(1);
  out_ival=cell(1);
  if any(strfind(lower(x),'pi'))
   out_rval=mpfr_pi(precision);
%%%   [str,exponent]=mpfr_pi(precision);
%%%   out_rval=mpExpForm(mpAddDecimal(str),exponent);
  else
   [str,exponent]=mpfr_construct_cd(x,precision);
   out_rval{1,1}=mpExpForm(mpAddDecimal(str),exponent);
  end
 end
 out=class(struct('rval',out_rval,...
                  'ival',out_ival,...
                  'precision',precision),'mp');
end


%%%out_rval
%%%out_rexp
%%%out_ival
%%%out_iexp

%'rrrrrrr',kb
% x=magic(3),s1='023e1',s2='-.002e-1'
% mp(x)


