import csv, logging, types, re, json, itertools, sys
import numpy as np
import openbabel
from StringIO import StringIO
from optparse import OptionParser

R = 8.31e-3 # kJ/(K*mol)
default_T = 298.15 # K
default_pH = 7.0

GROUP_CSV = StringIO(""""NAME","PROTONS","CHARGE","MAGNESIUMS","SMARTS","FOCAL_ATOMS","REMARK","SKIP"
"primary -Cl3",0,0,0,"Cl[CH0](Cl)Cl",0,"chlorine (attached to a primary carbon with 2 other chlorine atoms attached)",
"primary -Cl2",0,0,0,"Cl[CH1]Cl",0,"chlorine (attached to a primary carbon with 1 other chlorine atom attached)",
"secondary -Cl2",0,0,0,"Cl[CH0]Cl",0,"chlorine (attached to a secondary carbon with 1 other chlorine atom attached)",
"primary -Cl",0,0,0,"Cl[CH2]",0,"chlorine (attached to a primary carbon with 0 other chlorine atoms attached)",
"secondary -Cl",0,0,0,"Cl[CH1]",0,"chlorine (attached to a secondary carbon with 0 other chlorine atoms attached)",
"tertiary -Cl",0,0,0,"Cl[CH0]",0,"chlorine (attached to a tertiary carbon with 0 other chlorine atoms attached)",
"ring -Cl",0,0,0,"Cl[c,n]",0,"chlorine (attached to an aromatic ring)",
"ring -Br",0,0,0,"Br[c,n]",0,"bromine (attached to an aromatic ring)",
"ring -I",0,0,0,"I[c,n]",0,"iodine (attached to an aromatic ring)",
"ring -F",0,0,0,"F[c,n]",0,"fluorine (attached to an aromatic ring)",
"-Br",0,0,0,"Br[C,N]",0,"bromine",
"-I",0,0,0,"I[C,N]",0,"iodine",
"-F",0,0,0,"F[C,N]",0,"fluorine",
"-S-O",1,0,0,"[S;H0;X2][OH]","All","sulfur hydroxyl",
"-S-O",0,-1,0,"[S;H0;X2][O-]","All","sulfur hydroxyl",
"ring -s-",0,0,0,"c[s;H0;X2;R]c","1","thioether (participating in an aromatic ring)",
"ring -S-",0,0,0,"C[S;H0;X2;R]C","1","thioether (participating in a nonaromatic ring)",
"-SO3",1,0,0,"S(=O)(=O)[OH]","All","sulfate",
"-SO3",0,-1,0,"S(=O)(=O)[O-]","All","sulfate",
"-SO2-",0,0,0,"[C,c,N,n]S(=O)(=O)[C,c,N,n]","1|2|3","sulfonyl",
"-SOO",0,-1,0,"[C,c,N,n]S(=O)[O-]","1|2|3","sulfonyl",
"-SOO",1,0,0,"[C,c,N,n]S(=O)[OH]","1|2|3","sulfonyl",
"-S<",0,0,0,"[S;H0;X3]","All","sulfonium",
"-S-S-",0,0,0,"C[S;H0;X2;R0][S;H0;X2;R0]C","1|2","dithionine",
"ring -S-S-",0,0,0,"C[S;H0;X2;R1][S;H0;X2;R1]C","1|2","dithionine",
"-C(=O)S-",0,0,0,"C(=O)[S;H0;X2][C,c,N,n]","0|1|2","thioester",
"-C(=O)S",1,0,0,"C(=O)[S;H1;X2;+0]","0|1|2","thiocarboxyl",
"-C(=O)S",0,-1,0,"C(=O)[S;H0;X1;-1]","0|1|2","thiocarboxyl",
"-S",1,0,0,"[C,c,N,n,S][S;H1;X2;+0]","1","thiol",
"-S",0,-1,0,"[C,c,N,n,S][S;H0;X1;-1]","1","thiol",
"-S-",0,0,0,"[C,c,N,n,S][S;H0;X2][C,c,N,n,S]","1","thioether",
"-CO-OPO3",0,-2,0,"[C;H0;X3](=O)OP(=O)([O-])[O-]","All","phospho-carboxylic acid",
"-CO-OPO3",1,-1,0,"[C;H0;X3](=O)OP(=O)([O-])O","All","phospho-carboxylic acid",
"-CO-OPO3",2,0,0,"[C;H0;X3](=O)OP(=O)([O])O","All","phospho-carboxylic acid",
"CO-OPO3",1,-2,0,"[C;H1;X3](=O)OP(=O)([O-])[O-]","All","formyl phosphate",
"CO-OPO3",2,-1,0,"[C;H1;X3](=O)OP(=O)([O-])O","All","formyl phosphate",
"CO-OPO3",3,0,0,"[C;H1;X3](=O)OP(=O)([O])O","All","formyl phosphate",
"*PC",0,0,0,"P",0,"phosphate chains - (C)harge sensitive",
"N-PO3",0,-2,0,"NP(=O)([O-])[O-]","1|2|3|4","terminal phosphate group attached to nitrogen",
"N-PO3",1,-1,0,"NP(=O)([O-])O","1|2|3|4","terminal phosphate group attached to nitrogen",
"N-PO3",2,0,0,"NP(=O)(O)O","1|2|3|4","terminal phosphate group attached to nitrogen",
"C-PO3",0,-2,0,"CP(=O)([O-])[O-]","1|2|3|4","terminal phosphate group attached to carbon",
"C-PO3",1,-1,0,"CP(=O)([O-])O","1|2|3|4","terminal phosphate group attached to carbon",
"C-PO3",2,0,0,"CP(=O)(O)O","1|2|3|4","terminal phosphate group attached to carbon",
"-NO2",0,0,0,"[C,c,N,n]N(=O)=O","1|2|3","Nitro",
"NC(=N)N",0,0,0,"NC(=N)N","1","guanidine",
"ring nc(=n)n",0,0,0,"[N,n][c;H0,+0](~[N,n])[N,n]","1","aromatic guanidine",
"two fused rings =n<",0,0,0,"[nR2]","All","participating in two fused aromatic rings",
"ring =n<",0,1,0,"[C,c][n;+1](~[C,c])[C,c]","1","double bond and one single bond participating in a ring",
"ring =n<",0,0,0,"[C,c][n;+0](~[C,c])[C,c]","1","double bond and one single bond participating in a ring",
"ring -n=",1,1,0,"c~[n;+1]~c","1","participating in a ring",
"ring -n=",0,0,0,"c~[n;+0]~c","1","participating in a ring",
"ring -n=",0,-1,0,"c~[n;-1]~c","1","participating in a ring",
"two fused rings -N<",1,1,0,"[N;H1;R2;+1]","All","participating in two fused rings",
"two fused rings -N<",0,0,0,"[N;H0;R2;+0]","All","participating in two fused rings",
"two fused rings =N<",0,1,0,"[N;H0;R2;+1]","All","participating in two fused rings",
"ring =N<",0,1,0,"[N;H0;X3;R1;+1]=[C,N]",0,"double bond and one single bond participating in a ring",
"-N-",2,1,0,"[N;H2;X4;R0;+1]","All",,
"-N-",1,0,0,"[N;H1;X3;R0;+0]","All",,
"-N-",0,-1,0,"[N;H0;X2;R0;-1]","All",,
"ring =N-",1,1,0,"[N;H1;X3;R1;+1]=[C,c,N,n]",0,"participating in a ring",
"ring =N-",0,0,0,"[N;H0;X2;R1;+0]=[C,c,N,n]",0,"participating in a ring",
"ring -N-",2,1,0,"[N;H2;X4;R1;+1]","All","participating in a ring",
"ring -N-",1,0,0,"[N;H1;X3;R1;+0]","All","participating in a ring",
"ring -N-",0,-1,0,"[N;H0;X2;R1;-1]","All","participating in a ring",
"ring -N<",1,1,0,"[N;H1;X4;R1;+1]","All","participating in a ring",
"ring -N<",0,0,0,"[N;H0;X3;R1;+0]","All","participating in a ring",
"=N",2,1,0,"[N;H2;+1]=[C,c,N,n]",0,,
"=N",1,0,0,"[N;H1;+0]=[C,c,N,n]",0,,
"ring N-CO-N",0,0,0,"N[C;H0;X3;R1;+0](=O)N","1|2","urea participating in a ring",
"N-CO-N",0,0,0,"NC(=O)N","1|2","urea",
"N-COO",1,0,0,"NC(=O)[OH]","1|2|3","carbamate",
"N-COO",0,-1,0,"NC(=O)[O-]","1|2|3","carbamate",
"N-COO-",0,0,0,"NC(=O)O[C,c,N,n]","1|2|3","carbamoyl",
"N-CO",1,0,0,"N[C;H1;X3;+0]=O","1|2","formamide",
"-N-CO-",0,0,0,"[C,c,N,n]N[C;H0;X3;+0](=O)[C,c,N,n]","2|3","amide",
"N-CO-",0,0,0,"[N;H2;X3;+0][C;H0;X3;+0](=O)[C,c,N,n]","1|2","carboxamide",
"-N",3,1,0,"C[N;H3;X4;+1]","1","primary amine",
"-N",2,0,0,"C[N;H2;X3;+0]","1","primary amine",
"-N",1,-1,0,"C[N;H1;X2;-1]","1","primary amine",
"ring >c-N",2,0,0,"c[N;H2;X3;+0]","1","primary amine on aromatic ring",
"ring >c-N",3,1,0,"c[N;H3;X4;+1]","1","primary amine on aromatic ring",
"-N<",1,1,0,"[N;H1;X4;R0]","All",,
"-N<",0,0,0,"[N;H0;X3;R0]","All",,
"=N-",0,0,0,"[N;H0;X2;R0;+0]=[C,c,N,n,O]",0,,
"=N-",1,1,0,"[N;H1;X3;R0;+1]=[C,c,N,n,O]",0,,
">N<",0,1,0,"[N;H0;X4;R0]","All",,
"=N=O",0,1,0,"[C,c,N,n]=[N+]=O","1|2",,
"-O-CO-O-",0,0,0,"[O;H0;X2][C;H0;X3](=O)[O;H0;X2]","All","carbonate",
"ring -o-cO-",0,0,0,"O=[c;H0;X3;R][o;H0;X2;R]","All","ester (participating in an aromatic ring)",
"ring -O-CO-",0,0,0,"O=[C;H0;X3;R][O;H0;X2;R]","All","ester (participating in a nonaromatic ring)",
"-O-CO-",0,0,0,"[C;H0;X3](=O)[O;H0;X2]","All","ester",
"-O-C=O",0,0,0,"[C;H1;X3](=O)[O;H0;X2]","All","ester (terminal)",
"ring >c-O",1,0,0,"c~[O;+0]","All","hydroxyl (participating in an aromatic ring)",
"ring >c-O",0,-1,0,"c~[O;-1]","All","hydroxyl (participating in an aromatic ring)",
"ring >C=O",0,0,0,"[CR]=O","All","ketone (participating in a ring)",
"ring >C-O",2,0,0,"[CR;H1][O;H1]","All","ketone (participating in a ring)",
"ring >C(-O)-",1,0,0,"[CR;H0][O;H1;+0]","All","tertiary hydroxyl (participating in a ring)",
"ring >C(-O)-",0,-1,0,"[CR;H0][O;H0;-1]","All","tertiary hydroxyl (participating in a ring)",
"-COO",0,-1,0,"[C,c,N,n]C(=O)[O-]","1|2|3","carboxylate",
"-COO",1,0,0,"[C,c,N,n]C(=O)[OH]","1|2|3","carboxylic acid",
">C=O",0,0,0,"[C,N,c,n]C(=O)[C,N,c,n]","1|2","ketone",
"-C=O",1,0,0,"[C,N,c,n][C;H1]=O","1|2","aldehyde",
"ring -o-",0,0,0,"[c,n][o;H0;X2][c,n]","1","participating in an aromatic ring",
"ring -O-",0,0,0,"[C,c,N,n][O;H0;X2;R][C,c,N,n]","1","participating in a nonaromatic ring",
"-C-O",3,0,0,"[C;H2][O;H1;+0]","All","primary hydroxyl",
"-C-O",2,-1,0,"[C;H2][O;H0;-1]","All","primary hydroxyl",
"-C(-O)-",2,0,0,"[C;H1][O;H1;+0]","All","secondary hydroxyl",
"-C(-O)-",1,-1,0,"[C;H1][O;H0;-1]","All","secondary hydroxyl",
">C(-O)-",1,0,0,"[C;H0][O;H1;+0]","All","tertiary hydroxyl",
">C(-O)-",0,-1,0,"[C;H0][O;H0;-1]","All","tertiary hydroxyl",
"[N]-O",1,0,0,"N[O;H1;X2]","1","hydroxamine",
"[N]-O",0,-1,0,"N[O;H0;X1;-1]","1","hydroxamine",
"-O-",0,0,0,"[O;H0;X2]","All","ether",
"-C#C-",1,0,0,"[C;H0;X2]#[C;H0;X2]","All",,
"-C#C",1,0,0,"[C;H0;X2]#[C;H1;X2;+0]","All",,
"-C#C",0,-1,0,"[C;H0;X2]#[C;H0;X1;-1]","All",,
"N#C-",0,0,0,"N#[C;H0;X2]","All",,
"3-ring =c<",0,0,0,"[a][c;H0;R3]([a])[a]","1","participating in 3 aromatic rings",
"2-ring >C<",0,0,0,"[A][C;H0;R2]([A])([A])[A]",1,"quaternary carbon participating in two fused aliphatic rings",
"2-ring -C<",1,0,0,"[A][C;H1;R2]([A])[A]",1,"tertiary carbon participating in two fused aliphatic rings",
"2-ring -C-",2,0,0,"[A][C;H2;R2][A]",1,"secondary carbon (participating in two fused aliphatic rings)",
"2-ring =C<",0,0,0,"[A]=[C;H0;R2]([A])[A]",1,"participating in two fused aliphatic rings",
"(1+1)-ring =C<",0,0,0,"[a][c;H0;R2]([a])[A]",1,"participating in two fused aliphatic+aromatic rings",
"2-ring =c<",0,0,0,"[a][c;R2]([a])[a]","1","participating in two fused aromatic rings",
"ring =c-",1,0,0,"[a][c;H1;R1][a]","1","participating in one aromatic ring",
"ring =c<",0,0,0,"[a][c;H0;R1]([a])*","1","one single bond and one double bond participating in an aromatic ring",
"ring =C<",0,0,0,"[A]=[C;H0;R1]([A])[A]","1","one single bond and one double bond participating in a aliphatic ring",
"ring =C-",1,0,0,"[A]=[C;H1;R1][A]","1","participating in a aliphatic ring",
"=C-",1,0,0,"[C,c,N,n]=[C;H1]*","1",,
"=C",2,0,0,"[C,c,N,n]=[C;H2]","1",,
"=C<",0,0,0,"[C,c,N,n]=[C;H0](*)*","1",,
"ring >C<",0,0,0,"*[C;H0;R1](*)(*)*","1","quaternary carbon (participating in one aliphatic ring)",
">C<",0,0,0,"*[C;H0;R0](*)(*)*","1","quaternary carbon",
"ring -C<",1,0,0,"*[C;H1;R1](*)*","1","tertiary carbon (participating in one aliphatic ring)",
"-C<",1,0,0,"*[C;H1;R0](*)*","1","tertiary carbon",
"ring -C-",2,0,0,"*[C;H2;R1]*","1","secondary carbon (participating in one aliphatic ring)",
"-C-",2,0,0,"*[C;H2;R0]*","1","secondary carbon",
"-C",3,0,0,"*[C;H3]","1","primary carbon",
""")


