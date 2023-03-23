#include "CMatrixUtils.h"
#include "binaryOperator.h"

template <typename Tx, typename Ti>
struct KeepTrue
{
	bool operator() (const Ti& row, const Ti& col, const Tx& value) const
	{
		return (bool)value;
	}
};


template <typename O, typename Tx = CType>
void runUnaryOperator()
{
	if (isInputSparse(1))
	{
		auto A = inputSparseMatrix<Tx>();
		auto m = A.rows(), n = A.cols();

		using OutputType = decltype(O::f(1, 1, Tx(1.0)));
		using Ti = typename SparseMap<Tx>::StorageIndex;
		SparseMatrix<OutputType> C(A.template cast<OutputType>());

		// Compute C
		auto Ax = A.valuePtr();
		auto Cx = C.valuePtr();
		auto Ci = C.innerIndexPtr(), Cj = C.outerIndexPtr();

		for (auto j = 0; j < n; ++j)
		{
			for (auto p = Cj[j]; p < Cj[j + 1]; ++p)
			{
				auto i = Ci[p];
				Cx[p] = O::f(i, j, Ax[p]);
			}
		}

		if (std::is_same<OutputType, bool>::value)
			C.prune(KeepTrue<OutputType, Ti>());

		outputSparseMatrix<OutputType>(C, O::NativeOutput);
	}
	else
	{
		auto A = inputDenseMatrix<Tx>();
		auto m = A.rows(), n = A.cols();

		using OutputType = decltype(O::f(1, 1, Tx(1.0)));
		Matrix<OutputType> C(m, n);

		for (auto j = 0; j < n; ++j)
			for (auto i = 0; i < m; ++i)
				C(i, j) = O::f(i, j, A(i, j));

		outputDenseMatrix<OutputType>(C, O::NativeOutput);
	}
}

