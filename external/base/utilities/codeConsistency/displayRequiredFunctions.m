function displayRequiredFunctions(fullFileName)
% List required files and toolboxes.  Displays them in the command window or console window (if deployed).
% Sample call
% 		fullFileName = [mfilename('fullpath'), '.m'];
%       DisplayRequiredFunctions(fullFileName)
% It takes a long time to run so that's why I only do it in the development environment.
try
	if ~isdeployed
		[~, baseFileNameNoExt, ext] = fileparts(fullFileName);
		baseFileName = [baseFileNameNoExt, '.m'];
		[requiredFileList, toolboxList] = matlab.codetools.requiredFilesAndProducts(fullFileName);
		fprintf('Required m-files for %s:\n', baseFileName);
		for k = 1 : length(requiredFileList)
			fprintf('    %s\n', requiredFileList{k});
		end
		fprintf('Required MATLAB Toolboxes for %s:\n', baseFileName);
		for k = 1 : length(toolboxList)
			fprintf('    %s\n', toolboxList(k).Name);
		end
	end
catch ME
end