class GroupVector(list):
    """A vector of groups."""
    
    def __init__(self, groups_data, iterable=None):
        """Construct a vector.
        
        Args:
            groups_data: data about all the groups.
            iterable: data to load into the vector.
        """
        self.groups_data = groups_data
        
        if iterable is not None:
            self.extend(iterable)
        else:
            for _ in xrange(len(self.groups_data.all_group_names)):
                self.append(0)
    
    def __str__(self):
        """Return a sparse string representation of this group vector."""
        group_strs = []
        gv_flat = self.Flatten()
        for i, name in enumerate(self.groups_data.GetGroupNames()):
            if gv_flat[i]:
                group_strs.append('%s x %d' % (name, gv_flat[i]))
        return " | ".join(group_strs)
    
    def __iadd__(self, other):
        for i in xrange(len(self.groups_data.all_group_names)):
            self[i] += other[i]
        return self

    def __isub__(self, other):
        for i in xrange(len(self.groups_data.all_group_names)):
            self[i] -= other[i]
        return self
            
    def __add__(self, other):
        result = GroupVector(self.groups_data)
        for i in xrange(len(self.groups_data.all_group_names)):
            result[i] = self[i] + other[i]
        return result

    def __sub__(self, other):
        result = GroupVector(self.groups_data)
        for i in xrange(len(self.groups_data.all_group_names)):
            result[i] = self[i] - other[i]
        return result
    
    def __eq__(self, other):
        for i in xrange(len(self.groups_data.all_group_names)):
            if self[i] != other[i]:
                return False
        return True
    
    def __nonzero__(self):
        for i in xrange(len(self.groups_data.all_group_names)):
            if self[i] != 0:
                return True
        return False
    
    def __mul__(self, other):
        try:
            c = float(other)
            return GroupVector(self.groups_data, [x*c for x in self])
        except ValueError:
            raise ValueError("A GroupVector can only be multiplied by a scalar"
                             ", given " + str(other))
        
    def NetCharge(self):
        """Returns the net charge."""
        return int(np.dot(self, self.groups_data.all_group_charges))
    
    def Hydrogens(self):
        """Returns the number of protons."""
        return int(np.dot(self, self.groups_data.all_group_hydrogens))

    def Magnesiums(self):
        """Returns the number of Mg2+ ions."""
        return int(np.dot(self, self.groups_data.all_group_mgs))
    
    def RemoveEpsilonValues(self, epsilon=1e-10):
        for i in range(len(self)):
            if abs(self[i]) < epsilon:
                self[i] = 0
    
    def ToJSONString(self):
        return json.dumps(dict([(i, x) for (i, x) in enumerate(self) if x != 0]))
    
    @staticmethod
    def FromJSONString(groups_data, s):
        v = [0] * groups_data.Count()
        for i, x in json.loads(s).iteritems():
            v[int(i)] = x
        return GroupVector(groups_data, v)
    
    def Flatten(self):
        if not self.groups_data.transformed:
            return tuple(self)
        
        # map all pseudoisomeric group indices to Biochemical group indices (which are fewer)
        # use the names of each group and ignore the nH, z and nMg.
        biochemical_group_names = self.groups_data.GetGroupNames()
        biochemical_vector = [0] * len(biochemical_group_names)
        for i, x in enumerate(self):
            group_name = self.groups_data.all_groups[i].name
            new_index = biochemical_group_names.index(group_name)
            biochemical_vector[new_index] += x
        return tuple(biochemical_vector)        

