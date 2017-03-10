function out=ones(in,varargin)

if nargin==1
 out=mp(ones(double(in)));
else
 out=mp(ones([double(in),double([varargin{:}])]));
end