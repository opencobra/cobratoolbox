#include <qd/dd_real.h>
#include <qd/qd_real.h>
using CType = dd_real;

#include "CMatrixUtils.h"

namespace Eigen
{
	template<> struct NumTraits<CType> : DefaultNumTraits<CType> {};
}

#include "customToMex.h"
#include "CMatrixMex.h"