class GroupsDataError(Exception):
    pass

class MalformedGroupDefinitionError(GroupsDataError):
    pass

class _AllAtomsSet(object):
    """A set containing all the atoms: used for focal atoms sets."""
    
    def __contains__(self, elt):
        return True

class FocalSet(object):
    
    def __init__(self, focal_atoms_str):
        if not focal_atoms_str:
            raise ValueError(
                'You must supply a non-empty focal atom string.'
                ' You may use "None" or "All" in the obvious fashion.')
        
        self.str = focal_atoms_str
        self.focal_atoms_set = None
        prepped_str = self.str.strip().lower()
        
        if prepped_str == 'all':
            self.focal_atoms_set = _AllAtomsSet()
        elif prepped_str == 'none':
            self.focal_atoms_set = set()
        else:
            self.focal_atoms_set = set([int(c) for c in self.str.split('|')])
    
    def __str__(self):
        return self.str
    
    def __contains__(self, elt):
        return self.focal_atoms_set.__contains__(elt)

class Group(object):
    """Representation of a single group."""
    
    def __init__(self, group_id, name, hydrogens, charge, nMg,
                 smarts=None, focal_atoms=None):
        self.id = group_id
        self.name = name
        self.hydrogens = hydrogens
        self.charge = charge
        self.nMg = nMg
        self.smarts = smarts
        self.focal_atoms = focal_atoms

    def _IsHydrocarbonGroup(self):
        return self.name.startswith('*Hc')

    def _IsSugarGroup(self):
        return self.name.startswith('*Su')
    
    def _IsAromaticRingGroup(self):
        return self.name.startswith('*Ar')
    
    def _IsHeteroaromaticRingGroup(self):
        return self.name.startswith('*Har')

    def IsPhosphate(self):
        return self.name.startswith('*P')
    
    def IgnoreCharges(self):
        # (I)gnore charges
        return self.name[2] == 'I'
    
    def ChargeSensitive(self):
        # (C)harge sensitive
        return self.name[2] == 'C'
    
    def IsCodedCorrection(self):
        """Returns True if this is a correction for which hand-written code.
           must be executed.
        """
        return (self._IsHydrocarbonGroup() or
                self._IsAromaticRingGroup() or
                self._IsHeteroaromaticRingGroup())

    @staticmethod
    def _IsHydrocarbon(mol):
        """Tests if a molecule is a simple hydrocarbon."""
        if mol.FindSmarts('[!C;!c]'):
            # If we find anything other than a carbon (w/ hydrogens)
            # then it's not a hydrocarbon.
            return 0
        return 1    

    @staticmethod
    def _CountAromaticRings(mol):
        expressions = ['c1cccc1', 'c1ccccc1']
        count = 0
        for smarts_str in expressions:
            count += len(mol.FindSmarts(smarts_str))
        return count
    
    @staticmethod
    def _CountHeteroaromaticRings(mol):
        expressions = ['a1aaaa1', 'a1aaaaa1']
        count = 0
        all_atoms = mol.GetAtoms()
        for smarts_str in expressions:
            for match in mol.FindSmarts(smarts_str):
                atoms = set([all_atoms[i].atomicnum for i in match])
                atoms.discard(6)  # Ditch carbons
                if atoms:
                    count += 1
        return count

    def GetCorrection(self, mol):
        """Get the value of the correction for this molecule."""
        if self._IsHydrocarbonGroup():
            return self._IsHydrocarbon(mol)
        elif self._IsAromaticRingGroup():
            return self._CountAromaticRings(mol)
        elif self._IsHeteroaromaticRingGroup():
            return self._CountHeteroaromaticRings(mol)
        
        raise TypeError('This group is not a correction.')
    
    def FocalSet(self, nodes):
        """Get the set of focal atoms from the match.
        
        Args:
            nodes: the nodes matching this group.
        
        Returns:
            A set of focal atoms.
        """        
        focal_set = set()
        for i, node in enumerate(nodes):
            if i in self.focal_atoms:
                focal_set.add(node)            
        return focal_set
    
    def __str__(self):
        if self.hydrogens is not None and self.charge is not None and self.nMg is not None:
            return '%s [H%d Z%d Mg%d]' % (self.name, self.hydrogens or 0, self.charge or 0, self.nMg or 0)
        else:
            return '%s' % self.name
    
    def __eq__(self, other):
        """Enable == checking.
        
        Only checks name, protons, charge, and nMg.
        """
        return (str(self.name) == str(other.name) and
                self.hydrogens == other.hydrogens and
                self.charge == other.charge and
                self.nMg == other.nMg)
    
    def __hash__(self):
        """We are HASHABLE!
        
        Note that the hash depends on the same attributes that are checked for equality.
        """
        return hash((self.name, self.hydrogens, self.charge, self.nMg))

