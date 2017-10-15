function FluxCompare = compareMatricies(CMODEL, Cspawn)
% Creates a structure with the matrices before and after merging. Useful
% for comparing how successful merging was.  Called by `mergeModelsBorg`.
%
% USAGE:
%
%    FluxCompare = compareMatricies(CMODEL, Cspawn)
%
% INPUTS:
%    CMODEL:         model in cobra standard
%    Cspawn:         `Cmodel` after it has been removed from the` `TmodelC`
%
% OUTPUTS:
%    FluxCompare:    structure with matrices
%
% Please cite:
% `Sauls, J. T., & Buescher, J. M. (2014). Assimilating genome-scale
% metabolic reconstructions with modelBorgifier. Bioinformatics
% (Oxford, England), 30(7), 1036?8`. http://doi.org/10.1093/bioinformatics/btt747
%
% ..
%    Edit the above text to modify the response to help addMetInfo
%    Last Modified by GUIDE v2.5 06-Dec-2013 14:19:28
%    This file is published under Creative Commons BY-NC-SA.
%
%    Correspondance:
%    johntsauls@gmail.com
%
%    Developed at:
%    BRAIN Aktiengesellschaft
%    Microbial Production Technologies Unit
%    Quantitative Biology and Sequencing Platform
%    Darmstaeter Str. 34-36
%    64673 Zwingenberg, Germany
%    www.brain-biotech.de

[FluxCompare.CrxnsSort, FluxCompare.CrxnsSorti] = sort(CMODEL.rxnID) ; % Sort rxns and mets so they are in the same order.
[FluxCompare.SrxnsSort, FluxCompare.SrxnsSorti] = sort(Cspawn.rxnID) ;
[FluxCompare.CmetsSort, FluxCompare.CmetsSorti] = sort(CMODEL.metID) ;
[FluxCompare.SmetsSort, FluxCompare.SmetsSorti] = sort(Cspawn.metID) ;

% Create sorted S matricies for Cmodel before and after it was added.
FluxCompare.CmodelS = CMODEL.S(FluxCompare.CmetsSorti, ...
    FluxCompare.CrxnsSorti) ;
FluxCompare.CspawnS = Cspawn.S(FluxCompare.SmetsSorti, ...
    FluxCompare.SrxnsSorti) ;

try
    % Find the differences between the matricies.
    FluxCompare.diffS = abs(FluxCompare.CmodelS) - ...
        abs(FluxCompare.CspawnS) ;
catch
    % matricies are likely different sizes
    return
end    

% find protons and water
CMODELprotonpos = logical(strncmpi(FluxCompare.CmetsSort, 'h[', 2) + ...
    strncmpi(FluxCompare.CmetsSort, 'h+[', 3) + ...
    strncmpi(FluxCompare.CmetsSort, 'c0065[', 6) + ...
    strncmpi(FluxCompare.CmetsSort, 'proton[', 7) ) ;

CMODELwaterpos = logical(strncmpi(FluxCompare.CmetsSort, 'h2o[', 4) + ...
    strncmpi(FluxCompare.CmetsSort, 'water[', 6) ) ;

ignorepos = logical(CMODELprotonpos + CMODELwaterpos) ;
% ignore protons and water
FluxCompare.diffS(ignorepos, :) = 0 ;

end
