classdef COBRArrowSolver
    % COBRArrowSolver is a class for managing solver configurations.
    % It allows setting a solver's name and managing key-value pairs
    % of parameters required by the solver.
    %
    % The class provides methods to set, update, remove, and display
    % solver parameters, enabling easy configuration and adjustment
    % of solver settings within MATLAB.
    %
    % Example usage:
    %   solver = COBRArrowSolver('GLPK');
    %   solver = solver.setParameter('maxIterations', 1000);
    %   solver.showParameters();
    %
    % .. Author: - Yixing Lei
    
    properties
        name  % The name of the solver, e.g., 'GLPK'
        parameters  % A dictionary to store solver parameters as key-value pairs
    end
    
    methods
        function obj = COBRArrowSolver(solverName)
            % Constructor method to initialize the solver with a name
            % and an empty dictionary for parameters.
            %
            % INPUT:
            %   solverName: A string specifying the name of the solver. It is not case-sensitive.
            %               Current supported solvers are 'GLPK', 'Gurobi', 'CPLEX'.
            %
            % OUTPUT:
            %   obj: An instance of the COBRArrowSolver class.
            obj.name = solverName;
            obj.parameters = containers.Map();  % Initialize an empty dictionary
        end
        
        function obj = setName(obj, solverName)
            % Method to update the solver's name.
            %
            % INPUT:
            %   solverName: A string specifying the new name of the solver.
            %
            % OUTPUT:
            %   obj: The updated instance of the COBRArrowSolver class.
            obj.name = solverName;
        end
        
        function obj = setParameter(obj, key, value)
            % Method to add or update a solver parameter.
            % If the key already exists, its value is updated.
            %
            % INPUT:
            %   key: A string specifying the parameter's key.
            %   value: The value associated with the parameter key.
            %
            % OUTPUT:
            %   obj: The updated instance of the COBRArrowSolver class.
            obj.parameters(key) = value;
        end
        
        function obj = removeParameter(obj, key)
            % Method to remove a parameter from the solver's dictionary.
            % The parameter is identified by its key.
            %
            % INPUT:
            %   key: A string specifying the parameter's key to be removed.
            %
            % OUTPUT:
            %   obj: The updated instance of the COBRArrowSolver class.
            obj.parameters.remove(key);
        end
        
        function obj = clearParameters(obj)
            % Method to clear all parameters from the solver's dictionary.
            % This reinitializes the parameters map to an empty state.
            %
            % OUTPUT:
            %   obj: The updated instance of the COBRArrowSolver class with cleared parameters.
            obj.parameters = containers.Map();
        end
        
        function showParameters(obj)
            % Method to display all the solver's parameters.
            % The parameters are shown as key-value pairs.
            %
            % OUTPUT:
            %   None. This method displays the parameters in the console.
            keys = obj.parameters.keys;
            disp(['Parameters for solver: ', obj.name]);
            for i = 1:length(keys)
                disp([keys{i}, ': ', num2str(obj.parameters(keys{i}))]);
            end
        end
    end
end
