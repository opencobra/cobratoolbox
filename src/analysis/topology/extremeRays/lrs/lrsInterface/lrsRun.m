function fileNameOut = lrsRun(modelName, param)
% Runs lrs in the command line either using a shell script or launched
% directly from within Matlab.
%
% USAGE:
%
%    fileNameOut = lrsRun(modelName, param)
%
% INPUTS:
%    modelName:      name of the file to give as input to lrs
%
%    param:          parameter structure with the following fields:
%
%                      * .positivity - {0, 1} if 1, then positive orthant base
%                      * .inequality - {0, 1} if 1, then represent as two inequalities rather than a single equality
%                      * .shellScript - {0, 1} if 1, then lrs is run through a bash script
%                      * .facetEnumeration - {0, 1} if 1, run facet enumeration, otherwise vertex enumeration
%                      * .redund - {0, 1} if 0, then remove redundant inequalities from the
%                        facets (facet enumeration), with the redund option of lrs
%                        (lrslib 7 or later); the output file then takes the suffix _noR
%
% OUTPUTS:
%    fileNameOut:    full path to the output file produced by lrs
%
% NOTE:
%
%    Any non-zero exit status of lrs or the shell script (for example 127 when the lrs
%    executable cannot start) raises the error `lrsRun:commandFailed`, whose message
%    names the command, its exit status and its output. In shell-script mode, exit
%    status 0 is success and `fileNameOut` is returned as in direct mode.
%    (Feature 20261026-220121-fix-ci-test-failures, October 2026. Before, only exit
%    status 1 was treated as a failure, and shell-script mode treated success as
%    failure.)
%
%    With redund = 0 and facet enumeration, lrs is run a second time, on a temporary
%    copy of its facet output that ends with the option line `redund 0 0`; the copy is
%    removed afterwards. (Feature 20261120-140123-lrsrun-without-redund, November 2026,
%    Constitution Principle XI. Before, the separate program redund was run, which
%    lrslib 7 no longer needs and which COBRA's lrs for Linux does not include.)

% Ronan Fleming 2021

if ~exist('param','var')
    param = struct();
end
if ~isfield(param,'positivity')
    param.positivity  = 0;
end
if ~isfield(param,'inequality')
    param.inequality  = 0;
end
if ~isfield(param,'shellScript')
    param.shellScript  = 0;
end
if ~isfield(param,'facetEnumeration')
    %assume vertex enumeration, unless specified that it is facet enumeration
    param.facetEnumeration  = 1;
end
if ~isfield(param,'redund')
    param.redund  = 1;
end

if contains(modelName,'.ine')
    param.facetEnumeration  = 0;
end



if contains(modelName,'.ine') || contains(modelName,'.ext')
    modelName = strrep(modelName,'.ine','');
    modelName = strrep(modelName,'.ext','');
else
    if param.inequality == 0
%         if param.positivity == 0
%             modelName = [modelName '_pos_eq'];
%         else
%             modelName = [modelName '_neg_eq'];
%         end
    else
        if param.positivity == 1
            modelName = [modelName '_pos_ineq'];
        else
            modelName = [modelName '_neg_ineq'];
        end
    end
    if ~param.redund
        modelName = [modelName '_noR'];
    end
end

if param.facetEnumeration
    [status, result] = lrsSpecifyRows([modelName '.ext']);
else
    [status, result] = lrsSpecifyRows([modelName '.ine']);
end

if isunix
    [status, result] = system('which lrs');
    if ~isempty(result)
        if param.shellScript
            % call lrs through a bash script and wait until extreme pathways have been calculated
            systemCallText = ['sh ' pwd filesep modelName '.sh'];
            [status, result] = system(systemCallText);
            checkCommandStatus(status, result, systemCallText);
            if param.facetEnumeration
                fileNameOut = [modelName '.ine'];
            else
                fileNameOut = [modelName '.ext'];
            end
        else
            if param.facetEnumeration
                fileNameOut = [modelName '.ine'];
                % call lrs to compute halfspaces
                systemCallText = ['lrs ' pwd filesep modelName '.ext > ' pwd filesep fileNameOut];
                localCallText = ['lrs ' modelName '.ext > ' fileNameOut];
                disp(localCallText)
            else
                fileNameOut = [modelName '.ext'];
                % call lrs to compute vertices
                systemCallText = ['lrs ' pwd filesep modelName '.ine > ' pwd filesep fileNameOut];
                localCallText = ['lrs ' modelName '.ine > ' fileNameOut];
                disp(localCallText)
            end
            [status, result] = system(systemCallText);
            checkCommandStatus(status, result, systemCallText);
            if param.facetEnumeration
                if param.redund == 0
                    fileNameIn = fileNameOut;
                    fileNameOut = [modelName '_noR.ine'];

                    [status, result] = lrsSpecifyRows(fileNameIn);

                    % remove all redundant halfspaces with the redund option of lrs
                    % (http://cgm.cs.mcgill.ca/%7Eavis/C/lrslib/USERGUIDE.html#redopt):
                    % rows 0 to 0 means every row. The option goes after "end" in a
                    % temporary copy, so the facet output fileNameIn is not modified
                    optionFile = [tempname '.ine'];
                    removeOptionFile = onCleanup(@() deleteIfPresent(optionFile));
                    % a newline before the option puts it on a line of its own even when the
                    % facet output does not end with one (lrs ignores the blank line)
                    fid = fopen(optionFile, 'w');
                    fprintf(fid, '%s\nredund 0 0\n', fileread(fileNameIn));
                    fclose(fid);
                    systemCallText = ['lrs ' optionFile ' > ' pwd filesep fileNameOut];
                    localCallText = ['lrs ' fileNameIn ' (with option redund 0 0) > ' fileNameOut];
                    disp(localCallText);
                    [status, result] = system(systemCallText);
                    checkCommandStatus(status, result, systemCallText);
                end
            end
        end
    else
        fprintf('lrs not installed or not in path\n');
    end
else
    fprintf('non unix machines not yet supported\n');
end
end

function deleteIfPresent(fileName)
% removes the temporary lrs input, if it was written
if isfile(fileName)
    delete(fileName);
end
end

function checkCommandStatus(status, result, systemCallText)
% any non-zero exit status is a failure (e.g. 127 when lrs cannot be executed), so stop
% before an empty or missing output file is read
if status ~= 0
    error('lrsRun:commandFailed', 'lrsRun: command "%s" failed with exit status %d.\nOutput: %s', ...
        systemCallText, status, strtrim(result));
end
end