class GroupsData(object):
    """Contains data about all groups."""
    
    ORIGIN = Group('Origin', 'Origin', hydrogens=0, charge=0, nMg=0)
    
    # Phosphate groups need special treatment, so they are defined in code...
    # TODO(flamholz): Define them in the groups file.
    
    # each tuple contains: (name, description, nH, charge, nMg, is_default)
    
    phosphate_groups = [('initial H0', '-OPO3-', 0, -1, 0, True),
                        ('initial H1', '-OPO3-', 1, 0, 0, False),
                        ('middle H0', '-OPO2-', 0, -1, 0, True),
                        ('middle H1', '-OPO2-', 1, 0, 0, False),
                        ('final H0', '-OPO3', 0, -2, 0, True),
                        ('final H1', '-OPO3', 1, -1, 0, False),
                        ('final H2', '-OPO3', 2,  0, 0, False),
                        ('initial chain H0', '-OPO3-OPO2-', 0, -2, 0, True),
                        ('initial chain H1', '-OPO3-OPO2-', 1, -1, 0, False),
                        ('initial chain H2', '-OPO3-OPO2-', 2, 0, 0, False),
                        ('initial chain Mg1', '-OPO3-OPO2-', 0, 0, 1, False),
                        ('middle chain H0', '-OPO2-OPO2-', 0, -2, 0, True),
                        ('middle chain H1', '-OPO2-OPO2-', 1, -1, 0, False),
                        ('middle chain H2', '-OPO2-OPO2-', 2, 0, 0, False),
                        ('middle chain Mg1', '-OPO2-OPO2-', 0, 0, 1, False),
                        ('ring initial H0', 'ring -OPO3-', 0, -1, 0, True),
                        ('ring initial H1', 'ring -OPO3-', 1, 0, 0, False),
                        ('ring initial chain H0', 'ring -OPO3-OPO2-', 0, -2, 0, True),
                        ('ring initial chain H1', 'ring -OPO3-OPO2-', 1, -1, 0, False),
                        ('ring initial chain H2', 'ring -OPO3-OPO2-', 2, 0, 0, False),
                        ('ring middle chain H0', 'ring -OPO2-OPO2-', 0, -2, 0, True),
                        ('ring middle chain H1', 'ring -OPO2-OPO2-', 1, -1, 0, False),
                        ('ring middle chain H2', 'ring -OPO2-OPO2-', 2, 0, 0, False),
                        ('ring initial chain Mg1', 'ring -OPO2-OPO2-', 0, 0, 1, False)]
    
    PHOSPHATE_GROUPS = []
    PHOSPHATE_DICT = {}
    DEFAULTS = {}
    for name, desc, nH, z, nMg, is_default in phosphate_groups:
        group = Group(name, desc, nH, z, nMg)
        PHOSPHATE_GROUPS.append(group)
        PHOSPHATE_DICT[name] = group
        if is_default:
            DEFAULTS[desc] = group

    RING_PHOSPHATES_TO_MGS = ((PHOSPHATE_DICT['ring initial chain H0'], PHOSPHATE_DICT['ring initial chain Mg1']),)    
    MIDDLE_PHOSPHATES_TO_MGS = ((PHOSPHATE_DICT['initial chain H0'], PHOSPHATE_DICT['initial chain Mg1']),)    
    FINAL_PHOSPHATES_TO_MGS = ((PHOSPHATE_DICT['middle chain H0'], PHOSPHATE_DICT['middle chain Mg1']),)
    
    def __init__(self, groups, transformed=False):
        """Construct GroupsData.
        
        Args:
            groups: a list of Group objects.
        """
        self.transformed = transformed
        self.groups = groups
        self.all_groups = self._GetAllGroups(self.groups)
        self.all_group_names = [str(g) for g in self.all_groups]
        self.all_group_hydrogens = np.array([g.hydrogens or 0 for g in self.all_groups])
        self.all_group_charges = np.array([g.charge or 0 for g in self.all_groups])
        self.all_group_mgs = np.array([g.nMg or 0 for g in self.all_groups])

        if self.transformed:
            # find the unique group names (ignoring nH, z, nMg)
            # note that Group.name is does not contain these values,
            # unlike Group.__str__() which concatenates the name and the nH, z, nMg
            self.biochemical_group_names = []
            for group in self.all_groups:
                if group.name not in self.biochemical_group_names:
                    self.biochemical_group_names.append(group.name)
    
    def Count(self):
        return len(self.all_groups)
    
    count = property(Count)
    
    @staticmethod
    def _GetAllGroups(groups):
        all_groups = []
        
        for group in groups:
            # Expand phosphate groups.
            if group.IsPhosphate():
                all_groups.extend(GroupsData.PHOSPHATE_GROUPS)
            else:
                all_groups.append(group)
        
        # Add the origin.
        all_groups.append(GroupsData.ORIGIN)
        return all_groups
    
    @staticmethod
    def _ConvertFocalAtoms(focal_atoms_str):
        if not focal_atoms_str:
            return _AllAtomsSet()
        if focal_atoms_str.lower().strip() == 'none':
            return set()
        
        return set([int(c) for c in focal_atoms_str.split('|')])
    
    @staticmethod
    def FromGroupsFile(filename, transformed=False):
        """Factory that initializes a GroupData from a CSV file."""
        assert filename
        if type(filename) == types.StringType:
            logging.debug('Reading the list of groups from %s ... ' % filename)
            fp = open(filename, 'r')
        else:
            fp = filename
        list_of_groups = []
        
        gid = 0
        for line_num, row in enumerate(csv.DictReader(fp)):
            if row.get('SKIP', False):
                logging.debug('Skipping group %s', row.get('NAME'))
                continue
            
            try:
                group_name = row['NAME']
                protons = int(row['PROTONS'])
                charge = int(row['CHARGE'])
                mgs = int(row['MAGNESIUMS'])
                smarts = row['SMARTS']
                focal_atoms = FocalSet(row['FOCAL_ATOMS'])
                _remark = row['REMARK']
                
                # Check that the smarts are good.
                if not Molecule.VerifySmarts(smarts):
                    raise GroupsDataError('Cannot parse SMARTS from line %d: %s' %
                                          (line_num, smarts))
                
                group = Group(gid, group_name, protons, charge, mgs, str(smarts),
                              focal_atoms)
                list_of_groups.append(group)
            except KeyError, msg:
                logging.error(msg)
                raise GroupsDataError('Failed to parse row.')
            except ValueError, msg:
                logging.error(msg)
                raise GroupsDataError('Wrong number of columns (%d) in one of the rows in %s: %s' %
                                      (len(row), filename, str(row)))
            
            gid += 1
        logging.debug('Done reading groups data.')
        
        return GroupsData(list_of_groups, transformed)    

    @staticmethod
    def FromDatabase(db, filename=None, transformed=False):
        """Factory that initializes a GroupData from a DB connection.
        
        Args:
            db: a Database object.
            filename: an optional filename to load data from when
                it's not in the DB. Will write to DB if reading from file.
        
        Returns:
            An initialized GroupsData object.
        """
        logging.debug('Reading the list of groups from the database.')
        
        if not db.DoesTableExist('groups'):
            if filename:
                groups_data = GroupsData.FromGroupsFile(filename)
                groups_data.ToDatabase(db)
                return groups_data
            else:
                raise Exception('Cannot initialize GroupsData, no file was '
                                'provided and the database does not contain '
                                'the information either')
        
        # Table should exist.
        list_of_groups = []
        for row in db.Execute('SELECT * FROM groups'):
            (gid, group_name, protons, charge, nMg, smarts, focal_atom_set, unused_remark) = row
            try:
                focal_atoms = FocalSet(focal_atom_set)
            except ValueError as e:
                raise ValueError('Group #%d (%s): %s' % (gid, group_name, str(e)))
            list_of_groups.append(Group(gid, group_name, protons, charge, nMg, str(smarts), focal_atoms))
        logging.debug('Done reading groups data.')
        
        return GroupsData(list_of_groups, transformed)
    
    def ToDatabase(self, db):
        """Write the GroupsData to the database."""
        logging.debug('Writing GroupsData to the database.')
        
        db.CreateTable('groups', 'gid INT, name TEXT, protons INT, charge INT, nMg INT, smarts TEXT, focal_atoms TEXT, remark TEXT')
        for group in self.groups:
            focal_atom_str = str(group.focal_atoms)
            db.Insert('groups', [group.id, group.name, group.hydrogens, group.charge, 
                                 group.nMg, group.smarts, focal_atom_str, ''])

        logging.debug('Done writing groups data into database.')

    def Index(self, gr):
        try:
            return self.all_groups.index(gr)
        except ValueError:
            raise ValueError('group %s is not defined' % str(gr))
    
    def GetGroupNames(self):
        if self.transformed:
            return self.biochemical_group_names
        else:
            return self.all_group_names

class GroupDecompositionError(Exception):
    
    def __init__(self, msg, decomposition):
        Exception.__init__(self, msg)
        self.decomposition = decomposition
        
    def __str__(self):
        return Exception.__str__(self)
    
    def GetDebugTable(self):
        return self.decomposition.ToTableString()

