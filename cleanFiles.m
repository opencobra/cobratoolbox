%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Purpose: Clean log and result files
% Author: Laurent Heiredt, LCSB
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Clear log files from the drivers directory
%D = dir('../drivers/*.log');
%nbFiles = numel(D);
%if(nbFiles > 0)
%  unix('sudo rm ../drivers/*.log');
%end

userInteraction = true;

% Clear previous log files in logFiles/
D = dir('../fastFVA/logFiles/*.log');
nbFiles = numel(D);
if(nbFiles > 0)
    fprintf('\n Number of files in logFiles/: %d\n', nbFiles);

    if userInteraction
      m=input('\n Do you want to clean all log files in logFiles/ ? - Y/N [Y]: ','s');
    end

    if m=='Y' || m =='y' || ~userInteraction
      unix('rm ../fastFVA/logFiles/*.log');
      fprintf(' >> All log files in logFiles/ removed.\n');
    end
else
    fprintf('\n The directory logFiles/ is empty.\n');
end

% Clear previous result files in results/
D = dir('../fastFVA/results/*.mat');
nbFiles = numel(D);
if(nbFiles > 0)
    fprintf('\n Number of files in results/: %d\n', nbFiles);
    
    if userInteraction
      m=input('\n Do you want to clean al results files in results/ ? - Y/N [Y]: ','s');
    end
    if m=='Y' || m =='y' || ~userInteraction
      unix('rm ../fastFVA/results/*.mat');
      fprintf(' >> All result files in results/ removed.\n');
    end
else
    fprintf('\n The directory results/ is empty.\n');
end

fprintf('\n');
