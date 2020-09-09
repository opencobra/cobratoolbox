function out=sprintf(varargin)

for ii=1:length(varargin)
 if isa(varargin{ii},'mp')
  varargin{ii}=double(varargin{ii});
 end
end

out=builtin('sprintf',varargin{:});
