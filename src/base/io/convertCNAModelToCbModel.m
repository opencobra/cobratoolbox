function model = convertCNAModelToCbModel(cnaModel)
% Function uses the CNAcna2cobra from CellNetAnalyzer to
% convert a CNA model to a COBRA model
%
% USAGE:
%
%    model = convertCNAModelToCbModel(cnaModel)
%
% INPUT:
%
%    cnaModel:   cnap is a CNA mass-flow project structure
%
% OUTPUT:
%
%    model:      COBRA model structure
%
% Note:
%
% This functions requires a working installation of CellNetAnalyzer
% which can be downloaded from https://www2.mpi-magdeburg.mpg.de/projects/cna/cna.html
%

    model = CNAcna2cobra(cnaModel);

end
