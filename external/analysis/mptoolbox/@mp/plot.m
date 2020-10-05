function handles=plot(varargin)
%plot:  plots graphs and lines involving mp-type data

%this function, despite being a built-in, is not overloaded for non-double-type parameters...

%converts any numeric parameter to type double
V=varargin;
for i=1:length(varargin)
    if isa(varargin{i},'mp')
        V{i}=double(varargin{i});
    end
end
handles=plot(V{:});



