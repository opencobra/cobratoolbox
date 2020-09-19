function mw = molweight(varargin)

% MOLWEIGHT  Computes the molecular weights for a set of chemical species.
%
% SYNTAX
%
%   mw = molweight(formula)
%   mw = molweight(species)
%   mw = molweigth(r)
%
%   Computes the molecular weight of a chemical species. The species may be
%   specified as a chemical formula, a cell array of chemical formulas or
%   as a structure array of atomic representations. If there are no output
%   arguments then a table of molecular weights is displayed.
%
%
% EXAMPLES
%
%   1. Molecular weight of methane
%
%       mw = molweight('CH4')
%
%   2. Molecular weight of methane using a structure array
%
%       r.C = 1;
%       r.H = 4;
%       molweight(r);
%
%   3. Molecular weights of set of compounds
%
%       molweight({'CH4','O2','CO2','H2O'});
%
 
% AUTHOR
%
%    Jeff Kantor
%    December 18, 2010

    % This file is part of larger project for developing Matlab based tools
    % for undergraduate use in Chemical Engineering. The following data
    % structure was adapted from that project.

    persistent ppds;

    if isempty(ppds)
        element = @(str, atomicnumber, amu) amu;
        
        ppds.M  = element('any metal',      0,   NaN);
        ppds.X  = element('any halogen',    0,   NaN);

        ppds.H  = element('hydrogen atom',  1,   1.00794);
        ppds.D  = element('deuterium',      1,   2.01410178);
        ppds.T  = element('tritium',        1,   3.0160492);
        ppds.He = element('helium',         2,   4.0026002);
        ppds.Li = element('lithium',        3,   6.941);
        ppds.Be = element('beryllium',      4,   9.012182);
        ppds.B  = element('boron',          5,  10.811);
        ppds.C  = element('carbon',         6,  12.011);
        ppds.N  = element('nitrogen atom',  7,  14.00674);
        ppds.O  = element('oxygen atom',    8,  15.9994);
        ppds.F  = element('flourine',       9,  18.99840);
        ppds.Ne = element('neon',          10,  20.1797);
        ppds.Na = element('sodium',        11,  22.989768);
        ppds.Mg = element('magnesium',     12,  24.3050);
        ppds.Al = element('aluminium',     13,  26.981539);
        ppds.Si = element('silicon',       14,  28.0855);
        ppds.P  = element('phosphorus',    15,  30.97362);
        ppds.S  = element('sulfur',        16,  32.066);
        ppds.Cl = element('chlorine atom', 17,  35.4527);
        ppds.Ar = element('argon',         18,  39.948);
        ppds.K  = element('potassium',     19,  39.0983);
        ppds.Ca = element('calcium',       20,  40.078);
        ppds.Sc = element('scandium',      21,  44.95591);
        ppds.Ti = element('titanium',      22,  47.88);
        ppds.V  = element('vanadium',      23,  50.9415);
        ppds.Cr = element('chromium',      24,  51.9961);
        ppds.Mn = element('manganese',     25,  54.93085);
        ppds.Fe = element('iron',          26,  55.847);
        ppds.Co = element('cobalt',        27,  58.9332);
        ppds.Ni = element('nickel',        28,  58.69);
        ppds.Cu = element('copper',        29,  63.546);
        ppds.Zn = element('zinc',          30,  65.39);
        ppds.Ga = element('gallium',       31,  69.723);
        ppds.Ge = element('germanium',     32,  72.61);
        ppds.As = element('arsenic',       33,  74.92159);
        ppds.Se = element('selenium',      34,  78.96);
        ppds.Br = element('bromine',       35,  79.904);
        ppds.Kr = element('krypton',       36,  83.80);
        ppds.Rb = element('rubidium',      37,  85.4678);
        ppds.Sr = element('strontium',     38,  87.62);
        ppds.Y  = element('yttrium',       39,  88.90585);
        ppds.Zr = element('zirconium',     40,  91.224);
        ppds.Nb = element('niobium',       41,  92.90638);
        ppds.Mo = element('molybdenum',    42,  95.94);
        ppds.Tc = element('technetium',    43,  98);
        ppds.Ru = element('ruthenium',     44, 101.070);
        ppds.Rh = element('rhodium',       45, 102.9055);
        ppds.Pd = element('palladium',     46, 106.42);
        ppds.Ag = element('silver',        47, 107.8682);
        ppds.Cd = element('cadmium',       48, 112.411);
        ppds.In = element('indium',        49, 114.82);
        ppds.Sn = element('tin',           50, 118.71);
        ppds.Sb = element('antimony',      51, 121.75);
        ppds.Te = element('tellurium',     52, 127.60);
        ppds.I  = element('iodine',        53, 126.90447);
        ppds.Xe = element('xenon',         54, 131.29);
        ppds.Cs = element('cesium',        55, 132.90543);
        ppds.Ba = element('barium',        56, 137.327);
        ppds.La = element('lanthanum',     57, 138.9055);
        ppds.Ce = element('cerium',        58, 140.115);
        ppds.Pr = element('praseodymium',  59, 140.90765);
        ppds.Nd = element('neodymium',     60, 144.24);
        ppds.Pm = element('promethium',    61, 145);
        ppds.Sm = element('samarium',      62, 150.36);
        ppds.Eu = element('europium',      63, 151.965);
        ppds.Gd = element('gadolinium',    64, 157.25);
        ppds.Tb = element('terbium',       65, 158.92534);
        ppds.Dy = element('dysprosium',    66, 162.50);
        ppds.Ho = element('holmium',       67, 164.92032);
        ppds.Er = element('erbium',        68, 167.26);
        ppds.Tm = element('thulium',       69, 168.93421);
        ppds.Yb = element('ytterbium',     70, 173.04);
        ppds.Lu = element('lutetium',      71, 174.967);
        ppds.Hf = element('hafnium',       72, 178.49);
        ppds.Ta = element('tantalum',      73, 180.9479);
        ppds.W  = element('tungsten',      74, 183.85);
        ppds.Re = element('rhenium',       75, 186.207);
        ppds.Os = element('osmium',        76, 190.2);
        ppds.Ir = element('iridium',       77, 192.22);
        ppds.Pt = element('platinum',      78, 195.09);
        ppds.Au = element('gold',          79, 196.96654);
        ppds.Hg = element('mercury',       80, 200.59);
        ppds.Tl = element('thallium',      81, 204.3833);
        ppds.Pb = element('lead',          82, 207.2);
        ppds.Bi = element('bismuth',       83, 208.98037);
        ppds.Po = element('polonium',      84, 209);
        ppds.At = element('astatine',      85, 210);
        ppds.Rn = element('radon',         86, 222);
        ppds.Fr = element('francium',      87, 223);
        ppds.Ra = element('radium',        88, 226.025);
        ppds.Ac = element('actinium',      89, 227.028);
        ppds.Th = element('thorium',       90, 232.0381);
        ppds.Pa = element('protactinium',  91, 231.03588);
        ppds.U  = element('uranium',       92, 238.0289);
        ppds.Np = element('neptunium',     93, 237.0482);
        ppds.Pu = element('plutonium',     94, 244);
        ppds.Am = element('americium',     95, 243);
        ppds.Cm = element('curium',        96, 247);
        ppds.Bk = element('berkelium',     97, 247);
        ppds.Cf = element('californium',   98, 251);
        ppds.Es = element('einsteinium',   99, 252);
        ppds.Fm = element('fermium',      100, 257);
        ppds.Q  = element('charge',         0,   0);
        ppds.e  = element('electron',       0,   0);

    end
    
    assert(nargin > 0, 'molweight:input', ['No input. Expects a cell ', ...
                        'array of formulas or struct array of atoms.']);
    assert(nargin < 2, 'molweight:input', 'Unexpected extra inputs.');
     
    % Process function argument to produce a cell array of chemical
    % formulas and structure array of atomic representations.
    
    switch class(varargin{1})
        case 'char'                      % Single formula
            species = varargin;
            r = parse_formula(species);
        
        case 'cell'                      % Cell array of formulas
            species = varargin{1};
            r = parse_formula(species);
            
        case 'struct'                    % Structure array
            r = varargin{1};
            species = hillformula(r);
            
        otherwise
            error('molweight:input',['requires cell array of chemical ',...
              'formulas or a structure array of atomic representations']);
    end

    % For each element of the structure array, compute a molecular weight

    mw = zeros(size(r));
    atoms = fields(r);
    
    for n = 1:size(r(:))
        for i = 1:length(atoms)
            
            % The following check is needed to avoid add adding NaN in
            % cases where M or X appear in atoms.
            
            if r(n).(atoms{i}) > 0
                mw(n) = mw(n) + ppds.(atoms{i})*r(n).(atoms{i});
            end
            
        end
    end
    
    % If no outputs, then display results

    if nargout == 0
        fprintf('\n');
        fprintf('%-25s  %8s\n','Species','Mol. Wt.');
        fprintf('%-25s  %8s\n','-------','--------');
        for n = 1:size(mw(:))
            fprintf('%-25s  %8.2f\n',species{n},mw(n));
        end  
    end

end
