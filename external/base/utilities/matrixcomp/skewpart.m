function S = skewpart(A)
%SKEWPART  Skew-symmetric (skew-Hermitian) part.
%          SKEWPART(A) is the skew-symmetric (skew-Hermitian) part of A,
%          (A - A')/2.
%          It is the nearest skew-symmetric (skew-Hermitian) matrix to A in
%          both the 2- and the Frobenius norms.

S = (A - A')./2;