class GroupDecomposition(object):
    """Class representing the group decomposition of a molecule."""
    
    def __init__(self, groups_data, mol, groups, unassigned_nodes):
        self.groups_data = groups_data
        self.mol = mol
        self.groups = groups
        self.unassigned_nodes = unassigned_nodes
    
    def ToTableString(self):
        """Returns the decomposition as a tabular string."""
        spacer = '-' * 50 + '\n'
        l = ['%30s | %2s | %2s | %3s | %s\n' % ("group name", "nH", "z", "nMg", "nodes"),
             spacer]
                
        for group, node_sets in self.groups:
            if group.hydrogens is None and group.charge is None and group.nMg is None:
                for n_set in node_sets:
                    s = '%30s |    |    |     | %s\n' % \
                        (group.name, ','.join([str(i) for i in n_set]))
                    l.append(s)
            else:
                for n_set in node_sets:
                    s = '%30s | %2d | %2d | %2d | %s\n' % \
                        (group.name, group.hydrogens or 0, group.charge or 0, group.nMg or 0,
                         ','.join([str(i) for i in n_set]))
                    l.append(s)

        if self.unassigned_nodes:
            l.append('\nUnassigned nodes: \n')
            l.append('%10s | %3s | %2s | %10s | %10s\n' %
                     ('index', 'an', 'el', 'valence', 'charge'))
            l.append(spacer)
            
            all_atoms = self.mol.GetAtoms()
            for i in self.unassigned_nodes:
                a = all_atoms[i]
                l.append('%10d | %3d | %2s | %10d | %10d\n' %
                         (i, a.GetAtomicNum(), Molecule.GetSymbol(a.GetAtomicNum()),
                          a.GetHvyValence(), a.GetFormalCharge()))
        return ''.join(l)

    def __str__(self):
        """Convert the groups to a string."""        
        group_strs = []
        for group, node_sets in self.NonEmptyGroups():
            if group.hydrogens is None and group.charge is None and group.nMg is None:
                group_strs.append('%s x %d' % (group.name, len(node_sets)))
            else:
                group_strs.append('%s [H%d %d %d] x %d' % 
                    (group.name, group.hydrogens, group.charge, group.nMg, 
                     len(node_sets)))
        return " | ".join(group_strs)
    
    def __len__(self):
        counter = 0
        for _group, node_sets in self.NonEmptyGroups():
            counter += len(node_sets)
        return counter
    
    def AsVector(self):
        """Return the group in vector format.
        
        Note: self.groups contains an entry for *all possible* groups, which is
        why this function returns consistent values for all compounds.
        """
        group_vec = GroupVector(self.groups_data)
        for i, (unused_group, node_sets) in enumerate(self.groups):
            group_vec[i] = len(node_sets)
        group_vec[-1] = 1 # The origin
        return group_vec
    
    def NonEmptyGroups(self):
        """Generator for non-empty groups."""
        for group, node_sets in self.groups:
            if node_sets:
                yield group, node_sets
    
    def UnassignedAtoms(self):
        """Generator for unassigned atoms."""
        for i in self.unassigned_nodes:
            yield self.mol.GetAtoms()[i], i
    
    def SparseRepresentation(self):
        """Returns a dictionary representation of the group.
        
        TODO(flamholz): make this return some custom object.
        """
        return dict((group, node_sets) for group, node_sets in self.NonEmptyGroups())
    
    def NetCharge(self):
        """Returns the net charge."""
        return self.AsVector().NetCharge()
    
    def Hydrogens(self):
        """Returns the number of hydrogens."""
        return self.AsVector().Hydrogens()
    
    def Magnesiums(self):
        """Returns the number of Mg2+ ions."""
        return self.AsVector().Magnesiums()
    
    def CountGroups(self):
        """Returns the total number of groups in the decomposition."""
        return sum([len(gdata[-1]) for gdata in self.groups])

    def PseudoisomerVectors(self):
        
        def distribute(total, num_slots):
            """
                Returns:
                    a list with all the distinct options of distributing 'total' balls
                    in 'num_slots' slots.
                
                Example:
                    distribute(3, 2) = [[0, 3], [1, 2], [2, 1], [3, 0]]
            """
            if num_slots == 1:
                return [[total]]
            
            if total == 0:
                return [[0] * num_slots]
            
            all_options = []
            for i in xrange(total+1):
                for opt in distribute(total-i, num_slots-1):
                    all_options.append([i] + opt)
                    
            return all_options
        
        def multi_distribute(total_slots_pairs):
            """
                Returns:
                    similar to distribute, but with more constraints on the sub-totals
                    in each group of slots. Every pair in the input list represents
                    the subtotal of the number of balls and the number of available balls for them.
                    The total of the numbers in these slots will be equal to the subtotal.
                
                Example:
                    multi_distribute([(1, 2), (2, 2)]) =
                    [[0, 1, 0, 2], [0, 1, 1, 1], [0, 1, 2, 0], [1, 0, 0, 2], [1, 0, 1, 1], [1, 0, 2, 0]]
                    
                    in words, the subtotal of the two first slots must be 1, and the subtotal
                    of the two last slots must be 2.
            """
            multilist_of_options = []
            for (total, num_slots) in total_slots_pairs:
                multilist_of_options.append(distribute(total, num_slots))
        
            return [sum(x) for x in itertools.product(*multilist_of_options)]
        
        """Returns a list of group vectors, one per pseudo-isomer."""    
        if not self.CountGroups():
            logging.debug('No groups in this decomposition, not calculating pseudoisomers.')
            return []
        
        # A map from each group name to its indices in the group vector.
        # Note that some groups appear more than once (since they can have
        # multiple protonation levels).
        group_name_to_index = {}

        # 'group_name_to_count' is a map from each group name to its number of appearances in 'mol'
        group_name_to_count = {}
        for i, gdata in enumerate(self.groups):
            group, node_sets = gdata
            group_name_to_index.setdefault(group.name, []).append(i)
            group_name_to_count[group.name] = group_name_to_count.get(group.name, 0) + len(node_sets)
        
        index_vector = [] # maps the new indices to the original ones that are used in groupvec

        # A list of per-group pairs (count, # possible protonation levels).
        total_slots_pairs = [] 

        for group_name, groupvec_indices in group_name_to_index.iteritems():
            index_vector += groupvec_indices
            total_slots_pairs.append((group_name_to_count[group_name],
                                      len(groupvec_indices)))

        # generate all possible assignments of protonations. Each group can appear several times, and we
        # can assign a different protonation level to each of the instances.
        groupvec_list = []
        for assignment in multi_distribute(total_slots_pairs):
            v = [0] * len(index_vector)
            for i in xrange(len(v)):
                v[index_vector[i]] = assignment[i]
            v += [1]  # add 1 for the 'origin' group
            groupvec_list.append(GroupVector(self.groups_data, v))
        return groupvec_list

    # Various properties
    nonempty_groups = property(NonEmptyGroups)
    unassigned_atoms = property(UnassignedAtoms)
    hydrogens = property(Hydrogens)
    net_charge = property(NetCharge)
    magnesiums = property(Magnesiums)
    group_count = property(CountGroups)

