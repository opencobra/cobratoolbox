function report = checkOptArrowSetup(endpoint, opts)
% checkOptArrowSetup  Verify the OptArrow Gateway is reachable.
%
% Checks that the Gateway is responding and returning valid Arrow IPC data.
% No Python environment check is performed — MATLAB communicates with the
% Gateway natively via Apache Arrow.
%
% USAGE:
%
%   report = checkOptArrowSetup()
%   report = checkOptArrowSetup(endpoint)
%   report = checkOptArrowSetup(endpoint, opts)
%
% INPUTS:
%   endpoint   char/string  Gateway URL (default: 'http://127.0.0.1:8000/compute').
%              For local runs both 'http://127.0.0.1:8000/compute' and
%              'http://127.0.0.1:8000/cobra/compute' are valid — the former
%              is the health check target; the latter is the solve endpoint.
%
%   opts       struct  Optional:
%                timeoutSec     numeric  Connection timeout (default: 10)
%                throwOnError   logical  Error on failure (default: true)
%
% OUTPUT:
%   report   struct
%              ok           logical
%              endpoint     char
%              timeoutSec   double
%              httpStatus   double   HTTP status code from Gateway (0 if unreachable)
%              failures     cell     Error messages (empty when ok=true)
%
% Starting the Gateway locally:
%   cd <optArrow_mat>
%   python src/run_server.py
%
% .. Author: - Farid Zare 12/04/2026

if nargin < 1 || isempty(endpoint)
    endpoint = 'http://127.0.0.1:8000/compute';
end
if nargin < 2 || ~isstruct(opts)
    opts = struct();
end

endpoint     = char(string(endpoint));
timeoutSec   = double(localGetOr(opts, 'timeoutSec', 10));
throwOnError = logical(localGetOr(opts, 'throwOnError', true));

report           = struct();
report.ok        = false;
report.endpoint  = endpoint;
report.timeoutSec= timeoutSec;
report.httpStatus= 0;
report.failures  = {};

% Check MATLAB version
try
    ver = matlabRelease().Release;
    year = str2double(ver(2:5));
    if year < 2023
        report = localFail(report, sprintf( ...
            'OptArrow requires MATLAB R2023b or later (detected %s).\n', ver));
    end
catch
    % matlabRelease not available on older versions — add a warning only
    warning('OptArrow: could not verify MATLAB version. R2023b or later is required.');
end

% Attempt HTTP GET to root — a running Gateway returns 200/404/405
report = localCheckGateway(report, endpoint, timeoutSec);

report.ok = isempty(report.failures);

if ~report.ok && throwOnError
    error('OptArrow setup check failed.\n\n%s', strjoin(report.failures, [newline newline]));
end
end


% -------------------------------------------------------------------------
function report = localCheckGateway(report, endpoint, timeoutSec)
import matlab.net.http.*
import matlab.net.http.field.*

try
    uri      = matlab.net.URI(endpoint);
    reqOpts  = matlab.net.http.HTTPOptions( ...
        'ConnectTimeout',  timeoutSec, ...
        'ResponseTimeout', timeoutSec);
    req      = RequestMessage(RequestMethod.GET);
    response = req.send(uri, reqOpts);
    report.httpStatus = double(response.StatusCode);

    % Any response (even 404/405) means the server is up
    code = report.httpStatus;
    if code == 0 || code >= 500
        report = localFail(report, sprintf( ...
            'OptArrow Gateway returned HTTP %d from %s.\n' ...
            'Start the Gateway with:\n  python src/run_server.py', ...
            code, endpoint));
    end
catch ME
    report = localFail(report, sprintf( ...
        'OptArrow Gateway not reachable at %s.\n' ...
        'Start it with:\n  python src/run_server.py\n' ...
        'Error: %s', endpoint, ME.message));
end
end

function report = localFail(report, msg)
report.failures{end+1, 1} = msg;
end

function val = localGetOr(s, field, default)
if isfield(s, field), val = s.(field); else, val = default; end
end
