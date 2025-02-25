function status = runSeqC(...
    repoPathSeqC, outputPathSeqC, fileIDSeqC, procKeepSeqC, maxMemSeqC, maxCpuSeqC, maxProcSeqC, debugSeqC, ...
    readsTablePath, outputPathMARS, outputExtensionMARS, relAbunFilePath, sample_read_counts_cutoff, cutoffMARS, ...
    OTUTable, flagLoneSpecies, taxaSplit, removeCladeExtensionsFromTaxa, whichModelDatabase, ...
    userDatabase_path, taxaTable ...
)
%======================================================================================================#
% Title: SeqC as Flux Pipeline MATLAB Wrapper
% Author: Wiley Barton
% Modified code sources:
%   matlab script structure: Tim Hensen, runMars.m, 2025.01
%   assistance and reference from a generative AI model [ChatGPT](https://chatgpt.com/)
%       clean-up and improved readability
% Last Modified: 2025.02.09
% Part of: Persephone Pipeline
%
% Description:
%   This function builds and runs the SeqC Docker image from a MATLAB environment.
%   It ensures necessary databases exist and coordinates execution with the MARS pipeline.
%
% Inputs:
%   - repoPathSeqC (char) : Path to the SeqC repository
%   - outputPathSeqC (char) : Path for SeqC output
%   - fileIDSeqC (char) : Unique identifier for file processing
%   - procKeepSeqC (logical) : Keep all files (true/false)
%   - maxMemSeqC (int) : Maximum memory allocation for SeqC
%   - maxCpuSeqC (int) : Maximum CPU allocation for SeqC
%   - maxProcSeqC (int) : Maximum processes for SeqC
%   - debugSeqC (logical) : Enable debug mode (true/false)
%   ...
%
% Dependencies:
%   - MATLAB
%   - Docker installed and accessible in the system path
%======================================================================================================#
%% Determine Operating System
if ismac
    vOS = 'mac';
    setenv('PATH', [getenv('PATH') ':/usr/local/bin']); % Ensure Docker is found
elseif isunix
    vOS = 'unix';
elseif ispc
    vOS = 'win';
else
    error('Unsupported operating system.');
end

%% Determine directory size and estimate usage exapansion
% TODO add check for getD 
dirPath = fullfile(repoPathSeqC,'seqc_input/'); % Directory path
totalBytes = getDirectorySize(dirPath); % Function from previous response
totalMB = totalBytes / (1024^2); % Convert to MB
totalGB = totalBytes / (1024^3); % Convert to GB
inflateRatio = 3.2; % inflation term
inflateGB = totalGB * inflateRatio;
msgDsize = sprintf('Total size of directory: %.2f GB\nExpected inflation size: %.2f GB\n', totalGB, inflateGB);

%% Initialize Paths
vdir_init = cd;
vdir_out_seqc = 'seqc_output';
vdir_out_mars = fullfile(vdir_out_seqc, 'mars_out');
% Set system to seqc repo
cd(repoPathSeqC);
    
%% Convert Numeric Inputs to Strings
maxCpuSeqC = num2str(maxCpuSeqC);
maxMemSeqC = num2str(maxMemSeqC);
maxProcSeqC = num2str(maxProcSeqC);
if isnumeric(cutoffMARS)
    cutoffMARS = sprintf('%f', cutoffMARS);
end

%% Build Docker Options
% Hardware params
comm_build_opt_hw = sprintf('--build-arg varg_cpu_max=%s --build-arg varg_mem_max=%s --build-arg varg_proc_max=%s', ...
                            maxCpuSeqC, maxMemSeqC, maxProcSeqC);
% MARS params
comm_build_opt_mars = sprintf(['--build-arg varg_mars_outputExtensionMARS=%s' ...
' --build-arg varg_mars_sample_read_counts_cutoff=%d' ...
' --build-arg varg_mars_cutoffMARS=%s' ...
' --build-arg varg_mars_flagLoneSpecies=%s' ...
' --build-arg varg_mars_taxaSplit="%s"' ...
' --build-arg varg_mars_removeCladeExtensionsFromTaxa=%s' ...
' --build-arg varg_mars_whichModelDatabase=%s'], ...
outputExtensionMARS, sample_read_counts_cutoff, cutoffMARS, ...
string(flagLoneSpecies), string(taxaSplit), string(removeCladeExtensionsFromTaxa), ...
whichModelDatabase);

%% Append Optional Build Arguments - MARS
% exclude if empty
optionalParams = {OTUTable, readsTablePath, relAbunFilePath, userDatabase_path, taxaTable};
paramNames = {'varg_mars_OTUTable', 'varg_mars_readsTablePath', 'varg_mars_relAbunFilePath', 'varg_mars_userDatabase_path', 'varg_mars_taxaTable'};
for vi = 1:length(optionalParams)
    if ~ismissing(optionalParams{vi})
        if ~isempty(optionalParams{vi}) && ~strcmpi(optionalParams{vi}, "")
            comm_build_opt_mars = sprintf('%s --build-arg %s=%s', comm_build_opt_mars, paramNames{vi}, optionalParams{vi});
        end
    end
end

%% Build Docker Image command
comm_build = sprintf('docker build -t dock_seqc --ulimit nofile=65536:65536 %s %s .', comm_build_opt_hw, comm_build_opt_mars);

%% Docker run commands
% core run command
comm_run_core = 'docker run --interactive --tty --user 0 --rm --mount';
% sans interactive
comm_run_core = sprintf('docker run --tty --user 0 --rm --memory=%s --cpus=%s --mount',sprintf('%sg',maxMemSeqC),maxCpuSeqC);

%% Set Database Assignment Command
switch whichModelDatabase
    case 'AGORA'
        comm_run_db_kb = '-s "tool_k2_agora"';
    case 'APOLLO'
        comm_run_db_kb = '-s "tool_k2_apollo"';
    case 'full_db'
        comm_run_db_kb = '-s "tool_k2_agora2apollo"';
    otherwise
        comm_run_db_kb = '-s "tool_k2_agora2apollo"'; % Default case
end
comm_run_db_kd = '-s "host_kd_hsapcontam"';
comm_run_db = sprintf('BASH_seqc_makedb.sh %s %s', comm_run_db_kd, comm_run_db_kb);

%% Construct Command for Running SeqC
comm_mama_help = 'BASH_seqc_mama.sh -h';
comm_mama_full = 'BASH_seqc_mama.sh';
% append optional flags
if debugSeqC
    comm_mama_full = [comm_mama_full ' -b'];
end
if procKeepSeqC
    comm_mama_full = [comm_mama_full ' -k'];
end
comm_mama_full = sprintf('%s -i "step0_data_in/" -n "%s" -r "SR" -s 0', comm_mama_full, fileIDSeqC);
% Append volume mapping commands to core
% OS sensitive
if strcmp(vOS, 'unix')
    comm_run_main = sprintf('%s "type=bind,src=$(pwd)/seqc_input,target=/home/seqc_user/seqc_project/step0_data_in" --mount "type=bind,src=$(pwd)/seqc_output,target=/home/seqc_user/seqc_project/final_reports" --mount "type=volume,dst=/DB,volume-driver=local,volume-opt=type=none,volume-opt=o=bind,volume-opt=device=$(pwd)/seqc_proc" dock_seqc /bin/bash', comm_run_core);
%    comm_exit_mv = 'mv -r $(pwd)/seqc_proc/DEPO_proc/* $(pwd)/seqc_output'
elseif strcmp(vOS, 'mac')
    comm_run_main = sprintf('%s "type=bind,src=$(pwd)/seqc_input,target=/home/seqc_user/seqc_project/step0_data_in" --mount "type=bind,src=$(pwd)/seqc_output,target=/home/seqc_user/seqc_project/final_reports" --mount "type=volume,dst=/DB,volume-driver=local,volume-opt=type=none,volume-opt=o=bind,volume-opt=device=$(pwd)/seqc_proc" dock_seqc /bin/bash', comm_run_core);
%    comm_exit_mv = 'mv -r $(pwd)/seqc_proc/DEPO_proc/* $(pwd)/seqc_output'
elseif strcmp(vOS, 'win')
    comm_run_main = sprintf('%s "type=bind,src=%s\\seqc_input,target=/home/seqc_user/seqc_project/step0_data_in" --mount "type=bind,src=%s\\seqc_output,target=/home/seqc_user/seqc_project/final_reports" --mount "type=bind,src=%s\\seqc_proc,target=/DB" dock_seqc /bin/bash', comm_run_core, pwd, pwd, pwd);
%    comm_exit_mv = 'mv -r .\seqc_proc\DEPO_proc\* .\seqc_output\'
end
%% Run Commands
try
    % check for preexisting image
    imageName = 'dock_seqc';
[status, cmdout] = system(['docker images -q ' imageName]);

if isempty(strtrim(cmdout))
    disp(['Image "' imageName '" does NOT exist. Now creating...']);
    disp(' > Building SeqC docker image, wait time ~10min.');
    [status, cmdout] = system(comm_build);
    if status ~= 0, error('Docker build failed:\n%s', cmdout); end
else
    disp(['Docker Image "' imageName '" exists.']);
end
    
    % Test MAMA script - TMP
    [status, cmdout] = system(sprintf('%s %s',comm_run_main, comm_mama_help));
    if status ~= 0, warning('MAMA test failed:\n%s', cmdout); end

    % Run database creation
    disp(' > Running database setup, wait time ~30min....');
    [status, cmdout] = system(sprintf('%s %s',comm_run_main, comm_run_db));
    if status ~= 0, error('Database setup failed:\n%s', cmdout); end

    % Run full SeqC pipeline
    disp(sprintf(' > SeqC Processing Begins...\n%s',msgDsize));
    [status, cmdout] = system(sprintf('%s %s',comm_run_main, comm_mama_full));
    if status ~= 0, error('SeqC pipeline execution failed:\n%s', cmdout); end
    disp(' > SeqC Processing Ends.');

    % Move final output
    movefile(fullfile(vdir_out_seqc, '*'), outputPathSeqC);
    % Update mars path
    vdir_out_mars = fullfile(outputPathSeqC, 'mars_out');
    if ~strcmp(outputPathSeqC, outputPathMARS)
        movefile(fullfile(vdir_out_mars, '*'), outputPathMARS);
        vdir_out_mars = fullfile(outputPathSeqC);
    end
    % Relocate RA file for pipeline catch - resolved in primary persephone function
    %movefile(fullfile(vdir_out_mars, 'renormalized_mapped_forModelling', ['renormalized_mapped_forModelling_species.', outputExtensionMARS]),vdir_out_mars)

catch ME
    disp(['Error: ', ME.message]);
end

% Restore original directory
cd(vdir_init);
end
% EoB