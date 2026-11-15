% The COBRAToolbox: testRunSeqC.m
%
% Purpose:
%     - runSeqC builds the SeqC container image (Docker, or Apptainer when requested and
%       installed), runs the SeqC help, database and pipeline commands through system calls,
%       writes a Slurm batch file instead when Apptainer is requested but not installed, skips
%       the pipeline when SeqC outputs already exist, and moves the *.txt outputs of
%       seqc_output to the output folder. It returns 0 on success and 1 on a batch file or an
%       error. The test never starts a container: the function runs with a PATH that holds only
%       stub 'docker' and 'apptainer' shell scripts written to a tempname folder (plus copies of
%       'which' and 'id'). The stubs log their arguments, print an image id on request and fail
%       for chosen commands, so the test checks the exact commands, the build and skip
%       decisions, the warnings, the error handling, the batch file and the moved outputs. The
%       expected commands and file contents are derived from the source and its documentation
%       (no first-run values).
%
% Function under test:
%     src/analysis/persephone/runSeqC.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built folders in a tempname folder. The test needs
%     Linux or macOS (prepareTest('needsUnix', true)): the stubs are POSIX shell scripts. The
%     expected commands follow the branch of the operating system (user and group ids on
%     Linux, fixed id 42069 and user 0 on macOS).
%
% Coverage exemptions:
%     Lines 33, 34, 110, 112, 113, 114, 155, 157-162: macOS branch (reached by the test on
%     macOS; the reference machine runs Linux); lines 37, 38, 115, 117, 118, 119, 163-168:
%     Windows branch (the stubs need a POSIX shell); line 40: unreachable on any operating
%     system MATLAB supports (ismac, isunix or ispc is always true); lines 176, 178, 181,
%     182, 184: dead code (reconstructionDb is fixed to 'full_db' on line 172, so only the
%     'full_db' case runs).
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRunSeqC'));
cd(fileDir);

% declare the requirements of this test: no solver or MATLAB toolbox; the stub programs are
% POSIX shell scripts, so the test needs Linux or macOS
prepareTest('needsUnix', true);

%% hermetic set-up: stub programs, a SeqC repository folder and a PATH without real programs

sandboxDir = tempname;
stubDir = fullfile(sandboxDir, 'bin');
repoDir = fullfile(sandboxDir, 'seqc');
outputDir = fullfile(sandboxDir, 'final');
mkdir(stubDir);
mkdir(fullfile(repoDir, 'seqc_input'));
mkdir(fullfile(repoDir, 'seqc_output'));
% one 2048-byte input file for the directory size estimate
fid = fopen(fullfile(repoDir, 'seqc_input', 'reads.fastq'), 'w');
fwrite(fid, repmat('A', 1, 2048));
fclose(fid);

% files through which the stubs report and are controlled
stubFiles.log = fullfile(sandboxDir, 'calls.log');
stubFiles.fail = fullfile(sandboxDir, 'fail.txt');
stubFiles.image = fullfile(sandboxDir, 'imageId.txt');

% copies of 'which' (used by runSeqC to look for apptainer) and 'id' (user and group ids)
[whichStatus, whichPath] = system('command -v which');
[idStatus, idPath] = system('command -v id');
assert(whichStatus == 0 && idStatus == 0);
copyfile(strtrim(whichPath), fullfile(stubDir, 'which'));
copyfile(strtrim(idPath), fullfile(stubDir, 'id'));
fileattrib(fullfile(stubDir, 'which'), '+x', 'u');
fileattrib(fullfile(stubDir, 'id'), '+x', 'u');
writeStub(stubDir, 'docker', stubFiles);

% expected user and group ids (documented in the source: the ids of the user on Linux, the
% fixed id 42069 for the build and user 0 for the run on macOS) and the folder as the shell
% sees it
if ismac()
    userId = '42069';
    groupId = '42069';
    runUser = '0';
else
    [~, userId] = system('id -u');
    [~, groupId] = system('id -g');
    userId = strtrim(userId);
    groupId = strtrim(groupId);
    runUser = [userId ':' groupId];
end
cd(repoDir);
[~, shellRepoDir] = system('pwd');
shellRepoDir = strtrim(shellRepoDir);
cd(fileDir);

% the PATH seen by system() holds only the stub folder from here on
originalPath = getenv('PATH');
setenv('PATH', stubDir);

