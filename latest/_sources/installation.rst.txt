Installation
============

.. raw:: html

   <br>
   <div class="alert alert-danger">
     <strong>System Requirements:</strong>
     Please follow <a href="https://opencobra.github.io/cobratoolbox/docs/requirements.html">this guide</a> in order to configure your system properly.
   </div>

   <div class="alert alert-warning">
       <strong>Solver Installation:</strong>
       The default solver is <code>glpk</code> (for <code>LP</code> and <code>MILP</code>). You can install <code>TOMLAB</code>, <code>IBM ILOG CPLEX</code>, <code>GUROBI</code>, or <code>MOSEK</code> by following these <strong><a href="https://opencobra.github.io/cobratoolbox/docs/solvers.html">detailed instructions</a></strong>.
   </div>
   <ol>
   <li>
   <p>Download this repository (the folder <code>./cobratoolbox/</code> will be created). You can clone the repository using:</p>
   <code class="descname"><pre>$ git clone https://github.com/opencobra/cobratoolbox.git</pre></code>
   <p><a href="https://camo.githubusercontent.com/775fe6a01aa9214ec2081d47ffb7f82d4dbcf9b0/68747470733a2f2f7072696e63652e6c6373622e756e692e6c752f6a656e6b696e732f75736572436f6e74656e742f7761726e696e672e706e67" target="_blank"><img src="https://camo.githubusercontent.com/775fe6a01aa9214ec2081d47ffb7f82d4dbcf9b0/68747470733a2f2f7072696e63652e6c6373622e756e692e6c752f6a656e6b696e732f75736572436f6e74656e742f7761726e696e672e706e67" height="20px" alt="warning" data-canonical-src="https://prince.lcsb.uni.lu/jenkins/userContent/warning.png" style="max-width:100%;"></a> Run this command in <code>Terminal</code> (on <a href="https://camo.githubusercontent.com/e1c96fa2107f13c0f25763a0302c0a0c3b59dfea/68747470733a2f2f7072696e63652e6c6373622e756e692e6c752f6a656e6b696e732f75736572436f6e74656e742f6170706c652e706e67" target="_blank"><img src="https://camo.githubusercontent.com/e1c96fa2107f13c0f25763a0302c0a0c3b59dfea/68747470733a2f2f7072696e63652e6c6373622e756e692e6c752f6a656e6b696e732f75736572436f6e74656e742f6170706c652e706e67" height="20px" alt="macOS" data-canonical-src="https://prince.lcsb.uni.lu/jenkins/userContent/apple.png" style="max-width:100%;"></a> and <a href="https://camo.githubusercontent.com/0bd50b2b51b258e8420c3180783088dcc6ff150d/68747470733a2f2f7072696e63652e6c6373622e756e692e6c752f6a656e6b696e732f75736572436f6e74656e742f6c696e75782e706e67" target="_blank"><img src="https://camo.githubusercontent.com/0bd50b2b51b258e8420c3180783088dcc6ff150d/68747470733a2f2f7072696e63652e6c6373622e756e692e6c752f6a656e6b696e732f75736572436f6e74656e742f6c696e75782e706e67" height="20px" alt="Linux" data-canonical-src="https://prince.lcsb.uni.lu/jenkins/userContent/linux.png" style="max-width:100%;"></a>) or in <code>Git Bash</code> (on <a href="https://camo.githubusercontent.com/cea93e91cf579569bd40fbae0eaee6b2be007b66/68747470733a2f2f7072696e63652e6c6373622e756e692e6c752f6a656e6b696e732f75736572436f6e74656e742f77696e646f77732e706e67" target="_blank"><img src="https://camo.githubusercontent.com/cea93e91cf579569bd40fbae0eaee6b2be007b66/68747470733a2f2f7072696e63652e6c6373622e756e692e6c752f6a656e6b696e732f75736572436f6e74656e742f77696e646f77732e706e67" height="20px" alt="Windows" data-canonical-src="https://prince.lcsb.uni.lu/jenkins/userContent/windows.png" style="max-width:100%;"></a>) - <strong>not</strong> in <a href="https://camo.githubusercontent.com/1f365f530de7eb97293b654a6e6c9c71aaf50a4b/68747470733a2f2f7072696e63652e6c6373622e756e692e6c752f6a656e6b696e732f75736572436f6e74656e742f6d61746c61622e706e67" target="_blank"><img src="https://camo.githubusercontent.com/1f365f530de7eb97293b654a6e6c9c71aaf50a4b/68747470733a2f2f7072696e63652e6c6373622e756e692e6c752f6a656e6b696e732f75736572436f6e74656e742f6d61746c61622e706e67" height="20px" alt="Matlab" data-canonical-src="https://prince.lcsb.uni.lu/jenkins/userContent/matlab.png" style="max-width:100%;"></a>. Although not recommended, you can download the repository as a <a href="https://github.com/opencobra/cobratoolbox/archive/master.zip">compressed archive</a>.</p>
   </li>
   <li>
   <p>Change to the folder <code>cobratoolbox/</code> and run from <a href="https://camo.githubusercontent.com/1f365f530de7eb97293b654a6e6c9c71aaf50a4b/68747470733a2f2f7072696e63652e6c6373622e756e692e6c752f6a656e6b696e732f75736572436f6e74656e742f6d61746c61622e706e67" target="_blank"><img src="https://camo.githubusercontent.com/1f365f530de7eb97293b654a6e6c9c71aaf50a4b/68747470733a2f2f7072696e63652e6c6373622e756e692e6c752f6a656e6b696e732f75736572436f6e74656e742f6d61746c61622e706e67" height="20px" alt="Matlab" data-canonical-src="https://prince.lcsb.uni.lu/jenkins/userContent/matlab.png" style="max-width:100%;"></a></p>
   <code class="descname"><pre>&gt;&gt; initCobraToolbox</pre></code>
   </li>
   <li>
   <p>You can test your installation by running from <a href="https://camo.githubusercontent.com/1f365f530de7eb97293b654a6e6c9c71aaf50a4b/68747470733a2f2f7072696e63652e6c6373622e756e692e6c752f6a656e6b696e732f75736572436f6e74656e742f6d61746c61622e706e67" target="_blank"><img src="https://camo.githubusercontent.com/1f365f530de7eb97293b654a6e6c9c71aaf50a4b/68747470733a2f2f7072696e63652e6c6373622e756e692e6c752f6a656e6b696e732f75736572436f6e74656e742f6d61746c61622e706e67" height="20px" alt="Matlab" data-canonical-src="https://prince.lcsb.uni.lu/jenkins/userContent/matlab.png" style="max-width:100%;"></a></p>
   <code class="descname"><pre>&gt;&gt; testAll</pre></code>
   </li>
   </ol>


Binaries and Compatibility
--------------------------

.. raw:: html

   <p>For convenience, we provide <a href="https://github.com/blegat/glpkmex"><code>glpk_mex</code></a> and <a href="http://sbml.org/Software/libSBML"><code>libSBML-5.15+</code></a> in <code>/external</code>.</p>
   <p><a href="https://github.com/opencobra/COBRA.binary">Binaries</a> for these libraries are provided in a submodule for Mac OS X 10.6 or later (64-bit), GNU/Linux Ubuntu 14.0+ (64-bit), and Microsoft Windows 7+ (64-bit).<br>
   For unsupported OS, please refer to their respective building instructions (<a href="https://github.com/blegat/glpkmex#instructions-for-compiling-from-source"><code>glpk_mex</code></a>, <a href="http://sbml.org/Software/libSBML/5.13.0/docs//cpp-api/libsbml-installation.html"><code>libSBML</code></a>).</p>
   <p>Read more on the compatibility with SBML-FBCv2 <a href="https://opencobra.github.io/cobratoolbox/docs/notes.html">here</a>.</p>
