%From the MATLAB command prompt, add the current folder to the Python search path.
if count(py.sys.path,'') == 0
    insert(py.sys.path,int32(0),'');
end

%Create an input argument, a list of names, in MATLAB.
N = py.list({'Jones','Johnson','James'});

names = py.mymod.search(N)