function cnaModel = convertCNAModelToCbModel(model)
% Function uses the CNAcobra2cna from CellNetAnalyzer to
% convert a COBRA model to a CNA model
%
% USAGE:
%
%    cnaModel = convertCNAModelToCbModel(model)
%
% INPUT:
%
%    model:      COBRA model structure
%
% OUTPUT:
%
%    cnaModel:   cnaModel is a CNA mass-flow project structure
%
% Note:
%
% This functions requires a working installation of CellNetAnalyzer
% which can be downloaded from https://www2.mpi-magdeburg.mpg.de/projects/cna/cna.html
%

    cnaModel = CNAcobra2cna(model);

end
