#pragma once
#include "CMatrixUtils.h"

enum EntryType { kSetSet, kNullSet, kSetNull, kNullNull };

// Assume f(0, 0) = 0
template <typename O, typename Tx = CType>
SparseMatrix<decltype(O::f(1, 1, Tx(1.0), Tx(1.0), kSetSet))>
binaryOperator(SparseMap<Tx> A, SparseMap<Tx> B)
{
	assertThrow(isZero(O::f(1, 1, Tx(0.0), Tx(0.0), kNullNull)), "binaryOperator(Sparse,Sparse): f(0,0) must be 0");

	auto m = A.rows(), n = A.cols(), Bm = B.rows(), Bn = B.cols();
	auto Annz = A.nonZeros(), Bnnz = B.nonZeros();

	auto Ai = A.innerIndexPtr(), Bi = B.innerIndexPtr();
	auto Aj = A.outerIndexPtr(), Bj = B.outerIndexPtr();
	auto Ax = A.valuePtr(), Bx = B.valuePtr();

	assertThrow(m == Bm && n == Bn, "binaryOperator(Sparse,Sparse): mismatch dimensions");
	using OutputType = decltype(O::f(1, 1, Tx(1.0), Tx(1.0), kSetSet));
	using Ti = typename SparseMap<Tx>::StorageIndex;

	auto Cx = new OutputType[Annz + Bnnz];
	auto Cj = new Ti[n + 1];
	auto Ci = new Ti[Annz + Bnnz];

	// Compute C
	Tx Tzero = Tx(0.0);
	Ti nnz = 0;
	for (int j = 0; j < n; ++j)
	{
		Cj[j] = nnz;				/* column j of C starts here */

		Ti p1 = Aj[j], p2 = Bj[j];
		Ti end1 = Aj[j + 1], end2 = Bj[j + 1];
		while (true)
		{
			Ti i1 = (p1 < end1) ? Ai[p1] : m;
			Ti i2 = (p2 < end2) ? Bi[p2] : m;

			if (i1 < i2)
			{
				Cx[nnz] = O::f(i1, j, Ax[p1++], Tzero, kSetNull);
				Ci[nnz++] = i1;
			}
			else if (i2 < i1)
			{
				Cx[nnz] = O::f(i2, j, Tzero, Bx[p2++], kNullSet);
				Ci[nnz++] = i2;
			}
			else if (i1 < m)
			{
				Cx[nnz] = O::f(i1, j, Ax[p1++], Bx[p2++], kSetSet);
				Ci[nnz++] = i1;
			}
			else
				break;
		}
	}
	Cj[n] = nnz;

	SparseMatrix<OutputType> out(SparseMap<OutputType>(m, n, nnz, Cj, Ci, Cx));

	delete[] Cx; delete[] Ci; delete[] Cj;
	return out;
}

template <typename T>
std::tuple<T, T> computeBinaryOperatorOuputSize(T Am, T An, T Bm, T Bn)
{
	T m = Am, n = An;
	if (Bm != 1) m = Bm;
	if (Bn != 1) n = Bn;
	if ((Am != 1 && Am != m) || (Bm != 1 && Bm != m) ||
		(An != 1 && An != n) || (Bn != 1 && Bn != n))
		throw std::invalid_argument("Incompatiable input sizes: "
			"" + to_string(Am) + " x " + to_string(An) + " and "
			"" + to_string(Bm) + " x " + to_string(Bn) + ".");
	return { m, n };
}