% expected commands of the Docker branch (memory 4, cpus 2, processes 3)
mounts = sprintf(['--mount type=bind,src=%s/seqc_input,dst=/home/seqc_user/seqc_project/step0_data_in ' ...
    '--mount type=bind,src=%s/seqc_output,dst=/home/seqc_user/seqc_project/final_reports ' ...
    '--mount type=bind,src=%s/seqc_proc,dst=/DB'], shellRepoDir, shellRepoDir, shellRepoDir);
hardwareArgs = '--build-arg varg_cpu_max=2 --build-arg varg_mem_max=4 --build-arg varg_proc_max=3';
dockerBuild = sprintf('docker build -t dock_seqc --ulimit nofile=65536:65536 %s --build-arg USER_UID=%s --build-arg USER_GID=%s .', ...
    hardwareArgs, userId, groupId);
dockerMain = sprintf('docker run --tty --user %s --rm --memory=4g --cpus=2 %s dock_seqc /bin/bash', ...
    runUser, mounts);
dbArgs = 'BASH_seqc_makedb.sh -s host_kd_hsapcontam -s tool_k2_agora2apollo';
pipelineArgs = 'BASH_seqc_mama.sh -i step0_data_in/ -n sample01 -r SR -s 0 -d host_kd_hsapcontam -d tool_k2_agora2apollo';
apptainerBuild = sprintf('apptainer build --fakeroot --bind=%s:/tmp %s apter_seqc.sif Apptainer.def', getenv('TMPDIR'), hardwareArgs);
apptainerMain = sprintf('apptainer exec --cwd /home/seqc_user/seqc_project --writable-tmpfs --no-mount tmp --no-home -e %s apter_seqc.sif /bin/bash', mounts);

%% Docker, image missing: build, help, database and pipeline commands, outputs moved

% the debug and keep flags add -b and -k to the pipeline command; the output folder does
% not exist yet and is created; apptainer is not installed and not requested (no warning)
resetCase(repoDir, outputDir, stubFiles, {}, '');
writeTextFile(fullfile(repoDir, 'seqc_output', 'taxa_profile.txt'), 'taxon reads');
lastwarn('');
status = runSeqC(repoDir, outputDir, 'sample01', true, 4, 2, 3, true, false);
assert(status == 0);
assert(isempty(lastwarn));
assert(isequal(readLines(stubFiles.log), {'docker images -q dock_seqc'; dockerBuild; ...
    [dockerMain ' BASH_seqc_mama.sh -v']; [dockerMain ' ' dbArgs]; ...
    [dockerMain ' BASH_seqc_mama.sh -b -k -i step0_data_in/ -n sample01 -r SR -s 0 -d host_kd_hsapcontam -d tool_k2_agora2apollo']}));
% the output was moved, and the current folder is restored
assert(isfile(fullfile(outputDir, 'taxa_profile.txt')));
assert(~isfile(fullfile(repoDir, 'seqc_output', 'taxa_profile.txt')));
assert(strcmp(pwd, fileDir));

%% Docker, image present, apptainer installed but not requested, output folder present

% no build; the warning says Docker is used; no output file to move
writeStub(stubDir, 'apptainer', stubFiles);
resetCase(repoDir, outputDir, stubFiles, {}, '0123456789ab');
mkdir(outputDir);
lastwarn('');
status = runSeqC(repoDir, outputDir, 'sample01', false, 4, 2, 3, false, false);
assert(status == 0);
assert(strcmp(lastwarn, 'Apptainer is installed but not requested. Running Docker.'));
assert(isequal(readLines(stubFiles.log), {'docker images -q dock_seqc'; ...
    [dockerMain ' BASH_seqc_mama.sh -v']; [dockerMain ' ' dbArgs]; [dockerMain ' ' pipelineArgs]}));
assert(isempty(dir(fullfile(outputDir, '*.txt'))));
delete(fullfile(stubDir, 'apptainer'));

%% Docker build fails: error caught, status 1, no further command

resetCase(repoDir, outputDir, stubFiles, {'docker build'}, '');
status = runSeqC(repoDir, outputDir, 'sample01', false, 4, 2, 3, false, false);
assert(status == 1);
assert(isequal(readLines(stubFiles.log), {'docker images -q dock_seqc'; dockerBuild}));
assert(strcmp(pwd, fileDir));

%% help command fails (warning only), then the database setup fails (status 1)

resetCase(repoDir, outputDir, stubFiles, {'BASH_seqc_mama.sh -v', 'BASH_seqc_makedb.sh'}, '0123456789ab');
lastwarn('');
status = runSeqC(repoDir, outputDir, 'sample01', false, 4, 2, 3, false, false);
assert(status == 1);
assert(startsWith(lastwarn, 'MAMA test failed:'));
assert(isequal(readLines(stubFiles.log), {'docker images -q dock_seqc'; ...
    [dockerMain ' BASH_seqc_mama.sh -v']; [dockerMain ' ' dbArgs]}));
