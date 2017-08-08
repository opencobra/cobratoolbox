function envVarValue = getsysenvironvar(environmentVariable, printLevel)
% Author: Luis Cantero.
% The MathWorks.
% https://nl.mathworks.com/matlabcentral/answers/uploaded_files/1420/get_set_sys_env_var.zip

if nargin < 2
    printLevel = 0;
end

shellObject = actxserver('WScript.Shell');
envVarValue = [];
% Write environment variable.
try
    envVarValue = shellObject.RegRead(['HKEY_CURRENT_USER\Environment\' environmentVariable]);
catch
    if printLevel > 0
        warning(['The environment variable', environmentVariable, ' cannot be retrieved from the registry.']);
    end
end

shellObject.delete;
clear shellObject;
