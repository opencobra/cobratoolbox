function setsysenvironvar(environmentVariable, newValue)
% Author: Luis Cantero.
% The MathWorks.

shellObject = actxserver('WScript.Shell');

% Write local environment variable.
setenv(environmentVariable, newValue);

% Write system environment variable.
try
    %shellObject.RegWrite(['HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Session Manager\Environment\' environmentVariable], newValue, 'REG_SZ');
    shellObject.RegWrite(['HKEY_CURRENT_USER\Environment\' environmentVariable], newValue, 'REG_SZ');
catch
    warning('cannot set');
end

%warning('Changes on a system level will not take effect until you restart.'); %#ok<WNTAG>

shellObject.delete;
clear shellObject;
