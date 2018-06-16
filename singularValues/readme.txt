function [U,S,V] = svdecon(X)

Input:
X : m x n matrix

Output:
X = U*S*V'

Description:
Does equivalent to svd(X,'econ') but faster

***

function [U,S,V] = svdsecon(X,k)

Input:
X : m x n matrix
k : extracts the first k singular values

Output:
X = U*S*V' approximately (up to k)

Description:
Does equivalent to svds(X,k) but faster
Requires that k < min(m,n) where [m,n] = size(X)
This function is useful if k is much smaller than m and n or if X is sparse (see doc eigs)

***

function [U,T,mu] = pcaecon(X,k)

Input:
X : m x n matrix
Each column of X is a feature vector

Output:
X = U*T approximately (up to k)

Description:
Principal Component Analysis (PCA)
Requires that k <= min(m,n) where [m,n] = size(X)

***

function [U,T,mu] = pcasecon(X,k)

Input:
X : m x n matrix
Each column of X is a feature vector

Output:
X = U*T approximately (up to k)

Description:
Principal Component Analysis (PCA)
Requires that k <= min(m,n) where [m,n] = size(X)
This function is useful if k is much smaller than m and n or if X is sparse (see doc eigs)
