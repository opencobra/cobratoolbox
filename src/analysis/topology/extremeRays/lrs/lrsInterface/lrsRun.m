function fileNameOut = lrsRun(modelName, param)
% Runs lrs in the command line either using a shell script or launched
% directly from within Matlab.
%
% USAGE:
%
%     fileNameOut = runLrs(modelName, positivity, inequality, shellScript)
%
% INPUTS:
%    modelName:      name of the file to give as input to lrs
%
%    param:         parameter structure with the following fields:
%    *.positivity:    if equals to 1, then positive orthant base
%    *.inequality:    if equals to 1, then represent as two inequalities rather than a single equality
%    *.shellScript:   if equals to 1, then lrs is run through a bash script
%    *.redund         if equals to 0, then remove redundant linear equalities 
%
% OUTPTS
% fileNameOut       full path to output file

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

if param.redund==0
    %remove all redundant halfspaces
    %http://cgm.cs.mcgill.ca/%7Eavis/C/lrslib/USERGUIDE.html#redopt
    redundCmd = ['redund ' int2str(0) ' ' int2str(0)]; 
end

if isunix
    [status, result] = system('which lrs');
    if ~isempty(result)
        if param.shellScript
            % call lrs through a bash script and wait until extreme pathways have been calculated
            systemCallText = ['sh ' pwd filesep modelName '.sh'];
            [status, result] = system(systemCallText);
            if status == 0
                error(['Failure to run Bash script ' pwd filesep modelName '.sh']);
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
            if status == 1
                error(['lsr failed on file ', pwd filesep modelName '.ine']);
            end
            if param.facetEnumeration
                if param.redund == 0
                    fileNameIn = fileNameOut;
                    fileNameOut = [modelName '_noR.ine'];
                    uselrsRedundOption =0;
                    
                    [status, result] = lrsSpecifyRows(fileNameIn);
                                        
                    if uselrsRedundOption
                        [status, result] =  system(['sed -i ''s/end/end\nredund 0 0/g'' ' fileNameIn]);
                        systemCallText = ['lrs ' pwd filesep fileNameIn ' > ' pwd filesep fileNameOut];
                        localCallText = ['lrs ' fileNameIn ' > ' fileNameOut];
                    else
                        systemCallText = ['redund ' pwd filesep fileNameIn ' > ' pwd filesep fileNameOut];
                        localCallText = ['redund ' fileNameIn ' > ' fileNameOut];
                    end
                    disp(localCallText);
                    [status, result] = system(systemCallText);
                    if status == 1
                        disp(result)
                        error(['lsr failed on file ', pwd filesep modelName '.ine']);
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


