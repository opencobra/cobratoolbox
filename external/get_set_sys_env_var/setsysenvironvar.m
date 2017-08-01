function setsysenvironvar(environmentVariable, newValue)
% Author: Luis Cantero.
% The MathWorks.
% https://nl.mathworks.com/matlabcentral/answers/uploaded_files/1420/get_set_sys_env_var.zip

shellObject = actxserver('WScript.Shell');

% Write local environment variable.
setenv(environmentVariable, newValue);

% Write system environment variable.
try
    shellObject.RegWrite(['HKEY_CURRENT_USER\Environment\' environmentVariable], newValue, 'REG_SZ');
catch
    warning(['The environment variable', environmentVariable, ' cannot be set in the registry.']);
end

shellObject.delete;
clear shellObject;
