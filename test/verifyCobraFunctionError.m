function success = verifyCobraFunctionError(functionCall, message)
% Tests whether the provided call throws an error and if the error message
% fits to the message provided
%
% USAGE:
%
%    success = verifyCobraFunctionError(functionCall, message)
%
% INPUTS:
%    functionCall:      A function call (to be called by functionCall()).
%
% OPTIONAL INPUTS:
%    message:           The message that should be thrown in this error. If
%                       no message is supplied, any thrown error will be
%                       accepted
%
% OUTPUTS:
%    success:           Whether an error was thrown, and the type and
%                       message match (if provided)

testMessage = false;

if exist('message','var')
    testMessage = true;
end

success = true;
try   
    functionCall();
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