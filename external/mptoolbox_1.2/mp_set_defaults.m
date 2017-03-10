function default_precision=mp_set_defaults(x)
%Sets default precision to round(x) for use within the mp_toolbox
%If unset, the default is 250 binary digits
%If invoked with no arguments, it returns the current value

default_precision=250;
defaults=getappdata(0,'defaults');
%Trap early errors
if isempty(defaults) 
 defaults.default_data_type='mp';
 defaults.precision=default_precision;
end
if ~isfield(defaults,'default_data_type')
 defaults.default_data_type='mp';
end
if ~isfield(defaults,'precision')
 defaults.precision=default_precision;
end
%Do the real processing
if nargin>0
 x=real(x(1));%to deal with matrix, etc.
 if (x<0) | isinf(x) | isnan(x) | (round(x)==0)
  %Non valid arguments!
  %return already available defaults
  default_precision=defaults.precision;
 else
  default_precision=round(x);
 end
 defaults.precision=default_precision;
else
 %No arguments; the user just wants to know the current precision
 default_precision=defaults.precision;
end
%In any case...
setappdata(0,'defaults',defaults)    
