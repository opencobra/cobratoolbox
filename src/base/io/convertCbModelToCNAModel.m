function cnaModel = convertCbModelToCNAModel(model, printLevel)
% Function uses the CNAcobra2cna from CellNetAnalyzer to
% convert a COBRA model to a CNA model
%
% USAGE:
%
%    cnaModel = convertCNAModelToCbModel(model, printLevel)
%
% INPUT:
%
%    model:         COBRA model structure
%    printLevel:    verbose level (default: 1)
%
% OUTPUT:
%
%    cnaModel:      cnaModel is a CNA mass-flow project structure
%
% NOTE:
%
%    This functions requires a working installation of CellNetAnalyzer
%    which can be downloaded from https://www2.mpi-magdeburg.mpg.de/projects/cna/cna.html
%

    if nargin < 2  % set default printLevel
        printLevel = 1;
    end

    % check if CNA is properly installed
    status = checkCNAinstallation(printLevel);

    if status
        cnaModel = CNAcobra2cna(model);
    end
end
