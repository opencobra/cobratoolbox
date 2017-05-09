function out=uminus(x)

if isempty(x), out=x; return; end
precision=x(1).precision;
out_rval=cell(size(x));
out_ival=cell(size(x));

for ii=1:numel(x)
 imag=false;
 [xrval,xival]=getVals(x,ii);
 if ~isreal(x(ii)), imag=true; end
 if strncmp(xrval,'-',1)
  out_rval{ii}=['+',xrval(2:end)];
 elseif strncmp(xrval,'+',1)
  out_rval{ii}=['-',xrval(2:end)];
 else
  out_rval{ii}=['-',xrval];
 end
 if imag
  if strncmp(xival,'-',1)
   out_ival{ii}=['+',xival(2:end)];
  elseif strncmp(xival,'+',1)
   out_ival{ii}=['-',xival(2:end)];
  else
   out_ival{ii}=['-',xival];
  end
 end
end % for ii=1:max(ex,
out=class(struct('rval',out_rval,...
                 'ival',out_ival,...
                 'precision',precision),'mp');
