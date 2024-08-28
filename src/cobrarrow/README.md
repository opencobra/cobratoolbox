# Instructions for Using MATLAB API

This guide will walk you through setting up and running the MATLAB API.

## Step 1: Install Python and Create a Virtual Environment

If Python is not installed on your system, download and install a compatible version as specified by [MathWorks](https://www.mathworks.com/content/dam/mathworks/mathworks-dot-com/support/sysreq/files/python-support.pdf).

### 1.1 Create a Virtual Environment

Ensure you use a Python version compatible with your MATLAB installation. For this example, we'll use Python 3.9.

```sh
# Specify Python version when you create the virtual environment
python3.9 -m venv python_env
```

### 1.2 Activate the Virtual Environment

Activate the virtual environment you just created:

- **On Windows:**

  ```sh
  .\python_env\Scripts\activate
  ```

- **On macOS and Linux:**

  ```sh
  source python_env/bin/activate
  ```

## Step 2: Install Dependencies

Once the virtual environment is activated, install the required dependencies using the `requirements.txt` file provided with the MATLAB API:

```sh
pip install -r requirements.txt
```

## Step 3: Set MATLAB to Use the Python Environment

To ensure MATLAB uses this Python environment every time it starts:

1. **Locate or Create the MATLAB Startup File**:

   - On Windows: The `startup.m` file is usually located in the `Documents\MATLAB` folder.
   - On macOS or Linux: The file is also named `startup.m` and is located in the MATLAB user folder, typically `~/Documents/MATLAB`.

   If the file doesn't exist, create a new `startup.m` file in the appropriate directory.

2. **Edit the Startup File**:

   Add the following lines to the `startup.m` file, replacing the path with the full path to your virtual environment's Python executable:

   ```matlab
   % Set the Python environment for MATLAB
   pyenv('Version', fullfile('path_to_your_virtual_env', 'python'));
   ```

   For example:

   ```matlab
   pyenv('Version', fullfile('C:\COBRArrow\client\MATLAB_API\python_env\Scripts\python.exe'));
   ```

   Or on macOS/Linux:

   ```matlab
   pyenv('Version', fullfile('~/Document/COBRArrow/client/MATLAB_API/python_env/bin/python'));
   ```

3. **Save and Restart MATLAB**:

   Save the `startup.m` file. When you restart MATLAB, it will automatically use the specified Python environment.


## Step 4: MATLAB API is ready to use.

### Example Use of Calling MATLAB APIs

Refer to MATLAB script `testMatlab.m` that uses the MATLAB API to perform some operations.

```matlab
% Example MATLAB script to use the MATLAB API

% load the model
recon3D_model = load('../models/Recon3D_301.mat').Recon3D;
model = recon3D_model;
schemaName = 'Recon3D';

% Create an instance of the COBRArrow class
host = 'localhost';
port = 443;
client = COBRArrow(host, port);

% Login
client = client.login('johndoe', '123456');

% Send the model to the server
client.sendModel(model, schemaName);

% Read the model back for general purposes
fetchedModel = client.fetchModel(schemaName);
disp('Fetched Model:');
disp(fetchedModel);

% For example, fetchedModel can be used to do simulations using COBRA Toolbox
initCobraToolbox;
solution = optimizeCbModel(fetchedModel);
disp('solution:');
disp(solution);

% Read the model back for FBA analysis
FBAmodel = client.fetchModelForFBAAnalysis(schemaName);
disp('FBA Model:');
disp(FBAmodel);

% Set solver for using remote optimization service
arrowSolver = COBRArrowSolver('GLPK');
arrowSolver.setParameter('tol', 1e-9);
% Perform optimization
resultStruct = client.optimizeModel(schemaName,arrowSolver);

% Display results
disp('Optimization Results:');
disp(resultStruct);

% Example of sending an individual field
fieldName = 'rxns';
fieldData = model.rxns;
client.sendField(schemaName, fieldName, fieldData);

% Read the field back
readData = client.readField(schemaName, fieldName);
disp('Read Field Data:');
disp(readData);

% List all flight information in a schema on server
flightsList = client.listAllFlights(schemaName);
disp('Flights List in schema:');
disp(flightsList);

% List all flight information on server
flightsList = client.listAllFlights();
disp('All Flights List:');
disp(flightsList);

% Get all unique identifier of the flights in a schema
descriptors = client.getAllDescriptors(schemaName);
disp('Descriptors:');
disp(descriptors);
```
