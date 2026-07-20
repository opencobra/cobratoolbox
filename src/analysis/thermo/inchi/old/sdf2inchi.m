function [inchi, metList] = sdf2inchi(sdfFileName, options)
% Convert metabolite structures in an SDF to a cell array of InChI strings with OpenBabel
%
% USAGE:
%
%    [inchi, metList] = sdf2inchi(sdfFileName, options)
%
% INPUT:
%    sdfFileName:    path to the SDF file
%
% OPTIONAL INPUT:
%    options:        write options for the InChI strings (see the InChI
%                    documentation); if omitted, standard InChI is written
%
% OUTPUTS:
%    inchi:          cell array of InChI strings for the metabolites in the SDF
%    metList:        cell array of metabolite identifiers (first line of each molfile
%                    in the SDF); empty unless the write option `t` is used (`-xt`)
%
% .. Author: - Hulda SH, Nov. 2012

% Check inputs
if ~strcmp(sdfFileName(end-3:end),'.sdf')
    sdfFileName = [sdfFileName '.sdf'];
end

if ~exist('options','var')
    options = [];
end
if ~isempty(options)
   options = [' ' strtrim(options)]; 
end

% Convert to InChI with OpenBabel
[success,result] = system(['babel ' sdfFileName ' -oinchi' options]);

% Parse output from OpenBabel
if success == 0
    result = regexp(result,'InChI=[^\n]*\n','match');
    result = result';
    result = strtrim(result);
    
    [inchi,metList] = strtok(result);
    inchi = strtrim(inchi);
    metList = strtrim(metList);
    if isempty(inchi)
            [success,result] = system(['babel ' sdfFileName ' -oinchi' options])
        fprintf('%s\n','If you get a ''not found'' message from the call to Babel, make sure that Matlab''s LD_LIBRARY_PATH is edited to include correct system libraries. See initVonBertylanffy')
        error('Conversion to InChI not successful. Make sure OpenBabel is installed correctly.\n')
    end
else
    [success,result] = system(['babel ' sdfFileName ' -oinchi' options])
    fprintf('%s\n','If you get a ''not found'' message from the call to Babel, make sure that Matlab''s LD_LIBRARY_PATH is edited to include correct system libraries. See initVonBertylanffy')
    error('Conversion to InChI not successful. Make sure OpenBabel is installed correctly.\n')
end

if size(inchi,2) > size(inchi,1)
    inchi = inchi';
end
if size(metList,2) > size(metList,1)
    metList = metList';
end
