function [u1, u2] = projectSVD(U1, u)
% Assumes that `U1` has orthonormal columns
% so that :math:`U1 U1^T` is a projector.
% It returns the projections
%
% .. math::
%    u1 &= U1 U1^T u \\
%    u2 &= (I - U1 U1^T) u
%
% USAGE:
%
%    [u1, u2] = projectSVD(U1, u)
%
% EXAMPLE:
%
%    [U1, D1, V1, r] = subspaceSVD(S);
%    [uC, uL] = projectSVD(U1, u);
%    [vfR, vfN] = projectSVD(V1, vf);
%    [vrR, vrN] = projectSVD(V1, vr);
%
% .. Author: - Michael Saunders 29 Jul 2009 First version of projectSVD.m written as alternative to Ronan's projectOntoSubspace.m.

  u1 = U1*(U1'*u);
  u2 = u - u1;
