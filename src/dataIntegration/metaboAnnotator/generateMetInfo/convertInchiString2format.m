function [result] = convertInchiString2format(inchiString,format)
%% function [result] = convertInchiString2format(inchiString,format)
% This function converts an inchiString into a given format (either
% inchikey or smiles). It relies on obabel being installed.
% obabel installation on mac with home brew:
% brew install open-babel
%
% INPUT
% inchiString   inchiString
% format        either 'inchiKey' or 'smiles'
%
% OUTPUT
% result        converted inchiString in format as defined by 'format'
%
% Ines Thiele 2020/2021

% example conversion from inchi string to inchi key:
% Iness-MBP:~ inesthiele$ obabel -:"InChI=1S/C10H20O2/c1-2-3-4-5-6-7-8-9-10(11)12/h2-9H2,1H3,(H,11,12)/p-1" -i inchi -o inchikey
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