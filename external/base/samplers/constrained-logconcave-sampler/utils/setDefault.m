function obj = setDefault(obj, defaults, source)
    if nargin == 2
        key = fieldnames(defaults);
        for i = 1:length(key)
            if ~isfield(obj, key{i})
                obj.(key{i}) = defaults.(key{i});
            end
        end
    else
        key = fieldnames(defaults);
        for i = 1:length(key)
            if ~isfield(source, key{i})
                obj.(key{i}) = defaults.(key{i});
            else
                obj.(key{i}) = source.(key{i});
            end
        end
    end
end