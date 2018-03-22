function [vfN, vfR, vrN, vrR, vnetN, vnetR, uL, uC, u0L, u0C, lnxL, lnxC] = projectOntoSubspace(A, vf, vr, vnet, u, u0, lnx,printLevel,rowBool,colBool)
% Projects flux, net flux, potential and logarithmic concentration onto
% their respective subspaces of A using projection matrices generated either 
% derived from SVD, or by using the Moore-Penrose pseudoinverse
%
% Optionally, a subset of the matrix A may be chosen by using A(rowBool,colBool)
% but then only the true rows of u, u0, lnx, and true columns of vf,vr,vnet are
% projected and the remaining rows and columns are not affected
%
% Let `M` denote the Moore-Penrose pseudoinverse of A and the subscripts are the following
% `_R` row space,
% `_N` nullspace,
% `_C` column space,
% `_L` left nullspace,
%
% Example for flux of net flux
%
% Let
%
% .. math::
%      vf   &= vf_R + vf_N \\
%      vf_R &= M A vf = PR vf \\
%      vf_N &= (I - M A) vf = PN vf
%
% Example for potential or logarithmic concentration
%
% Let
%
% .. math::
%      u   &= u_C + u_L \\
%      u_C &= A M u = PC u \\
%      u_L &= (I - A M) u = PL u
%
% USAGE:
%
%    [vfN, vfR, vrN, vrR, vnetN, vnetR, uL, uC, u0L, u0C, lnxL, lnxC] = projectOntoSubspace(modelT, vf, vr, vnet, u, u0, lnx)
%
% INPUTS:
%    A          `m x n` matrix
%    vf:        `n x 1` - forward flux
%    vr:        `n x 1` - reverse flux
%    vnet:      `n x 1` - net flux
%    u:         `m x 1` - chemical potential
%    u0:        `m x 1` - standard chemical potential
%    lnx:       `m x 1` - logarithmic concentration
% OPTIONAL INPUTS
%    rowBool    `m x 1` - boolean indicating the subset of rows of A
%    colBool    'n x 1' - boolean indicating the subset of cols of A
%
% OUTPUTS:
%    vfN:       forward flux - nullspace
%    vfR:       forward flux - row space
%    vrN:       reverse flux - nullspace
%    vrR:       reverse flux - row space
%    vnetN:     net flux - nullspace
%    vnetR:     net flux - row space
%    uL:        chemical potential - left nullspace
%    uC:        chemical potential - column space
%    lnxL:      logarithmic concentration - left nullspace
%    lnxC:      logarithmic concentration - column space

if ~isempty(vf)
    if any((vnet(colBool)- vf +vr)>1e-12) %sanity check
    error('Net flux does not equal the difference between forward and reverse flux')
    end
end

if ~isempty(lnx)
    if any((u - u0 - lnx)>1e-12)
        error('Chemical potential does not equal standard chemical potential plus logarithmic conc.')
    end
end

if ~exist('printLevel','var')
    printLevel=0;
end

[m,n]=size(A);

if ~exist('rowBool','var')
    rowBool=true(m,1);
end

if ~exist('colBool','var')
    colBool=true(n,1);
end

%generate fake outputs, or populate with unprojected vectors, part of which
%will be overwritten with the projected vectos further below.
if ~exist('u','var')
    uL=NaN*ones(m,1);
    uC=NaN*ones(m,1);
else
    uL=u;
    uC=u;
end
if ~exist('u0','var')
    u0L=NaN*ones(m,1);
    u0C=NaN*ones(m,1);
else
    u0L=u0;
    u0C=u0;
end
if ~exist('lnx','var')
    lnxL=NaN*ones(m,1);
    lnxC=NaN*ones(m,1);
else
    lnxL=lnx;
    lnxC=lnx;
end
if ~exist('vf','var')
    vfN=NaN*ones(n,1);
    vfR=NaN*ones(n,1);
else
    vfN=vf;
    vfR=vf;
end
if ~exist('vr','var')
    vrN=NaN*ones(n,1);
    vrR=NaN*ones(n,1);
else
    vrN=vr;
    vrR=vr;
end
if ~exist('vnet','var')
    vnetN=NaN*ones(n,1);
    vnetR=NaN*ones(n,1);
else
    vnetN=vnet;
    vnetR=vnet;
end

%generate projection matrices
sub_space='all';

[PR,PN,PC,PL]=subspaceProjector(A(rowBool,colBool),printLevel,sub_space);

%potential
if ~isempty(u)
    %concentration
    uC(rowBool)=PC*u(rowBool);
    uL(rowBool)=PL*u(rowBool);
end

if ~isempty(u0)
    %standard potential
    u0L(rowBool)=PL*u0(rowBool);
    u0C(rowBool)=PC*u0(rowBool);
end

if ~isempty(lnx)
    %concentration
    lnxC(rowBool)=PC*lnx(rowBool);
    lnxL(rowBool)=PL*lnx(rowBool);
end

%flux
if ~isempty(vnet)
    vnetN(colBool)=PN*vnet(colBool);
    vnetR(colBool)=PR*vnet(colBool);
end
if ~isempty(vf)
    vfN(colBool)=PN*vf(colBool);
    vrR(colBool)=PR*vr(colBool);
end
if ~isempty(vr)
    vrN(colBool)=PN*vr(colBool);
    vrR(colBool)=PR*vr(colBool);
end

