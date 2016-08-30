function [efm,rev,idx,ray] = CNAcomputeEFM(cnap,constraints,mexversion,irrev_flag,convbasis_flag,iso_flag,c_macro,display,efmtool_options)


% CellNetAnalyzer API function 'CNAcomputeEFM'
% ---------------------------------------------
%
% --> Computes elementary modes / elementary vectors or a minimal generating set (convex basis) 
%     of flux cones or flux poloyhedra associated with mass-flow networks. Two different scenarios 
%     can be considered: 
%     (i) In the homogeneous case, the solution space defined by the steady state assumption and i
%         reversibility constraints form a polyhedral (flux) cone. Elementary modes correspond 
%         to particular (elementary) rays with an irreducible set of non-zero elements. The set of
%         elementary modes includes all extreme rays of the flux cone (but possibly more). In contrast, 
%         the convex basis of a flux cone is the lineality space plus the set of extreme rays of that cone. 
%     (ii) In the inhomogeneous case, inhomogeneous constraints (e.g. fixing a reaction rate to a non-zero 
%          value or introducing upper and/or lower boundaries for the rates) form a flux polyhedron. 
%          CNAcomputeEFM will then compute either the elementary vectors (with irreducible number of 
%          non-zero entires) of the flux polyhedron (including all extreme rays and extreme points) OR, again, 
%          only a minimal set of unbounded (lineality space + extreme rays) and bounded (extreme points) 
%          generators spanning the resulting flux polyhedron (Minkowsi sum). Note that the zero point will not 
%          be delivered, even if it is an extreme point of the solution space. 
%     Most applications focus on elementary modes in the homogeneous setting but there are also applications 
%     for inhomogeneous specifications.
%
%
% Usage: [efm,rev,idx,ray] = CNAcomputeEFM(cnap, constraints,...
%	mexversion, irrev_flag, convbasis_flag, iso_flag, c_macro, display, efmtool_options)
% 
% cnap is a CellNetAnalyzer (mass-flow) project variable and mandatory argument. 
% The function accesses the following fields in cnap (see also manual):
%   cnap.stoichmat: the stoichiometric matrix of the network
%   cnap.numr = number of reactions (columns in cnap.stoichMat)
%   cnap.mue: index of the biosynthesis reaction; can be empty
%   cnap.macroComposition: matrix defining the stoichiometry of the
%   cnap.specInternal: vector with the indices of the internal species
%   cnap.reacID: names of the columns (reactions) in cnap.stoichMat
%   cnap.specID: names of the rows (species) in cnap.stoichMat
%   cnap.macroID:  names of the macromolecules
%   cnap.macroDefault: default concentrations of the macromolecules
%   cnap.reacMin: lower boundaries of reaction rates
%       (if reacMin(i)=0 --> reaction i is irreversible)
%   cnap.reacMax: upper boundaries of reaction rates
%   cnap.epsilon : smallest number greater than zero (for numerical purposes)
%
% The other arguments are optional:  
%
%   constraints: is a matrix specifying homogeneous and inhonogeneous constraints 
%     on the reaction rates;  the matrix is either empty (no constraints considered; 
%     this is also the default value) or has cnap.numr many rows and up to 4 columns:
%     - COLUMN1 specifies excluded/enforced reactions: if(constraints(i,1)==0) then only 
%           those modes / rays / points will be computed that do not include reaction i;  
%           constraints(i,1)~=0 and constraints(i)~=NaN enforces reaction i, i.e. only  
%           those modes / rays / points will be computed that involve reaction i; for all 
%           other reactions choose constraint(i,1)=NaN; several reactions may be 
%           suppressed/enforced simultaneously
%     - COLUMN2: specifies lower boundaries for the reaction rates (choose NaN if none is 
%           active). Note that zero boundaries (irreversibilities) are better described by 
%           cnap.reacMin. In any case, the lower boundary eventually considered will be zero 
%           if cnap.reaMin(i)==0 and constraints(i,2)<0.
%     - COLUMN3: specifies upper boundaries for the reaction rates (choose NaN if none is active)
%     - COLUMN4: specifies equalities for the reaction rates (choose NaN if none is active). 
%     If columns 2,3, or 4 are not specified or if they do not contain any non-zero (non-NaN) value, 
%     then the elementary modes (convbasis_flag=0) or minimal generating set (convbasis_flag=1) of 
%     the flux cone will be computed (homogeneous probelm). Any non-zero non-NaN value in 
%     columns 2,3, or 4 renders the problem to be inhomogeneous and the solution space to be a 
%     (flux) polyhedron. This function will then compute either the elementary vectors with maximum 
%     number of zeros (including all extreme rays and extreme points) of the flux polyhedron 
%     (if convbasis_flag=0)  OR, again, only a minimal set of unbounded (lineality space + extreme rays) 
%     and bounded (extreme points) generators spanning the resulting flux polyhedron (if convbasis_flag=0). 
%     For the inhomogenous case, the returned vector 'ray' indicates whether the i-th vector in 'efm' is 
%     unbounded (ray(i)==1) or bounded (e.g. an extreme point; ray(i)==0) (see also below). The returned 
%     vector 'rev' indicates whether a mode/ray is reversible or not (see below). Be careful to not define 
%     inconsistent constraints, such as constraints(i,:)=[NaN,2,3,1] (reaction i cannot be in the range 
%     of [2,3] and exactly 1 at the same time). Note that cnap.reacMin and cnap.reacMax cannot be used 
%     for specifying inhomogeneous constraints. cnap.reacMin is only used for marking reaction reversibility.         
%
%   mexversion: [0|1|2|3|4] 0: scripts, 1: CNA mex files,
%     2: Metatool mex files, 3: CNA and Metatool mex files
%     4: Marco Terzer's EFM tool (see http://www.csb.ethz.ch/tools/index)
%       (the toolbox must be installed and in the MATLAB path)
%    (default:3)
%
%   irrev_flag: [0|1] wheter or not to consider reversibilities
%     of reactions 0: all reactions are reversible (default: 1)
%
%   convbasis_flag: [0|1] whether all elementary vectors (including all extreme rays and extreme points) of 
%   the flux cone / flux polyhedron are to be computed [0] or whether only a minimal generating set 
%   (convex basis) [1] is to be calculated. For example, in a homogeneous system, setting this flag to 0 
%   will compute the elementary modes of the flux cone. Default: 0.
%
%   iso_flag: [0|1] whether or not to consider isoenzymes
%     (parallel reactions) only once (default: 0)
%
%   c_macro: vector containing the macromolecule values (concentrations); 
%     can be empty when cnap.mue or cnap.macroComposition is empty
%     (default: cnap.macroDefault)
%
%   display: control the detail of console output; choose one of 
%     {'None', 'Iteration', 'All', 'Details'}
%     default: 'All'
%
%   efmtool_options: cell array with input for the CreateFluxModeOpts function
%     default: {}   (some options will be set by default; cf. console
%                    output for the actual options used)
%
%
% The following results are returned:
%
%   efm: matrix that contains (row-wise) the elementary modes (elemenatry vectors) or a minimal set of 
%     generators (lineality space + extreme rays/points), depending on the chosen scenario. The columns 
%     correspond to the reactions; the column indices of efms (with respect to the columns in cnap.stoichMat) 
%     are stored in the returned variable idx (see below; note that columns are removed in efms if the 
%     corresponding reactions are not contained in any mode) %
%
%   rev:  vector indicating for each mode whether it is reversible(0)/irreversible (1)
%
%   idx:   maps the columns in efm onto the column indices in cnap.stoichmat, 
%	   i.e. idx(i) refers to the column number in cnap.stoichmat (and to
%	   the row number in cnap.reacID)
%
%   ray: indicates whether the i-th row (vector) in efm is an unbounded (1) or bounded (0) direction 
%     of the flux cone / flux polyhedron. Bounded directions (such as extreme points) can only arise 
%     if an inhomogeneous problem was defined (see also above for 'constraints').


