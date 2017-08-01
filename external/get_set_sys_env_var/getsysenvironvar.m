function envVarValue = getsysenvironvar(environmentVariable)
% Author: Luis Cantero.
% The MathWorks.
% https://nl.mathworks.com/matlabcentral/answers/uploaded_files/1420/get_set_sys_env_var.zip

shellObject = actxserver('WScript.Shell');

% Write environment variable.
try
    envVarValue = shellObject.RegRead(['HKEY_CURRENT_USER\Environment\' environmentVariable]);
catch
    warning(['The environment variable', environmentVariable, ' cannot be retrieved from the registry.']);
end

shellObject.delete;
clear shellObject;
