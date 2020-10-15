
formulae = {'C7H13A2N3O2';'C4H5A2N2O3';'CHA2NO';'C9H17A2N3O2';'C47H68O5';'C41H83NO8P';'C48H93NO8';'C13H24NO10P';...
          'C31H54NO4';'C28H44N2NaO23';'C5H10O3';'C6H11NO4';'C4H9N3O5P';'C55H95AN3O30';'C9H20ANO7P';'C39H44N4O12';'H';'Na';'C19H28O2'};
      
      
isotopeAbundance = 0; %use polyisotopic inexact mass i.e. uses all isotopes of each element weighted by natural abundance 
generalFormula = 1; %NaN for unknown elements
[getMolecularMassMasses, knownMasses, unknownElements, Ematrix, elements] = getMolecularMass(formulae,isotopeAbundance,generalFormula);

%Jeff Kantor's code:
molweightMasses = molweight(formulae);

%here is the smallest difference obtained by tweaking the options
differenceMW = [0.00221999999999412;0.00127999999997996;0.000340000000001339;0.00281999999995719;0.0140999999999849;0.0121990000000096;0.0144400000000360;0.00379899999990130;0.00933999999989510;0.00847799999996823;0.00149999999999295;0.00183999999998719;0.00117900000000759;0.0166200000001027;0.00259899999997515;0.0118599999999560;0;-1.99999999850320e-06;0.00569999999993343];

%compare = [molweightMasses, getMolecularMassMasses]

%TODO not sure what is the correct code to use
res = molweightMasses - getMolecularMassMasses - differenceMW;
assert(norm(res(isfinite(res)),inf)<1e-11)