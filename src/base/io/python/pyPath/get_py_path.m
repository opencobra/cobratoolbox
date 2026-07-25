function current_py_path = get_py_path()
% Return the current python search path as a cell array of strings
%
% USAGE:
%
%    current_py_path = get_py_path()
%
% OUTPUT:
%    current_py_path:    Cell array of strings, the current Python search path

    current_py_path = cellfun(@char, cell(py.sys.path), 'UniformOutput', 0)';
end