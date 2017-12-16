function adaptMacPath()
% Adapts the path for binaries on a mac with Sierra/High Sierra or higher
% and Anything below.
%
% USAGE:
%     adaptMacPath();
%

global CBTDIR;
oldMac = false;

[status,macVer] = system('sw_vers');
if status ~= 0
    oldMac = true;
else
    try
        macVer = strsplit(macVer,'\n');
        macVer = macVer{2};
        macVer = strsplit(macVer,':');
        macVer = str2double(macVer{2});
        if macVer < 10.12 %Lower than Sierra
            oldMac = true;
        end
    catch
        oldMac = true;
    end
end

macBinaryPath = [CBTDIR filesep 'binary' filesep 'maci64' filesep 'bin'];

% set the current and remove the other path.
if oldMac
    addpath([macBinaryPath filesep 'preSierra']);
    rmpath([macBinaryPath filesep 'postSierra']);
else
    addpath([macBinaryPath filesep 'postSierra']);
    rmpath([macBinaryPath filesep 'preSierra']);
end
end