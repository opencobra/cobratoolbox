function varargout = greedyExtremeRayBasis(varargin)
% Recording shim (feature 20261106-213424-greedy-basis-reconcile, T005).
%
% Placed first on the path while the ancestor's testGreedyExtremeRayBasis runs. Every
% call is forwarded to the real function in the folder named by the global
% GREEDY_RECORD_REALDIR, and its inputs, nargout, the RNG state just before the call and
% its outputs (or error) are saved to GREEDY_RECORD_OUTDIR/call_NNN.mat for replay
% against the reconciled function (FR-007, SC-003).

global GREEDY_RECORD_REALDIR GREEDY_RECORD_OUTDIR GREEDY_RECORD_COUNT
persistent realFn
if isempty(realFn)
    here = cd(GREEDY_RECORD_REALDIR);
    realFn = @greedyExtremeRayBasis;   % bound to the real file while it is in the current folder
    cd(here);
    realInfo = functions(realFn);
    assert(~contains(realInfo.file, 'recorder'), 'recording shim bound to itself: %s', realInfo.file);
end
if isempty(GREEDY_RECORD_COUNT)
    GREEDY_RECORD_COUNT = 0;
end
GREEDY_RECORD_COUNT = GREEDY_RECORD_COUNT + 1;

callInputs = varargin; %#ok<NASGU>
callNargout = max(nargout, 1);
rngBefore = rng; %#ok<NASGU>
callOutputs = cell(1, callNargout);
errorId = '';
errorMessage = '';
try
    [callOutputs{:}] = realFn(varargin{:});
catch ME
    errorId = ME.identifier;
    errorMessage = ME.message;
end
save(fullfile(GREEDY_RECORD_OUTDIR, sprintf('call_%03d.mat', GREEDY_RECORD_COUNT)), ...
    'callInputs', 'callNargout', 'rngBefore', 'callOutputs', 'errorId', 'errorMessage', '-v7.3');
if ~isempty(errorId) || ~isempty(errorMessage)
    rethrow(ME);
end
varargout = callOutputs(1:max(nargout, 1));
end
