function status = runSeqC(...
    repoPathSeqC, outputPathSeqC, fileIDSeqC, ...
    procKeepSeqC, maxMemSeqC, maxCpuSeqC, ...
    maxProcSeqC, debugSeqC, runApptainer ...
)
%======================================================================================================#
% Title: SeqC as Flux Pipeline MATLAB Wrapper
% Author: Wiley Barton
% Modified code sources:
%   matlab script structure: Tim Hensen, runMars.m, 2025.01
%   assistance and reference from a generative AI model [ChatGPT](https://chatgpt.com/)
%       clean-up and improved readability
% Last Modified: 2026.04.22 - wbarton
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
%   - runApptainer (logical) : Enable apptainer wrapping (true/false)
%   ...
%
% Dependencies:
%   - MATLAB
%   - Docker installed and accessible in the system path
% Optional:
%   - Apptainer (formerly Singularity) installed and accessible in the system path (tested for version 1.3.6-1.el8)
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

%% Determine availability of Apptainer - 0=ya
% if on system and T in runApptainer, pass with vAPTER=0
% Build comms with runApptainer = true, execute with vAPTER=0, write batch file with vAPTER=1 + vBATCH=0
vBATCH = 1;
[vAPTER, cmdout] = system('which apptainer');
if vAPTER == 0
	if runApptainer
		vAPTER = 0;
	else
		vAPTER = 1;
        warning('Apptainer is installed but not requested. Running Docker.');
    end
else
    if runApptainer
		% pot. try docker in absence of apptainer		
        warning('Apptainer is requested but not installed. Writing batch file.');
		vBATCH = 0;
    end
    vAPTER = 1;
end
%% Determine directory size and estimate usage exapansion
% TODO add check for getD 
dirPath = fullfile(repoPathSeqC,'seqc_input/'); % Directory path
totalBytes = getDirectorySize(dirPath); % Function in /persephone/additionalFunctions
totalMB = totalBytes / (1024^2); % Convert to MB
totalGB = totalBytes / (1024^3); % Convert to GB
inflateRatio = 3.2; % inflation term
inflateGB = totalGB * inflateRatio;
msgDsize = sprintf('Total size of directory: %.2f GB\nExpected inflation size: %.2f GB\n', totalGB, inflateGB);

%% Initialize Paths
vdir_init = cd;
vdir_out_seqc = 'seqc_output';
vdir_out_mars = fullfile(vdir_out_seqc, 'mars_out'); % Pot. remove
% Set system to seqc repo
cd(repoPathSeqC);

%% Check for pre-existing batch outputs or final outputs
skipSeqCRun = false;
% Check if files are in holding from the batch script
if exist(vdir_out_seqc, 'dir') && ~isempty(dir(fullfile(vdir_out_seqc, '*.txt')))
    disp(' > SeqC outputs found in holding dir. Assuming external batch job completion and skipping pipeline execution.');
    skipSeqCRun = true;
% Check if they've already been moved and finalized
elseif exist(outputPathSeqC, 'dir') && ~isempty(dir(fullfile(outputPathSeqC, '*.txt')))
    disp(' > Final SeqC outputs already exist in designated path. Skipping pipeline execution.');
    skipSeqCRun = true;
end

%% Convert Numeric Inputs to Strings
maxCpuSeqC = num2str(maxCpuSeqC);
maxMemSeqC = num2str(maxMemSeqC);
maxProcSeqC = num2str(maxProcSeqC);
%if isnumeric(cutoffMars)
%    cutoffMars = sprintf('%f', cutoffMars);
%end

%% Build Docker Options
% User ID params
if strcmp(vOS, 'unix')
    [~, v_uid] = system('id -u');
    [~, v_gid] = system('id -g');
    % Strip newline characters
    v_uid = strtrim(v_uid);
    v_gid = strtrim(v_gid);
    comm_build_opt_UID = sprintf('--build-arg USER_UID=%s --build-arg USER_GID=%s', v_uid, v_gid);
elseif strcmp(vOS, 'mac')
    % fixed for OSX jank
    v_uid = num2str(42069);
    v_gid = num2str(42069);
    comm_build_opt_UID = sprintf('--build-arg USER_UID=%s --build-arg USER_GID=%s', v_uid, v_gid);
elseif strcmp(vOS, 'win')
    % fixed for windows jank
    v_uid = num2str(42069);
    v_gid = num2str(42069);
    comm_build_opt_UID = sprintf('--build-arg USER_UID=%s --build-arg USER_GID=%s', v_uid, v_gid);
end
% Hardware params
comm_build_opt_hw = sprintf('--build-arg varg_cpu_max=%s --build-arg varg_mem_max=%s --build-arg varg_proc_max=%s', ...
                            maxCpuSeqC, maxMemSeqC, maxProcSeqC);
%% Build Docker Image command
if runApptainer
	comm_build = sprintf('apptainer build --fakeroot --bind="$TMPDIR:/tmp" %s apter_seqc.sif Apptainer.def', comm_build_opt_hw);
    %comm_build = 'apptainer build --fakeroot --bind="$TMPDIR:/tmp" apter_seqc.sif Apptainer.def';
else
    % w/ mars
    %comm_build = sprintf('docker build -t dock_seqc --ulimit nofile=65536:65536 %s %s %s .', comm_build_opt_hw, comm_build_opt_mars, comm_build_opt_UID);
    %sans mars
    comm_build = sprintf('docker build -t dock_seqc --ulimit nofile=65536:65536 %s %s .', comm_build_opt_hw, comm_build_opt_UID);
end
%% Docker run commands
if runApptainer
    %% Apptainer commands
    % Build from docker image
    % comm_build_apter = 'apptainer build apter_seqc.sif docker-daemon://dock_seqc:latest';
    % Build from def file
% Run statement
% cgroups error with resource flags - bypassed by ommision atm
    comm_run_core = sprintf('apptainer exec --cwd /home/seqc_user/seqc_project --writable-tmpfs --no-mount tmp --no-home -e');
    comm_run_dir_I = '--mount type=bind,src=$(pwd)/seqc_input,dst=/home/seqc_user/seqc_project/step0_data_in';
    comm_run_dir_O = '--mount type=bind,src=$(pwd)/seqc_output,dst=/home/seqc_user/seqc_project/final_reports';
    comm_run_dir_P = '--mount type=bind,src=$(pwd)/seqc_proc,dst=/DB';
    comm_run_main = sprintf('%s %s %s %s apter_seqc.sif /bin/bash',comm_run_core,comm_run_dir_I,comm_run_dir_O,comm_run_dir_P);
elseif strcmp(vOS, 'unix')
    % core run command
    comm_run_core = sprintf('docker run --tty --user %s:%s --rm --memory=%s --cpus=%s',v_uid,v_gid,sprintf('%sg',maxMemSeqC),maxCpuSeqC);
    % Append volume mapping commands to core
    comm_run_dir_I = '--mount type=bind,src=$(pwd)/seqc_input,dst=/home/seqc_user/seqc_project/step0_data_in';
    comm_run_dir_O = '--mount type=bind,src=$(pwd)/seqc_output,dst=/home/seqc_user/seqc_project/final_reports';
    comm_run_dir_P = '--mount type=bind,src=$(pwd)/seqc_proc,dst=/DB';
    comm_run_main = sprintf('%s %s %s %s dock_seqc /bin/bash',comm_run_core,comm_run_dir_I,comm_run_dir_O,comm_run_dir_P);
elseif strcmp(vOS, 'mac')
    % currently unable to simulate user permission transfer
    comm_run_core = sprintf('docker run --tty --user 0 --rm --memory=%s --cpus=%s',sprintf('%sg',maxMemSeqC),maxCpuSeqC);
    comm_run_dir_I = '--mount type=bind,src=$(pwd)/seqc_input,dst=/home/seqc_user/seqc_project/step0_data_in';
    comm_run_dir_O = '--mount type=bind,src=$(pwd)/seqc_output,dst=/home/seqc_user/seqc_project/final_reports';
    comm_run_dir_P = '--mount type=bind,src=$(pwd)/seqc_proc,dst=/DB';
    comm_run_main = sprintf('%s %s %s %s dock_seqc /bin/bash',comm_run_core,comm_run_dir_I,comm_run_dir_O,comm_run_dir_P);
    system("chmod -R a+rw ./seqc_input ./seqc_output ./seqc_proc"); % allow interaction from host:dock
elseif strcmp(vOS, 'win')
    comm_run_core = sprintf('docker run --tty --user %s:%s --rm --memory=%s --cpus=%s',v_uid,v_gid,sprintf('%sg',maxMemSeqC),maxCpuSeqC);
    comm_run_dir_I = sprintf('--mount "type=bind,src=%s\\seqc_input,target=/home/seqc_user/seqc_project/step0_data_in"', pwd);
    comm_run_dir_O = sprintf('--mount "type=bind,src=%s\\seqc_output,target=/home/seqc_user/seqc_project/final_reports"', pwd);
    comm_run_dir_P = sprintf('--mount "type=bind,src=%s\\seqc_proc,target=/DB"', pwd);
    comm_run_main = sprintf('%s %s %s %s dock_seqc /bin/bash',comm_run_core,comm_run_dir_I,comm_run_dir_O,comm_run_dir_P);
end

%% Set Database Assignment Command
%reconstructionDb = 'full_db'; % Default for now - to be user input
reconstructionDb = 'smol_db'; % TEMP TEST
switch reconstructionDb
    case 'AGORA'
        comm_run_db_kb = '"tool_k2_agora"';
    case 'APOLLO'
        comm_run_db_kb = '"tool_k2_apollo"';
    case 'full_db'
        comm_run_db_kb = '"tool_k2_agora2apollo"';
    case 'smol_db'
        comm_run_db_kb = '"tool_k2_std8"'; % smol test db
    otherwise
        comm_run_db_kb = '"tool_k2_agora2apollo"'; % Default case
end
% Default host contaminant db
comm_run_db_kd = '"host_kd_hsapcontam"';
% DB command - force rebuild if Apptainer due to HPC vol issues
if runApptainer
    comm_run_db = sprintf('BASH_seqc_makedb.sh -s %s -s %s', comm_run_db_kd, comm_run_db_kb);
else
    comm_run_db = sprintf('BASH_seqc_makedb.sh -s %s -s %s', comm_run_db_kd, comm_run_db_kb);
end
comm_mama_db = sprintf('-d %s -d %s', comm_run_db_kd, comm_run_db_kb); % to include in main run rather sep DB
%% Construct Command for Running SeqC
comm_mama_help = 'BASH_seqc_mama.sh -v';
comm_mama_full = 'BASH_seqc_mama.sh';
% append optional flags
if debugSeqC
    comm_mama_full = [comm_mama_full ' -b'];
end
if procKeepSeqC
    comm_mama_full = [comm_mama_full ' -k'];
end
comm_mama_full = sprintf('%s -i "step0_data_in/" -n "%s" -r "SR" -s 0 %s', comm_mama_full, fileIDSeqC, comm_mama_db);

%% Do seqc stuff...
try
	% if vBATCH == 0, write batch file and exit
	if vBATCH == 0 && ~skipSeqCRun
		% write batch file
		fid = fopen('batch_run_seqc.sh', 'w');
		fprintf(fid, '#!/bin/bash\n');
		fprintf(fid, '# batch_run_seqc.sh\n');
		fprintf(fid, '#\n');
		fprintf(fid, '# Batch script to build and run SeqC on an HPC.\n');
		fprintf(fid, '# This script accommodates the Apptainer environment.\n');
		fprintf(fid, '# Part of the Persephone workflow.\n');
		fprintf(fid, '# Use at your own risk, have fun, be cool\n');
		fprintf(fid, '#\n');
		fprintf(fid, '# Slurm directives for cluster job submission. \n');
		fprintf(fid, '# Adjust the account, time, and resources as necessary.\n');
		fprintf(fid, '#SBATCH --job-name=seqc_HPC\n');
		fprintf(fid, '#SBATCH --account=project_42069\n');
		fprintf(fid, '#SBATCH --time=02:00:00\n');
		fprintf(fid, '#SBATCH --mem=%s\n', sprintf('%sG',maxMemSeqC));
		% Calculate required NVMe space (minimum 50GB for base operations + inflation estimate)
		nvmeReq = max(50, ceil(inflateGB) + 10);
		fprintf(fid, '#SBATCH --cpus-per-task=%s\n', maxCpuSeqC);
		fprintf(fid, '#SBATCH --gres=nvme:50\n'); % 50GB for temp files, .sif=1.3G
		%fprintf(fid, '#SBATCH --gres=nvme:%d\n', nvmeReq); % Dynamic temp storage mapped for Apptainer volumes
		fprintf(fid, '#\n');
		fprintf(fid, '# BUILD\n');
		fprintf(fid, 'srun %s\n', comm_build);
		fprintf(fid, '#\n');
		fprintf(fid, '# RUN\n');
		fprintf(fid, '# Create database\n');
		fprintf(fid, 'srun %s\n', sprintf('%s %s',comm_run_main, comm_run_db));
		fprintf(fid, '# Run SeqC\n');
		fprintf(fid, 'srun %s\n', sprintf('%s %s',comm_run_main, comm_mama_full));
		fprintf(fid, '#EoB');
		fclose(fid);
		disp(' > Batch file written.');
		disp(' > Confirm details are correct.');
		disp(' > THEN submit the batch file to the cluster using:');
		disp(' > sbatch batch_run_seqc.sh');
		disp(' > Once SeqC completes, restart Persephone to continue analysis.');
		status = 1; % Return status 1 specifying it didn't complete natively
		cd(vdir_init);
		return;
	elseif vBATCH == 1 && ~skipSeqCRun
		%% Build container
		if vAPTER == 0
			% check for preexisting apptainer image
			imageName = 'apter_seqc.sif';
			if isfile(imageName)
				disp(['Apptainer Object "' imageName '" exists - BUILD SKIPPED']);
			else
				disp(['Image "' imageName '" does NOT exist. Now creating...']);
				disp(' > Building SeqC Apptainer image, wait time ~15min');
				[status_IMG, cmdout] = system(comm_build);
				if status_IMG ~= 0, warning('Apptainer build failed:\n%s', cmdout); end
			end
		else
			% check for preexisting docker image
			imageName = 'dock_seqc';
			[status_IMG, cmdout] = system(['docker images -q ' imageName]);
			if isempty(strtrim(cmdout))
				disp(['Image "' imageName '" does NOT exist. Now creating...']);
				disp(' > Building SeqC docker image, wait time ~15min.');
				[status_IMG, cmdout] = system(comm_build);
				if status_IMG ~= 0, error('Docker build failed:\n%s', cmdout); end
			else
				disp(['Docker Image "' imageName '" exists.']);
			end
		end
		%% Run Commands
		% Test MAMA script
		[status_IMG, cmdout] = system(sprintf('%s %s',comm_run_main, comm_mama_help));
		if status_IMG ~= 0, warning('MAMA test failed:\n%s', cmdout); end

		% Run database creation
		disp(' > Running database setup, wait time ~30min....');
		[status_IMG, cmdout] = system(sprintf('%s %s',comm_run_main, comm_run_db));
		if status_IMG ~= 0, error('Database setup failed:\n%s', cmdout); end

		% Run full SeqC pipeline
		disp(sprintf(' > SeqC Processing Begins...\n%s',msgDsize));
		%sprintf('%s %s',comm_run_main, comm_mama_full) % TS - display final command
		[status_IMG, cmdout] = system(sprintf('%s %s',comm_run_main, comm_mama_full));
		if status_IMG ~= 0, error('SeqC pipeline execution failed:\n%s', cmdout); end
		disp(' > SeqC Processing Ends.');
	end
	% Move final output
	if ~exist(outputPathSeqC, 'dir')
		mkdir(outputPathSeqC);
	end
	outputFiles = dir(fullfile(vdir_out_seqc, '*.txt'));
	if ~isempty(outputFiles)
		movefile(fullfile(vdir_out_seqc, '*.txt'), outputPathSeqC);
	end
	
	status = 0; % Successfully completed

catch ME
    disp(['Error: ', ME.message]);
	status = 1;
end

% Restore original directory
cd(vdir_init);
end
% EoB
