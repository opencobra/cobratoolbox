function current_py_path = get_py_path()
%Function to return the current python search path as a cell array of strings
    current_py_path = cellfun(@char, cell(py.sys.path), 'UniformOutput', 0)';
end