function out=rand(x,varargin)

precision=x(1).precision;
if nargin==1
 ss=double(round(abs(x)));
 if numel(x)==1
  out_rval=cell(ss,ss);
  out_ival=cell(ss,ss);
 else
  out_rval=cell(ss);
  out_ival=cell(ss);
 end
else
 ss=[x(1)];
 for ii=2:nargin
  ss=[double(ss),varargin{ii-1}]
 end
 out_rval=cell(ss);
 out_ival=cell(ss);
end
for ii=1:numel(out_rval)
 out_rval{ii}=mpfr_rand(precision,round(rand(1)*1000000));
end
out=class(struct('rval',out_rval,...
                 'ival',out_ival,...
                 'precision',precision),'mp');
