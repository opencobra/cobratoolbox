function outputFormatOK = changeCbMapOutput(outputFormat)
%changeCbMapOutput sets the output format for drawCbMap. Displays
%outputFormat if no inputs provided.
%
% outputFormatOK = changeCbMapOutput(outputFormat)
%
%OPTIONAL INPUT
% outputFormat      drawCbMap render format
%                   {'svg', 'matlab', 'java'} (java not implemented)
%OUTPUT
% outputFormatOK    True if output format set properly, else false.
%
%

global CB_MAP_OUTPUT

%% List output format if no inputs
if nargin <1  
    outputFormatOK = 0;
    fprintf('CB map output set to : %s\n',CB_MAP_OUTPUT);
    return;
end

%% List supported output here
supportedOutput = {'matlab','svg'};

%% Set CB_MAP_OUTPUT if outputFormat is supported
if any(strcmpi(outputFormat,supportedOutput))
    CB_MAP_OUTPUT = outputFormat;
    outputFormatOK = 1;
else
    warning([outputFormat ' is not a supported render format.']);
    outputFormatOK = 0;
end