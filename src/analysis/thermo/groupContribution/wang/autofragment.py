# autofragment.py
import pandas as pd
import pdb
import json
from rdkit import Chem

def count_substructures(radius,molecule):
    """Helper function for get the information of molecular signature of a
    metabolite. The relaxed signature requires the number of each substructure
    to construct a matrix for each molecule.
    Parameters
    ----------
    radius : int
        the radius is bond-distance that defines how many neighbor atoms should
        be considered in a reaction center.
    molecule : Molecule
        a molecule object create by RDkit (e.g. Chem.MolFromInchi(inchi_code)
        or Chem.MolToSmiles(smiles_code))
    Returns
    -------
    dict
        dictionary of molecular signature for a molecule,
        {smiles: molecular_signature}
    """
    m = molecule
    smi_count = dict()
    atomList = [atom for atom in m.GetAtoms()]

    for i in range(len(atomList)):
        env = Chem.FindAtomEnvironmentOfRadiusN(m,radius,i)
        atoms=set()
        for bidx in env:
            atoms.add(m.GetBondWithIdx(bidx).GetBeginAtomIdx())
            atoms.add(m.GetBondWithIdx(bidx).GetEndAtomIdx())

        # only one atom is in this environment, such as O in H2O
        if len(atoms) == 0:
            atoms = {i}

        smi = Chem.MolFragmentToSmiles(m,atomsToUse=list(atoms),
                                    bondsToUse=env,canonical=True)

        if smi in smi_count:
            smi_count[smi] = smi_count[smi] + 1
        else:
            smi_count[smi] = 1
    return smi_count

def decompse_ac(db_smiles,radius=1):
    non_decomposable = []
    decompose_vector = dict()

    for cid in db_smiles:
        # print cid
        smiles_pH7 = db_smiles[cid]
        try:
            mol = Chem.MolFromSmiles(smiles_pH7)
            mol = Chem.RemoveHs(mol)
            # Chem.RemoveStereochemistry(mol) 
            smi_count = count_substructures(radius,mol)
            decompose_vector[cid] = smi_count

        except Exception as e:
            non_decomposable.append(cid)

    with open('./data/decompose_vector_ac.json','w') as fp:
        json.dump(decompose_vector,fp)

