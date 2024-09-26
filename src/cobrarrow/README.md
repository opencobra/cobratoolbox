# Instructions for Using MATLAB API

## Step 1: Run `initCobrarrow`

1. In the MATLAB command window, run the following command:

    ```matlab
    initCobrarrow()
    ```
2. If you encounter an error while running `initCobrarrow`, it may be because Python is not installed on your system or the installed version is not compatible with MATLAB.

   - **Solution**: Download and install a compatible version of Python as specified by [MathWorks Python Compatibility](https://www.mathworks.com/content/dam/mathworks/mathworks-dot-com/support/sysreq/files/python-support.pdf).
   - For detailed instructions on installing and configuring Python, refer to the following MathWorks documentation:
     - [Configure Your System to Use Python](https://uk.mathworks.com/help/matlab/matlab_external/install-supported-python-implementation.html)



## Step 2: MATLAB API is ready to use.

### Example Use of Calling MATLAB APIs

```matlab
% Example MATLAB script to use the MATLAB API

% Load the model
file = load('path/to/your_model.mat');
model = file.yourModel;
schemaName = 'yourModelName';

% Create an instance of the COBRArrow class
host = 'cobrarrowServerHost';
port = cobrarrowServerPort; % port is optional if you use a domain name for host
client = COBRArrow(host, port);

% Login
client = client.login('username', 'password');

% Send the model to the server
client.sendModel(model, schemaName);

% Persist the model in DuckDB
client.persistModel(schemaName, true);

% Read the model back for general purposes
fetchedModel = client.fetchModel(schemaName);

% For example, fetchedModel can be used to do simulations using COBRA Toolbox
initCobraToolbox;
solution = optimizeCbModel(fetchedModel);

% Read the model back for FBA analysis
FBAmodel = client.fetchModelForFBAAnalysis(schemaName);

% Set solver for using remote optimization service
arrowSolver = COBRArrowSolver('GLPK');

% Perform optimization
resultStruct = client.optimizeModel(schemaName, arrowSolver);

% Example of sending flux value(an individual field) for animation
fieldName = 'flux';
fieldData = resultStruct.flux;
client.sendField(schemaName, fieldName, fieldData);

% Read the field back
readData = client.fetchField(schemaName, fieldName);

% List all flight information in a schema on the server
flightsList = client.listAllFlights(schemaName);

% List all flight information on the server
flightsList = client.listAllFlights();

% Get all unique identifiers of the flights in a schema
descriptors = client.getAllDescriptors(schemaName);

```
