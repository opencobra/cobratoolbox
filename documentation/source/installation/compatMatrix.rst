Solver compatibility
====================

This document summarises tested solver compatibility with the COBRA Toolbox across operating systems and MATLAB releases.

Linux Ubuntu
------------

.. list-table::
   :header-rows: 1
   :widths: 24 12 12 12 12

   * - SolverName
     - R2023b
     - R2021b
     - R2020b
     - R2020a
   * - IBM CPLEX 20.10
     - ❌
     - ❌
     - ❌
     - ❌
   * - IBM CPLEX 12.10
     - ✅
     - ✅
     - ✅
     - ✅
   * - IBM CPLEX 12.8
     - ✅
     - ✅
     - ✅
     - ✅
   * - GUROBI 9.1.1
     - ✅
     - ✅
     - ✅
     - ✅
   * - TOMLAB CPLEX 8.6
     - ✅
     - ✅
     - ✅
     - ✅
   * - MOSEK 10.1
     - ✅
     - ✅
     - ✅
     - ✅
   * - GLPK
     - ✅
     - ✅
     - ✅
     - ✅
   * - DQQ MINOS
     - ✅
     - ✅
     - ✅
     - ✅
   * - PDCO
     - ✅
     - ✅
     - ✅
     - ✅

macOS 10.13+
------------

.. list-table::
   :header-rows: 1
   :widths: 24 12 12 12 12

   * - SolverName
     - R2021b
     - R2021a
     - R2020b
     - R2020a
   * - IBM CPLEX 20.10
     - ❌
     - ❌
     - ❌
     - ❌
   * - IBM CPLEX 12.10
     - ✅
     - ✅
     - ✅
     - ✅
   * - IBM CPLEX 12.8
     - ✅
     - ✅
     - ✅
     - ✅
   * - GUROBI 9.1.1
     - ✅
     - ✅
     - ✅
     - ✅
   * - TOMLAB CPLEX 8.6
     - ✅
     - ✅
     - ✅
     - ✅
   * - MOSEK 10.1
     - ✅
     - ✅
     - ✅
     - ✅
   * - GLPK
     - ✅
     - ✅
     - ✅
     - ✅
   * - DQQ MINOS
     - ✅
     - ✅
     - ✅
     - ✅
   * - PDCO
     - ✅
     - ✅
     - ✅
     - ✅

Windows 10
----------

.. list-table::
   :header-rows: 1
   :widths: 24 12 12 12 12

   * - SolverName
     - R2021b
     - R2021a
     - R2020b
     - R2020a
   * - IBM CPLEX 20.10
     - ❌
     - ❌
     - ❌
     - ❌
   * - IBM CPLEX 12.10
     - ✅
     - ✅
     - ✅
     - ✅
   * - IBM CPLEX 12.8
     - ✅
     - ✅
     - ✅
     - ✅
   * - GUROBI 9.1.1
     - ✅
     - ✅
     - ✅
     - ✅
   * - TOMLAB CPLEX 8.6
     - ✅
     - ✅
     - ✅
     - ✅
   * - MOSEK 10.1
     - ✅
     - ✅
     - ✅
     - ✅
   * - GLPK
     - ✅
     - ✅
     - ✅
     - ✅
   * - DQQ MINOS
     - ✅
     - ✅
     - ✅
     - ✅
   * - PDCO
     - ✅
     - ✅
     - ✅
     - ✅


Legend
------

- ✅ : compatible with the COBRA Toolbox (tested)
- ❌ : not compatible with the COBRA Toolbox (tested)
- ⚠️ : possibly incompatible with the COBRA Toolbox (problems reported)

Notes
-----

- Make sure to install the correct Tomlab version for your version of ``macOS``. There is a different Tomlab installer for MATLAB ``R2017a+``.
- Only **actively** supported interfaces are evaluated for compatibility.
- The ``matlab`` solver interface is compatible with all actively supported MATLAB versions.
- The interfaces ``cplex_direct`` and ``tomlab_snopt`` bear the same compatibility pattern as ``tomlab_cplex``.
- The interface ``quadMinos`` bears the same compatibility pattern as ``dqqMinos``.
- The interface ``lindo_old`` bears the same compatibility pattern as ``lindo_legacy``.
