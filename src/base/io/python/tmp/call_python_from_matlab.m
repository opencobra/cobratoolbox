

if 0
    %% Set RTLD_NOW and RTLD_DEEPBIND
    %https://nl.mathworks.com/matlabcentral/answers/327193-calling-python-module-from-matlab-causes-segmentation-fault-in-h5py
    py.sys.setdlopenflags(int32(10));
else
    %PythonEnvironment objects contain information about the settings and status of the Python® interpreter.
    %MATLAB® communicates with the interpreter when you call a py. command.
    %Python environment information is persistent across different MATLAB sessions.
    
    % Out-of-Process Execution of Python Functionality
    % MATLAB® can run Python scripts and functions in a separate process. Running Python in a separate process enables you to:
    % Use some third-party libraries in the Python code that are not compatible with MATLAB.
    % Isolate the MATLAB process from crashes in the Python code.
    PythonEnvironment = pyenv("ExecutionMode","OutOfProcess");
end

try
  py.list('x','y',1)
catch e
  e.message
  if(isa(e,'matlab.exception.PyException'))
    e.ExceptionObject
  end
end



try
  py.help('pandas.read_csv')
catch e
  e.message
  if(isa(e,'matlab.exception.PyException'))
    e.ExceptionObject
  end
end

%pandas.read_csv function signature
%pandas.read_csv = read_csv(filepath_or_buffer: Union[str, pathlib.Path, IO[~AnyStr]], sep=',', delimiter=None, header='infer', names=None, index_col=None, usecols=None, squeeze=False, prefix=None, mangle_dupe_cols=True, dtype=None, engine=None, converters=None, true_values=None, false_values=None, skipinitialspace=False, skiprows=None, skipfooter=0, nrows=None, na_values=None, keep_default_na=True, na_filter=True, verbose=False, skip_blank_lines=True, parse_dates=False, infer_datetime_format=False, keep_date_col=False, date_parser=None, dayfirst=False, cache_dates=True, iterator=False, chunksize=None, compression='infer', thousands=None, decimal: str = '.', lineterminator=None, quotechar='"', quoting=0, doublequote=True, escapechar=None, comment=None, encoding=None, dialect=None, error_bad_lines=True, warn_bad_lines=True, delim_whitespace=False, low_memory=True, memory_map=False, float_precision=None)

%pyargs https://nl.mathworks.com/help/matlab/ref/pyargs.html
% Python command:
% db = pd.read_csv('./data/cache_compounds_20160818.csv',index_col='compound_id')
% MATLAB command using pyargs
db = py.pandas.read_csv(pyargs('filepath_or_buffer',[pyLibraryFolder filesep 'data' filesep 'test_compounds.csv'],'index_col','compound_id'));


order = py.dict(pyargs('soup',3.57,'bread',2.29,'bacon',3.91,'salad',5.00))
% A dictionary has pairs of keys and values. Display the menu items in the variable order using the Python keys function.
keys(order)
values(order)

if count(py.sys.path,'') == 0
    insert(py.sys.path,int32(0),'');
end

mymod = py.importlib.import_module('mymod')

N = py.list({'Jones','Johnson','James'})

names = py.mymod.search(N)