template <typename O, typename Tx = CType>
void runBinaryOperator()
{
	bool isASparse = isInputSparse(1), isBSparse = isInputSparse(2);
	SparseMap<Tx> sparseA(0, 0, 0, nullptr, nullptr, nullptr), sparseB(0, 0, 0, nullptr, nullptr, nullptr);
	Map<Tx> denseA(nullptr, 0, 0), denseB(nullptr, 0, 0);

	SparseMatrix<Tx> sparseAMat, sparseBMat;
	Matrix<Tx> denseAMat, denseBMat;
	using Ti = typename SparseMap<Tx>::StorageIndex;

	Ti Am, An, Bm, Bn;
	if (isASparse)
	{
		sparseA = inputSparseMatrix<Tx>();
		Am = sparseA.rows(); An = sparseA.cols();
	}
	else
	{
		auto A = inputDenseMatrix<Tx>();
		new (&denseA) Map<Tx>(A);
		Am = denseA.rows(); An = denseA.cols();
	}

	if (isBSparse)
	{
		sparseB = inputSparseMatrix<Tx>();
		Bm = sparseB.rows(); Bn = sparseB.cols();
	}
	else
	{
		auto B = inputDenseMatrix<Tx>();
		new (&denseB) Map<Tx>(B);
		Bm = denseB.rows(); Bn = denseB.cols();
	}

	// Decide the output is dense or sparse
	bool sparseOutput = false;
	if (isASparse && isBSparse)
		sparseOutput = O::SparseSparseToSparse;
	else if (isASparse && !isBSparse)
		sparseOutput = O::SparseDenseToSparse;
	else if (!isASparse && isBSparse)
		sparseOutput = O::DenseSparseToSparse;
	else if (!isASparse && !isBSparse)
		sparseOutput = O::DenseDenseToSparse;

	// Densify the matrices if it is a row or column or if the output is dense
	if (isASparse && (!sparseOutput || Am == 1 || An == 1))
	{
		if (!sparseOutput)
		{
			denseAMat = sparseA;
			new (&denseA) Map<Tx>(denseAMat.data(), Am, An);
			isASparse = false;
		}
		else
		{
			if (Am == 1 && An == 1)
				sparseAMat = SparseMatrix<Tx>(Matrix<Tx>::Constant(Bm, Bn, sparseA.coeff(0, 0)).sparseView());
			else if (Am == 1)
				sparseAMat = SparseMatrix<Tx>(Matrix<Tx>::Ones(Bm, 1).sparseView()) * sparseA;
			else
				sparseAMat = sparseA * SparseMatrix<Tx>(Matrix<Tx>::Ones(1, Bn).sparseView());
			
			new (&sparseA) SparseMap<Tx>(sparseAMat.rows(), sparseAMat.cols(),
				sparseAMat.nonZeros(),
				sparseAMat.outerIndexPtr(), sparseAMat.innerIndexPtr(),
				sparseAMat.valuePtr());
		}
	}

	if (isBSparse && (!sparseOutput || Bm == 1 || Bn == 1))
	{
		if (!sparseOutput)
		{
			denseBMat = sparseB;
			new (&denseB) Map<Tx>(denseBMat.data(), Bm, Bn);
			isBSparse = false;
		}
		else
		{
			if (Bm == 1 && Bn == 1)
				sparseBMat = SparseMatrix<Tx>(Matrix<Tx>::Constant(Am, An, sparseB.coeff(0, 0)).sparseView());
			else if (Bm == 1)
				sparseBMat = SparseMatrix<Tx>(Matrix<Tx>::Ones(Am, 1).sparseView()) * sparseB;
			else
				sparseBMat = sparseB * SparseMatrix<Tx>(Matrix<Tx>::Ones(1, An).sparseView());
			new (&sparseB) SparseMap<Tx>(sparseBMat.rows(), sparseBMat.cols(),
				sparseBMat.nonZeros(),
				sparseBMat.outerIndexPtr(), sparseBMat.innerIndexPtr(),
				sparseBMat.valuePtr());
		}
	}

	// Run the operator
	using OutputType = decltype(O::f(1, 1, Tx(1.0), Tx(1.0), kSetSet));
	if (isASparse && isBSparse)
	{
		auto C = binaryOperator<O>(sparseA, sparseB);
		if (std::is_same<OutputType, bool>::value)
			C.prune(KeepTrue<OutputType, Ti>());
		outputSparseMatrix<OutputType>(C, O::NativeOutput);
	}
	else if (!isASparse && isBSparse)
	{
		auto C = binaryOperator<O>(denseA, sparseB);
		if (std::is_same<OutputType, bool>::value)
			C.prune(KeepTrue<OutputType, Ti>());
		outputSparseMatrix<OutputType>(C, O::NativeOutput);
	}
	else if (isASparse && !isBSparse)
	{
		auto C = binaryOperator<O>(sparseA, denseB);
		if (std::is_same<OutputType, bool>::value)
			C.prune(KeepTrue<OutputType, Ti>());
		outputSparseMatrix<OutputType>(C, O::NativeOutput);
	}
	else if (!isASparse && !isBSparse)
	{
		auto C = binaryOperator<O>(denseA, denseB);
		outputDenseMatrix<OutputType>(C, O::NativeOutput);
	}
}

template <typename O, typename Tx = CType>
void runReductionOperator()
{
	if (isInputSparse(1))
	{
		auto A = inputSparseMatrix<Tx>();
		auto m = A.rows(), n = A.cols();

		using OutputType = decltype(O::f(Tx(1.0), Tx(1.0)));
		Matrix<OutputType> C(1, n);

		// Compute C
		auto Ax = A.valuePtr();
		auto Ai = A.innerIndexPtr(), Aj = A.outerIndexPtr();

		for (auto j = 0; j < n; ++j)
		{
			Tx value = Tx(0.0);
			bool null_value = true;
			for (auto p = Aj[j]; p < Aj[j + 1]; ++p)
			{
				{
					if (null_value)
					{
						value = Ax[p];
						null_value = false;
					}
					else
						value = O::f(value, Ax[p]);
				}
				C(0, j) = value;
			}
		}
		outputDenseMatrix<OutputType>(C);
	}
	else
	{
		auto A = inputDenseMatrix<Tx>();
		auto m = A.rows(), n = A.cols();

		using OutputType = decltype(O::f(Tx(1.0), Tx(1.0)));
		Matrix<OutputType> C(1, n);

		for (auto j = 0; j < n; ++j)
		{
			Tx value = Tx(0.0);
			bool null_value = true;

			for (auto i = 0; i < m; ++i)
			{
				if (null_value)
				{
					value = A(i, j);
					null_value = false;
				}
				else
					value = O::f(value, A(i, j));
			}
			C(0, j) = value;
		}

		outputDenseMatrix<OutputType>(C);
	}
}

