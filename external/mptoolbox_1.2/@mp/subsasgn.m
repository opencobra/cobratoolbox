function out=subsasgn(x,varargin)

if isempty(x)
 x=mp(x);
end
out=builtin('subsasgn',x,varargin{:});

% This has to be fixed to allow the incoming doubles (or other mp's) 
% to be promoted to the right precision
%'ssssssss',kb