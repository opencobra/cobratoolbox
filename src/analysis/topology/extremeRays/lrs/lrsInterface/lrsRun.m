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

%remove the suffix in case it is present
if contains(modelName,'.ine') || contains(modelName,'.ext')
    if contains(modelName,'.ext')
        modelName = strrep(modelName,'.ext','');
    end
    if contains(fileName,'.ine')
        modelName = strrep(modelName,'.ine','');
    end
end


if param.redund==0
    %remove all redundant halfspaces
    %http://cgm.cs.mcgill.ca/%7Eavis/C/lrslib/USERGUIDE.html#redopt
    redundCmd = ['redund ' int2str(0) ' ' int2str(0)]; 
end

if isunix
    [status, result] = system('which lrs');
    if ~isempty(result)
        suffix = '';
        if param.positivity
            suffix = [suffix 'pos_'];
        else
            suffix = [suffix 'neg_'];
        end
        if param.inequality
            suffix = [suffix 'ineq'];
        else
            suffix = [suffix 'eq'];
        end
        
        if param.shellScript
            % call lrs through a bash script and wait until extreme pathways have been calculated
            systemCallText = ['sh ' pwd filesep modelName '_' suffix '.sh'];
            [status, result] = system(systemCallText);
            if status == 0
                error(['Failure to run Bash script ' pwd filesep modelName '_' suffix '.sh']);
            end
        else
            if param.facetEnumeration
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
            if param.facetEnumeration
                if param.redund == 0
                    fileNameIn = fileNameOut;
                    fileNameOut = [modelName '_noR.ine'];
                    uselrsRedundOption =0;
                    
                    %read the number of rows of the file and replace the ****
                    fid = fopen([pwd filesep fileNameIn],'r+');
                    countRows = 0;
                    while 1
                        tline = fgetl(fid);
                        if countRows ~=0
                            countRows = countRows + 1;
                        end
                        if strcmp(tline, 'begin')
                            countRows = 1;
                        elseif ~ischar(tline)
                            error('Could not read lrs output file.');
                        end
                        if strcmp(tline,'end')
                            if uselrsRedundOption
                            [status, result] =  system(['sed -i ''s/end/end\nredund 0 0/g'' ' pwd filesep fileNameIn]);
                            end
                            break
                        end
                    end
                    nRows = countRows -3;
                    
                    %open the file and write the number of rows and columns
                    %The procedure to change the text in files under Linux/Unix using sed:
                    %Use Stream EDitor (sed) as follows:
                    %sed -i 's/old-text/new-text/g' input.txt
                    %The s is the substitute command of sed for find and replace
                    %It tells sed to find all occurrences of ‘old-text’ and replace with ‘new-text’ in a file named input.txt
                    [status, result] =  system(['sed -i ''s/\*\*\*\*\*/' int2str(nRows) '/g'' ' pwd filesep fileNameIn]);
                    if status == 1
                        disp(result)
                        error(['sed failed on file ' pwd filesep fileNameIn]);
                    end
                                                
                    if uselrsRedundOption
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


