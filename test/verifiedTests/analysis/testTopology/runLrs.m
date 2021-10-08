function fileNameOut = runLrs(modelName, positivity, inequality, shellScript, facetEnumeration, redund)
% Runs lrs in the command line either using a shell script or launched
% directly from Matlab.
%
% USAGE:
%
%     runLrs(modelName, positivity, inequality, shellScript)
%
% INPUTS:
%    modelName:      name of the file to give as input to lrs
%    positivity:    if equals to 1, then positive orthant base
%    inequality:    if equals to 1, then use two inequalities rather than a single equality
%    shellScript:   if equals to 1, then lrs is run through a bash script
%

%assume vertex enumeration, unless specified that it is facet enumeration
if ~exist('facetEnumeration','var')
    if contains(fileName,'.ext')
        facetEnumeration = 1;
    else
        facetEnumeration = 0;
    end
end

if contains(modelName,'.ine') || contains(modelName,'.ext')
    if contains(modelName,'.ext')
        modelName = strrep(modelName,'.ext','');
    end
    if contains(fileName,'.ine')
        modelName = strrep(modelName,'.ine','');
    end
end

if ~exist('redund','var')
    redund = 1;
end
if redund ==0
    %remove all redundant halfspaces
    redund = 'redund 0 0'; 
end

if isunix
    [status, result] = system('which lrs');
    if ~isempty(result)
        suffix = '';
        if positivity
            suffix = [suffix 'pos_'];
        else
            suffix = [suffix 'neg_'];
        end
        if inequality
            suffix = [suffix 'ineq'];
        else
            suffix = [suffix 'eq'];
        end
        
        if shellScript
            % call lrs through a bash script and wait until extreme pathways have been calculated
            systemCallText = ['sh ' pwd filesep modelName '_' suffix '.sh'];
            [status, result] = system(systemCallText);
            if status == 0
                error(['Failure to run Bash script ' pwd filesep modelName '_' suffix '.sh']);
            end
        else
            if facetEnumeration
                fileNameOut = [modelName '.ine'];
                % call lrs to compute halfspaces
                systemCallText = ['lrs ' pwd filesep modelName '.ext > ' pwd filesep fileNameOut];
                localCallText = ['lrs ' modelName '.ext > ' fileNameOut];
                disp(localCallText)
            else
                fileNameOut = [modelName '_' suffix '.ext'];
                % call lrs to compute vertices
                systemCallText = ['lrs ' pwd filesep modelName '_' suffix '.ine > ' pwd filesep fileNameOut];
                localCallText = ['lrs ' modelName '_' suffix '.ine > ' fileNameOut];
                disp(localCallText)
            end
            [status, result] = system(systemCallText);
            if status == 1
                error(['lsr failed on file ', pwd filesep modelName '_' suffix '.ine']);
            end
            if facetEnumeration
                if redund == 0
                    fid = fopen(fileNameOut,'w');
                    while 1
                        tline = fgetl(fid);
                        if strcmp(tline, 'end')
                            fprintf(fid, '%s\n','redund 0 0');
                            fclose(fid)
                            break;
                        elseif ~ischar(tline)
                            error('Could not read lrs output file.');
                        end
                    end
                    fileNameIn = fileNameOut;
                    fileNameOut = [modelName '_noR.ine'];
                    systemCallText = ['lrs ' pwd filesep fileNameIn ' > ' pwd filesep fileNameOut];
                    [status, result] = system(systemCallText);
                    if status == 1
                        error(['lsr failed on file ', pwd filesep modelName '_' suffix '.ine']);
                    end
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