struct UnaryOperatorConfig
{
	const static bool NativeOutput = false;
};

template<typename T = CType>
struct absFunc : UnaryOperatorConfig
{
	static T f(size_t i, size_t j, T x)
	{
		return abs(x);
	}
};

template<typename T = CType>
struct sqrtFunc : UnaryOperatorConfig
{
	static T f(size_t i, size_t j, T x)
	{
		return sqrt(x);
	}
};

template<typename T = CType>
struct uminusFunc : UnaryOperatorConfig
{
	static T f(size_t i, size_t j, T x)
	{
		return -x;
	}
};

template<typename T = CType>
struct notFunc : UnaryOperatorConfig
{
	static bool f(size_t i, size_t j, T x)
	{
		return isZero(x);
	}
};

template<typename T = CType>
struct doubleFunc : UnaryOperatorConfig
{
	const static bool NativeOutput = true;
	static double f(size_t i, size_t j, T x)
	{
		return double(x);
	}
};

template<typename T = CType>
struct logicalFunc : UnaryOperatorConfig
{
	const static bool NativeOutput = true;
	static bool f(size_t i, size_t j, T x)
	{
		return !isZero(x);
	}
};

struct BinaryOperatorConfig
{
	const static bool NativeOutput = false;
	const static bool DenseDenseToSparse = false;
	const static bool SparseDenseToSparse = false;
	const static bool DenseSparseToSparse = false;
	const static bool SparseSparseToSparse = true;
};

template<typename T = CType>
struct ltFunc : BinaryOperatorConfig
{
	const static bool NativeOutput = true;
	static bool f(size_t i, size_t j, T x1, T x2, EntryType type)
	{
		return (x1 < x2);
	}
};

template<typename T = CType>
struct gtFunc : BinaryOperatorConfig
{
	const static bool NativeOutput = true;
	static bool f(size_t i, size_t j, T x1, T x2, EntryType type)
	{
		return (x1 > x2);
	}
};

template<typename T = CType>
struct neFunc : BinaryOperatorConfig
{
	const static bool NativeOutput = true;
	static bool f(size_t i, size_t j, T x1, T x2, EntryType type)
	{
		return (x1 != x2);
	}
};

template<typename T = CType>
struct orFunc : BinaryOperatorConfig
{
	const static bool NativeOutput = true;
	static bool f(size_t i, size_t j, T x1, T x2, EntryType type)
	{
		return ((!isZero(x1)) | (!isZero(x2)));
	}
};

template<typename T = CType>
struct andFunc : BinaryOperatorConfig
{
	const static bool NativeOutput = true;
	const static bool SparseDenseToSparse = true;
	const static bool DenseSparseToSparse = true;
	static bool f(size_t i, size_t j, T x1, T x2, EntryType type)
	{
		return ((!isZero(x1)) & (!isZero(x2)));
	}
};

template<typename T = CType>
struct plusFunc : BinaryOperatorConfig
{
	static T f(size_t i, size_t j, T x1, T x2, EntryType type)
	{
		return x1 + x2;
	}
};

template<typename T = CType>
struct minusFunc : BinaryOperatorConfig
{
	static T f(size_t i, size_t j, T x1, T x2, EntryType type)
	{
		return x1 - x2;
	}
};

template<typename T = CType>
struct timesFunc : BinaryOperatorConfig
{
	const static bool SparseDenseToSparse = true;
	const static bool DenseSparseToSparse = true;
	static T f(size_t i, size_t j, T x1, T x2, EntryType type)
	{
		return x1 * x2;
	}
};

template<typename T = CType>
struct rdivideFunc : BinaryOperatorConfig
{
	const static bool SparseSparseToSparse = false;
	const static bool SparseDenseToSparse = true;
	static T f(size_t i, size_t j, T x1, T x2, EntryType type)
	{
		return x1 / x2;
	}
};

