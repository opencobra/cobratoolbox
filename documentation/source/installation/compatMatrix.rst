Solver compatibility
====================

This document summarises tested solver compatibility with the COBRA Toolbox across operating systems and MATLAB releases.

Linux Ubuntu
------------

.. list-table::
   :header-rows: 1
   :widths: 24 12 12 12 12

   * - SolverName
     - R2024a
     - R2024b
     - R2025a
     - R2025b
   * - GUROBI 12.0
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
   * - IBM CPLEX
     - ❌
     - ❌
     - ❌
     - ❌

macOS 10.13+
------------

.. list-table::
   :header-rows: 1
   :widths: 24 12 12 12 12

   * - SolverName
     - R2024a
     - R2024b
     - R2025a
     - R2025b
   * - GUROBI 12.0
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
   * - IBM CPLEX
     - ❌
     - ❌
     - ❌
     - ❌


Windows 10
----------

.. list-table::
   :header-rows: 1
   :widths: 24 12 12 12 12

   * - SolverName
     - R2024a
     - R2024b
     - R2025a
     - R2025b
   * - GUROBI 12.0
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
   * - IBM CPLEX
     - ❌
     - ❌
     - ❌
     - ❌


** Notice that IBM CPLEX no longer support MATLAB interface. The latest version of MATLAB and CPLEX that are compatible with each other is MATLAB R2019b with IBM ILOG CPLEX Optimization Studio Version 12.10.0.0. Running the COBRA toolbox on a system where IBM Cplex is installed, with any MATLAB later than R2019b is prone to a software conflict and crash.

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
