#pragma once

#define CUSTOM_TOMEX

void customToMex()
{
	if (isInputSparse(1))
	{
		if (compatibleWith<double>(1))
			outputSparseMatrix<CType>(inputSparseMatrix<double>());
		else if (compatibleWith<dd_real>(1))
			outputSparseMatrix<CType>(inputSparseMatrix<dd_real>());
		else if (compatibleWith<qd_real>(1))
			outputSparseMatrix<CType>(inputSparseMatrix<qd_real>());
		else
			throw std::runtime_error("Unsupported type for toMex.");
	}
	else
	{
		if (compatibleWith<double>(1))
		{
			outputDenseMatrix<CType>(inputDenseMatrix<double>());
		}
		else if (compatibleWith<dd_real>(1))
		{
			outputDenseMatrix<CType>(inputDenseMatrix<dd_real>());
		}
		else if (compatibleWith<qd_real>(1))
		{
			outputDenseMatrix<CType>(inputDenseMatrix<qd_real>());
		}
		else
			throw std::runtime_error("Unsupported type for toMex.");
	}
}