class GroupDecomposer(object):
    """Decomposes compounds into their constituent groups."""
    
    def __init__(self, groups_data):
        """Construct a GroupDecomposer.
        
        Args:
            groups_data: a GroupsData object.
        """
        self.groups_data = groups_data

    @staticmethod
    def FromGroupsFile(filename):
        """Factory that initializes a GroupDecomposer from a CSV file."""
        assert filename
        gd = GroupsData.FromGroupsFile(filename)
        return GroupDecomposer(gd)
    
    @staticmethod
    def FromDatabase(db, filename=None):
        """Factory that initializes a GroupDecomposer from the database.
        
        Args:
            db: a Database object.
            filename: an optional filename to load data from when
                it's not in the DB. Will write to DB if reading from file.
        
        Returns:
            An initialized GroupsData object.
        """
        assert db
        gd = GroupsData.FromDatabase(db, filename)
        return GroupDecomposer(gd)

    @staticmethod
    def _RingedPChainSmarts(length):
        return ''.join(['[C,S][O;R1]', '[P;R1](=O)([OH,O-])[O;R1]' * length, '[C,S]'])

    @staticmethod
    def _InternalPChainSmarts(length):
        return ''.join(['[C,S][O;R0]', '[P;R0](=O)([OH,O-])[O;R0]' * length, '[C,S]'])
    
    @staticmethod
    def _TerminalPChainSmarts(length):
        return ''.join(['[OH,O-]', 'P(=O)([OH,O-])O' * length, '[C,S]'])

    @staticmethod
    def AttachMgToPhosphateChain(mol, chain_map, assigned_mgs):
        """Attaches Mg2+ ions the appropriate groups in the chain.
        
        Args:
            mol: the molecule.
            chain_map: the groups in the chain.
            assigned_mgs: the set of Mg2+ ions that are already assigned.
        
        Returns:
            The updated list of assigned Mg2+ ions. 
        """
        # For each Mg2+ we see, we attribute it to a phosphate group if
        # possible. We prefer to assign it to a terminal phosphate, but otherwise 
        # we assign it to a 'middle' group when there are 2 of them.
        def AddMg(p_group, pmg_group, mg):
            node_set = chain_map[p_group].pop(0)
            mg_index = mg[0]
            node_set.add(mg_index)
            assigned_mgs.add(mg_index)
            chain_map[pmg_group].append(node_set)
        
        all_pmg_groups = (GroupsData.FINAL_PHOSPHATES_TO_MGS +
                          GroupsData.MIDDLE_PHOSPHATES_TO_MGS + 
                          GroupsData.RING_PHOSPHATES_TO_MGS)
        for mg in mol.FindSmarts('[Mg+2]'):
            if mg[0] in assigned_mgs:
                continue
            
            for p_group, pmg_group in all_pmg_groups:
                if chain_map[p_group]:
                    AddMg(p_group, pmg_group, mg)
                    break

        return assigned_mgs

    @staticmethod
    def UpdateGroupMapFromChain(group_map, chain_map):
        """Updates the group_map by adding the chain."""
        for group, node_sets in chain_map.iteritems():
            group_map.get(group, []).extend(node_sets)
        return group_map

    @staticmethod
    def FindPhosphateChains(mol, max_length=4, ignore_protonations=False):
        """
        Chain end should be 'OC' for chains that do not really end, but link to carbons.
        Chain end should be '[O-1,OH]' for chains that end in an hydroxyl.
    
        Args:
            mol: the molecule to decompose.
            max_length: the maximum length of a phosphate chain to consider.
            ignore_protonations: whether or not to ignore protonation values.
        
        Returns:
            A list of 2-tuples (phosphate group, # occurrences).
        """
        group_map = dict((pg, []) for pg in GroupsData.PHOSPHATE_GROUPS)
        v_charge = [a.GetFormalCharge() for a in mol.GetAtoms()]
        assigned_mgs = set()
        
        def pop_phosphate(pchain, p_size):
            if len(pchain) < p_size:
                raise Exception('trying to pop more atoms than are left in the pchain')
            phosphate = pchain[0:p_size]
            charge = sum(v_charge[i] for i in phosphate)
            del pchain[0:p_size]
            return set(phosphate), charge
            
        def add_group(chain_map, group_name, charge, atoms):
            default = GroupsData.DEFAULTS[group_name]
            
            if ignore_protonations:
                chain_map[default].append(atoms)
            else:
                # NOTE(flamholz): We rely on the default number of magnesiums being 0 (which it is).
                hydrogens = default.hydrogens + charge - default.charge
                group = Group(default.id, group_name, hydrogens,
                                          charge, default.nMg)
                if group not in chain_map:
                    #logging.warning('This protonation (%d) level is not allowed for terminal phosphate groups.' % hydrogens)
                    #logging.warning('Using the default protonation level (%d) for this name ("%s").' %
                    #                (default.hydrogens, default.name))
                    raise GroupDecompositionError('The group %s cannot have nH = %d' % (group_name, hydrogens))
                    chain_map[default].append(atoms)
                else:
                    chain_map[group].append(atoms)
        
        # For each allowed length
        for length in xrange(1, max_length + 1):
            # Find internal phosphate chains (ones in the middle of the molecule).
            smarts_str = GroupDecomposer._RingedPChainSmarts(length)
            chain_map = dict((k, []) for (k, _) in group_map.iteritems())
            for pchain in mol.FindSmarts(smarts_str):
                working_pchain = list(pchain)
                working_pchain.pop() # Lose the last carbon
                working_pchain.pop(0) # Lose the first carbon
                
                if length % 2:
                    atoms, charge = pop_phosphate(working_pchain, 5)
                    add_group(chain_map, 'ring -OPO3-', charge, atoms)                    
                else:
                    atoms, charge = pop_phosphate(working_pchain, 9)
                    add_group(chain_map, 'ring -OPO3-OPO2-', charge, atoms)
                
                while working_pchain:
                    atoms, charge = pop_phosphate(working_pchain, 8)
                    add_group(chain_map, 'ring -OPO2-OPO2-', charge, atoms)
            
            assigned_mgs = GroupDecomposer.AttachMgToPhosphateChain(mol, chain_map,
                                                                    assigned_mgs)
            GroupDecomposer.UpdateGroupMapFromChain(group_map, chain_map)

            # Find internal phosphate chains (ones in the middle of the molecule).
            smarts_str = GroupDecomposer._InternalPChainSmarts(length)
            chain_map = dict((k, []) for (k, _) in group_map.iteritems())
            for pchain in mol.FindSmarts(smarts_str):
                working_pchain = list(pchain)
                working_pchain.pop() # Lose the last carbon
                working_pchain.pop(0) # Lose the first carbon
                
                if length % 2:
                    atoms, charge = pop_phosphate(working_pchain, 5)
                    add_group(chain_map, '-OPO3-', charge, atoms)                    
                else:
                    atoms, charge = pop_phosphate(working_pchain, 9)
                    add_group(chain_map, '-OPO3-OPO2-', charge, atoms)
                
                while working_pchain:
                    atoms, charge = pop_phosphate(working_pchain, 8)
                    add_group(chain_map, '-OPO2-OPO2-', charge, atoms)
            
            assigned_mgs = GroupDecomposer.AttachMgToPhosphateChain(mol, chain_map,
                                                                    assigned_mgs)
            GroupDecomposer.UpdateGroupMapFromChain(group_map, chain_map)
            
            # Find terminal phosphate chains.
            smarts_str = GroupDecomposer._TerminalPChainSmarts(length)
            chain_map = dict((k, []) for (k, _) in group_map.iteritems())
            for pchain in mol.FindSmarts(smarts_str):
                working_pchain = list(pchain)
                working_pchain.pop() # Lose the carbon
                
                atoms, charge = pop_phosphate(working_pchain, 5)
                add_group(chain_map, '-OPO3', charge, atoms)
                
                if not length % 2:
                    atoms, charge = pop_phosphate(working_pchain, 4)
                    add_group(chain_map, '-OPO2-', charge, atoms)
                
                while working_pchain:
                    atoms, charge = pop_phosphate(working_pchain, 8)
                    add_group(chain_map, '-OPO2-OPO2-', charge, atoms)
                
            assigned_mgs = GroupDecomposer.AttachMgToPhosphateChain(mol, chain_map,
                                                                    assigned_mgs)
            GroupDecomposer.UpdateGroupMapFromChain(group_map, chain_map)

        return [(pg, group_map[pg]) for pg in GroupsData.PHOSPHATE_GROUPS]

    def CreateEmptyGroupDecomposition(self):
        emptymol = Molecule.FromSmiles("")
        decomposition = self.Decompose(emptymol, ignore_protonations=True, strict=False)
        for i, (group, _node_sets) in enumerate(decomposition.groups):
            decomposition.groups[i] = (group, [])
        return decomposition

    def Decompose(self, mol, ignore_protonations=False, strict=False):
        """
        Decompose a molecule into groups.
        
        The flag 'ignore_protonations' should be used when decomposing a compound with lacing protonation
        representation (for example, the KEGG database doesn't posses this information). If this flag is
        set to True, it overrides the '(C)harge sensitive' flag in the groups file (i.e. - *PC)
        
        Args:
            mol: the molecule to decompose.
            ignore_protonations: whether to ignore protonation levels.
            strict: whether to assert that there are no unassigned atoms.
        
        Returns:
            A GroupDecomposition object containing the decomposition.
        """
        unassigned_nodes = set(range(len(mol)))
        groups = []
        
        def _AddCorrection(group, count):
            l = [set() for _ in xrange(count)]
            groups.append((group, l))
        
        for group in self.groups_data.groups:
            # Phosphate chains require a special treatment
            if group.IsPhosphate():
                pchain_groups = None
                if group.IgnoreCharges() or ignore_protonations:
                    pchain_groups = self.FindPhosphateChains(mol, ignore_protonations=True)
                elif group.ChargeSensitive():
                    pchain_groups = self.FindPhosphateChains(mol, ignore_protonations=False)
                else:
                    raise MalformedGroupDefinitionError(
                        'Unrecognized phosphate wildcard: %s' % group.name)
                
                for phosphate_group, group_nodesets in pchain_groups:
                    current_groups = []
                    
                    for focal_set in group_nodesets:
                        if focal_set.issubset(unassigned_nodes):
                            # Check that the focal-set doesn't override an assigned node
                            current_groups.append(focal_set)
                            unassigned_nodes = unassigned_nodes - focal_set
                    groups.append((phosphate_group, current_groups))
            elif group.IsCodedCorrection():
                _AddCorrection(group, group.GetCorrection(mol))
            # Not a phosphate group or expanded correction.
            else:
                # TODO: if the 'ignore_protonation' flag is True, this should always
                # use the pseudogroup with the lowest nH in each category regardless
                # of the hydrogens in the given Mol.
                current_groups = []
                for nodes in mol.FindSmarts(group.smarts): 
                    try:
                        focal_set = group.FocalSet(nodes)
                    except IndexError:
                        logging.error('Focal set for group %s is out of range: %s'
                                      % (str(group), str(group.focal_atoms)))
                        sys.exit(-1)

                    # check that the focal-set doesn't override an assigned node
                    if focal_set.issubset(unassigned_nodes): 
                        current_groups.append(focal_set)
                        unassigned_nodes = unassigned_nodes - focal_set
                groups.append((group, current_groups))
        
        # Ignore the hydrogen atoms when checking which atom is unassigned
        for nodes in mol.FindSmarts('[H]'): 
            unassigned_nodes = unassigned_nodes - set(nodes)
        
        decomposition = GroupDecomposition(self.groups_data, mol,
                                           groups, unassigned_nodes)
        
        if strict and decomposition.unassigned_nodes:
            raise GroupDecompositionError('Unable to decompose %s into groups.' % mol.title,
                                          decomposition)
        
        return decomposition