efm=[];
rev=[];
idx=[];

if(nargin<1)
	warning('Not enough input arguments.');
	return;
end

cnap.local.val_mex=3;
cnap.local.rb=[];
cnap.local.val_irrev=1;
cnap.local.val_iso=0;
cnap.local.val_extreme=0;
cnap.local.c_makro=cnap.macroDefault;
cnap.local.display= 'All';
cnap.local.efmtool_options= {};

if(nargin>1 && ~isempty(constraints))
	numcolconsts=size(constraints,2);

	%first column: excluded/enforced reactions
	rb=find(~isnan(constraints(:,1))); % excluded/enforced reactions
	if(size(rb,1)<size(rb,2) && ~isempty(rb))
		rb=rb';
		rb(:,2)=constraints(rb)';
    	elseif(~isempty(rb))
		rb=[rb constraints(rb)];
		
	end
	cnap.local.rb=rb;

	%second-fourth column: inhomogeneous constraints
	if(numcolconsts>1)
		cnap.local.lthan=nan(cnap.numr,1);
		cnap.local.sthan=nan(cnap.numr,1);
		cnap.local.eqto=nan(cnap.numr,1);

		if(numcolconsts>=2)
			%second column: lower boundaries
			cnap.local.lthan(:)=constraints(:,2);
			if(numcolconsts>=3)
				%third column: upper boundaries
				cnap.local.sthan(:)=constraints(:,3);
				if(numcolconsts>=4)
					%fourth column: equalities
					cnap.local.eqto(:)=constraints(:,4);
				end
			end
		end
	end
		
end
if(nargin>2)
	cnap.local.val_mex=mexversion;
end
if(nargin>3)
	cnap.local.val_irrev=irrev_flag;
end
if(nargin>4)
	cnap.local.val_extreme=convbasis_flag;
end
if(nargin>5)
	cnap.local.val_iso=iso_flag;
end
if(nargin>6)
	if(size(c_macro,1)<(size(c_macro,2)))
		c_macro=c_macro';
	end
	cnap.local.c_makro=c_macro;
end
if nargin > 7
  cnap.local.display= display;
end
if nargin > 8
  cnap.local.efmtool_options= efmtool_options;
end

cnap=compute_elmodes(cnap);

efm=cnap.local.elmoden;
rev=cnap.local.elm_consts;
idx=cnap.local.mode_rates;
ray=cnap.local.ray;
