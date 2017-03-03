% demo : Compare the results of FindExtremeRay and the results of efmtool
%   (requires efmtool from http://www.csb.ethz.ch/people/tools/efmtool)
% 
%   $Revision: 0.0.1 $  $Date: 2012/06/25 $
% 
% example from "System Modeling in Cellular Biology: From Concepts to Nuts and 
% Bolts", section "Stoichiometric and Constraint Based Modeling", MIT Press
model.S = [
  1 , 0 , 0 , 0 ,-1 ,-1 ,-1 , 0 , 0 , 0
  0 , 1 , 0 , 0 , 1 , 0 , 0 ,-1 ,-1 , 0
  0 , 0 , 0 , 0 , 0 , 1 , 0 , 1 , 0 ,-1
  0 , 0 , 0 , 0 , 0 , 0 , 1 , 0 , 0 ,-1
  0 , 0 , 0 ,-1 , 0 , 0 , 0 , 0 , 0 , 1
  0 , 0 ,-1 , 0 , 0 , 0 , 0 , 0 , 1 , 1
  ];
model.revRxns = [0 1 0 0 0 0 0 1 0 0];

model.stoich = model.S;
model.reversibilities = model.revRxns;


v = findExtremePathway(model) 




if 0
    mnet = CalculateFluxModes(model);  % calculate EFMs using efmtool
    mnet.efms  % print efms
end



model2.S=  [-1     0       1 ;
             1      -1      0 ;
             0      1       -1 ];
 [x, output] = findExtremePool(model2)