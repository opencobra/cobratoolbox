#pragma once

#include <Eigen/Dense>
#include <Eigen/Sparse>
#include <Eigen/SparseCholesky>
#include <Eigen/SparseLU>
#include <Eigen/SparseQR>

#include <stdexcept>
#undef eigen_assert
#define eigen_assert(x) \
  if (!(x)) { throw (std::runtime_error("Eigen runtime error.")); }

#include "mexUtils.h"
using namespace MexEnvironment;


template<class T>
using Matrix = Eigen::Matrix<T, Eigen::Dynamic, Eigen::Dynamic>;

template<class T>
using Map = Eigen::Map<Matrix<T>, Eigen::Aligned32>;

template<class T>
using SparseMatrix = Eigen::SparseMatrix<T, Eigen::ColMajor, SignedIndex>;

template<class T>
using SparseMap = Eigen::Map<SparseMatrix<T>, Eigen::Aligned32>;

template<typename T>
struct DefaultNumTraits : Eigen::GenericNumTraits<T>
{
	static inline T dummy_precision() { return 1000 * std::numeric_limits<T>::epsilon(); }
	static inline T epsilon() { return std::numeric_limits<T>::epsilon(); }
};

template<typename T>
bool isZero(T x, int eps_factor = 1)
{
	T eps = eps_factor * std::numeric_limits<T>::epsilon();
	return x < eps&& x > -eps;
}

template<>
bool isZero(bool x, int _)
{
	return !x;
}

bool isInputSparse(int id)
{
	const mxArray* pt = prhs[id];
	return (mxIsSparse(pt) || mxIsCell(pt));
}

template<typename T>
bool compatibleWith(uint64_t id)
{
	const mxArray* pt = prhs[id];
	if (!mxIsCell(pt))
		return (mxGetClassID(pt) == MexType<T>()) || (mxGetClassID(pt) == MexType<uint8_t>() && mxGetM(pt) == sizeof(T));
	else
	{
		const mxArray* pt_x = mxGetCell(pt, 1);
		return (mxGetClassID(pt_x) == MexType<uint8_t>() && mxGetM(pt_x) == sizeof(T)) || (mxGetClassID(pt_x) == MexType<T>());
	}
}


void checkAlignment(const void* ptr)
{
	auto iptr = reinterpret_cast<std::uintptr_t>(ptr);
	assertThrow(iptr % 32 == 0, "Input array is not 32 byte aligned.");
}


template<typename Tx>
Map<Tx> inputDenseMatrix(size_t required_m = kAnySize, size_t required_n = kAnySize)
{
	const mxArray* pt = input();

	assertThrow(!mxIsComplex(pt) && !mxIsSparse(pt),
		"inputDenseMatrix: The " + to_string(rhs_id) + "-th parameter should be a real dense array.");

	auto n_dim = mxGetNumberOfDimensions(pt);
	auto dims = mxGetDimensions(pt);
	size_t m = dims[0], n = dims[1];

	bool navie_input = false;
	if (mxGetClassID(pt) == MexType<uint8_t>() && m == sizeof(Tx))
	{
		m = dims[1];
		if (n_dim == 3)
			n = dims[2];
		else
			n = 1;
		navie_input = true;
	}

	checkInputSize(required_m, required_n, m, n);

	void* x = mxGetData(pt);
	checkAlignment(x);
	if (navie_input || mxGetClassID(pt) == MexType<Tx>())
		return Map<Tx>((Tx*)x, m, n);
	else
		throw std::runtime_error("inputDenseMatrix: The " + to_string(rhs_id) + "-th parameter should be of type " + typeid(Tx).name() + ".");
}

template<typename Tx, typename Derived>
void outputDenseMatrix(const Eigen::DenseBase<Derived>& A, bool native_output = false)
{
	mxArray* pt;
	auto m = A.rows(), n = A.cols();

	if (std::is_same<Tx, double>::value && native_output)
		pt = mxCreateNumericMatrix(m, n, MexType<double>(), mxREAL);
	else if (std::is_same<Tx, bool>::value && native_output)
		pt = mxCreateNumericMatrix(m, n, MexType<bool>(), mxREAL);
	else
	{
		mwSize dims[3] = { mwSize(sizeof(Tx)), mwSize(m), mwSize(n) };
		pt = mxCreateNumericArray(3, dims, MexType<uint8_t>(), mxREAL);
	}

	Tx* Ax = (Tx*)mxGetData(pt);
	for (int j = 0; j < n; ++j)
		for (int i = 0; i < m; ++i)
			Ax[i + j * m] = Tx(A(i, j));

	output(pt);
}

