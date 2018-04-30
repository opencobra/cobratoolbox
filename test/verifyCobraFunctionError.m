function success = verifyCobraFunctionError(functionCall, varargin)
% Tests whether the provided call throws an error and if the error message
% fits to the message provided
%
% USAGE:
%
%    success = verifyCobraFunctionError(functionCall, message)
%
% INPUTS:
%    functionCall:       The name of a function.
%
% OPTIONAL INPUTS:
%    
%    varargin:           Parameter Value pairs for specific options.
%                         * outputArgCount -     The number of output arguments requested, as this can influence the functionality (Default: 0).
%                         * testMessage -        The message that should be thrown in this error. If no message is supplied, any thrown error will be accepted
%                         * inputs -             If the function requires Any inputs, provide them in a cell array.
%
% OUTPUTS:
%    success:            Whether an error was thrown, and the type and
%                        message match (if provided)
% EXAMPLES:
%    %Test whether pow throws an error when using chars
%    verifyCobraFunctionError('pow','inputs',{'abc','dce'});
%    %Test, whether initCobraToolbox throws an error
%    verifyCobraFunctionError('initCobraToolbox');
%    %Test whether targetFunctions error message is 'blubb'
%    verifyCobraFunctionError('targetFunctions','message','blubb');
%    %Test whether fluxvariability throws an error when 5 outputs are defined
%    verifyCobraFunctionError('fluxVariability','inputs',{model,0},'outputArgCount',10);

testMessage = false;
parser = inputParser();
parser.addRequired('functionCall',@ischar)
parser.addParamValue('inputs',{},@iscell)
parser.addParamValue('testMessage','',@ischar)
parser.addParamValue('outputArgCount',0,@(x) isnumeric(x) && mod(x,1) == 0);

parser.parse(functionCall,varargin{:});

outputArgcount = parser.Results.outputArgCount;
testMessage = ~any(ismember('testMessage',parser.UsingDefaults));
message = parser.Results.testMessage;
inputs = parser.Results.inputs;

functionCall = str2func(functionCall);
success = true;
try   
    if outputArgcount > 0
        outArgs = cell(outputArgcount,1);
        [outArgs{:}] = functionCall(inputs{:});
    else
        functionCall(inputs{:});
    end
catch ME
    if testMessage
        success = strcmp(ME.message,message);
    end
    %Now, we checked the message if necessary, and we are obvously in the
    %catch block, so an error was thrown, i.e. this is successful.
    return
end
%If we reach this point, the function did not throw an error. i.e. the
%verification is unsuccessful.
success = false;