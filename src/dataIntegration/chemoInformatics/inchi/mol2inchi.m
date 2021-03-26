function [inchi, annotation] = mol2inchi(molFileName, options)
% Converts metabolite structures in a mol file to an InChI strings with OpenBabel.
% 
% An entry can be assigned an InChI identifier if it has an SDF file describing the structure and all of the following conditions hold:
% 
%     1. It does not contain an element that is not an atom. This is not common, but SDF files can contain non-atom elements (e.g., an electron or positron) or exotic atoms (e.g., muonium). These elements are not supported by InChI.
%     2. It does not contain an unknown or general atom. In addition to a symbol from the periodic table, an SDF file can also contain general elements, often denoted as A, Q, * or R.
%     3. It does not contain an R-group. Some atom of the structure may be aliased as an R-group, which indicates an undefined chemical group.
%     4. It does not contain an undefined charge. A valid SDF file cannot contain an undefined charge. However, if we convert an mmCIF file containing an undefined charge into an SDF file, the resulting SDF file is excluded.
%     5. It does not contain an unknown type of bond. This is not common, but an SDF file can contain an “any” bond, which does not specify the chemical type of the bond.
%     6. It is not a polymer with an unknown number of repeating monomers. Some part of the structure can be denoted as a repetitive part, but an InChI identifier cannot be generated if the number of repeats is not known.
% https://link.springer.com/article/10.1186/1758-2946-6-15
%
% USAGE:
%
%     [inchi, metAbbr] = mol2inchi(molFileName, options)
%
% INPUT:
%    molFileName:    MDL mole file name (inc path if not in pwd)
%
% OPTIONAL INPUTS:
%    options:        Write options for InChI strings. See InChI documentation
%                    for details. https://openbabel.org/docs/dev/FileFormats/InChI_format.html
%                    If no options are specified the function will output standard InChI.
%
% OUTPUTS:
%    inchi:          InChI (character array) for metabolites in the SDF file.
%    annotation:     Annotation in first line of molfile
%                    Will be empty unless write option `t` is used (i.e., options >= '-xt').
%

if ~strcmp(molFileName(end-3:end),'.mol') % Check inputs
    molFileName = [molFileName '.mol'];
end

if ~exist('options','var')
    options = '-xt';
end
if ~isempty(options)
   options = [' ' strtrim(options)];
end

% Convert to InChI with OpenBabel
[success,resultOri] = system(['obabel ' molFileName ' -oinchi' options]);

[filepath,name,ext] = fileparts(molFileName);

% Parse output from OpenBabel
inchi='';
annotation='';
if success == 0
    result = regexp(resultOri,'InChI=[^\n]*\n','match');
    if isempty(result)
        fprintf('%s\n',['mol2inchi: could not generate inchi for ' name])
        if contains(resultOri,'Alias R was not chemically interpreted')
            fprintf('%s\n','obabel: Alias R was not chemically interpreted')
        else
            if contains(resultOri,'Unknown element(s): Xx')
                fprintf('%s\n','obabel: Unknown element(s): Xx')
            else
                disp(resultOri)
            end
        end
    else
        if iscell(result)
            result=result{1};
        end
        result = strtrim(result);
        
        [inchi,annotation] = strtok(result);
        inchi = strtrim(inchi);
        
        annotation = strtrim(annotation);
        if length(annotation)==0
            fprintf('%s\n',['mol2inchi: no annotation in ' name])
        end
    end
else
    fprintf('%s\n','If you get a ''not found'' message from the call to Babel, make sure that Matlab''s LD_LIBRARY_PATH is edited to include correct system libraries. See initVonBertylanffy')
    error('Conversion to InChI not successful. Make sure OpenBabel is installed correctly.\n')
end

if size(inchi,1) > size(inchi,2)
    inchi = inchi';
end
