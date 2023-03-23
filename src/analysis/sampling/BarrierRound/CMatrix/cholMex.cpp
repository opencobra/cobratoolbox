#include <random>

#include <qd/dd_real.h>
#include <qd/qd_real.h>

#include "CMatrixUtils.h"

namespace Eigen
{
	template<> struct NumTraits<dd_real> : DefaultNumTraits<dd_real> {};
	template<> struct NumTraits<qd_real> : DefaultNumTraits<qd_real> {};
}

enum realType : uint32_t
{
	doubleType = 1,
	dd_realType = 2,
	qd_realType = 3
};

template<class T>
using LLT = Eigen::SimplicialLLT<SparseMatrix<T>, Eigen::Upper, Eigen::NaturalOrdering<Eigen::Index>>;

// First, how to include the matrix
// Automatically choosen. Then, it creates a Chol Solver of that type.
// Okay, maybe A has all type already. Call matrixType
// Then, I have cholType
// Both factorize and solve are template function to avoid too much backAndForth
// solve have input on how many iterations.

template <typename CType>
struct CholSolver
{
	SparseMatrix<CType> A;
	SparseMatrix<CType> At;
	LLT<CType> L;
	std::mt19937_64 gen;

	bool analyzed = false;

	template<typename T>
	void initialize(T A_, uint64_t uid)
	{
		A = A_.template cast<CType>();
		gen.seed(uid);
	}

	template<typename T>
	void factorize(T W)
	{
		assertThrow(A.cols() == W.rows(), "factorize: dimension mismatch.");

		if (!analyzed)
			At = A.transpose();

		SparseMatrix<CType> AW = A * W.template cast<CType>();
		SparseMatrix<CType> H = AW * At;

		double offset = inputScalar<double>();
		L.setShift(CType(offset));

		if (!analyzed)
		{
			L.analyzePattern(H);
			analyzed = true;
		}

		L.factorize(H);
		outputScalar<bool>(L.info() == Eigen::Success);
	}

	void halfProj(int k)
	{
		assertThrow(L.info() == Eigen::Success, "factorize must be called before leverageScore.");

		std::bernoulli_distribution dist(0.5);

		auto n = L.rows();
		Matrix<CType> z(n, k);
		for (auto j = 0; j < k; ++j)
		{
			for (auto i = 0; i < n; ++i)
			{
				z(i, j) = CType(double(dist(gen))*2.0-1.0);
			}
		}

		L.matrixU().solveInPlace(z);
		Matrix<CType> u = At * z;

		outputDenseMatrix<CType>(u, true);
	}

	void outputDiagonal()
	{
		assertThrow(L.info() == Eigen::Success, "diagonal: Numerical Issue.");
		SparseMatrix<CType> L_concrete = L.matrixL();
		Matrix<CType> D = L_concrete.diagonal();
		outputDenseMatrix<CType>(D, true);
	}
};

struct CholSolvers
{
	realType cholType;
	CholSolver<double> solver_d;
	CholSolver<dd_real> solver_dd;
	CholSolver<qd_real> solver_qd;

	template<typename T>
	void initialize(uint64_t uid)
	{
		auto A = inputSparseMatrix<T>();
		solver_d.initialize(A, uid);
		solver_dd.initialize(A, uid);
		solver_qd.initialize(A, uid);
	}

	template<typename T, typename T2>
	void solveStep(Matrix<T> &X, T2 &B)
	{
		if (cholType == doubleType)
		{
			assertThrow(solver_d.L.info() == Eigen::Success, "solve: Numerical Issue.");
			assertThrow(solver_d.A.rows() == B.rows(), "solve: dimension mismatch.");
			X = solver_d.L.solve(B.template cast<double>()).template cast<T>();
		}
		else if (cholType == dd_realType)
		{
			assertThrow(solver_dd.L.info() == Eigen::Success, "solve: Numerical Issue.");
			assertThrow(solver_dd.A.rows() == B.rows(), "solve: dimension mismatch.");
			X = solver_dd.L.solve(B.template cast<dd_real>()).template cast<T>();
		}
		else if (cholType == qd_realType)
		{
			assertThrow(solver_qd.L.info() == Eigen::Success, "solve: Numerical Issue.");
			assertThrow(solver_qd.A.rows() == B.rows(), "solve: dimension mismatch.");
			X = solver_qd.L.solve(B.template cast<qd_real>()).template cast<T>();
		}
	}