template<typename Tx>
SparseMap<Tx> inputSparseMatrix(size_t required_m = kAnySize, size_t required_n = kAnySize)
{
	const mxArray* pt = input();

	const mxArray* pt_S, * pt_x;
	if (mxIsCell(pt))
	{
		pt_S = mxGetCell(pt, 0);
		pt_x = mxGetCell(pt, 1);
	}
	else if (mxIsSparse(pt))
	{
		pt_S = pt;
		pt_x = pt;
	}
	else
		throw std::runtime_error("inputSparseMatrix: The " + to_string(rhs_id) + "-th parameter should be sparse.");

	size_t m = mxGetM(pt_S), n = mxGetN(pt_S), nzmax = mxGetNzmax(pt_S);
	checkInputSize(required_m, required_n, m, n);

	SignedIndex* ir = (SignedIndex*)mxGetIr(pt_S), * jc = (SignedIndex*)mxGetJc(pt_S);
	void* x = mxGetData(pt_x);
	checkAlignment(x);
	if ((mxGetClassID(pt_x) == MexType<uint8_t>() && mxGetM(pt_x) == sizeof(Tx)) || mxGetClassID(pt_x) == MexType<Tx>())
		return SparseMap<Tx>(m, n, nzmax, jc, ir, (Tx*)x);
	else
		throw std::runtime_error("inputSparseMatrix: The " + to_string(rhs_id) + "-th parameter should be of type " + typeid(Tx).name());
}

// We do not optimize the performance of outputing sparse matrix
template<typename Tx, typename Derived>
void outputSparseMatrix(const Eigen::SparseCompressedBase<Derived>& A, bool  native_output = false)
{
	assertThrow(A.isCompressed(), "outputSparseMatrix: A should be compressed.");

	if (A.IsRowMajor)
	{
		SparseMatrix<Tx> A_col_major(A.template cast<Tx>());
		outputSparseMatrix<Tx>(A_col_major);
		return;
	}

	mxArray* pt;
	auto m = A.rows(), n = A.cols(), nnz = A.nonZeros();

	mxArray* pt_S, * pt_x;
	if (std::is_same<Tx, double>::value && native_output)
	{
		pt = mxCreateSparse(m, n, nnz, mxREAL);
		pt_S = pt;
		pt_x = pt;
	}
	else if (std::is_same<Tx, bool>::value && native_output)
	{
		pt = mxCreateSparseLogicalMatrix(m, n, nnz);
		pt_S = pt;
		pt_x = pt;
	}
	else
	{
		pt = mxCreateCellMatrix(2, 1);
		pt_S = mxCreateSparseLogicalMatrix(m, n, nnz);
		pt_x = mxCreateNumericMatrix(sizeof(Tx), nnz, MexType<uint8_t>(), mxREAL);
		mxSetCell(pt, 0, pt_S);
		mxSetCell(pt, 1, pt_x);

		bool* Ax_S = (bool*)mxGetData(pt_S);
		for (int s = 0; s < nnz; ++s)
			Ax_S[s] = true;
	}

	auto x = A.valuePtr();
	Tx* Ax_x = (Tx*)mxGetData(pt_x);
	for (int s = 0; s < nnz; ++s)
		Ax_x[s] = Tx(x[s]);

	auto i = A.innerIndexPtr();
	SignedIndex* Ai = (SignedIndex*)mxGetIr(pt_S);
	for (int s = 0; s < nnz; ++s)
		Ai[s] = SignedIndex(i[s]);

	auto j = A.outerIndexPtr();
	SignedIndex* Aj = (SignedIndex*)mxGetJc(pt_S);
	for (int s = 0; s <= n; ++s)
		Aj[s] = SignedIndex(j[s]);

	output(pt);
}

constexpr unsigned int str2int(const char* str, int h = 0)
{
	return !str[h] ? 5381 : (str2int(str, h + 1) * 33) ^ str[h];
}