% the output folder is not created after an error
assert(~isfolder(outputDir));

%% the pipeline command fails: status 1

resetCase(repoDir, outputDir, stubFiles, {'BASH_seqc_mama.sh -i'}, '0123456789ab');
status = runSeqC(repoDir, outputDir, 'sample01', false, 4, 2, 3, false, false);
assert(status == 1);
assert(isequal(readLines(stubFiles.log), {'docker images -q dock_seqc'; ...
    [dockerMain ' BASH_seqc_mama.sh -v']; [dockerMain ' ' dbArgs]; [dockerMain ' ' pipelineArgs]}));

%% Apptainer requested and installed, no image: the image is built, then the commands run

writeStub(stubDir, 'apptainer', stubFiles);
resetCase(repoDir, outputDir, stubFiles, {}, '');
writeTextFile(fullfile(repoDir, 'seqc_output', 'KB_mapped.txt'), 'taxon reads');
lastwarn('');
status = runSeqC(repoDir, outputDir, 'sample01', false, 4, 2, 3, false, true);
assert(status == 0);
assert(isempty(lastwarn));
assert(isequal(readLines(stubFiles.log), {apptainerBuild; [apptainerMain ' BASH_seqc_mama.sh -v']; ...
    [apptainerMain ' ' dbArgs]; [apptainerMain ' ' pipelineArgs]}));
assert(isfile(fullfile(outputDir, 'KB_mapped.txt')));

%% Apptainer image build fails: only a warning, the commands still run

resetCase(repoDir, outputDir, stubFiles, {'apptainer build'}, '');
lastwarn('');
status = runSeqC(repoDir, outputDir, 'sample01', false, 4, 2, 3, false, true);
assert(status == 0);
assert(startsWith(lastwarn, 'Apptainer build failed:'));
assert(isequal(readLines(stubFiles.log), {apptainerBuild; [apptainerMain ' BASH_seqc_mama.sh -v']; ...
    [apptainerMain ' ' dbArgs]; [apptainerMain ' ' pipelineArgs]}));

%% Apptainer image present: the build is skipped

resetCase(repoDir, outputDir, stubFiles, {}, '');
writeTextFile(fullfile(repoDir, 'apter_seqc.sif'), 'image');
status = runSeqC(repoDir, outputDir, 'sample01', false, 4, 2, 3, false, true);
assert(status == 0);
assert(isequal(readLines(stubFiles.log), {[apptainerMain ' BASH_seqc_mama.sh -v']; ...
    [apptainerMain ' ' dbArgs]; [apptainerMain ' ' pipelineArgs]}));
delete(fullfile(repoDir, 'apter_seqc.sif'));
delete(fullfile(stubDir, 'apptainer'));

%% Apptainer requested but not installed: a Slurm batch file is written, status 1

resetCase(repoDir, outputDir, stubFiles, {}, '');
lastwarn('');
status = runSeqC(repoDir, outputDir, 'sample01', true, 4, 2, 3, true, true);
assert(status == 1);
assert(strcmp(lastwarn, 'Apptainer is requested but not installed. Writing batch file.'));
% no program is called, and the batch file holds the documented directives and commands
assert(~isfile(stubFiles.log));
batchMounts = ['--mount type=bind,src=$(pwd)/seqc_input,dst=/home/seqc_user/seqc_project/step0_data_in ' ...
    '--mount type=bind,src=$(pwd)/seqc_output,dst=/home/seqc_user/seqc_project/final_reports ' ...
    '--mount type=bind,src=$(pwd)/seqc_proc,dst=/DB'];
batchMain = ['apptainer exec --cwd /home/seqc_user/seqc_project --writable-tmpfs --no-mount tmp --no-home -e ' ...
    batchMounts ' apter_seqc.sif /bin/bash'];
