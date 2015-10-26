function [vfN,vfR,vrN,vrR,vnetN,vnetR,uL,uC,u0L,u0C,lnxL,lnxC]=projectOntoSubspace(modelT,vf,vr,vnet,u,u0,lnx)
% project flux, net flux, potential and logarithmic concentration onto
% their respective subspaces of the internal reaction stoichiometric matrix
% using projection matrices generated using the Moore-Penrose pseudoinverse
% 
% Let M denote the Moore-Penrose pseudoinverse of the internal reaction
% stoichiometric matrix and the subscripts are the following
% _R row space
% _N nullspace
% _C column space
% _L left nullspace
%
% Example for flux of net flux
% Let vf = vf_R + vf_N
%
% vf_R = M*S*vf = PR*vf 
%
% vf_N = (I - M*S)*vf = PN*vf
% 
% Example for potential or logarithmic concentration
% Let u = u_C + u_L
%
% u_C = S*M*u = PC*u
%
% u_L = (I - S*M)*u = PL*u
%
%INPUT
% modelT.S              m x n matrix
% modelT.SIntRxnBool    Boolean vector defining the nIntRxn internal 
%                       reactions    
% vf                    nIntRxn x 1     forward flux for internal reactions
% vr                    nIntRxn x 1     reverse flux for internal reactions
% vnet                  n x 1           net flux for all reactions
% u                     m x 1           chemical potential
% u0                    m x 1           standard chemical potential
% lnx                   m x 1           logarithmic concentration
%
%OUTPUT
% vfN       
% vfR
% vrN
% vrR
% vnetN
% vnetR
% uL
% uC
% lnxL
% lnxC

%sanity check
if any((vnet(modelT.SIntRxnBool)- vf +vr)>1e-12)
    error('Net flux does not equal the difference between forward and reverse flux')
end
if ~isempty(lnx)
    if any((u - u0 - lnx)>1e-12)
        error('Chemical potential does not equal standard chemical potential plus logarithmic conc.')
    end
end

%generate projection matrices
[PR,PN,PC,PL]=subspaceProjector(modelT);

%potential 
uL=PL*u;
uC=PC*u;

%standard potential 
u0L=PL*u0;
u0C=PC*u0;

if ~isempty(lnx)
    %concentration
    lnxC=PC*lnx;
    lnxL=PL*lnx;
else
    lnxC=NaN*ones(size(u,1),1);
    lnxL=NaN*ones(size(u,1),1);
end

%net flux
vnetN=vnet;
vnetN(modelT.SIntRxnBool)=PN*vnet(modelT.SIntRxnBool);
vnetR=vnet;
vnetR(modelT.SIntRxnBool)=PR*vnet(modelT.SIntRxnBool);

%unidirectional flux
vfN=PN*vf;
vfR=PR*vf;
vrN=PN*vr;
vrR=PR*vr;