Quick readme: start with demo_template.m, and modify the problem to the one you want to sample; demo_template has a few examples. 

The main component of this package is the function
sample in sample.m
to sample according to a density proportional to a given function of the form 

f(x) = exp(-sum f_i(x_i)) 

restricted to a polyhedron defined by
{Aineq x <= bineq, Aeq x = beq, lb <= x <= ub}

The function f is given by a vector function of its 1st, 2nd and 3rd derivatives.
Only the first derivative is required.
If 2nd derivative is provided, 3rd derivative must also be provided, else it is assumed to be zero.

This core function sample.m is supplemented by functions to: 
1. find an initial feasible point 
2. test convergence of the sampling algorithm
3. compute a set of statistics using sampling, including the center of gravity, covariance matrix, 
marginal distribution and volume/integral

Before using sample, the function prepare sets up the parameters for sampling.
The function prepare.m takes an input problem (in the object Problem)
and a structure of options called opts with the following properties:

  trajLength - trajectory length of each step in HMC (default:2)
               Decrease this number to get better accuracy and robustness.

  JLsize - dimension of subspace used to estimate the drift (default:7)
           Increase this number to get better accuracy.

  maxRelativeStepSize - the maximum step size
    (relative to the distance to the boundary) in the ODE solver (default:0.2)

  method - the ODE solver (default:@implicitMidPoint)
    Use @GaussLegendre4 for better accuracy

  maxStepSize - the maximum step size in the ODE solver (default:0.1)

  minStepSize - the minimum step size in the ODE solver  (default:1e-4)
     If the ODE solver uses smaller step size multiple times, the program quits

  display - show the number of iterations (default:false)
and outputs a samplePlan.

The sample function takes as input: 

  samplePlan - (output by prepare) and 

  N - the number of desired samples (note: one per step; the program also outputs an estimate of the mixing time, so one can divide N by the mixing time to get the effective number of samples)

and outputs a dim x N array of samples (also in the basis of the span of the domain).