	template<typename T>
	void solve()
	{
		auto B = inputDenseMatrix<T>();
		auto W = inputSparseMatrix<T>();
		int step = (int)inputScalar<double>();
		Matrix<T> X;
		solveStep(X, B);

		Matrix<T> R, Atx, WAtx, Hinv_R;
		for (int i = 1; i < step; ++i)
		{
			if (cholType == doubleType)
			{
				Atx = solver_d.At.cast<T>() * X;
				WAtx = W * Atx;
				R = B - solver_d.A.cast<T>() * WAtx;
			}
			else if (cholType == dd_realType)
			{
				Atx = solver_dd.At.cast<T>() * X;
				WAtx = W * Atx;
				R = B - solver_dd.A.cast<T>() * WAtx;
			}
			else if (cholType == qd_realType)
			{
				Atx = solver_qd.At.cast<T>() * X;
				WAtx = W * Atx;
				R = B - solver_qd.A.cast<T>() * WAtx;
			}
			solveStep(Hinv_R, R);
			X += Hinv_R;
		}
		outputDenseMatrix<T>(X, true);
	}
};

int main()
{
	auto cmd = inputString();
	auto cmdHash = str2int(cmd.c_str());

	uint64_t uid = inputScalar<uint64_t>();
	if (cmdHash == str2int("new"))
	{
		CholSolvers* solver = new CholSolvers;

		if (compatibleWith<double>(rhs_id))
			solver->initialize<double>(uid);
		else if (compatibleWith<dd_real>(rhs_id))
			solver->initialize<dd_real>(uid);
		else if (compatibleWith<qd_real>(rhs_id))
			solver->initialize<qd_real>(uid);
		else
			throw std::runtime_error("Unsupported type.");

		outputScalar<uint64_t>((uint64_t)solver);
	}
	else
	{
		CholSolvers* solver = (CholSolvers*)uid;
		switch (cmdHash)
		{
		case str2int("solve"):
		{
			if (compatibleWith<double>(rhs_id))
				solver->solve<double>();
			else if (compatibleWith<dd_real>(rhs_id))
				solver->solve<dd_real>();
			else if (compatibleWith<qd_real>(rhs_id))
				solver->solve<qd_real>();
			else
				throw std::runtime_error("Unsupported type.");
			break;
		}
		case str2int("factorize"):
		{
			if (compatibleWith<double>(rhs_id))
			{
				solver->solver_d.factorize(inputSparseMatrix<double>());
				solver->cholType = doubleType;
			}
			else if (compatibleWith<dd_real>(rhs_id))
			{
				solver->solver_dd.factorize(inputSparseMatrix<dd_real>());
				solver->cholType = dd_realType;
			}
			else if (compatibleWith<qd_real>(rhs_id))
			{
				solver->solver_qd.factorize(inputSparseMatrix<qd_real>());
				solver->cholType = qd_realType;
			}
			else
				throw std::runtime_error("Unsupported type.");
			break;
		}
		case str2int("diagonal"):
		{
			if (solver->cholType == doubleType)
				solver->solver_d.outputDiagonal();
			else if (solver->cholType == dd_realType)
				solver->solver_dd.outputDiagonal();
			else if (solver->cholType == qd_realType)
				solver->solver_qd.outputDiagonal();
			else
				throw std::runtime_error("Unsupported type.");
			break;
		}
		case str2int("halfProj"):
		{
			int JLDim = (int)inputScalar<double>();
         
			if (solver->cholType == doubleType)
				solver->solver_d.halfProj(JLDim);
			else if (solver->cholType == dd_realType)
				solver->solver_dd.halfProj(JLDim);
			else if (solver->cholType == qd_realType)
				solver->solver_qd.halfProj(JLDim);
			else
				throw std::runtime_error("Unsupported type.");
			break;
		}
		case str2int("delete"):
		{
			delete solver;
			break;
		}
		default:
			throw std::runtime_error("Unsupported command: " + cmd);
		}
	}
}