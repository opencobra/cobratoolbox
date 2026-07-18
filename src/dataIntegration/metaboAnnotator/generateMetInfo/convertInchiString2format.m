function [result] = convertInchiString2format(inchiString, format)
% Converts an InChI string into a given format (either inchiKey or smiles)
% It relies on obabel (Open Babel) being installed. Installation on mac with
% Homebrew: `brew install open-babel`.
%
% USAGE:
%
%    [result] = convertInchiString2format(inchiString, format)
%
% INPUTS:
%    inchiString:    InChI string to be converted
%    format:         Target format, either 'inchiKey' or 'smiles'
%
% OUTPUTS:
%    result:         Converted InChI string in the format defined by `format`
%
% .. Author: - Ines Thiele 2020/2021

if strcmp(format,'inchiKey')
    if ismac
        [status, result]=system(strcat('/usr/local/bin/obabel -:"',inchiString,'" -i inchi -o inchikey'));
    else
        [status, result]=system(strcat('obabel -:"',inchiString,'" -i inchi -o inchikey'));
    end
    result = regexprep(result,'1 molecule converted','');
    result = regexprep(result,'\n','');
    if strfind(result,'Missing or unknown output file')
        result = NaN;
    end
elseif  strcmp(format,'smiles')
    % writes smiles in canonical form
    % (http://openbabel.org/docs/2.3.0/FileFormats/SMILES_format.html#write-options)
    if ismac
        [status, result]=system(strcat('/usr/local/bin/obabel -:"',inchiString,'" -i inchi -o smiles -xc'));
    else
        [status, result]=system(strcat('obabel -:"',inchiString,'" -i inchi -o smiles -xc'));
    end
    result = regexprep(result,'1 molecule converted','');
    result = regexprep(result,'\n','');
    if strfind(result,'Missing or unknown output file')
        result = NaN;
    end
end