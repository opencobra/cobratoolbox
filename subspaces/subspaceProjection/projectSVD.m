function [u1,u2] = projectSVD(U1,u)

%        [u1,u2] = projectSVD(U1,u);
% assumes that U1 has orthonormal columns
% so that   U1*U1' is a projector.
% It returns the projections
%            u1  = U1 U1' u
%            u2  = (I - U1 U1') u.
%
% Example:
%        [U1,D1,V1,r] = subspaceSVD(S);
%        [uC,uL]      = projectSVD(U1,u);
%        [vfR,vfN]    = projectSVD(V1,vf);
%        [vrR,vrN]    = projectSVD(V1,vr);

% 29 Jul 2009: (Michael Saunders) First version of projectSVD.m
%              written as alternative to Ronan's projectOntoSubspace.m.

  u1 = U1*(U1'*u);
  u2 = u - u1;