class OpenBabelError(Exception):
    pass

class Molecule(object):

    # for more rendering options visit:
    # http://www.ggasoftware.com/opensource/indigo/api/options#rendering
    _obElements = openbabel.OBElementTable()
    _obSmarts = openbabel.OBSmartsPattern()
    
    @staticmethod
    def GetNumberOfElements():
        return Molecule._obElements.GetNumberOfElements()
    
    @staticmethod
    def GetAllElements():
        return [Molecule._obElements.GetSymbol(i) for i in 
                xrange(Molecule.GetNumberOfElements())]

    @staticmethod
    def GetSymbol(atomic_num):
        return Molecule._obElements.GetSymbol(atomic_num)
            
    @staticmethod
    def GetAtomicNum(elem):
        if type(elem) == types.UnicodeType:
            elem = str(elem)
        return Molecule._obElements.GetAtomicNum(elem)
    
    @staticmethod
    def VerifySmarts(smarts):
        return Molecule._obSmarts.Init(smarts)
    
    def __init__(self):
        self.title = None
        self.obmol = openbabel.OBMol()
        self.smiles = None
        self.inchi = None

    def __str__(self):
        return self.title or self.smiles or self.inchi or ""
        
    def __len__(self):
        return self.GetNumAtoms()
    
    def Clone(self):
        tmp = Molecule()
        tmp.title = self.title
        tmp.obmol = openbabel.OBMol(self.obmol)
        tmp.smiles = self.smiles
        tmp.inchi = self.inchi
        return tmp
    
    def SetTitle(self, title):
        self.title = title 
    
    @staticmethod
    def FromSmiles(smiles):
        m = Molecule()
        m.smiles = smiles
        obConversion = openbabel.OBConversion()
        obConversion.SetInFormat("smiles")
        if not obConversion.ReadString(m.obmol, m.smiles):
            raise OpenBabelError("Cannot read the SMILES string: " + smiles)
        try:
            m.UpdateInChI()
        except OpenBabelError:
            raise OpenBabelError("Failed to create Molecule from SMILES: " + smiles)
        m.SetTitle(smiles)
        return m
        
    @staticmethod
    def FromInChI(inchi):
        m = Molecule()
        m.inchi = inchi
        obConversion = openbabel.OBConversion()
        obConversion.SetInFormat("inchi")
        obConversion.ReadString(m.obmol, m.inchi)
        try:
            m.UpdateSmiles()
        except OpenBabelError:
            raise OpenBabelError("Failed to create Molecule from InChI: " + inchi)
        m.SetTitle(inchi)
        return m
    
    @staticmethod
    def FromMol(mol):
        m = Molecule()
        obConversion = openbabel.OBConversion()
        obConversion.SetInFormat("mol")
        obConversion.ReadString(m.obmol, mol)
        try:
            m.UpdateInChI()
            m.UpdateSmiles()
        except OpenBabelError:
            raise OpenBabelError("Failed to create Molecule from MOL file:\n" + mol)
        m.SetTitle("")
        return m

    @staticmethod
    def FromOBMol(obmol):
        m = Molecule()
        m.obmol = obmol
        try:
            m.UpdateInChI()
            m.UpdateSmiles()
        except OpenBabelError:
            raise OpenBabelError("Failed to create Molecule from OBMol")
        m.SetTitle("")
        return m
    
    @staticmethod
    def _FromFormat(s, fmt='inchi'):
        if fmt == 'smiles' or fmt == 'smi':
            return Molecule.FromSmiles(s)
        if fmt == 'inchi':
            return Molecule.FromInChI(s)
        if fmt == 'mol':
            return Molecule.FromMol(s)
        if fmt == 'obmol':
            return Molecule.FromOBMol(s)
    
    @staticmethod
    def _ToFormat(obmol, fmt='inchi'):
        obConversion = openbabel.OBConversion()
        obConversion.SetOutFormat(fmt)
        res = obConversion.WriteString(obmol)
        if not res:
            raise OpenBabelError("Cannot convert OBMol to %s" % fmt)
        if fmt == 'smiles' or fmt == 'smi':
            res = res.split()
            if res == []:
                raise OpenBabelError("Cannot convert OBMol to %s" % fmt)
            else:
                return res[0]
        elif fmt == 'inchi':
            return res.strip()
        else:
            return res
        
    @staticmethod
    def Smiles2InChI(smiles):
        obConversion = openbabel.OBConversion()
        obConversion.SetInAndOutFormats("smiles", "inchi")
        obmol = openbabel.OBMol()
        if not obConversion.ReadString(obmol, smiles):
            raise OpenBabelError("Cannot read the SMILES string: " + smiles)
        return obConversion.WriteString(obmol).strip()

    @staticmethod
    def InChI2Smiles(inchi):
        obConversion = openbabel.OBConversion()
        obConversion.SetInAndOutFormats("inchi", "smiles")
        obmol = openbabel.OBMol()
        if not obConversion.ReadString(obmol, inchi):
            raise OpenBabelError("Cannot read the InChI string: " + inchi)
        return obConversion.WriteString(obmol).split()[0]
        
    def RemoveHydrogens(self):
        self.obmol.DeleteHydrogens()
    
    def RemoveAtoms(self, indices):
        self.obmol.BeginModify()
        for i in sorted(indices, reverse=True):
            self.obmol.DeleteAtom(self.obmol.GetAtom(i+1))
        self.obmol.EndModify()
        self.smiles = None
        self.inchi = None
        
    def SetAtomicNum(self, index, new_atomic_num):
        self.obmol.GetAtom(index+1).SetAtomicNum(new_atomic_num)
        self.smiles = None
        self.inchi = None
        
    def ToOBMol(self):
        return self.obmol
    
    def ToFormat(self, fmt='inchi'):
        return Molecule._ToFormat(self.obmol, fmt=fmt)
    
    def ToMolfile(self):
        return self.ToFormat('mol')

    def UpdateInChI(self):
        self.inchi = Molecule._ToFormat(self.obmol, 'inchi')

    def ToInChI(self):
        """ 
            Lazy storage of the InChI identifier (calculate once only when 
            asked for and store for later use).
        """
        if not self.inchi:
            self.UpdateInChI()
        return self.inchi
    
    def UpdateSmiles(self):
        self.smiles = Molecule._ToFormat(self.obmol, 'smiles')
    
    def ToSmiles(self):
        """ 
            Lazy storage of the SMILES identifier (calculate once only when 
            asked for and store for later use).
        """
        if not self.smiles:
            self.UpdateSmiles()
        return self.smiles
    
    def GetFormula(self):
        tokens = re.findall('InChI=1S?/([0-9A-Za-z\.]+)', self.ToInChI())
        if len(tokens) == 1:
            return tokens[0]
        elif len(tokens) > 1:
            raise ValueError('Bad InChI: ' + self.ToInChI())
        else:
            return ''
    
    def GetExactMass(self):
        return self.obmol.GetExactMass()
    
    def GetAtomBagAndCharge(self):
        inchi = self.ToInChI()

        fixed_charge = 0
        for s in re.findall('/q([0-9\+\-]+)', inchi):
            fixed_charge += int(s)

        fixed_protons = 0
        for s in re.findall('/p([0-9\+\-]+)', inchi):
            fixed_protons += int(s)
        
        formula = self.GetFormula()

        atom_bag = {}
        for mol_formula_times in formula.split('.'):
            for times, mol_formula in re.findall('^(\d+)?(\w+)', mol_formula_times):
                if not times:
                    times = 1
                else:
                    times = int(times)
                for atom, count in re.findall("([A-Z][a-z]*)([0-9]*)", mol_formula):
                    if count == '':
                        count = 1
                    else:
                        count = int(count)
                    atom_bag[atom] = atom_bag.get(atom, 0) + count * times
        
        if fixed_protons:
            atom_bag['H'] = atom_bag.get('H', 0) + fixed_protons
            fixed_charge += fixed_protons
        return atom_bag, fixed_charge
        
    def GetHydrogensAndCharge(self):
        atom_bag, charge = self.GetAtomBagAndCharge()
        return atom_bag.get('H', 0), charge
        
    def GetNumElectrons(self):
        """Calculates the number of electrons in a given molecule."""
        atom_bag, fixed_charge = self.GetAtomBagAndCharge()
        n_protons = 0
        for elem, count in atom_bag.iteritems():
            n_protons += count * self._obElements.GetAtomicNum(elem)
        return n_protons - fixed_charge
    
    def GetNumAtoms(self):
        return self.obmol.NumAtoms()

    def GetAtoms(self):
        return [self.obmol.GetAtom(i+1) for i in xrange(self.obmol.NumAtoms())]
    
    def FindSmarts(self, smarts):
        """
        Corrects the pyBel version of Smarts.findall() which returns results as tuples,
        with 1-based indices even though Molecule.atoms is 0-based.
    
        Args:
            mol: the molecule to search in.
            smarts_str: the SMARTS query to search for.
        
        Returns:
            The re-mapped list of SMARTS matches.
        """
        Molecule._obSmarts.Init(smarts)
        if Molecule._obSmarts.Match(self.obmol):
            match_list = Molecule._obSmarts.GetMapList()
            shift_left = lambda m: [(n - 1) for n in m] 
            return map(shift_left, match_list)
        else:
            return []

    def GetAtomCharges(self):
        """
            Returns:
                A list of charges, according to the number of atoms
                in the molecule
        """
        return [atom.GetFormalCharge() for atom in self.GetAtoms()]

    @staticmethod
    def _GetDissociationTable(molstring, fmt='inchi', mid_pH=default_pH, 
                              min_pKa=0, max_pKa=14, T=default_T):
        """
            Returns the relative potentials of pseudoisomers,
            relative to the most abundant one at pH 7.
        """
        from pygibbs.dissociation_constants import DissociationTable
        from toolbox import chemaxon

        diss_table = DissociationTable()
        try:
            pKa_table, major_ms = chemaxon.GetDissociationConstants(molstring, 
                                                                    mid_pH=mid_pH)

            mol = Molecule.FromSmiles(major_ms)
            nH, z = mol.GetHydrogensAndCharge()
            diss_table.SetMolString(nH, nMg=0, s=major_ms)
            diss_table.SetCharge(nH, z, nMg=0)
            
            pKa_higher = [x for x in pKa_table if mid_pH < x[0] < max_pKa]
            pKa_lower = [x for x in pKa_table if mid_pH > x[0] > min_pKa]
            for i, (pKa, _, smiles_above) in enumerate(sorted(pKa_higher)):
                diss_table.AddpKa(pKa, nH_below=(nH-i), nH_above=(nH-i-1),
                                  nMg=0, ref='ChemAxon', T=T)
                diss_table.SetMolString((nH-i-1), nMg=0, s=smiles_above)
    
            for i, (pKa, smiles_below, _) in enumerate(sorted(pKa_lower, reverse=True)):
                diss_table.AddpKa(pKa, nH_below=(nH+i+1), nH_above=(nH+i),
                                  nMg=0, ref='ChemAxon', T=T)
                diss_table.SetMolString((nH+i+1), nMg=0, s=smiles_below)
        except chemaxon.ChemAxonError:
            mol = Molecule._FromFormat(molstring, fmt)
            diss_table.SetOnlyPseudoisomerMolecule(mol)
            
        return diss_table

    def GetDissociationTable(self, fmt='inchi', mid_pH=default_pH, 
                           min_pKa=0, max_pKa=14, T=default_T):
        """
            Returns the relative potentials of pseudoisomers,
            relative to the most abundant one at pH 7.
        """
        
        return Molecule._GetDissociationTable(self.ToInChI(), 'inchi',
                                            mid_pH, min_pKa, max_pKa, T)

