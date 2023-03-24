classdef CMatrixTest < matlab.unittest.TestCase
   properties (TestParameter)
      type = {@ddouble}
      lhsSize = {[0, 0], [1, 1], [30, 20], [30, 1], [1 20]}
      rhsSize = {[0, 0], [1, 1], [30, 20], [30, 1], [1 20]}
      lhsMode = struct('dense', 0, 'sparse', 1);
      rhsMode = struct('dense', 0, 'sparse', 1);
   end
   
   methods (Static)
      function [okay, A1, B1] = generateMatrices(lhsSize, rhsSize, lhsMode, rhsMode)
         Am = lhsSize(1); An = lhsSize(2); Bm = rhsSize(1); Bn = rhsSize(2);
         A1 = randn(Am, An); B1 = randn(Bm, Bn);
         okay = false;
         
         if lhsMode == 1, A1 = sparse(A1); end
         if rhsMode == 1, B1 = sparse(B1); end
         
         % check compatibility
         m = Am; n = An;
         if (Bm ~= 1), m = Bm; end
         if (Bn ~= 1), n = Bn; end
         if (Am ~= 1 && Am ~= m), return; end
         if (Bm ~= 1 && Bm ~= m), return; end
         if (An ~= 1 && An ~= n), return; end
         if (Bn ~= 1 && Bn ~= n), return; end
         
         okay = true;
      end
   end
   
   methods (Test)
      function comparisons(testCase, type, lhsSize, rhsSize, lhsMode, rhsMode)
         [okay, A1, B1] = CMatrixTest.generateMatrices(lhsSize, rhsSize, lhsMode, rhsMode);
         if (~okay), return; end
         
         % lt, gt, le, ge
         A2 = type(A1); B2 = type(B1);
         testCase.verifyEqual(A2 < B2, A1 < B1)
         testCase.verifyEqual(A2 > B2, A1 > B1)
         testCase.verifyEqual(A2 <= B2, A1 <= B1)
         testCase.verifyEqual(A2 >= B2, A1 >= B1)
         
         % ne, eq, and, or, not
         A1 = round(A1); B1 = round(B1);
         A2 = type(A1); B2 = type(B1);
         testCase.verifyEqual(A2 ~= B2, A1 ~= B1)
         testCase.verifyEqual(A2 == B2, A1 == B1)
         testCase.verifyEqual(A2 & B2, A1 & B1)
         testCase.verifyEqual(A2 | B2, A1 | B1)
         testCase.verifyEqual(~A2, ~A1)
      end
      
      function arithmetic(testCase, type, lhsSize, rhsSize, lhsMode, rhsMode)
         [okay, A1, B1] = CMatrixTest.generateMatrices(lhsSize, rhsSize, lhsMode, rhsMode);
         Ceps = double(eps(type(1))) + eps;
         if (~okay), return; end
         
         % plus, minus, times, rdivide, ldivide
         A2 = type(A1); B2 = type(B1);
         testCase.verifyEqual(double(A2 + B2), A1 + B1, 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(A2 - B2), A1 - B1, 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(A2 .* B2), A1 .* B1, 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(A2 ./ B2), A1 ./ B1, 'AbsTol', Ceps*1e4, 'RelTol', Ceps*1e4)
         testCase.verifyEqual(double(A2 .\ B2), A1 .\ B1, 'AbsTol', Ceps*1e4, 'RelTol', Ceps*1e4)
         
         % max, min
         testCase.verifyEqual(double(max(A2,B2)), max(A1,B1), 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(min(A2,B2)), min(A1,B1), 'AbsTol', Ceps*1e4)
         
         % horzcat, vertcat
         if size(A2,1) == size(B2,1)
            testCase.verifyEqual(double([A2 B2]), [A1 B1], 'AbsTol', Ceps*1e4)
            testCase.verifyEqual(double([A2 B2 A2 B2]), [A1 B1 A1 B1], 'AbsTol', Ceps*1e4)
         end
         
         if size(A2,2) == size(B2,2)
            testCase.verifyEqual(double([A2;B2]), [A1;B1], 'AbsTol', Ceps*1e4)
            testCase.verifyEqual(double([A2;B2;A2;B2]), [A1;B1;A1;B1], 'AbsTol', Ceps*1e4)
         end
         
         % times, rdivide, ldivide
         if size(A1,2) == size(B2',1)
            testCase.verifyEqual(double(A2 * B2'), A1 * B1', 'AbsTol', Ceps*1e6)
         end
         
         if size(A1,1) == size(B2,1)
            testCase.verifyEqual(double(A2 \ B2), A1 \ B1, 'AbsTol', Ceps*1e6)
         end
         
         if size(A1,2) == size(B2,2)
            testCase.verifyEqual(double(A2 / B2), A1 / B1, 'AbsTol', Ceps*1e6)
         end
      end
      
      function unaryOperations(testCase, type, lhsSize, lhsMode)
         A1 = randn(lhsSize);
         if lhsMode == 1, A1 = sparse(A1); end
         Ceps = double(eps(type(1))) + eps;
         
         % size, length, numel
         A2 = type(A1);
         testCase.verifyEqual(size(A2), size(A1))
         testCase.verifyEqual(size(A2, 1), size(A1, 1))
         testCase.verifyEqual(size(A2, 2), size(A1, 2))
         [a1, b1] = size(A1);
         [a2, b2] = size(A2);
         testCase.verifyEqual(a2, a1)
         testCase.verifyEqual(b2, b1)
         testCase.verifyEqual(length(A2), length(A1))
         testCase.verifyEqual(numel(A2), numel(A1))
         
         % isscalar, isvector, ismatrix, isempty, isrow, iscolumn, issymmetric
         testCase.verifyEqual(isscalar(A2), isscalar(A1))
         testCase.verifyEqual(isvector(A2), isvector(A1))
         testCase.verifyEqual(ismatrix(A2), ismatrix(A1))
         testCase.verifyEqual(isempty(A2), isempty(A1))
         testCase.verifyEqual(isrow(A2), isrow(A1))
         testCase.verifyEqual(iscolumn(A2), iscolumn(A1))
         testCase.verifyEqual(issymmetric(A2), issymmetric(A1))
         
         if (size(A1,1) == size(A1,2))
            A1 = A1 + A1'; A2 = type(A1);
            testCase.verifyEqual(issymmetric(A2), issymmetric(A1))
         end
         
         % uminus, uplus, abs, transpose, ctranspose, sqrt, all, any, nnz, diag
         testCase.verifyEqual(double(-A2), -A1, 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(+A2), +A1, 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(abs(A2)), abs(A1), 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(transpose(A2)), transpose(A1), 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(ctranspose(A2)), ctranspose(A1), 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(sqrt(abs(A2)+1)), sqrt(abs(A1)+1), 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(all(A2), all(A1))
         testCase.verifyEqual(all(A2,1), all(A1,1))
         testCase.verifyEqual(all(A2,2), all(A1,2))
         testCase.verifyEqual(any(A2), any(A1))
         testCase.verifyEqual(any(A2,1), any(A1,1))
         testCase.verifyEqual(any(A2,2), any(A1,2))
         testCase.verifyEqual(nnz(A2), nnz(A1))
         testCase.verifyEqual(double(diag(A2)), diag(A1), 'AbsTol', Ceps*1e4)
         
         % sum, prod, max, min, norm
         testCase.verifyEqual(double(sum(A2)), sum(A1), 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(sum(A2,1)), sum(A1,1), 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(sum(A2,2)), sum(A1,2), 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(sum(A2,'all')), sum(A1,'all'), 'AbsTol', Ceps*1e4)
         
         testCase.verifyEqual(double(prod(A2)), prod(A1), 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(prod(A2,1)), prod(A1,1), 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(prod(A2,2)), prod(A1,2), 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(prod(A2,'all')), prod(A1,'all'), 'AbsTol', Ceps*1e4)
         
         testCase.verifyEqual(double(max(A2)), max(A1), 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(max(A2,[],1)), max(A1,[],1), 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(max(A2,[],2)), max(A1,[],2), 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(max(A2,[],'all')), max(A1,[],'all'), 'AbsTol', Ceps*1e4)
         
         testCase.verifyEqual(double(min(A2)), min(A1), 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(min(A2,[],1)), min(A1,[],1), 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(min(A2,[],2)), min(A1,[],2), 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(min(A2,[],'all')), min(A1,[],'all'), 'AbsTol', Ceps*1e4)
         
         if isvector(A1)
            testCase.verifyEqual(double(norm(A2)), norm(A1), 'AbsTol', Ceps*1e4)
         end
         
         % find
         testCase.verifyEqual(find(A2), find(A1))
         [i2,j2] = find(A2); [i1,j1] = find(A1);
         testCase.verifyEqual(i2, i1)
         testCase.verifyEqual(j2, j1)
         [i2,j2,v2] = find(A2); [i1,j1,v1] = find(A1);
         testCase.verifyEqual(i2, i1)
         testCase.verifyEqual(j2, j1)
         testCase.verifyEqual(double(v2), v1, 'AbsTol', Ceps*1e4)
         
         % chol
         H1 = A1 * A1' + speye(size(A1,1));
         testCase.verifyEqual(double(chol(type(H1))), chol(H1), 'AbsTol', Ceps*1e6)
      end
      
      function externalFunc(testCase, type, lhsSize)
         Am = lhsSize(1); An = lhsSize(2);
         Ceps = double(eps(type(1))) + eps;
         typename = class(type(1.0));
         
         % ones, zeros, eye, rand, randn, randi, sparse
         A1 = ones(Am, An, typename); A2 = ones(Am, An);
         testCase.verifyTrue(all(A1 == A2, 'all'))
         A1 = zeros(Am, An, typename); A2 = zeros(Am, An);
         testCase.verifyTrue(all(A1 == A2, 'all'))
         A1 = eye(Am, An, typename); A2 = eye(Am, An);
         testCase.verifyTrue(all(A1 == A2, 'all'))
         rng(1); A1 = rand(Am, An, typename); rng(1); A2 = rand(Am, An);
         testCase.verifyTrue(all(A1 == A2, 'all'))
         rng(1); A1 = randn(Am, An, typename); rng(1); A2 = randn(Am, An);
         testCase.verifyTrue(all(A1 == A2, 'all'))
         rng(1); A1 = randi(10, Am, An, typename); rng(1); A2 = randi(10, Am, An);
         testCase.verifyTrue(all(A1 == A2, 'all'))
         A1 = full(sprand(Am, An, 0.5)); A2 = type(A1);
         testCase.verifyEqual(double(sparse(A2)), sparse(A1), 'AbsTol', 1e4*Ceps);
         testCase.verifyEqual(double(full(A2)), full(A1), 'AbsTol', 1e4*Ceps);
         A1 = (sprand(Am, An, 0.5)); A2 = type(A1);
         testCase.verifyEqual(double(sparse(A2)), sparse(A1), 'AbsTol', 1e4*Ceps);
         testCase.verifyEqual(double(full(A2)), full(A1), 'AbsTol', 1e4*Ceps);
         Carr = type(1:Am);
         testCase.verifyEqual(double(sparse(1:Am, 1:Am, Carr)), sparse(1:Am, 1:Am, 1:Am));
         testCase.verifyEqual(double(sparse(1:Am, 1:Am, Carr, Am, Am)), sparse(1:Am, 1:Am, 1:Am, Am, Am));
         testCase.verifyEqual(double(sparse(1:Am, 1:Am, Carr, Am, Am, Am)), sparse(1:Am, 1:Am, 1:Am, Am, Am, Am));
         
         % .x
         b = A2.x;
         A2.x = b;
      end
      
      function otherTests(testCase, type, lhsMode)
         A1 = sprandn(5, 6, 0.6);
         if lhsMode == 0, A1 = full(A1); end
         A2 = type(A1);
         Ceps = double(eps(type(1))) + eps;
         
         % subsref
         testCase.verifyEqual(double(A2(1:3,:)), A1(1:3,:), 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(A2(:,2:4)), A1(:,2:4), 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(A2(1:3,2:4)), A1(1:3,2:4), 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(A2(1:3,2:end)), A1(1:3,2:end), 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(A2(5:end)), A1(5:end), 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(A2(:)), A1(:), 'AbsTol', Ceps*1e4)
         testCase.verifyEqual(double(A2(2:2:8)), A1(2:2:8), 'AbsTol', Ceps*1e4)
         
         % subsasgn
         A1(1:3,:) = 5; A2(1:3,:) = 5;
         testCase.verifyEqual(double(A2),A1, 'AbsTol', Ceps*1e4)
         A1(5:end) = 5; A2(5:end) = 5;
         testCase.verifyEqual(double(A2),A1, 'AbsTol', Ceps*1e4)
         A1(:,2:4) = []; A2(:,2:4) = [];
         testCase.verifyEqual(double(A2),A1, 'AbsTol', Ceps*1e4)
         
         disp(A2);
         
         % dissect, amd, symbfact
         A1 = sprandn(6, 6, 0.6);
         A1 = A1 * A1';
         A2 = type(A1);
         testCase.verifyEqual(dissect(A2),dissect(A1))
         testCase.verifyEqual(amd(A2),amd(A1))
         testCase.verifyEqual(symbfact(A2),symbfact(A1))
         [r21, r22] = etree(A2);
         [r11, r12] = etree(A1);
         testCase.verifyEqual(r21,r11)
         testCase.verifyEqual(r22,r12)
         
         % chol
         try
            A = randn(5,5);
            A = A * A';
            A = sparse(A) * NaN;
            Z = chol(type(A));
            Z'\randn(5,1);
         end
         
         A = sprandn(30,30,0.3);
         H = type(A * A');
         R = chol(H);
         D = H - R' * R;
         testCase.verifyLessThan(double(norm(D(:))), Ceps*1e4)
         
         % solves for triangular matrix
         A = type(tril(sprandn(30,30,0.3) + speye(30)));
         b = randn(30,1);
         x = A\b;
         testCase.verifyLessThan(double(norm(A*x-b)), Ceps*1e4)
         
         A = type(triu(sprandn(30,30,0.3) + speye(30)));
         b = randn(30,1);
         x = A\b;
         testCase.verifyLessThan(double(norm(A*x-b)), Ceps*1e4)
         
         A = type(tril(randn(30,30) + eye(30)));
         b = randn(30,1);
         x = A\b;
         testCase.verifyLessThan(double(norm(A*x-b)), Ceps*1e4)
         
         A = type(triu(randn(30,30) + eye(30)));
         b = randn(30,1);
         x = A\b;
         testCase.verifyLessThan(double(norm(A*x-b)), Ceps*1e4)
      end
      
      function cholTests(testCase)
         load('..\..\Problem\LPnetlib\lp_80bau3b.mat')
         
         A = Problem.A;
         p = colamd(A');
         A = A(p,:);
         w = rand(size(A,2),1);
         R = chol((A*(w.*A')));
         x = rand(size(A,1),1);
         z = R\(R'\x);
         d = full(diag(R));
         
         o = AdaptiveChol(A);
         o.factorize(diag(sparse(w)));
         z2 = o.solve(x);
         testCase.verifyEqual(double(z), z2, 'AbsTol', eps*1e4)
         
         d2 = o.diagonal();
         testCase.verifyEqual(double(d), d2, 'AbsTol', eps*1e4)
         
         ls = o.leverageScore(100);
         testCase.verifyTrue(all(ls<1.5));
         
         try
            o.factorize(diag(sparse(rand(12,1))));
         end
      end
   end
end