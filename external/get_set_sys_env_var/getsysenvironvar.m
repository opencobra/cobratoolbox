function envVarValue = getsysenvironvar(environmentVariable)
% Author: Luis Cantero.
% The MathWorks.

shellObject = actxserver('WScript.Shell');

% Write environment variable.
try
    %envVarValue = shellObject.RegRead(['HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Session Manager\Environment\' environmentVariable]);
    envVarValue = shellObject.RegRead(['HKEY_CURRENT_USER\Environment\' environmentVariable]);
catch
end

shellObject.delete;
clear shellObject;
