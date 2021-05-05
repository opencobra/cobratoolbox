Solver compatibility
--------------------

Linux Ubuntu
~~~~~~~~~~~~

+-------------------+--------------------+--------------------+--------------------+--------------------+
| SolverName        | R2021b             | R2021a             | R2020b             | R2020a             | 
+===================+====================+====================+====================+====================+
| IBM CPLEX 20.10   |       |x|          |       |x|          |       |x|          |       |x|          |
+-------------------+--------------------+--------------------+--------------------+--------------------+
| IBM CPLEX 12.10   | |white_check_mark| | |white_check_mark| | |white_check_mark| | |white_check_mark| |
+-------------------+--------------------+--------------------+--------------------+--------------------+
| IBM CPLEX 12.8    | |white_check_mark| | |white_check_mark| | |white_check_mark| | |white_check_mark| | 
+-------------------+--------------------+--------------------+--------------------+--------------------+
| GUROBI 9.1.1      | |white_check_mark| | |white_check_mark| | |white_check_mark| | |white_check_mark| |
+-------------------+--------------------+--------------------+--------------------+--------------------+
| TOMLAB CPLEX 8.6  | |white_check_mark| | |white_check_mark| | |white_check_mark| | |white_check_mark| |
+-------------------+--------------------+--------------------+--------------------+--------------------+
| MOSEK 9.2         | |white_check_mark| | |white_check_mark| | |white_check_mark| | |white_check_mark| |
+-------------------+--------------------+--------------------+--------------------+--------------------+
| GLPK              | |white_check_mark| | |white_check_mark| | |white_check_mark| | |white_check_mark| |
+-------------------+--------------------+--------------------+--------------------+--------------------+
| DQQ MINOS         | |white_check_mark| | |white_check_mark| | |white_check_mark| | |white_check_mark| |
+-------------------+--------------------+--------------------+--------------------+--------------------+
| PDCO              | |white_check_mark| | |white_check_mark| | |white_check_mark| | |white_check_mark| |
+-------------------+--------------------+--------------------+--------------------+--------------------+

macOS 10.13+
~~~~~~~~~~~~

+-------------------+--------------------+--------------------+--------------------+--------------------+
| SolverName        | R2021b             | R2021a             | R2020b             | R2020a             | 
+===================+====================+====================+====================+====================+
| IBM CPLEX 20.10   |       |x|          |       |x|          |       |x|          |       |x|          |
+-------------------+--------------------+--------------------+--------------------+--------------------+
| IBM CPLEX 12.10   | |white_check_mark| | |white_check_mark| | |white_check_mark| | |white_check_mark| |
+-------------------+--------------------+--------------------+--------------------+--------------------+
| IBM CPLEX 12.8    | |white_check_mark| | |white_check_mark| | |white_check_mark| | |white_check_mark| | 
+-------------------+--------------------+--------------------+--------------------+--------------------+
| GUROBI 9.1.1      | |white_check_mark| | |white_check_mark| | |white_check_mark| | |white_check_mark| |
+-------------------+--------------------+--------------------+--------------------+--------------------+
| TOMLAB CPLEX 8.6  | |white_check_mark| | |white_check_mark| | |white_check_mark| | |white_check_mark| |
+-------------------+--------------------+--------------------+--------------------+--------------------+
| MOSEK 9.2         | |white_check_mark| | |white_check_mark| | |white_check_mark| | |white_check_mark| |
+-------------------+--------------------+--------------------+--------------------+--------------------+
| GLPK              | |white_check_mark| | |white_check_mark| | |white_check_mark| | |white_check_mark| |
+-------------------+--------------------+--------------------+--------------------+--------------------+
| DQQ MINOS         | |white_check_mark| | |white_check_mark| | |white_check_mark| | |white_check_mark| |
+-------------------+--------------------+--------------------+--------------------+--------------------+
| PDCO              | |white_check_mark| | |white_check_mark| | |white_check_mark| | |white_check_mark| |
+-------------------+--------------------+--------------------+--------------------+--------------------+


Windows 10
~~~~~~~~~~

+-------------------+--------------------+--------------------+--------------------+--------------------+
| SolverName        | R2021b             | R2021a             | R2020b             | R2020a             | 
+===================+====================+====================+====================+====================+
| IBM CPLEX 20.10   |       |x|          |       |x|          |       |x|          |       |x|          |
+-------------------+--------------------+--------------------+--------------------+--------------------+
| IBM CPLEX 12.10   | |white_check_mark| | |white_check_mark| | |white_check_mark| | |white_check_mark| |
+-------------------+--------------------+--------------------+--------------------+--------------------+
| IBM CPLEX 12.8    | |white_check_mark| | |white_check_mark| | |white_check_mark| | |white_check_mark| | 
+-------------------+--------------------+--------------------+--------------------+--------------------+
| GUROBI 9.1.1      | |white_check_mark| | |white_check_mark| | |white_check_mark| | |white_check_mark| |
+-------------------+--------------------+--------------------+--------------------+--------------------+
| TOMLAB CPLEX 8.6  | |white_check_mark| | |white_check_mark| | |white_check_mark| | |white_check_mark| |
+-------------------+--------------------+--------------------+--------------------+--------------------+
| MOSEK 9.2         | |white_check_mark| | |white_check_mark| | |white_check_mark| | |white_check_mark| |
+-------------------+--------------------+--------------------+--------------------+--------------------+
| GLPK              | |white_check_mark| | |white_check_mark| | |white_check_mark| | |white_check_mark| |
+-------------------+--------------------+--------------------+--------------------+--------------------+
| DQQ MINOS         | |white_check_mark| | |white_check_mark| | |white_check_mark| | |white_check_mark| |
+-------------------+--------------------+--------------------+--------------------+--------------------+
| PDCO              | |white_check_mark| | |white_check_mark| | |white_check_mark| | |white_check_mark| |
+-------------------+--------------------+--------------------+--------------------+--------------------+

.. rubric:: Legend

-  |white_check_mark| : compatible with the COBRA Toolbox (tested)
-  |x| : not compatible with the COBRA Toolbox (tested)
-  |warning| : possibly incompatibile with the COBRA Toolbox (problems reported)

.. rubric:: Notes

-  Make sure to install the correct Tomlab version for your version of ``macOS``. Please note that there is a different Tomlab installer for MATLAB ``R2017a+``.
-  Only **actively** supported interfaces are evaluated for compatibility.
-  The ``matlab`` solver interface is compatible with all actively supported MATLAB versions.
-  The interfaces ``cplex_direct`` and ``tomlab_snopt`` bear the same compatibility pattern as ``tomlab_cplex``.
-  The interface ``quadMinos`` bears the same compatibility pattern as ``dqqMinos``.
-  The interface ``lindo_old`` bears the same compatibility pattern as ``lindo_legacy``.

.. |white_check_mark| raw:: html

   <img src="https://king.nuigalway.ie/cobratoolbox/img/white_check_mark.png" height="20px" width="20px" alt="white_check_mark">

.. |warning| raw:: html

   <img src="https://king.nuigalway.ie/cobratoolbox/img/warning.png" height="20px" width="20px" alt="warning">

.. |x| raw:: html

   <img src="https://king.nuigalway.ie/cobratoolbox/img/x.png" height="20px" width="20px" alt="warning">
