function [outFile] = getMolFileFromDrugbank(metAbbr,drugbank,directory)
% This function connects to drugbank and retrieves the mol file, which will be
% saved in the specified directory under the given metAbbr name
%
% INPUT
% metAbbr       Metabolite abbreviation
% drugbank      Drugbank ID
% directory     Full path where the mol files should be saved (without
%               final /)
%
%
% Ines Thiele, 09/2021

% get and save mol file
% https://go.drugbank.com/structures/metabolites/DBMET01243.mol
% https://go.drugbank.com/structures/small_molecule_drugs/DB05478.mol
try
    mkdir(directory);
catch
    directory = regexprep(directory,'^/','');
end
try
    url=strcat('https://go.drugbank.com/structures/metabolites/',drugbank,'.mol');
    outFile = websave([directory filesep metAbbr,'.mol'],url);
catch
    % add another try catch just in case that the link is dead
    try
        url=strcat('https://go.drugbank.com/structures/small_molecule_drugs/',drugbank,'.mol');
        outFile =  websave([directory filesep metAbbr,'.mol'],url);
    catch
        outFile = '';
    end
end