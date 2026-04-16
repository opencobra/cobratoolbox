function report = checkOptArrowSetup(endpoint, opts)
% checkOptArrowSetup  Verify the OptArrow Gateway is reachable and the
% Arrow IPC serialisation layer is available.
%
% Requires the "MATLAB Interface to Apache Arrow" add-on, which must be
% built from source (github.com/apache/arrow). If the add-on is not
% installed, this function reports a hard failure with build instructions.
%
% USAGE:
%
%   report = checkOptArrowSetup()
%   report = checkOptArrowSetup(endpoint)
%   report = checkOptArrowSetup(endpoint, opts)
%
% INPUTS:
%   endpoint   char/string  Gateway URL (default: 'http://127.0.0.1:8000/cobra/compute').
%
%   opts       struct  Optional:
%                timeoutSec     numeric  Connection timeout (default: 10)
%                throwOnError   logical  Error on failure (default: true)
%
% OUTPUT:
%   report   struct
%              ok                logical
%              endpoint          char
%              timeoutSec        double
%              httpStatus        double   HTTP status code (0 if unreachable)
%              arrowBackend      char     'native' | 'pyarrow'
%              failures          cell     Error messages (empty when ok=true)
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

report               = struct();
report.ok            = false;
report.endpoint      = endpoint;
report.timeoutSec    = timeoutSec;
report.httpStatus    = 0;
report.arrowBackend  = '';
report.failures      = {};

% Check MATLAB version (version('-release') is available since R2006a)
try
    ver  = version('-release');   % e.g. '2025a'
    year = str2double(ver(1:4));
    if year < 2023
        report = localFail(report, sprintf( ...
            'OptArrow requires MATLAB R2023b or later (detected R%s).', ver));
    end
catch
    warning('OptArrow: could not verify MATLAB version. R2023b or later is required.');
end

% Check which Arrow IPC serialisation backend is available
report = localCheckArrowBackend(report);

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
            ['OptArrow Gateway returned HTTP %d from %s.\n' ...
             'Start the Gateway with:\n  python src/run_server.py'], ...
            code, endpoint));
    end
catch ME
    report = localFail(report, sprintf( ...
        ['OptArrow Gateway not reachable at %s.\n' ...
         'Start it with:\n  python src/run_server.py\n' ...
         'Error: %s'], endpoint, ME.message));
end
end

% -------------------------------------------------------------------------
function report = localCheckArrowBackend(report)
% Check whether the native MATLAB Arrow add-on is installed.
% This is a hard requirement — OptArrow uses native Arrow for all
% Arrow IPC serialization. There is no Python fallback.

nativeOk = false;
try
    arrow.recordBatch(table(int32(1), 'VariableNames', {'x'}));
    nativeOk = true;
catch
end

if nativeOk
    report.arrowBackend = 'native';
    fprintf('   Arrow backend: native MATLAB Interface to Apache Arrow.\n');
else
    report.arrowBackend = '';
    report = localFail(report, sprintf([...
        'The "MATLAB Interface to Apache Arrow" is not installed.\n' ...
        'This add-on is required and must be built from source:\n\n' ...
        '  Prerequisites (macOS):\n' ...
        '    xcode-select --install\n' ...
        '    brew install cmake\n\n' ...
        '  Prerequisites (Linux):\n' ...
        '    sudo apt install -y cmake build-essential\n\n' ...
        '  Step 1 — Build Arrow C++ (without S3):\n' ...
        '    git clone https://github.com/apache/arrow.git\n' ...
        '    cd arrow\n' ...
        '    cmake -S cpp -B build_cpp \\\n' ...
        '      -DCMAKE_BUILD_TYPE=Release \\\n' ...
        '      -DCMAKE_INSTALL_PREFIX=$HOME/arrow_no_s3 \\\n' ...
        '      -DARROW_S3=OFF -DARROW_WITH_RE2=OFF \\\n' ...
        '      -DARROW_CSV=ON -DARROW_IPC=ON -DARROW_COMPUTE=ON \\\n' ...
        '      -DARROW_BUILD_TESTS=OFF -DxsimdSOURCE=BUNDLED\n' ...
        '    cmake --build build_cpp --config Release --target install\n\n' ...
        '  Step 2 — Build the MATLAB bindings:\n' ...
        '    cmake -S matlab -B build_matlab \\\n' ...
        '      -DArrow_DIR=$HOME/arrow_no_s3/lib/cmake/Arrow \\\n' ...
        '      -DCMAKE_INSTALL_PREFIX=$HOME/arrow_matlab\n' ...
        '    cmake --build build_matlab --config Release --target install\n\n' ...
        '  Step 3 — Verify in MATLAB:\n' ...
        '    arrow.recordBatch(table(["A";"B"], [1;2]))']));
end
end

function report = localFail(report, msg)
report.failures{end+1, 1} = msg;
end

function val = localGetOr(s, field, default)
if isfield(s, field), val = s.(field); else, val = default; end
end
