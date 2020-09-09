function varargout=find(x,varargin);

varargout{:}=find(x~=0,varargin{:});