function out=zeros(in,varargin)

if nargin==1
 out=mp(zeros(double(in)));
else
 out=mp(zeros([double(in),double([varargin{:}])]));
end