class InChI2GroupVector(object):
    
    def __init__(self, groups_data):
        self.RT = R * default_T
        self.group_decomposer = GroupDecomposer(groups_data)
        
    def EstimateInChI(self, inchi):
        mol = Molecule.FromInChI(inchi)
        #mol.RemoveHydrogens()
        decomposition = self.group_decomposer.Decompose(mol, 
                            ignore_protonations=False, strict=True)

        #nH = decomposition.Hydrogens()
        #charge = decomposition.NetCharge()
        #nMg = decomposition.Magnesiums()
        groupvec = decomposition.AsVector()
        gv = np.matrix(groupvec.Flatten())
        return gv
    
    def ArrayToSparseRep(self, a):
        d = {'size': a.shape, "nonzero": []}
        non_zero = a.nonzero()
        for i in xrange(len(non_zero[0])):
            index = tuple([p[i] for p in non_zero])
            d["nonzero"].append(list(index) + [a[index]])
        return d

def MakeOpts():
    """Returns an OptionParser object with all the default options."""
    opt_parser = OptionParser()
    opt_parser.add_option("-s", "--silent",
                          dest="silent",
                          default=False,
                          action="store_true",
                          help="suppress all error and warning messages")
    opt_parser.add_option("-i", "--inchi",
                          dest="inchi",
                          default=None,
                          help="input InChI string")
    opt_parser.add_option("-l", "--list_groups",
                          dest="list_groups",
                          default=False,
                          action="store_true",
                          help="list all group names")
    return opt_parser

if __name__ == "__main__":
    parser = MakeOpts()
    options, _ = parser.parse_args(sys.argv)
    if options.inchi is None and not options.list_groups:
        sys.stderr.write(parser.get_usage())
        sys.exit(-1)
    
    groups_data = GroupsData.FromGroupsFile(GROUP_CSV, transformed=False)
    if options.inchi:
        inchi2gv = InChI2GroupVector(groups_data)
        try:
            groupvec = inchi2gv.EstimateInChI(options.inchi)
        except GroupDecompositionError as e:
            if not options.silent:
                sys.stderr.write(str(e) + '\n')
                sys.stderr.write(e.GetDebugTable())
            sys.exit(-1)
        if options.list_groups:
            sys.stdout.write(', '.join(groups_data.GetGroupNames()) + '\n')
        sys.stdout.write(', '.join("%g" % i for i in groupvec.flat) + '\n')
    else:
        sys.stdout.write('\n'.join(groups_data.GetGroupNames()))
