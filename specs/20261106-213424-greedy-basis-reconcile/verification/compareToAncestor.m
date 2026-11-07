function compareToAncestor(repoRoot, callDir, outFile)
% Replay every greedyExtremeRayBasis call recorded from the ancestor's test (T005) on the
% reconciled function in repoRoot, with the same inputs, nargout and RNG state, and
% compare (FR-007, FR-008, SC-003; task T014).
%
% Zpos and Z are compared with isequal. Every status field the ancestor returned is
% compared with isequal, except wall-clock fields, which are listed but not judged.
% Fields the reconciled function adds (B's initial-basis fields, checkpointFile) are
% ignored. A call that errored must error with the same identifier.
%
% USAGE:
%    matlab -batch "addpath('<featureDir>/verification'); compareToAncestor('<repoRoot>', '<callDir>', '<out.txt>')"

restoredefaultpath;
clear functions; %#ok<CLFUNC>
setenv('GUROBI_HOME', '/usr/local/bin/gurobi1303/linux64');
setenv('GRB_LICENSE_FILE', '/usr/local/bin/gurobi1303/gurobi.lic2/gurobi.lic');
addpath('/usr/local/bin/gurobi1303/linux64/matlab/');
addpath('/usr/local/bin/mosektoolslinux64x86/mosek/11.2/toolbox/r2019b');
cd(repoRoot);
initCobraToolbox(false, 'agent');
changeCobraSolver('gurobi', 'LP', 0);

timingFields = {'elapsedTime', 'spectrumTime'};
files = dir(fullfile(callDir, 'call_*.mat'));
fid = fopen(outFile, 'w');
cleanupFid = onCleanup(@() fclose(fid));
report = @(varargin) cellfun(@(f) fprintf(f, varargin{:}), {1, fid}, 'UniformOutput', false);
report('compareToAncestor: %s resolves to %s\n', 'greedyExtremeRayBasis', which('greedyExtremeRayBasis'));
nDiffer = 0;
for k = 1:numel(files)
    rec = load(fullfile(callDir, files(k).name));
    rng(rec.rngBefore);
    outputs = cell(1, rec.callNargout);
    errorId = '';
    try
        [outputs{:}] = greedyExtremeRayBasis(rec.callInputs{:});
    catch ME
        errorId = ME.identifier;
    end
    differences = {};
    if ~isempty(rec.errorId) || ~isempty(errorId)
        if ~strcmp(rec.errorId, errorId)
            differences{end+1} = sprintf('error id ancestor "%s" vs reconciled "%s"', rec.errorId, errorId); %#ok<AGROW>
        end
    else
        names = {'Zpos', 'Z', 'status'};
        for o = 1:min(2, rec.callNargout)
            if ~isequal(rec.callOutputs{o}, outputs{o})
                differences{end+1} = sprintf('%s differs (max abs diff %g)', names{o}, ...
                    full(max(abs(rec.callOutputs{o}(:) - outputs{o}(:))))); %#ok<AGROW>
            end
        end
        if rec.callNargout >= 3
            sA = rec.callOutputs{3};
            sR = outputs{3};
            fieldsA = fieldnames(sA);
            for f = 1:numel(fieldsA)
                name = fieldsA{f};
                if ~isfield(sR, name)
                    differences{end+1} = sprintf('status.%s missing', name); %#ok<AGROW>
                elseif any(strcmp(name, timingFields))
                    continue
                elseif ~isequaln(sA.(name), sR.(name))
                    differences{end+1} = sprintf('status.%s differs', name); %#ok<AGROW>
                end
            end
        end
    end
    if isempty(differences)
        report('%s: identical\n', files(k).name);
    else
        nDiffer = nDiffer + 1;
        report('%s: %s\n', files(k).name, strjoin(differences, '; '));
    end
end
report('compareToAncestor: %d of %d calls differ\n', nDiffer, numel(files));
end