template<typename T = CType>
struct max2Func : BinaryOperatorConfig
{
	static T f(size_t i, size_t j, T x1, T x2, EntryType type)
	{
		return std::max(x1, x2);
	}
};

template<typename T = CType>
struct min2Func : BinaryOperatorConfig
{
	static T f(size_t i, size_t j, T x1, T x2, EntryType type)
	{
		return std::min(x1, x2);
	}
};

template<typename T = CType>
struct maxFunc
{
	static T f(T x, T y)
	{
		return std::max(x, y);
	}
};

template<typename T = CType>
struct minFunc
{
	static T f(T x, T y)
	{
		return std::min(x, y);
	}
};

template<typename T = CType>
struct prodFunc
{
	static T f(T x, T y)
	{
		return x * y;
	}
};

template<typename T = CType>
struct sumFunc
{
	static T f(T x, T y)
	{
		return x + y;
	}
};


#define DEFINE_UNARY_OP(O) case str2int(#O): runUnaryOperator<O##Func<CType>>(); break;
#define DEFINE_BINARY_OP(O) case str2int(#O): runBinaryOperator<O##Func<CType>>(); break;
#define DEFINE_REDUCT_OP(O) case str2int(#O): runReductionOperator<O##Func<CType>>(); break;

int main()
{
	auto cmd = inputString();
	auto cmd_hash = str2int(cmd.c_str());
	switch (cmd_hash)
	{
	case str2int("toMex"):
#if defined(CUSTOM_TOMEX)
		customToMex();
		break;
#else
		if (isInputSparse(1))
			outputSparseMatrix<CType>(inputSparseMatrix<double>());
		else
			outputDenseMatrix<CType>(inputDenseMatrix<double>());
		break;
#endif
	DEFINE_UNARY_OP(abs)
	DEFINE_UNARY_OP(sqrt)
	DEFINE_UNARY_OP(uminus)
	DEFINE_UNARY_OP(not)
	DEFINE_UNARY_OP(double)
	DEFINE_UNARY_OP(logical)
	DEFINE_BINARY_OP(lt)
	DEFINE_BINARY_OP(gt)
	DEFINE_BINARY_OP(ne)
	DEFINE_BINARY_OP(and)
	DEFINE_BINARY_OP(or )
	DEFINE_BINARY_OP(plus)
	DEFINE_BINARY_OP(minus)
	DEFINE_BINARY_OP(times)
	DEFINE_BINARY_OP(rdivide)
	DEFINE_BINARY_OP(max2)
	DEFINE_BINARY_OP(min2)
	DEFINE_REDUCT_OP(max)
	DEFINE_REDUCT_OP(min)
	DEFINE_REDUCT_OP(sum)
	DEFINE_REDUCT_OP(prod)
	case str2int("transpose"):
		{
			if (isInputSparse(1))
				outputSparseMatrix<CType>(inputSparseMatrix<CType>().transpose());
			else
				outputDenseMatrix<CType>(inputDenseMatrix<CType>().transpose());
			break;
		}
	case str2int("mtimes"):
	{
		if (isInputSparse(1) && isInputSparse(2))
		{
			auto A = inputSparseMatrix<CType>();
			auto B = inputSparseMatrix<CType>();
			assertThrow(A.cols() == B.rows(), "mtimes: Incompatible sizes.");

			SparseMatrix<CType> C = A * B;
			outputSparseMatrix<CType>(C);
		}
		else if (!isInputSparse(1) && isInputSparse(2))
		{
			auto A = inputDenseMatrix<CType>();
			auto B = inputSparseMatrix<CType>();
			assertThrow(A.cols() == B.rows(), "mtimes: Incompatible sizes.");

			Matrix<CType> C = A * B;
			outputDenseMatrix<CType>(C);
		}
		else if (isInputSparse(1) && !isInputSparse(2))
		{
			auto A = inputSparseMatrix<CType>();
			auto B = inputDenseMatrix<CType>();
			assertThrow(A.cols() == B.rows(), "mtimes: Incompatible sizes.");

			Matrix<CType> C = A * B;
			outputDenseMatrix<CType>(C);
		}
		else
		{
			auto A = inputDenseMatrix<CType>();
			auto B = inputDenseMatrix<CType>();
			assertThrow(A.cols() == B.rows(), "mtimes: Incompatible sizes.");

			Matrix<CType> C = A * B;
			outputDenseMatrix<CType>(C);
		}
		break;
	}
	case str2int("mldivide"):
	{
		Matrix<CType> C;
		if (isInputSparse(1))
		{
			auto A = inputSparseMatrix<CType>();
			auto B = inputDenseMatrix<CType>();
			assertThrow(A.rows() == B.rows(), "mldivide: Incompatible sizes.");

			bool solved = false;
			if (A.cols() == B.rows())
			{
				auto A_lower = A.triangularView<Eigen::Lower>();
				if (!solved && A.isApprox(A_lower))
				{
					C = A_lower.solve(B);
					solved = true;
				}

				auto A_upper = A.triangularView<Eigen::Upper>();
				if (!solved && A.isApprox(A_upper))
				{
					C = A_upper.solve(B);
					solved = true;
				}

				if (!solved && A.isApprox(A.transpose()))
				{
					Eigen::SimplicialLDLT<SparseMatrix<CType>> solver(A);
					if (solver.info() == Eigen::Success)
					{
						C = solver.solve(B);
						solved = true;
					}
				}

				if (!solved)
				{
					Eigen::SparseLU<SparseMatrix<CType>> solver(A);
					if (solver.info() == Eigen::Success)
					{
						C = solver.solve(B);
						solved = true;
					}
				}
			}

			if (!solved)
			{
				Eigen::SparseQR<SparseMatrix<CType>, Eigen::COLAMDOrdering<Eigen::Index>> solver(A);
				assertThrow(solver.info() == Eigen::Success, "mldivide: solver failed.");
				C = solver.solve(B);
			}
		}
		else
		{
			auto A = inputDenseMatrix<CType>();
			auto B = inputDenseMatrix<CType>();
			assertThrow(A.rows() == B.rows(), "mldivide: Incompatible sizes.");

			bool solved = false;

			if (A.cols() == B.rows())
			{
				if (A.isLowerTriangular())
				{
					C = A.triangularView<Eigen::Lower>().solve(B);
					solved = true;
				}
				else if (A.isUpperTriangular())
				{
					C = A.triangularView<Eigen::Upper>().solve(B);
					solved = true;
				}
				else if (A.isUnitary())
				{
					auto solver = A.ldlt();
					if (solver.info() == Eigen::Success)
					{
						C = solver.solve(B);
						solved = true;
					}
				}

				if (!solved)
					C = A.fullPivLu().solve(B);
			}
			else
			{
				auto solver = A.colPivHouseholderQr();
				assertThrow(solver.info() == Eigen::Success, "mldivide: solver failed.");
				C = solver.solve(B);
			}
		}

		outputDenseMatrix<CType>(C);
		break;
	}
	case str2int("chol"):
	{
		if (isInputSparse(1))
		{
			auto A = inputSparseMatrix<CType>();
			assertThrow(A.rows() == A.cols(), "chol: Incompatible sizes.");

			Eigen::SimplicialLLT<SparseMatrix<CType>, Eigen::Upper, Eigen::NaturalOrdering<Eigen::Index>> lltOfA(A); // compute the Cholesky decomposition of A
			assertThrow(lltOfA.info() == Eigen::Success, "chol: solver failed.");
			SparseMatrix<CType> U = lltOfA.matrixU();
			outputSparseMatrix<CType>(U);
		}
		else
		{
			auto A = inputDenseMatrix<CType>();
			assertThrow(A.rows() == A.cols(), "chol: Incompatible sizes.");

			Eigen::LLT<Matrix<CType>> lltOfA(A); // compute the Cholesky decomposition of A
			assertThrow(lltOfA.info() == Eigen::Success, "chol: solver failed.");
			Matrix<CType> U = lltOfA.matrixU();
			outputDenseMatrix<CType>(U);
		}
		break;
	}
	case str2int("eps"):
	{
		Matrix<CType> eps = Matrix<CType>::Constant(1, 1, std::numeric_limits<CType>::epsilon());
		outputDenseMatrix<CType>(eps);
		break;
	}
	default:
		throw std::runtime_error("Unsupported command: " + cmd);
	}
}