expectedBatch = {'#!/bin/bash'; '# batch_run_seqc.sh'; '#'; ...
    '# Batch script to build and run SeqC on an HPC.'; ...
    '# This script accommodates the Apptainer environment.'; '# Part of the Persephone workflow.'; ...
    '# Use at your own risk, have fun, be cool'; '#'; ...
    '# Slurm directives for cluster job submission. '; ...
    '# Adjust the account, time, and resources as necessary.'; '#SBATCH --job-name=seqc_HPC'; ...
    '#SBATCH --account=project_42069'; '#SBATCH --time=02:00:00'; '#SBATCH --mem=4G'; ...
    '#SBATCH --cpus-per-task=2'; '#SBATCH --gres=nvme:50'; '#'; '# BUILD'; ...
    ['srun apptainer build --fakeroot --bind="$TMPDIR:/tmp" ' hardwareArgs ' apter_seqc.sif Apptainer.def']; ...
    '#'; '# RUN'; '# Create database'; ...
    ['srun ' batchMain ' BASH_seqc_makedb.sh -s "host_kd_hsapcontam" -s "tool_k2_agora2apollo"']; ...
    '# Run SeqC'; ...
    ['srun ' batchMain ' BASH_seqc_mama.sh -b -k -i "step0_data_in/" -n "sample01" -r "SR" -s 0 -d "host_kd_hsapcontam" -d "tool_k2_agora2apollo"']; ...
    '#EoB'};
assert(isequal(readLines(fullfile(repoDir, 'batch_run_seqc.sh')), expectedBatch));
assert(strcmp(pwd, fileDir));
delete(fullfile(repoDir, 'batch_run_seqc.sh'));

%% SeqC outputs waiting in seqc_output (KB_S*.txt): the pipeline is skipped, outputs moved

resetCase(repoDir, outputDir, stubFiles, {}, '');
writeTextFile(fullfile(repoDir, 'seqc_output', 'KB_S1.txt'), 'taxon reads');
status = runSeqC(repoDir, outputDir, 'sample01', false, 4, 2, 3, false, false);
assert(status == 0);
assert(~isfile(stubFiles.log));
assert(isfile(fullfile(outputDir, 'KB_S1.txt')));

%% SeqC outputs already in the output folder: the pipeline is skipped

resetCase(repoDir, outputDir, stubFiles, {}, '');
mkdir(outputDir);
writeTextFile(fullfile(outputDir, 'KB_S2.txt'), 'taxon reads');
status = runSeqC(repoDir, outputDir, 'sample01', false, 4, 2, 3, false, false);
assert(status == 0);
assert(~isfile(stubFiles.log));
assert(isfile(fullfile(outputDir, 'KB_S2.txt')));

%% clean up: restore the PATH, remove the temporary files and return to the original folder

setenv('PATH', originalPath);
rmdir(sandboxDir, 's');
cd(currentDir)

function writeStub(stubDir, programName, stubFiles)
% write an executable stub that logs '<programName> <arguments>', prints the image id of
% stubFiles.image for 'images' and exits with 1 when '<programName> <arguments>' contains a line of
% stubFiles.fail (only shell built-ins are used, the PATH holds no other program)
stubLines = {'#!/bin/sh'; ...
    sprintf('echo "%s $*" >> "%s"', programName, stubFiles.log); ...
    'if [ "$1" = "images" ]; then'; ...
    sprintf('  if [ -f "%s" ]; then read imageId < "%s"; echo "$imageId"; fi', stubFiles.image, stubFiles.image); ...
    '  exit 0'; 'fi'; ...
    sprintf('if [ -f "%s" ]; then', stubFiles.fail); ...
    '  while read pattern; do'; ...
    sprintf('    case "%s $*" in *"$pattern"*) echo "%s stub failure"; exit 1;; esac', programName, programName); ...
    sprintf('  done < "%s"', stubFiles.fail); 'fi'; 'exit 0'};
stubFile = fullfile(stubDir, programName);
writeTextFile(stubFile, stubLines);
fileattrib(stubFile, '+x', 'u');
end

function resetCase(repoDir, outputDir, stubFiles, failPatterns, imageId)
% empty the log, seqc_output and the output folder; set the failing commands and image id
if isfile(stubFiles.log)
    delete(stubFiles.log);
end
rmdir(fullfile(repoDir, 'seqc_output'), 's');
mkdir(fullfile(repoDir, 'seqc_output'));
if isfolder(outputDir)
    rmdir(outputDir, 's');
end
if isfile(stubFiles.fail)
    delete(stubFiles.fail);
end
if ~isempty(failPatterns)
    writeTextFile(stubFiles.fail, failPatterns);
end
if isfile(stubFiles.image)
    delete(stubFiles.image);
end
if ~isempty(imageId)
    writeTextFile(stubFiles.image, imageId);
end
end

function writeTextFile(fileName, textLines)
% write each line followed by a newline
fid = fopen(fileName, 'w');
fprintf(fid, '%s\n', string(textLines));
fclose(fid);
end

function textLines = readLines(fileName)
% lines of a text file as a column cell array (no trailing empty line)
textLines = cellstr(splitlines(strip(fileread(fileName), 'right', newline)));
end