// Assume f(0, 0) = 0
// Assume f(0, 1) = 0
template <typename O, typename Tx = CType>
SparseMatrix<decltype(O::f(1, 1, Tx(1.0), Tx(1.0), kSetSet))>
binaryOperator(SparseMap<Tx> A, Map<Tx> B)
{
	assertThrow(isZero(O::f(1, 1, Tx(0.0), Tx(1.0), kNullSet)), "binaryOperator(Sparse,Dense): f(0,1) must be 0");

	auto Am = A.rows(), An = A.cols(), Annz = A.nonZeros(), Bm = B.rows(), Bn = B.cols();
	auto Ax = A.valuePtr();

	using OutputType = decltype(O::f(1, 1, Tx(1.0), Tx(1.0), kSetSet));
	using Ti = typename SparseMap<Tx>::StorageIndex;
	auto [m, n] = computeBinaryOperatorOuputSize(Am, An, Bm, Bn);

	SparseMatrix<OutputType> C(A.template cast<OutputType>());
	auto Ci = C.innerIndexPtr(), Cj = C.outerIndexPtr();
	auto Cx = C.valuePtr();

	// Compute the increment of the indices
	Ti iStepB = (Bm == 1) ? 0 : 1, jStepB = (Bn == 1) ? 0 : 1;

	// Compute C
	for (Ti j = 0; j < n; ++j)
	{
		for (Ti p = Cj[j]; p < Cj[j + 1]; ++p)
		{
			Ti i = Ci[p];
			Cx[p] = O::f(i, j, Ax[p], B(i * iStepB, j * jStepB), kSetSet);
		}
	}
	return C;
}


// Assume f(0, 0) = 0
// Assume f(1, 0) = 0
template <typename O, typename Tx = CType>
SparseMatrix<decltype(O::f(1, 1, Tx(1.0), Tx(1.0), kSetSet))>
binaryOperator(Map<Tx> A, SparseMap<Tx> B)
{
	assertThrow(isZero(O::f(1, 1, Tx(1.0), Tx(0.0), kSetNull)), "binaryOperator(Dense,Sparse): f(1,0) must be 0");

	auto Am = A.rows(), An = A.cols(), Bnnz = A.nonZeros(), Bm = B.rows(), Bn = B.cols();
	auto Bx = B.valuePtr();

	using OutputType = decltype(O::f(1, 1, Tx(1.0), Tx(1.0), kSetSet));
	using Ti = typename SparseMap<Tx>::StorageIndex;
	auto [m, n] = computeBinaryOperatorOuputSize(Am, An, Bm, Bn);

	SparseMatrix<OutputType> C(B.template cast<OutputType>());
	auto Ci = C.innerIndexPtr(), Cj = C.outerIndexPtr();
	auto Cx = C.valuePtr();

	// Compute the increment of the indices
	Ti iStepA = (Am == 1) ? 0 : 1, jStepA = (An == 1) ? 0 : 1;

	// Compute C
	for (Ti j = 0; j < n; ++j)
	{
		for (Ti p = Cj[j]; p < Cj[j + 1]; ++p)
		{
			Ti i = Ci[p];
			Cx[p] = O::f(i, j, A(i * iStepA, j * jStepA), Bx[p], kSetSet);
		}
	}
	return C;
}

template <typename O, typename Tx = CType>
Matrix<decltype(O::f(1, 1, Tx(1.0), Tx(1.0), kSetSet))>
binaryOperator(Map<Tx> A, Map<Tx> B)
{
	auto Am = A.rows(), An = A.cols(), Bm = B.rows(), Bn = B.cols();

	using OutputType = decltype(O::f(1, 1, Tx(1.0), Tx(1.0), kSetSet));
	using Ti = typename Map<Tx>::Index;
	auto [m, n] = computeBinaryOperatorOuputSize(Am, An, Bm, Bn);
	Matrix<OutputType> C(m, n);

	// Compute the increment of the indices
	Ti iStepA = (Am == 1) ? 0 : 1, jStepA = (An == 1) ? 0 : 1;
	Ti iStepB = (Bm == 1) ? 0 : 1, jStepB = (Bn == 1) ? 0 : 1;

	// Compute C
	for (Ti j = 0; j < n; ++j)
	{
		for (Ti i = 0; i < m; ++i)
		{
			C(i, j) = O::f(i, j, A(i * iStepA, j * jStepA), B(i * iStepB, j * jStepB), kSetSet);
		}
	}
	return C;
}
