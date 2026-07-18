function [outFile] = getMolFileFromDrugbank(metAbbr, drugbank, directory)
% Connects to DrugBank and retrieves the mol file for a metabolite
%
% The retrieved mol file is saved in the specified directory under the given
% metAbbr name. Two DrugBank endpoints are tried, for metabolites and for small
% molecule drugs respectively:
% https://go.drugbank.com/structures/metabolites/DBMET01243.mol
% https://go.drugbank.com/structures/small_molecule_drugs/DB05478.mol
%
% USAGE:
%
%    [outFile] = getMolFileFromDrugbank(metAbbr, drugbank, directory)
%
% INPUTS:
%    metAbbr:      Metabolite abbreviation
%    drugbank:     DrugBank ID
%    directory:    Full path where the mol files should be saved (without final /)
%
% OUTPUTS:
%    outFile:      Full path to the saved mol file, or '' if retrieval failed
%
% .. Author: - Ines Thiele, 09/2021

mkdir(directory);
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