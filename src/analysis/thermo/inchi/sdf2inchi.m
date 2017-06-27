function [inchi,metList] = sdf2inchi(sdfFileName,options)
% Converts metabolite structures in an SDF to a cell array of InChI
% strings with OpenBabel.
% 
% [inchi,metList] = sdf2inchi(sdfFileName,options)
% 
% INPUTS
% sdfFileName   Path to SDF file.
% 
% OPTIONAL INPUTS
% options       Write options for InChI strings. See InChI documentation
%               for details. If no options are specified the function will
%               output standard InChI.
% 
% OUTPUTS
% inchi         Cell array of InChI strings for metabolites in the SDF file.
% metList       Cell array of metabolite identifiers (first line of each
%               molfile in SDF). Will be empty unless write option t is
%               used (i.e., options >= '-xt').
% 
% Hulda SH, Nov. 2012

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
