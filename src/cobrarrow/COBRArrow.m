classdef COBRArrow
    % COBRArrow is a class that establishes a connection to a gRPC service
    % using Apache Arrow Flight in a Python environment. It provides methods
    % to send and receive data between MATLAB and the Flight server.
    %
    % .. Author: - Yixing Lei
    
    properties
        client  % The FlightClient object for communication with the server
        options % FlightCallOptions for the FlightClient object, it may include parameters like timeout, write_options, headers, and read_options
    end
    
    properties (Constant)
        pyarrowLib = py.importlib.import_module('pyarrow'); % PyArrow library
        pyarrowFlight = py.importlib.import_module('pyarrow.flight'); % PyArrow Flight library
    end
    
    methods
        function obj = COBRArrow(host, port)
            % Initializes the Python environment and establishes a client connection.
            %
            % USAGE:
            %
            %    obj = COBRArrow(host, port)
            %
            % INPUTS:
            %    host:  The hostname or IP address of the gRPC server.
            %    port:  (Optional) The port number on which the gRPC server is running. Default is 50051.
            %
            % OUTPUT:
            %    obj:   Instance of the COBRArrow class with an initialized Python environment
            %           and established FlightClient connection.
            %
            % EXAMPLE:
            %
            %    arrowClient = COBRArrow('cobrarrow.chatimd.org');
            %    arrowClient = COBRArrow('localhost', 50051);
            %
            
            % Check if the Python environment is already initialized
            currentEnv = pyenv;
            fprintf('Current Python path is: %s\n', currentEnv.Executable);
            
            % Determine the client URL based on whether the port is provided
            if nargin < 2
                clientUrl = sprintf('grpc+tcp://%s', host);
            else
                clientUrl = sprintf('grpc+tcp://%s:%d', host, port);
            end
            
            % Create the FlightClient object
            obj.client = COBRArrow.pyarrowFlight.FlightClient(clientUrl);
        end
        
        function obj = login(obj, username, password)
            % Use username and password to authenticate the user, since the server requires authentication
            % to use some of the services. The server requires authentication to send data, persist data,
            % and to use optimization service.
            %
            % USAGE:
            %
            %    obj = obj.login(username, password)
            %
            % INPUTS:
            %    obj: Instance of the COBRArrow class.
            %    username: String representing the username for authentication
            %    password: String representing the password for authentication
            %
            % OUTPUT:
            %    None
            %
            % DESCRIPTION:
            %    This function attempts to authenticate the user using the provided
            %    username and password. If the authentication is successful, it creates
            %    a token for the user and sets the options for the FlightClient object. The
            %    options include the token as part of the headers for the Flight RPC calls.
            %    If the authentication fails, an error is raised.
            %
            % EXAMPLE:
            %
            %    arrowClient = arrowClient.login('username', 'password');
            %
            
            try
                % Authenticate the user and get the token
                token = obj.client.authenticate_basic_token(username, password);
                % disp(token);
                % Set the token as part of the options for the FlightClient object
                obj.options = COBRArrow.pyarrowFlight.FlightCallOptions(pyargs('headers', {token}));
            catch ME
                if contains(ME.message, 'Could not finish writing before closing')
                    error('Connection Error: Please check the server connection and try again.');
                else
                    error('Failed to log in: %s', ME.message);
                end
            end
        end
        
        function isAuthenticated = requireAuthentication(obj)
            % checkLoginStatus checks if the user is authenticated by verifying the options.
            %
            % USAGE:
            %
            %    isAuthenticated = obj.checkLoginStatus()
            %
            % INPUTS:
            %    obj: Instance of the COBRArrow class.
            %
            % OUTPUT:
            %    isAuthenticated: Boolean indicating whether the user is authenticated.
            %
            % DESCRIPTION:
            %    This function checks if the user is authenticated by verifying the options
            %    for the FlightClient object. If the options include a token, the user is
            %    considered authenticated. If the options do not include a token, the user
            %    is considered unauthenticated.
            %
            % EXAMPLE:
            %
            %    isAuthenticated = arrowClient.checkLoginStatus();
            %
            
            if isa(obj.options, 'py.pyarrow._flight.FlightCallOptions')
                isAuthenticated = true;
            else
                error('Authentication Error: Please log in first to use this service.');
            end
        end
        
        function sendModel(obj, model, schemaName, toPersist, toOverwrite)
            % sendModel Transmits model data to the server using Apache Arrow Flight.
            % Note :
            % 1. Field `subSystems` are not sent.
            % 2. Field that has unsupported data type will be sent as an empty field, including struct type. It
            %    will raise a warning.
            %
            % USAGE:
            %    obj.sendModel(model, schemaName, toPersist, toOverwrite)
            %
            % INPUTS:
            %    obj:         Instance of the COBRArrow class.
            %    model:       MATLAB structure containing the model data to be sent.
            %    schemaName:  String specifying the schema name used as a prefix for keys in the data.
            %    toPersist:   (Optional) Boolean indicating whether to persist the model on the server. Defaults to false.
            %    toOverwrite: (Optional) Boolean indicating whether to overwrite an existing model on the server. Defaults to false.
            %
            % OUTPUT:
            %    None
            %
            % DESCRIPTION:
            %    This function processes each field of the input model structure to:
            %    1. Create a FlightDescriptor for each field (excluding fields named 'subSystems' and 'SetupInfo').
            %    2. Convert the field data to Apache Arrow format using PyArrow.
            %    3. Send the formatted data to the server via Flight RPC.
            %    4. Optionally, persist the model on the server if `toPersist` is true.
            %    5. Ensure that the model is not overwritten unless explicitly allowed by `toOverwrite`.
            %
            %    The function performs the following checks:
            %    - If `toOverwrite` is false and the schema already exists on the server, an error is raised.
            %    - If `toPersist` is true, it attempts to persist the model and handles any potential errors.
            %
            % EXAMPLES:
            %    % Send a model with the option to overwrite if it exists
            %    arrowClient.sendModel(myModel, 'mySchema', true, true);
            %
            
            % Ensure the user is authenticated
            obj.requireAuthentication();
            
            % Set default values for optional arguments if not provided
            if nargin < 4
                toPersist = false;
            end
            if nargin < 5
                toOverwrite = false;
            end
            
            % Check if the schema already exists and handle based on `toOverwrite`
            flightsList = obj.listAllFlights(schemaName);
            if ~isempty(flightsList) && ~toOverwrite
                % the schema has already existed and toOverwrite is false
                error('The model "%s" already exists in memory. Set toOverwrite=true to overwrite the existing model.', schemaName);
            end
            
            % Process each field in the model structure
            fieldNames = fieldnames(model);
            for i = 1:numel(fieldNames)
                fieldName = fieldNames{i};
                
                % Skip 'subSystems' for now
                if strcmp(fieldName, 'subSystems')
                    continue;
                end
                
                % Retrieve data for the current field
                fieldData = model.(fieldName);
                
                % Generate a unique key for the field using the schema name
                key = strcat(schemaName, ':', fieldName);
                descriptor = COBRArrow.pyarrowFlight.FlightDescriptor.for_command(py.str(key));
                pyArrowRecordBatch = obj.MatFieldToPyArrow(fieldData, fieldName);
                
                % Send the field data to the Flight server
                obj.writeToFlightRpc(descriptor, pyArrowRecordBatch);
            end
            
            fprintf('Model "%s" sent successfully to the server.\n', schemaName);
            
            % Optionally, persist the model on the server
            if toPersist
                try
                    % Persist the model on the server
                    obj.persistModel(schemaName);
                catch ME
                    error(['Failed to persist the model on the server. Error: %s. ' ...
                        'Try using persistModel(%s, true) to overwrite the existing data ' ...
                        'if necessary.'], ME.message, schemaName);
                end
            end
        end
        
        function sendField(obj, schemaName, fieldName, fieldData, toOverwrite)
            % sendField Sends individual field data to the server using Apache Arrow Flight.
            %
            % USAGE:
            %    obj.sendField(schemaName, fieldName, fieldData, toOverwrite)
            %
            % INPUTS:
            %    obj:         Instance of the COBRArrow class.
            %    schemaName:  String specifying the schema name used as a prefix for the key.
            %    fieldName:   String representing the name of the field to be sent.
            %    fieldData:   Data for the field to be sent to the server.
            %    toOverwrite: (Optional) Boolean indicating whether to overwrite an existing field on the server. Defaults to false.
            %
            % OUTPUT:
            %    None
            %
            % DESCRIPTION:
            %    This function performs the following steps:
            %    1. Concatenates the schema name and field name to form a unique key.
            %    2. Creates a FlightDescriptor using the key.
            %    3. Checks if a field with the same key already exists on the server.
            %    4. If the field exists and `toOverwrite` is false, it raises an error.
            %    5. Converts the field data to Apache Arrow format using the `MatFieldToPyArrow` method.
            %    6. Sends the field data to the server using Flight RPC via the `writeToFlightRpc` method.
            %
            % EXAMPLES:
            %    % Send a new field with the option to overwrite if it exists
            %    arrowClient.sendField('mySchema', 'myField', myData, true);
            %
            %    % Send a field without overwriting existing fields
            %    arrowClient.sendField('mySchema', 'myField', myData);
            %
            
            % Ensure the user is authenticated
            obj.requireAuthentication();
            
            % Set default value for toOverwrite if not provided
            if nargin < 5
                toOverwrite = false;
            end
            
            % Create a unique key by concatenating schema name and field name
            key = strcat(schemaName, ':', fieldName);
            
            % Create a FlightDescriptor for the key
            descriptor = COBRArrow.pyarrowFlight.FlightDescriptor.for_command(py.str(key));
            fieldExists = false;
            
            % Check if the field already exists on the server
            try
                endpoints = obj.client.get_flight_info(descriptor).endpoints;
                if ~isempty(endpoints)
                    fieldExists = true;
                end
            catch ME
                % If an exception is thrown, it means the field does not exist
                fieldExists = false;
            end
            
            % Handle case where the field exists and overwriting is not allowed
            if fieldExists && ~toOverwrite
                error('Field "%s" already exists in schema "%s". Use toOverwrite=true to overwrite the field.', fieldName, schemaName);
            end
            
            % Convert the field data to PyArrow format
            pyArrowRecordBatch = obj.MatFieldToPyArrow(fieldData, fieldName);
            
            % Send the field data to the Flight server
            obj.writeToFlightRpc(descriptor, pyArrowRecordBatch);
            fprintf('Field "%s" sent successfully to schema "%s".\n', fieldName, schemaName);
        end
        
        function model = fetchModel(obj, schemaName)
            % Fetches the model data from the server using Apache Arrow Flight.
            %
            % USAGE:
            %
            %    model = obj.fetchModel(schemaName)
            %
            % INPUTS:
            %    obj:         Instance of the COBRArrow class.
            %    schemaName:  String representing the schema name used as a prefix for keys.
            %
            % OUTPUT:
            %    model:       MATLAB structure containing the fetched model data.
            %
            % DESCRIPTION:
            %    This function creates an empty MATLAB structure `model` and retrieves descriptors
            %    associated with the given schema name from the server. If no descriptors are found,
            %    it attempts to load the data from DuckDB. The function iterates through each descriptor,
            %    fetches the corresponding field data, and assigns it to the relevant field in the `model`
            %    structure.
            %
            %    If no data is found in the server or DuckDB, an error is raised.
            %
            % EXAMPLE:
            %
            %    model = arrowClient.fetchModel('mySchema');
            %
            
            model = struct();
            descriptors = obj.getAllDescriptors(schemaName);
            
            if isempty(descriptors)
                fprintf('No data found on server. Attempting to load data from DuckDB...\n');
                % if the model is empty, try to load the data from DuckDB to the server
                % try
                obj.loadFromDuckDB(schemaName);
                descriptors = obj.getAllDescriptors(schemaName);
                
                if isempty(descriptors)
                    error('Failed to retrieve model "%s" from both the server and DuckDB.\n', schemaName);
                end
                % catch ME
                %     rethrow(ME);
                % end
            end
            % Iterate through the descriptors and fetch the field data
            for i = 1:numel(descriptors)
                descriptorStr = descriptors{i};
                descriptor = COBRArrow.pyarrowFlight.FlightDescriptor.for_command(py.str(descriptorStr));
                descriptorParts = split(descriptorStr, ':');
                fieldName = descriptorParts{2};
                pyArrowTable= obj.readFromFlightRpc(descriptor);
                model.(fieldName) = COBRArrow.pyArrowTableToMatField(pyArrowTable);
            end
        end
        
        function fieldData = fetchField(obj, schemaName, fieldName)
            % Retrieves individual field data from the server using Apache Arrow Flight.
            %
            % USAGE:
            %    fieldData = obj.fetchField(schemaName, fieldName)
            %
            % INPUTS:
            %    obj:         Instance of the COBRArrow class.
            %    schemaName:  String representing the schema name used as a prefix for keys.
            %    fieldName:   String representing the name of the field to be fetched.
            %
            % OUTPUT:
            %    fieldData:   Data of the fetched field in MATLAB format.
            %
            % DESCRIPTION:
            %    This function concatenates the schema name and field name to form a key,
            %    creates a FlightDescriptor for the key, and attempts to read the field data
            %    from the Flight server. If the data is not found on the server, it tries to
            %    load the data from DuckDB. The Arrow table data is then converted to MATLAB
            %    format and returned.
            %
            %    If the field does not exist in either the server or DuckDB, an error is raised.
            %
            % EXAMPLE:
            %
            %    fieldData = arrowClient.fetchField('mySchema', 'myField');
            %
            
            try
                % Concatenate schema name and field name for the key
                key = strcat(schemaName, ':', fieldName);
                
                % Create a FlightDescriptor
                descriptor = COBRArrow.pyarrowFlight.FlightDescriptor.for_command(py.str(key));
                % Read the field data from the Flight server
                pyArrowTable = obj.readFromFlightRpc(descriptor);
                % disp(pyArrowTable.schema.metadata);
                fieldData = COBRArrow.pyArrowTableToMatField(pyArrowTable);
            catch ME
                if contains(ME.message, 'KeyError')
                    % If the field does not exist on the server, try to load it from DuckDB
                    fprintf('Field "%s" not found on server. Attempting to load from DuckDB...\n', fieldName);
                    try
                        obj.loadFromDuckDB(schemaName);
                        pyArrowTable = obj.readFromFlightRpc(descriptor);
                        fieldData = COBRArrow.pyArrowTableToMatField(pyArrowTable);
                    catch innerME
                        % If the field does not exist in DuckDB, raise an error
                        error('Failed to retrieve field "%s" in model "%s" from both the server and DuckDB.\n', fieldName, schemaName);
                    end
                else
                    % Re-throw unknown errors
                    rethrow(ME);
                end
            end
        end
        
        function resultStruct = optimizeModel(obj, schemaName, solver)
            % optimizeModel sends an optimization action to the server and retrieves the result.
            %
            % USAGE:
            %
            %    resultStruct = obj.optimizeModel(schemaName, solver)
            %
            % INPUTS:
            %    obj:         Instance of the COBRArrow class.
            %    schemaName:  String representing the schema name to be optimized.
            %    solver:      Instance of the COBRArrowSolver class.
            %
            % OUTPUT:
            %    resultStruct: Structure containing the optimization results.
            %
            % DESCRIPTION:
            %    This function performs the following steps:
            %    1. Checks and sets the solver instance, defaulting to 'GLPK' if none is provided.
            %    2. Constructs an action body string with schema and solver details.
            %    3. Encodes the action body to bytes and creates a Flight Action.
            %    4. Sends the action to the server and retrieves the result stream.
            %    5. Converts the result stream into a PyArrow Table and then to a MATLAB struct.
            %    6. Handles and converts various data types as necessary.
            %
            % EXAMPLE:
            %
            %    result = arrowClient.optimizeModel('mySchema', arrowSolver);
            %
            
            obj.requireAuthentication();
            
            % Check and set the solver
            if nargin < 3
                % If no solver is provided, use a default solver
                solver = COBRArrowSolver('GLPK');
            elseif ~isa(solver, 'COBRArrowSolver')
                error('The solver must be an instance of the COBRArrowSolver class.');
            end
            
            % Construct action body string including solver parameters
            solverParamsStr = jsonencode(solver.parameters);
            actionBodyStr = sprintf("{'schema_name': '%s', 'solver_name': '%s', 'solver_params': %s}", ...
                schemaName, solver.name, solverParamsStr);
            
            % Convert action body string to bytes using Python encoding
            pyStr = py.str(actionBodyStr);
            actionBodyBytes = py.bytes(pyStr.encode('utf-8'));
            
            % Create the action
            action = COBRArrow.pyarrowFlight.Action('optimize', actionBodyBytes);
            
            % Send the action and get the result stream
            % pass in the options for authentication purposes
            resultStream = obj.client.do_action(action, obj.options);
            
            % Convert result stream to MATLAB cell array
            pyList = py.list(resultStream);
            resultCell = cell(pyList);
            
            % Initialize a struct to hold the data for this table
            tempStruct = struct();
            resultStruct = struct();
            
            for i = 1:length(resultCell)
                % Access the result
                result = resultCell{i};
                try
                    % Access the body of the result
                    body = result.body;
                    
                    % Convert result body to PyArrow Table
                    buffer = COBRArrow.pyarrowLib.BufferReader(body);
                    reader = COBRArrow.pyarrowLib.ipc.RecordBatchStreamReader(buffer);
                    table = reader.read_all();
                    
                    % Convert the PyArrow Table to a MATLAB struct
                    numColumns = int64(table.num_columns);
                    % Iterate through the columns of the table
                    for columnIdx = 1:numColumns
                        % Get column name and data
                        columnName = char(table.schema.names{columnIdx});
                        columnData = table.column(columnIdx - 1).to_pylist();
                        
                        % Add the column data to the struct
                        tempStruct.(columnName) = columnData;
                    end
                catch ME
                    % Convert error body to string and throw an error
                    body = result.body.to_pybytes();
                    message = char(body);
                    error('An error occurred: %s', message);
                end
            end
            
            % Convert specific fields in the struct to appropriate MATLAB types
            resultStruct.rxns = cellfun(@char, cell(tempStruct.rxns), 'UniformOutput', false)';
            resultStruct.flux = cellfun(@double, cell(tempStruct.flux))';
            resultStruct.status = char(tempStruct.status);
            resultStruct.objective_value = cellfun(@double, cell(tempStruct.objective_value));
        end
        
        function persistModel(obj, schemaName, toOverwrite)
            % persistModel sends a persist action to the server to save the model.
            %
            % USAGE:
            %
            %    obj.persistModel(schemaName)
            %
            % INPUTS:
            %    obj:         Instance of the COBRArrow class.
            %    schemaName:  String representing the schema name to be persisted.
            %    toOverwrite: (Optional) Boolean indicating whether to overwrite the model on the server. Default is false.
            %
            % OUTPUT:
            %    None
            %
            % DESCRIPTION:
            %    This function sends a persist action to the server using Apache Arrow Flight
            %    to save the model data. It creates a string representation of the dictionary
            %    and converts it to bytes using Python's encode method. The action is then created
            %    and called on the server to save the model.
            %
            % EXAMPLE:
            %
            %    arrowClient.persistModel('mySchema');
            %
            
            obj.requireAuthentication();
            
            % Set default value for toOverwrite if not provided
            if nargin < 3
                toOverwrite = false;
            end
            
            % Create a string representation of the dictionary
            actionBodyStr = sprintf("{'schema_name': '%s', 'to_overwrite': '%s'}", schemaName, string(toOverwrite));
            
            % Convert the string to bytes using Python's encode method
            pyStr = py.str(actionBodyStr);
            actionBodyBytes = py.bytes(pyStr.encode('utf-8'));
            
            % Create the action
            action = COBRArrow.pyarrowFlight.Action('persist', actionBodyBytes);
            
            % Call the action on the server
            fprintf("Persisting the model for schema '%s'...\n", schemaName);
            
            % pass in the options for authentication purposes
            resultStream = obj.client.do_action(action, obj.options);
            
            pyList = py.list(resultStream);
            resultCell = cell(pyList);
            % Initialize a struct to hold the data for this table
            for i = 1:length(resultCell)
                % Access the result
                result = resultCell{i};
                
                % Access the body of the result
                body = result.body.to_pybytes();
                
                % Convert the body to a string
                message = char(body);
                if contains(message, 'persisted successfully')
                    fprintf(message+"\n");
                else
                    error('An error occurred: %s', message);
                end
            end
            
        end
        
        function FBAmodel = fetchModelForFBAAnalysis(obj, schemaName)
            % fetchModelForFBAAnalysis reads the necessary fields for FBA analysis from the server.
            %
            % USAGE:
            %
            %    FBAmodel = obj.fetchModelForFBAAnalysis(schemaName)
            %
            % INPUTS:
            %    obj:         Instance of the COBRArrow class.
            %    schemaName:  String representing the schema name to read the model from.
            %
            % OUTPUTS:
            %    FBAmodel:    Structure containing the fields required for FBA analysis.
            %
            % DESCRIPTION:
            %    This function reads the required and optional fields for Flux Balance Analysis (FBA)
            %    from the server using the provided schema name. It initializes an empty struct and
            %    populates it with the necessary fields. If an optional field does not exist, the function
            %    continues without error.
            %
            % EXAMPLE:
            %
            %    FBAmodel = arrowClient.fetchModelForFBAAnalysis('mySchema');
            %
            FBAmodel = struct();
            % Define the necessary field names for FBA analysis
            requiredFields = {'S', 'c', 'lb', 'ub', 'b', 'csense', 'mets'};
            optionalFields = {'C', 'd', 'ctrs', 'dsense'};
            
            % Read the required fields
            for i = 1:numel(requiredFields)
                fieldName = requiredFields{i};
                FBAmodel.(fieldName) = obj.fetchField(schemaName, fieldName);
            end
            
            % Read the optional fields if they exist
            try
                for i = 1:numel(optionalFields)
                    fieldName = optionalFields{i};
                    FBAmodel.(fieldName) = obj.fetchField(schemaName, fieldName);
                end
                fprintf('It is a coupled model.\n');
            catch
                % If the field does not exist, continue without error
                fprintf('It is an uncoupled model.\n');
            end
        end
        
        function writeToFlightRpc(obj, descriptor, pyArrowRecordBatch)
            % writeToFlightRpc sends a PyArrow record batch to the server using Flight RPC.
            %
            % USAGE:
            %
            %    obj.writeToFlightRpc(descriptor, pyArrowRecordBatch)
            %
            % INPUTS:
            %    obj:                 Instance of the COBRArrow class.
            %    descriptor:          FlightDescriptor object describing the data.
            %    pyArrowRecordBatch:  PyArrow RecordBatch to be sent to the server.
            %
            % DESCRIPTION:
            %    This function sends a PyArrow RecordBatch to the server using the Flight RPC protocol.
            %    It writes the batch to the server and closes the writer.
            %
            % EXAMPLE:
            %
            %    arrowClient.writeToFlightRpc(descriptor, pyArrowRecordBatch);
            %
            
            % pass in the options for authentication purposes
            writerTuple = obj.client.do_put(descriptor, pyArrowRecordBatch.schema, obj.options);
            writer = writerTuple{1};
            writer.write_batch(pyArrowRecordBatch);
            writer.close();
        end
        
        function pyArrowTable = retrieveFlightData(obj, endpoint)
            % retrieveFlightData retrieves data from the server using Flight RPC and converts it to a PyArrow table.
            %
            % USAGE:
            %    pyArrowTable = obj.retrieveFlightData(endpoint)
            %
            % INPUTS:
            %    obj:         Instance of the COBRArrow class.
            %    endpoint:    Endpoint object representing where the data can be accessed.
            %
            % OUTPUTS:
            %    pyArrowTable: PyArrow Table containing the retrieved data.
            %
            % DESCRIPTION:
            %   This function retrieves data from the server using the Flight RPC protocol.
            %    It attempts to read all data at once using the provided endpoint. If an error
            %    occurs during this process, it reads the data in smaller chunks and combines them
            %    into a single PyArrow Table. The function returns the PyArrow Table containing the
            %    retrieved data.
            %
            % EXAMPLE:
            %
            %    arrowTable = arrowClient.retrieveFlightData(endpoint);
            %
            
            reader = obj.client.do_get(endpoint.ticket);
            try
                pyArrowTable = reader.read_all(); % Read all data but gives call stack error
            catch ME
                fprintf('Error reading all data at once: %s. Change to chunk read...\n', ME.message);
                % Read data in chunks
                all_chunks = py.list();
                while true
                    try
                        chunk = reader.read_chunk();
                        if isempty(chunk)
                            break;
                        end
                        all_chunks.append(chunk.data);  % Collect each chunk as Arrow RecordBatch
                    catch innerME
                        %  if eof error, means all data has been read
                        if contains(innerME.message, 'EOFError')
                            disp('No more chunks to read');
                        end
                        % If any other error occurs, break the loop
                        break;
                    end
                end
                
                % Combine all chunks into a single Arrow Table
                pyArrowTable = COBRArrow.pyarrowLib.Table.from_batches(all_chunks);
            end
        end
        
        function pyArrowTable = readFromFlightRpc(obj,descriptor)
            % Reads data from the server using Flight RPC and converts it to a PyArrow table.
            %
            % USAGE:
            %    pyArrowTable = readFromFlightRpc(obj, descriptor)
            %
            % INPUTS:
            %    obj:         Instance of the COBRArrow class.
            %    descriptor:  FlightDescriptor object that describes the data to be read.
            %
            % OUTPUT:
            %    pyArrowTable: PyArrow Table containing the retrieved data.
            %
            % DESCRIPTION:
            %    This function attempts to retrieve data from the Flight server using the
            %    provided descriptor. If the server does not have available endpoints, it
            %    raises an error. If endpoints are available, it retrieves the data from
            %    the first available endpoint and converts it into a PyArrow table.
            %
            % EXAMPLE:
            %
            %    arrowTable = arrowClient.readFromFlightRpc(descriptor);
            %
            
            % Attempt to retrieve flight information
            flightInfo = obj.client.get_flight_info(descriptor);
            endpoints = flightInfo.endpoints;
            
            % Check if endpoints are available
            if ~isempty(endpoints)
                endpoint = endpoints{1}; % Use the first endpoint
                pyArrowTable = obj.retrieveFlightData(endpoint);% Retrieve data from the endpoint
            else
                error('No endpoints available for the provided FlightDescriptor.');
            end
        end
        
        function flightsList = listAllFlights(obj,schemaName)
            % listAllFlights lists all available flights and detailed information from the server.
            %
            % USAGE:
            %
            %    flightsList = listAllFlights(obj)
            %    flightsList = obj.listAllFlights(schemaName)
            %
            % INPUTS:
            %    obj:         Instance of the FlightClient class.
            %    schemaName:  (Optional) String representing the schema name to filter flights.
            %
            % OUTPUT:
            %    flightsList: Cell array containing information about available flights.
            %              Each cell contains a struct with the following fields:
            %                - descriptor: Unique identifier for the flight.
            %                - total_records: Total number of records in the flight.
            %                - total_bytes: Total number of bytes in the flight.
            %                - endpoints: List of endpoints where the flight can be accessed.
            %                - schema: Schema of the flight, including column names and data types.
            %                - schema_metadata: Additional metadata associated with the schema, such as table name and description.
            %
            % DESCRIPTION:
            %    This function retrieves all available flights from the server and returns detailed information
            %    about each flight. If a schema name is provided, it filters the flights based on the schema name.
            %    The function converts the Python list of flights to a MATLAB cell array and returns it.
            %
            % EXAMPLE:
            %
            %    flightsList = arrowClient.listAllFlights();
            %    flightsList = arrowClient.listAllFlights('mySchema');
            %
            
            % List all available flights, return a _cython_3_0_10.generator object
            flights = obj.client.list_flights();
            
            % Convert _cython_3_0_10.generator object to Python list
            flightsPyList = py.list(flights);
            
            % Initialize an empty cell array for MATLAB
            flightsList = {};
            
            % Convert the Python list to MATLAB format
            for i = 1:length(flightsPyList)
                flight = flightsPyList{i};
                
                % unique identifier for the flight
                flightInfo.descriptor = char(flight.descriptor.command.decode('utf-8'));
                
                if nargin > 1 && ~contains(flightInfo.descriptor, schemaName)
                    %  Skip if the schema name does not match
                    continue;
                end
                
                % The total number of records in the dataset.
                flightInfo.total_records = double(flight.total_records);
                % The total number of bytes in the dataset.
                flightInfo.total_bytes = double(flight.total_bytes);
                
                % A list of endpoints where the data can be accessed, including tickets and locations.
                flightInfo.endpoints = cell(1, length(flight.endpoints));
                for j = 1:length(flight.endpoints)
                    endpoint = flight.endpoints{j};
                    flightInfo.endpoints{j} = char(endpoint);
                end
                
                % The schema of the flight, including column names and data types and metadata.
                flightInfo.schema = char(flight.schema);
                
                % Additional metadata associated with the schema, including table name and table description.
                flightInfo.schema_metadata = char(flight.schema.metadata);
                
                flightsList{end+1} = flightInfo;
            end
        end
        
        function descriptors = getAllDescriptors(obj,schemaName)
            % getAllDescriptors retrieves all flight descriptors(unique identifier of the
            % flight) from the server.
            %
            % USAGE:
            %
            %    descriptors = obj.getAllDescriptors()
            %    descriptors = obj.getAllDescriptors(schemaName)
            %
            % INPUTS:
            %    obj:         Instance of the FlightClient class.
            %    schemaName:  (Optional) String representing the schema name to filter flights.
            %
            % OUTPUT:
            %    descriptors: Cell array containing descriptors of available flights.
            %
            % DESCRIPTION:
            %    This function retrieves all flight descriptors from the server. If a schema name is provided,
            %    it filters the descriptors based on the schema name. The function converts the Python list of
            %    descriptors to a MATLAB cell array and returns it.
            %
            % EXAMPLE:
            %
            %    descriptors = arrowClient.getAllDescriptors();
            %    descriptors = arrowClient.getAllDescriptors('mySchema');
            %
            
            % Call the Python function
            if nargin < 2
                % No schemaName provided, list all flights
                flightsPyList = obj.listAllFlights();
            else
                % schemaName provided, filter flights by schemaName
                flightsPyList =  obj.listAllFlights(schemaName);
            end
            
            % Initialize an empty cell array for MATLAB
            descriptors = cell(1, length(flightsPyList));
            
            % Convert the Python list to MATLAB format
            for i = 1:length(flightsPyList)
                flight = flightsPyList{i};
                descriptors{i} = flight.descriptor;
            end
        end
        
        function loadFromDuckDB(obj,schemaName)
            % loadFromDuckDB loads data from DuckDB into the Flight server.
            %
            % USAGE:
            %    obj.loadFromDuckDB(schemaName)
            %
            % INPUTS:
            %    obj:         Instance of the COBRArrow class.
            %    schemaName:  String representing the schema name to be loaded from DuckDB.
            %
            % OUTPUTS:
            %    None
            %
            % DESCRIPTION:
            %    This function triggers the loading of data from a DuckDB database into
            %    the Flight server. It constructs a request using the schema name, encodes
            %    it into bytes, and sends the request to the server using the Flight RPC protocol.
            %
            % EXAMPLE:
            %    arrowClient.loadFromDuckDB('mySchema');
            
            obj.requireAuthentication();
            
            % Create a string representation of the dictionary
            actionBodyStr = sprintf("{'schema_name': '%s'}", schemaName);
            
            % Convert the string to bytes using Python's encode method
            pyStr = py.str(actionBodyStr);
            actionBodyBytes = py.bytes(pyStr.encode('utf-8'));
            
            disp("Loading data from DuckDB to the server...");
            % Create the action
            action = COBRArrow.pyarrowFlight.Action('load', actionBodyBytes);
            
            % Call the action on the server
            % pass in the options for authentication purposes
            obj.client.do_action(action, obj.options);
        end
        
    end
    
    
    methods (Static)
        function fieldData = pyArrowTableToMatField(pyArrowTable)
            % pyArrowTableToMatField converts a PyArrow table to a MATLAB struct field.
            %
            % USAGE:
            %
            %    fieldData = COBRArrow.pyArrowTableToMatField(pyArrowTable)
            %
            % INPUTS:
            %    pyArrowTable: PyArrow table object containing the data.
            %
            % OUTPUT:
            %    fieldData:    MATLAB data converted from the PyArrow table.
            %
            % DESCRIPTION:
            %    This function checks the type of the field and calls the appropriate
            %    helper function to convert the data from a PyArrow table to a MATLAB structure.
            %
            % EXAMPLE:
            %
            %    fieldData = COBRArrow.pyArrowTableToMatField(arrowTable);
            %
            
            metadata = COBRArrow.getMetadata(pyArrowTable);
            fieldType = metadata('mat_field_type');
            % disp(fieldType);
            
            % Check field type and call appropriate helper function
            if strcmp(fieldType, 'cellColumnVector')
                fieldData = COBRArrow.arrowToCellVector(pyArrowTable);
            elseif strcmp(fieldType, 'cellRowVector')
                fieldData = COBRArrow.arrowToCellVector(pyArrowTable);
                fieldData = fieldData';
            elseif strcmp(fieldType, 'double')
                fieldData = COBRArrow.arrowToDoubleVector(pyArrowTable);
            elseif strcmp(fieldType, 'charVector')
                fieldData = COBRArrow.arrowToCharVector(pyArrowTable);
            elseif strcmp(fieldType, 'matrix')
                fieldData = COBRArrow.arrowToDoubleMatrix(pyArrowTable);
            elseif strcmp(fieldType, 'string')
                fieldData = COBRArrow.arrowToString(pyArrowTable);
            elseif contains(fieldType, 'int')
                fieldData = COBRArrow.arrowToIntVector(pyArrowTable);
            elseif strcmp(fieldType, 'logical')
                fieldData = COBRArrow.arrowToInt(pyArrowTable);
                fieldData = logical(fieldData);
            elseif strcmp(fieldType, 'logicalVector')
                fieldData = COBRArrow.arrowToIntVector(pyArrowTable);
                fieldData = logical(fieldData);
            else
                warning('Unexpected field type: %s', fieldType);
                fieldData = [];
            end
        end
        
        function metadataMap = getMetadata(pyArrowTable)
            % getMetadata extracts the field type from the metadata of a PyArrow table.
            %
            % USAGE:
            %    metadataMap = COBRArrow.getMetadata(pyArrowTable)
            %
            % INPUTS:
            %    pyArrowTable: PyArrow table object containing the metadata.
            %
            % OUTPUT:
            %    matFieldType: The field type extracted from the metadata.
            %
            % DESCRIPTION:
            %    This function extracts metadata from the PyArrow table's schema and converts
            %    it from a Python dictionary to a MATLAB containers.Map object. It then retrieves
            %    the field type from this map.
            %
            %    The process involves:
            %    1. Extracting metadata from the PyArrow table schema.
            %    2. Converting the metadata dictionary's keys and values from Python byte strings
            %       to MATLAB strings.
            %    3. Creating a MATLAB containers.Map object to manage the metadata.
            %    4. Accessing the specific property 'mat_field_type' to determine the field type.
            %
            % EXAMPLE:
            %
            %    matFieldType = COBRArrow.getMetadata(pyArrowTable);
            %
            
            metadataPython = pyArrowTable.schema.metadata;
            % Convert Python dict to MATLAB containers.Map
            metadataKeys = cell(py.list(metadataPython.keys()));  % Extract keys from Python dict
            metadataValues = cell(py.list(metadataPython.values()));  % Extract values from Python dict
            
            % Convert each byte string to a regular Python string
            metadataKeysStr = cellfun(@(x) char(x.decode('utf-8')), metadataKeys, 'UniformOutput', false);
            metadataValuesStr = cellfun(@(x) char(x.decode('utf-8')), metadataValues, 'UniformOutput', false);
            
            % % Create a MATLAB map
            metadataMap = containers.Map(metadataKeysStr, metadataValuesStr);
        end
        
        function fieldData = arrowToCellVector(pyArrowTable)
            % arrowToCellVector converts a PyArrow table column to a MATLAB cell vector.
            %
            % USAGE:
            %
            %    fieldData = COBRArrow.arrowToCellVector(pyArrowTable)
            %
            % INPUTS:
            %    pyArrowTable: PyArrow table object containing the data.
            %
            % OUTPUT:
            %    fieldData:    MATLAB cell vector converted from the PyArrow table column.
            %
            % DESCRIPTION:
            %    This function handles the conversion of cell vector fields from a PyArrow table
            %    to a MATLAB cell vector. It extracts the first column of the PyArrow table,
            %    converts the data to a Python list, and then converts each element of the list
            %    to a MATLAB character array. The resulting cell array is then transposed to match
            %    the expected MATLAB format.
            %
            % EXAMPLE:
            %
            %    cellVector = COBRArrow.arrowToCellVector(arrowTable);
            %
            
            % Handle cell vector fields
            % Extract the first column of the PyArrow table and convert it to a Python list
            columnData = pyArrowTable.columns{1}.to_pylist();
            % Convert each element of the Python list to a MATLAB character array
            data = cellfun(@char, cell(columnData(:)), 'UniformOutput', false);
            % Transpose the cell array to match the expected MATLAB format
            fieldData = data';
        end
        
        function fieldData = arrowToDoubleVector(pyArrowTable)
            % arrowToDoubleVector converts a PyArrow table column to a MATLAB double vector.
            %
            % USAGE:
            %
            %    fieldData = COBRArrow.arrowToDoubleVector(pyArrowTable)
            %
            % INPUTS:
            %    pyArrowTable: PyArrow table object containing the data.
            %
            % OUTPUT:
            %    fieldData:    MATLAB double vector converted from the PyArrow table column.
            %
            % DESCRIPTION:
            %    This function handles the conversion of double vector fields from a PyArrow table
            %    to a MATLAB double vector. It extracts the first column of the PyArrow table,
            %    converts the data to a Python list, and then converts it to a MATLAB double array.
            %    The resulting double array is then transposed to match the expected MATLAB format.
            %
            % EXAMPLE:
            %
            %    doubleVector = COBRArrow.arrowToDoubleVector(arrowTable);
            %
            
            % Extract the first column of the PyArrow table and convert it to a Python list
            columnData = pyArrowTable.columns{1}.to_pylist();
            
            % Convert the Python list to a MATLAB double array
            data = cellfun(@double, cell(columnData));
            
            % Transpose the double array to match the expected MATLAB format
            fieldData = data';
        end
        
        function fieldData = arrowToCharVector(pyArrowTable)
            % arrowToCharVector converts a PyArrow table column to a MATLAB char vector.
            %
            % USAGE:
            %
            %    fieldData = COBRArrow.arrowToCharVector(pyArrowTable)
            %
            % INPUTS:
            %    pyArrowTable: PyArrow table object containing the data.
            %
            % OUTPUT:
            %    fieldData:    MATLAB char vector converted from the PyArrow table column.
            %
            % DESCRIPTION:
            %    This function handles the conversion of char vector fields from a PyArrow table
            %    to a MATLAB char vector. It extracts the first column of the PyArrow table,
            %    converts the data to a Python list, and then converts each element of the list
            %    to a MATLAB character array. The resulting char array is then transposed to match
            %    the expected MATLAB format.
            %
            % EXAMPLE:
            %
            %    charVector = COBRArrow.arrowToCharVector(arrowTable);
            %
            
            % Extract the first column of the PyArrow table and convert it to a Python list
            columnData = pyArrowTable.columns{1}.to_pylist();
            % Convert each element of the Python list to a MATLAB character array
            cellData = cellfun(@char, cell(columnData(:)), 'UniformOutput', false);
            % Combine the cell array into a single char array
            data = [cellData{:}];
            % Transpose the char array to match the expected MATLAB format
            fieldData = data';
        end
        
        function fieldData = arrowToDoubleMatrix(pyArrowTable)
            % arrowToDoubleMatrix converts a PyArrow table to a MATLAB sparse double matrix.
            %
            % USAGE:
            %
            %    fieldData = COBRArrow.arrowToDoubleMatrix(pyArrowTable)
            %
            % INPUTS:
            %    pyArrowTable: PyArrow table object containing the data.
            %
            % OUTPUT:
            %    fieldData:    MATLAB sparse double matrix converted from the PyArrow table columns.
            %
            % DESCRIPTION:
            %    This function converts a PyArrow table to a MATLAB sparse double matrix by extracting
            %    row, column, and value data from the table's columns. It uses the extracted data
            %    along with metadata specifying the matrix dimensions to construct a sparse matrix.
            %
            % EXAMPLE:
            %
            %    sparseMatrix = COBRArrow.arrowToDoubleMatrix(arrowTable);
            %
            
            % Extract metadata from the PyArrow table
            metdata = COBRArrow.getMetadata(pyArrowTable);
            dimensionsStr = metdata('dimensions');
            dimensionsArray = str2num(dimensionsStr);
            
            % Determine the size of the matrix
            nrows = dimensionsArray(1);
            ncols = dimensionsArray(2);
            
            % Extract row, column, and value data from the PyArrow table
            row = cellfun(@double, cell(pyArrowTable.columns{1}.to_pylist()));
            col = cellfun(@double, cell(pyArrowTable.columns{2}.to_pylist()));
            val = cellfun(@double, cell(pyArrowTable.columns{3}.to_pylist()));
            
            % Construct a sparse matrix from the row, column, and value data
            fieldData = sparse(row, col, val, nrows, ncols);
        end
        
        function fieldData = arrowToString(pyArrowTable)
            % arrowToString converts a PyArrow table column to a MATLAB string.
            %
            % USAGE:
            %
            %    fieldData = COBRArrow.arrowToString(pyArrowTable)
            %
            % INPUTS:
            %    pyArrowTable: PyArrow table object containing the data.
            %
            % OUTPUT:
            %    fieldData:    MATLAB string converted from the PyArrow table column.
            %
            % DESCRIPTION:
            %    This function handles the conversion of string fields from a PyArrow table
            %    to a MATLAB string. It extracts the first column of the PyArrow table,
            %    converts the data to a Python list, and then converts the first element of
            %    the list to a MATLAB string.
            %
            % EXAMPLE:
            %
            %    str = COBRArrow.arrowToString(arrowTable);
            %
            
            % Extract the first column of the PyArrow table and convert it to a Python list
            columnData = pyArrowTable.columns{1}.to_pylist();
            
            % Convert the first element of the Python list to a MATLAB string
            fieldData = char(columnData{1});
        end
        
        function fieldData = arrowToInt(pyArrowTable)
            % arrowToInt converts a PyArrow table column to a MATLAB integer.
            %
            % USAGE:
            %
            %    fieldData = COBRArrow.arrowToInt(pyArrowTable)
            %
            % INPUTS:
            %    pyArrowTable: PyArrow table object containing the data.
            %
            % OUTPUT:
            %    fieldData:    MATLAB integer converted from the PyArrow table column.
            %
            % DESCRIPTION:
            %    This function handles the conversion of integer fields from a PyArrow table
            %    to a MATLAB integer. It extracts the first column of the PyArrow table,
            %    converts the data to a Python list, and then converts the first element of
            %    the list to a MATLAB integer.
            %
            % EXAMPLE:
            %
            %    intValue = COBRArrow.arrowToInt(arrowTable);
            %
            
            % Extract the first column of the PyArrow table and convert it to a Python list
            columnData = pyArrowTable.columns{1}.to_pylist();
            % Convert the first element of the Python list to a MATLAB integer
            fieldData = columnData{1};
        end
        
        function fieldData = arrowToIntVector(pyArrowTable)
            % arrowToIntVector converts a PyArrow table column to a MATLAB integer vector.
            %
            % USAGE:
            %
            %    fieldData = COBRArrow.arrowToIntVector(pyArrowTable)
            %
            % INPUTS:
            %    pyArrowTable: PyArrow table object containing the data.
            %
            % OUTPUTS:
            %    fieldData:    MATLAB integer vector converted from the PyArrow table column.
            %
            % DESCRIPTION:
            %    This function handles the conversion of integer vector fields from a PyArrow table
            %    to a MATLAB integer vector. It extracts the first column of the PyArrow table,
            %    converts the data to a Python list, and then converts it to a MATLAB int64 array.
            %    The resulting integer array is then transposed to match the expected MATLAB format.
            %
            % EXAMPLE:
            %
            %    intVector = COBRArrow.arrowToIntVector(arrowTable);
            %
            
            % Extract the first column of the PyArrow table and convert it to a Python list
            columnData = pyArrowTable.columns{1}.to_pylist();
            
            % Convert the Python list to a MATLAB int64 array
            data = cellfun(@int64, cell(columnData));
            % Transpose the integer array to match the expected MATLAB format
            fieldData = data';
        end
        
        function pyArrowRecordBatch = MatFieldToPyArrow(fieldData, fieldName)
            % MatFieldToPyArrow converts a MATLAB struct field to an Apache Arrow record batch.
            %
            % USAGE:
            %    pyArrowRecordBatch = COBRArrow.MatFieldToPyArrow(fieldData, fieldName)
            %
            % INPUTS:
            %    fieldData: MATLAB data to be converted.
            %    fieldName: Name of the field.
            %
            % OUTPUT:
            %    pyArrowRecordBatch: Converted Apache Arrow record batch.
            %
            % EXAMPLE:
            %    arrowBatch = MatFieldToPyArrow(data, 'fieldName');
            %
            % DESCRIPTION:
            %    This function converts a MATLAB struct field to an Apache Arrow record batch.
            %    It handles different data types including character vectors, numeric vectors,
            %    matrices, and cell vectors, and adds metadata to the record batch schema.
            %
            %    The process involves:
            %    1. Determining the data type of the field.
            %    2. Converting the field data to an Apache Arrow record batch.
            %    3. Adding metadata to the schema of the record batch.
            %
            %    The function returns the Apache Arrow record batch with the added metadata.
            %
            % EXAMPLE:
            %    arrowBatch = COBRArrow.MatFieldToPyArrow(data, 'fieldName');
            %
            
            fieldType = class(fieldData);
            fieldDimensions = sprintf('[%d, %d]', size(fieldData, 1), size(fieldData, 2));
            
            if ischar(fieldData)
                % Handle char fields including row vectors and column vectors of char
                if iscolumn(fieldData)
                    % handle column vector, convert it to row vector
                    fieldData = fieldData';
                    fieldType = 'charVector';
                elseif isrow(fieldData)
                    % handle row vector and single char
                    fieldType = 'string';
                else
                    fieldType = 'charMatrix';
                    warning('Field %s has unsupported char array size: (%d, %d), uploading as an empty field.\n', fieldName, size(fieldData, 1), size(fieldData, 2));
                    fieldData = {};
                end
                pyArrowRecordBatch = COBRArrow.charVectorToArrow(fieldData, fieldName);
            elseif isnumeric(fieldData)
                if all(size(fieldData) > 1)
                    fieldType = 'matrix';
                    % handle matrix
                    pyArrowRecordBatch = COBRArrow.matrixToArrow(fieldData);
                else
                    if iscolumn(fieldData)
                        % handle column vector, convert it to row vector
                        fieldData = fieldData';
                    end
                    if isscalar(fieldData)
                        % handle 1x1 numeric field
                        pyArrowRecordBatch = COBRArrow.numericToArrow(fieldData, fieldName);
                    else
                        % handle numeric vector
                        pyArrowRecordBatch = COBRArrow.otherVectorToArrow(fieldData, fieldName);
                    end
                end
            elseif iscell(fieldData)
                if iscolumn(fieldData)
                    fieldType = 'cellColumnVector';
                    % handle column vector, convert it to row vector
                    fieldData = fieldData';
                elseif isrow(fieldData)
                    fieldType = 'cellRowVector';
                else
                    fieldType = 'cellMatrix';
                    warning('Field %s has unsupported cell array size: (%d, %d), uploading as an empty field.\n', fieldName, size(fieldData, 1), size(fieldData, 2));
                    fieldData = {};
                end
                pyArrowRecordBatch = COBRArrow.otherVectorToArrow(fieldData, fieldName);
            elseif islogical(fieldData)
                % handle logical vector
                if size(fieldData, 1) > 1
                    fieldType = 'logicalVector';
                    fieldData = double(fieldData);
                    fieldData = fieldData';
                    pyArrowRecordBatch = COBRArrow.otherVectorToArrow(fieldData, fieldName);
                else
                    fieldData = double(fieldData);
                    pyArrowRecordBatch = COBRArrow.numericToArrow(fieldData, fieldName);
                end
            else
                warning('Field %s has unsupported data type: %s, uploading as an empty field.\n', fieldName, fieldType);
                pyArrowRecordBatch = COBRArrow.unsupportedFieldToArrow(fieldName);
            end
            % fprintf('field %s has type %s\n', fieldName, fieldType);
            % Add metadata to the schema
            pyArrowRecordBatch = COBRArrow.addMetadata(pyArrowRecordBatch, fieldName, fieldType, fieldDimensions);
        end
        
        function pyArrowRecordBatch = unsupportedFieldToArrow(fieldName)
            % unsupportedFieldToArrow creates an empty Apache Arrow record batch for an unsupported field.
            %
            % USAGE:
            %
            %    pyArrowRecordBatch = COBRArrow.unsupportedFieldToArrow(fieldName)
            %
            % INPUTS:
            %    fieldName: Name of the unsupported field.
            %
            % OUTPUT:
            %    pyArrowRecordBatch: Apache Arrow record batch for the unsupported field.
            %
            %
            % DESCRIPTION:
            %    This function creates an empty Apache Arrow record batch for an unsupported field.
            %    It creates an empty string array and converts it to an Apache Arrow record batch.
            %
            % EXAMPLE:
            %
            %    arrowBatch = COBRArrow.unsupportedFieldToArrow('fieldName');
            %
            pyArrowArray = COBRArrow.pyarrowLib.array({''});
            pyArrowRecordBatch = COBRArrow.pyarrowLib.RecordBatch.from_arrays(py.list({pyArrowArray}), py.list({fieldName}));
        end
        
        function pyArrowRecordBatch = charVectorToArrow(fieldData, fieldName)
            % charVectorToArrow converts a character vector to an Apache Arrow record batch.
            %
            % USAGE:
            %
            %    pyArrowRecordBatch = COBRArrow.charVectorToArrow(fieldData, fieldName)
            %
            % INPUTS:
            %    fieldData: Character vector to be converted.
            %    fieldName: Name of the field.
            %
            % OUTPUT:
            %    pyArrowRecordBatch: Apache Arrow record batch containing the character vector.
            %
            %
            % DESCRIPTION:
            %    This function converts a character vector to an Apache Arrow record batch.
            %    It creates a Python list from the character vector and converts it to an Apache Arrow array.
            %    The array is then used to create an Apache Arrow record batch with the specified field name.
            %
            % EXAMPLE:
            %
            %    arrowBatch = COBRArrow.charVectorToArrow('example', 'fieldName');
            %
            pyArrowArray = COBRArrow.pyarrowLib.array({fieldData});
            pyArrowRecordBatch = COBRArrow.pyarrowLib.RecordBatch.from_arrays(py.list({pyArrowArray}), py.list({fieldName}));
        end
        
        function pyArrowRecordBatch = matrixToArrow(matrix)
            % matrixToArrow converts a MATLAB matrix to an Apache Arrow record batch.
            %
            % USAGE:
            %
            %    pyArrowRecordBatch = COBRArrow.matrixToArrow(matrix)
            %
            % INPUTS:
            %    matrix: MATLAB matrix to be converted.
            %
            % OUTPUT:
            %    pyArrowRecordBatch: Apache Arrow record batch containing the matrix data.
            %
            % DESCRIPTION:
            %    This function converts a MATLAB matrix to an Apache Arrow record batch.
            %    It extracts the row, column, and value data from the matrix and converts them to Python lists.
            %    The lists are then used to create Apache Arrow arrays, which are combined into a record batch.
            %
            % EXAMPLE:
            %
            %    arrowBatch = COBRArrow.matrixToArrow(magic(3));
            %
            
            [rows, cols, vals] = find(matrix);
            rowArray = COBRArrow.pyarrowLib.array(rows);
            colArray = COBRArrow.pyarrowLib.array(cols);
            valArray = COBRArrow.pyarrowLib.array(vals);
            data = py.list({rowArray, colArray, valArray});
            names = py.list({'row', 'col', 'val'});
            pyArrowRecordBatch = COBRArrow.pyarrowLib.RecordBatch.from_arrays(data, names);
        end
        
        function pyArrowRecordBatch = otherVectorToArrow(fieldData, fieldName)
            % otherVectorToArrow converts a numeric or cell vector to an Apache Arrow record batch.
            %
            % USAGE:
            %
            %    pyArrowRecordBatch = COBRArrow.otherVectorToArrow(fieldData, fieldName)
            %
            % INPUTS:
            %    fieldData: Numeric or cell vector to be converted.
            %    fieldName: Name of the field.
            %
            % OUTPUT:
            %    pyArrowRecordBatch: Apache Arrow record batch containing the vector data.
            %
            % DESCRIPTION:
            %    This function converts a numeric or cell vector to an Apache Arrow record batch.
            %    It creates a Python list from the vector and converts it to an Apache Arrow array.
            %    The array is then used to create an Apache Arrow record batch with the specified field name.
            %
            % EXAMPLE:
            %
            %    arrowBatch = COBRArrow.otherVectorToArrow([1, 2, 3], 'fieldName');
            %
            pyArrowArray = COBRArrow.pyarrowLib.array(fieldData);
            pyArrowRecordBatch = COBRArrow.pyarrowLib.RecordBatch.from_arrays(py.list({pyArrowArray}), py.list({fieldName}));
        end
        
        function pyArrowRecordBatch = numericToArrow(fieldData, fieldName)
            % numericToArrow converts a single numeric value to an Apache Arrow record batch.
            %
            % USAGE:
            %
            %    pyArrowRecordBatch = COBRArrow.numericToArrow(fieldData, fieldName)
            %
            % INPUTS:
            %    fieldData: Single numeric value to be converted.
            %    fieldName: Name of the field.
            %
            % OUTPUT:
            %    pyArrowRecordBatch: Apache Arrow record batch containing the numeric value.
            %
            % DESCRIPTION:
            %    This function converts a single numeric value to an Apache Arrow record batch.
            %    It creates a Python scalar from the numeric value and converts it to an Apache Arrow array.
            %    The array is then used to create an Apache Arrow record batch with the specified field name.
            %
            % EXAMPLE:
            %
            %    arrowBatch = COBRArrow.numericToArrow(42, 'fieldName');
            %
            pyArrowScalar = COBRArrow.pyarrowLib.scalar(fieldData);
            pyArrowArray = COBRArrow.pyarrowLib.array(py.list({pyArrowScalar}));
            pyArrowRecordBatch = COBRArrow.pyarrowLib.RecordBatch.from_arrays(py.list({pyArrowArray}), py.list({fieldName}));
        end
        
        function pyArrowRecordBatch = addMetadata(pyArrowRecordBatch, fieldName, fieldType, fieldDimensions)
            % addMetadata adds metadata to the schema of a PyArrow record batch.
            %
            % USAGE:
            %
            %    pyArrowRecordBatch = COBRArrow.addMetadata(pyArrowRecordBatch, fieldName)
            %
            % INPUTS:
            %    pyArrowRecordBatch: Apache Arrow record batch.
            %    fieldName:          Name of the field.
            %
            % OUTPUT:
            %    pyArrowRecordBatch: Apache Arrow record batch with metadata.
            %
            % DESCRIPTION:
            %    This function adds metadata to the schema of a PyArrow record batch.
            %    It converts the field name, field type, and field dimensions to Python strings
            %    and encodes them as UTF-8. The metadata is then added to the schema of the record batch.
            %
            % EXAMPLE:
            %
            %    arrowBatch = COBRArrow.addMetadata(arrowBatch, 'fieldName');
            %
            
            % Convert fieldName to Python string and encode
            tableName = py.str(fieldName).encode('utf-8');
            description = py.str(['This is a description for ', fieldName]).encode('utf-8');
            type = py.str(fieldType).encode('utf-8');
            dimensions = py.str(fieldDimensions).encode('utf-8');
            % Metadata to be added
            metadata = py.dict(pyargs(...
                'name', py.bytes(tableName), ...
                'description', py.bytes(description), ...
                'mat_field_type', py.bytes(type),... % Add the field type to the metadata
                'dimensions', py.bytes(dimensions)...
                ));
            % fprintf('field name: %s, field type: %s\n', fieldName, char(type.decode('utf-8')));
            % Add metadata to the schema
            schemaWithMetadata = pyArrowRecordBatch.schema.with_metadata(metadata);
            pyArrowRecordBatch = pyArrowRecordBatch.replace_schema_metadata(schemaWithMetadata.metadata);
        end
        
    end
    
end