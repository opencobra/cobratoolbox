function model = convertCNAModelToCbModel(cnaModel, printLevel)
% Function uses the CNAcna2cobra from CellNetAnalyzer to
% convert a CNA model to a COBRA model
%
% USAGE:
%
%    model = convertCNAModelToCbModel(cnaModel, printLevel)
%
% INPUT:
%
%    cnaModel:     CNA mass-flow project structure
%    printLevel:   verbose level (default: 1)
%
% OUTPUT:
%
%    model:        COBRA model structure
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
        model = CNAcna2cobra(cnaModel);
    end
end
