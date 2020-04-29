function [EFMRxns, EFMFluxes] = efmImport(EFMfileLocation, EFMFileName, EFMFluxfileLocation, EFMFluxFileName)
% This function reads the file containing all EFMs
%
% USAGE:
%    [EFMRxns, EFMFluxes] = importEFMs(EFMfileLocation, EFMFileName, EFMFluxfileLocation, EFMFluxFileName);
%    
% INPUTS:
%    EFMfileLocation:    location of the file containing all EFMs
%    EFMFileName:        name of the file containing all EFMs <name.txt>
%
% OPTIONAL INPUTS:
%    EFMFluxfileLocation:    location of the file containing relative fluxes of EFMs
%    EFMFluxFileName:        name of the file containing relative fluxes of EFMs <name.txt>
%
% OUTPUTS:
%    EFMRxns:    matlab array containing reactions in EFMs. 
%                Each row corresponds to an EFM and contains indices of reactions active in the EFM
%
% OPTIONAL OUTPUTS:
%    EFMFluxes:    matlab array containing reaction fluxes in EFMs. 
%                  rows = EFMs and columns = reactions. Each entry contains
%                  (relative) fluxes of reactions active in that EFM, zeros
%                  otherwise
%
% EXAMPLE:
%    EFMRxns = importEFMs('C;/Analysis/', 'testEFMs.txt'); 
%    EFMRxns = importEFMs('', 'test.txt'); % when the file is in the current directory
%    [EFMRxns, EFMFluxes] = importEFMs('C;/Analysis/', 'testEFMs.txt', 'C;/Analysis/', 'testFluxes.txt'); ; % with optional inputs
%
% .. Author: Last modified: Chaitra Sarathy, 1 Oct 2019

if nargin < 3
    EFMFluxfileLocation = '';
    EFMFluxFileName = '';
end

fid_EFM = fopen([EFMfileLocation EFMFileName]);
    
data = fgetl(fid_EFM);    
numEFMs = 1;
while ischar(data)
    temp = str2num(data);
    EFMRxns(numEFMs,1:size(temp, 2)) = temp;
    data = fgetl(fid_EFM);
    numEFMs = numEFMs+1;
end
fclose(fid_EFM);

if ~isempty(EFMFluxfileLocation) && ~isempty(EFMFluxFileName)
    fid_flux = fopen([EFMFluxfileLocation EFMFluxFileName]);
    
    data_flux = fgetl(fid_flux);    
    numflux = 1;
    while ischar(data_flux)
        temp = str2num(data_flux);
        EFMFluxes(numflux,1:size(temp, 2)) = temp;
        data_flux = fgetl(fid_flux);
        numflux = numflux+1;
    end
    fclose(fid_flux);
end


end

