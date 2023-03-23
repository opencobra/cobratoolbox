#pragma once
#include <cstdint>
#include <typeinfo>
#include <string>
#include <stdexcept>
#include "mex.h"

namespace MexEnvironment
{
	using std::string;
	using std::to_string;
	using SignedIndex = std::make_signed<mwIndex>::type;

	template <typename T> mxClassID MexType()
	{
		return mxUNKNOWN_CLASS;
	}

#define MEX_TYPE_DEFINE(CType, class_id) \
        template <> mxClassID MexType<CType>() { return class_id; }

	MEX_TYPE_DEFINE(bool, mxLOGICAL_CLASS);
	MEX_TYPE_DEFINE(char, mxCHAR_CLASS);
	MEX_TYPE_DEFINE(int8_t, mxINT8_CLASS);
	MEX_TYPE_DEFINE(uint8_t, mxUINT8_CLASS);
	MEX_TYPE_DEFINE(int16_t, mxINT16_CLASS);
	MEX_TYPE_DEFINE(uint16_t, mxUINT16_CLASS);
	MEX_TYPE_DEFINE(int32_t, mxINT32_CLASS);
	MEX_TYPE_DEFINE(uint32_t, mxUINT32_CLASS);
	MEX_TYPE_DEFINE(int64_t, mxINT64_CLASS);
	MEX_TYPE_DEFINE(uint64_t, mxUINT64_CLASS);
	MEX_TYPE_DEFINE(float, mxSINGLE_CLASS);
	MEX_TYPE_DEFINE(double, mxDOUBLE_CLASS);

#undef MEX_TYPE_DEFINE

#define assertThrow(val, msg) if (!(val)) throw std::runtime_error(msg);

	/* ====== Parameters Info ====== */
	// input
	const mxArray** prhs;
	size_t nrhs;
	size_t rhs_id = 0; // index to next input

	// output
	mxArray** plhs;
	size_t nlhs;
	size_t lhs_id = 0; // index to next output

	const mxArray* input(int id = -1)
	{
		assertThrow(rhs_id < nrhs, "At least " + to_string(rhs_id + 1) + " input parameters are required.");

		return prhs[rhs_id++];
	}

	void output(mxArray* out)
	{
		assertThrow(lhs_id < nlhs, "At least " + to_string(lhs_id + 1) + " output parameters are required.");

		plhs[lhs_id++] = out;
	}

	const size_t kAnySize = size_t(-1);
	void checkInputSize(size_t required_m, size_t required_n, size_t m, size_t n)
	{
		if ((required_m != kAnySize && required_m != m) || (required_n != kAnySize && required_n != n))
		{
			string required_m_string = std::to_string(required_m),
				required_n_string = std::to_string(required_n);

			if (required_m == kAnySize)
				required_m_string = "*";

			if (required_n == kAnySize)
				required_n_string = "*";

			throw std::runtime_error("Incorrect dimension for " + to_string(rhs_id) + "-th parameter. "
				"It should be (" + required_m_string + "," + required_n_string + ")"
				" instead of (" + to_string(m) + "," + to_string(n) + ")"
				" where * indicates any non-negative numbers.");
		}
	}

	/* ====== Basic input/output Functions ====== */
	string inputString()
	{
		const mxArray* pt = input();
		assertThrow(mxIsChar(pt), "The " + to_string(rhs_id) + "-th parameter should be a string.");

		const char* x = mxArrayToString(pt);
		string output = string(x);
		mxFree((void*)x);
		return output;
	}

	void outputString(const char* str)
	{
		output(mxCreateString(str));
	}

	template<typename T>
	const T* inputArray(size_t& required_m, size_t& required_n)
	{
		const mxArray* pt = input();

		auto nDim = mxGetNumberOfDimensions(pt);
		assertThrow(!mxIsComplex(pt) && !mxIsSparse(pt) && nDim == 2,
			"The " + to_string(rhs_id) + "-th parameter should be a real full 2-dim array.");

		assertThrow(mxGetClassID(pt) == MexType<T>(),
			"The " + to_string(rhs_id) + "-th parameter should be " + typeid(T).name());

		size_t m = mxGetM(pt), n = mxGetN(pt);
		checkInputSize(required_m, required_n, m, n);
		required_m = m; required_n = n;

		return (T*)mxGetData(pt);
	}

	template<typename T>
	const T* inputArray(size_t& required_m)
	{
		size_t required_n = 1;
		return inputArray<T>(required_m, required_n);
	}

	template<typename T>
	T inputScalar()
	{
		size_t required_m = 1, required_n = 1;
		return *inputArray<T>(required_m, required_n);
	}

	template<typename T>
	T inputScalar(T default_value)
	{
		if (rhs_id < nrhs)
			return inputScalar<T>();
		else
			return default_value;
	}

	template<typename T>
	T* outputArray(size_t m, size_t n = 1)
	{
		mxArray* pt = mxCreateNumericMatrix(m, n, MexType<T>(), mxREAL);
		output(pt);

		return (T*)mxGetData(pt);
	}

	template<typename T>
	void outputArray(T* x, size_t m, size_t n = 1)
	{
		double* out = outputArray<T>(m, n);
		for (size_t s = 0; s < m * n; ++s)
			out[s] = T(x[s]);
	}

	template<typename T>
	void outputScalar(T val)
	{
		*outputArray<T>(1, 1) = val;
	}
};

int main();

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
	try
	{
		MexEnvironment::nlhs = nlhs;
		MexEnvironment::nrhs = nrhs;
		MexEnvironment::plhs = plhs;
		MexEnvironment::prhs = prhs;
		MexEnvironment::lhs_id = 0;
		MexEnvironment::rhs_id = 0;
		main();
	}
	catch (const char* str)
	{
		mexErrMsgTxt(str);
	}
	catch (std::string str)
	{
		mexErrMsgTxt(str.c_str());
	}
	catch (const std::exception& e)
	{
		mexErrMsgTxt(e.what());
	}

	return;
}