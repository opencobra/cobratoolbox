Unified COBRA model field specification
-----------------------------------------

To support consistent handling of genome-scale metabolic models across the COBRA Toolbox ecosystem, a unified model field structure has been established. This shared specification ensures that models originating from different repositories, formats or reconstruction pipelines can be interpreted reliably by toolbox functions. By adhering to a common set of field names, dimensions and semantics, users and developers gain full interoperability, improved compatibility with input and output routines, and predictable behaviour when applying analysis methods. The definitions below describe the agreed standard for COBRA models and serve as the reference for constructing, validating and extending model structures.


Fields in the model structure
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following fields are defined in the COBRA Toolbox. If a field is included in a model, it should match the definition and dimensions listed below.  
The dimensions refer to m (metabolites), n (reactions), g (genes) and c (compartments).  
Singular fields are explicitly marked as ``scalar``, ``string`` or ``struct``.

.. rst-class:: wide-table
.. list-table::
   :header-rows: 1
   :align: left

   * - **Field Name**
     - **Dimension**
     - **Field Type**
     - **Field Description**
     - **COBRA Core Field**

   * - ``model.S``
     - ``m x n``
     - Sparse or Full Matrix of Double
     - Stoichiometric matrix
     - ✓
   * - ``model.mets``
     - ``m x 1``
     - Column Cell Array of Strings
     - Metabolite identifiers
     - ✓
   * - ``model.b``
     - ``m x 1``
     - Column Vector of Doubles
     - Right hand side values for metabolite constraints
     - ✓
   * - ``model.csense``
     - ``m x 1``
     - Column Vector of Chars
     - Constraint senses (E, L, G)
     - ✓
   * - ``model.rxns``
     - ``n x 1``
     - Column Cell Array of Strings
     - Reaction identifiers
     - ✓
   * - ``model.lb``
     - ``n x 1``
     - Column Vector of Doubles
     - Lower bounds
     - ✓
   * - ``model.ub``
     - ``n x 1``
     - Column Vector of Doubles
     - Upper bounds
     - ✓
   * - ``model.c``
     - ``n x 1``
     - Column Vector of Doubles
     - Objective coefficients
     - ✓
   * - ``model.osenseStr``
     - ``string``
     - String
     - Objective sense: ``max`` or ``min``
     - ✓
   * - ``model.genes``
     - ``g x 1``
     - Column Cell Array of Strings
     - Gene identifiers
     - ✓
   * - ``model.metNames``
     - ``m x 1``
     - Column Cell Array of Strings
     - Metabolite names
     - ✓
   * - ``model.grRules``
     - ``n x 1``
     - Column Cell Array of Strings
     - Readable gene protein reaction rules
     - ✓
   * - ``model.rxnNames``
     - ``n x 1``
     - Column Cell Array of Strings
     - Reaction names
     - ✓

   * - ``model.rules``
     - ``n x 1``
     - Column Cell Array of Strings
     - Evaluatable GPR rules
     - 
   * - ``model.geneNames``
     - ``g x 1``
     - Column Cell Array of Strings
     - Gene names
     - 
   * - ``model.compNames``
     - ``c x 1``
     - Column Cell Array of Strings
     - Compartment names
     - 
   * - ``model.comps``
     - ``c x 1``
     - Column Cell Array of Strings
     - Compartment symbols
     - 
   * - ``model.proteinNames``
     - ``g x 1``
     - Column Cell Array of Strings
     - Protein names
     - 
   * - ``model.proteins``
     - ``g x 1``
     - Column Cell Array of Strings
     - Proteins associated with genes
     - 
   * - ``model.metCharges``
     - ``m x 1``
     - Column Vector of Double
     - Metabolite charges
     - 
   * - ``model.metFormulas``
     - ``m x 1``
     - Column Cell Array of Strings
     - Elemental formulas
     - 
   * - ``model.metSmiles``
     - ``m x 1``
     - Column Cell Array of Strings
     - SMILES strings
     - 
   * - ``model.metNotes``
     - ``m x 1``
     - Column Cell Array of Strings
     - Notes for metabolites
     - 
   * - ``model.metHMDBID``
     - ``m x 1``
     - Column Cell Array of Strings
     - HMDB identifiers
     - 
   * - ``model.metInChIString``
     - ``m x 1``
     - Column Cell Array of Strings
     - InChI strings
     - 
   * - ``model.metKEGGID``
     - ``m x 1``
     - Column Cell Array of Strings
     - KEGG metabolite identifiers
     - 
   * - ``model.metChEBIID``
     - ``m x 1``
     - Column Cell Array of Strings
     - ChEBI identifiers
     - 
   * - ``model.metPubChemID``
     - ``m x 1``
     - Column Cell Array of Strings
     - PubChem identifiers
     - 
   * - ``model.metMetaNetXID``
     - ``m x 1``
     - Column Cell Array of Strings
     - MetaNetX metabolite identifiers
     - 
   * - ``model.metSEEDID``
     - ``m x 1``
     - Column Cell Array of Strings
     - SEED metabolite identifiers
     - 
   * - ``model.metBiGGID``
     - ``m x 1``
     - Column Cell Array of Strings
     - BiGG metabolite identifiers
     - 
   * - ``model.metBioCycID``
     - ``m x 1``
     - Column Cell Array of Strings
     - BioCyc metabolite identifiers
     - 
   * - ``model.metEnviPathID``
     - ``m x 1``
     - Column Cell Array of Strings
     - enviPath identifiers
     - 
   * - ``model.metLIPIDMAPSID``
     - ``m x 1``
     - Column Cell Array of Strings
     - LipidMaps identifiers
     - 
   * - ``model.metReactomeID``
     - ``m x 1``
     - Column Cell Array of Strings
     - Reactome metabolite identifiers
     - 
   * - ``model.metSABIORKID``
     - ``m x 1``
     - Column Cell Array of Strings
     - SABIO RK metabolite identifiers
     - 
   * - ``model.metSLMID``
     - ``m x 1``
     - Column Cell Array of Strings
     - SwissLipids identifiers
     - 
   * - ``model.metSBOTerms``
     - ``m x 1``
     - Column Cell Array of Strings
     - SBO terms for metabolites
     - 
   * - ``model.geneEntrezID``
     - ``g x 1`` 
     - Column Cell Array of Strings
     - Entrez gene identifiers
     - 
   * - ``model.geneRefSeqID``
     - ``g x 1``
     - Column Cell Array of Strings
     - RefSeq gene identifiers
     - 
   * - ``model.geneUniprotID``
     - ``g x 1``
     - Column Cell Array of Strings
     - UniProt identifiers
     - 
   * - ``model.geneEcoGeneID``
     - ``g x 1``
     - Column Cell Array of Strings
     - EcoGene identifiers
     - 
   * - ``model.geneKEGGID``
     - ``g x 1``
     - Column Cell Array of Strings
     - KEGG gene identifiers
     - 
   * - ``model.geneHPRDID``
     - ``g x 1``
     - Column Cell Array of Strings
     - HPRD identifiers
     - 
   * - ``model.geneASAPID``
     - ``g x 1``
     - Column Cell Array of Strings
     - ASAP identifiers
     - 
   * - ``model.geneCCDSID``
     - ``g x 1``
     - Column Cell Array of Strings
     - CCDS identifiers
     - 
   * - ``model.geneNCBIProteinID``
     - ``g x 1``
     - Column Cell Array of Strings
     - NCBI protein identifiers
     - 
   * - ``model.rxnGeneMat``
     - ``n x g``
     - Sparse or Full Matrix
     - Reaction gene incidence matrix
     - 
   * - ``model.rxnConfidenceScores``
     - ``n x 1``
     - Column Vector of Double
     - Reaction confidence scores
     - 
   * - ``model.rxnNotes``
     - ``n x 1``
     - Column Cell Array of Strings
     - Notes on reactions
     - 
   * - ``model.rxnECNumbers``
     - ``n x 1``
     - Column Cell Array of Strings
     - EC numbers
     - 
   * - ``model.rxnReferences``
     - ``n x 1``
     - Column Cell Array of Strings
     - Literature references
     - 
   * - ``model.rxnKEGGID``
     - ``n x 1``
     - Column Cell Array of Strings
     - KEGG reaction identifiers
     - 
   * - ``model.rxnKEGGPathways``
     - ``n x 1``
     - Column Cell Array of Strings
     - KEGG pathway mappings
     - 
   * - ``model.rxnMetaNetXID``
     - ``n x 1``
     - Column Cell Array of Strings
     - MetaNetX reaction identifiers
     - 
   * - ``model.rxnBRENDAID``
     - ``n x 1``
     - Column Cell Array of Strings
     - BRENDA reaction identifiers
     - 
   * - ``model.rxnBioCycID``
     - ``n x 1``
     - Column Cell Array of Strings
     - BioCyc reaction identifiers
     - 
   * - ``model.rxnReactomeID``
     - ``n x 1``
     - Column Cell Array of Strings
     - Reactome reaction identifiers
     - 
   * - ``model.rxnSABIORKID``
     - ``n x 1``
     - Column Cell Array of Strings
     - SABIO RK reaction identifiers
     - 
   * - ``model.rxnSEEDID``
     - ``n x 1``
     - Column Cell Array of Strings
     - SEED reaction identifiers
     - 
   * - ``model.rxnRheaID``
     - ``n x 1``
     - Column Cell Array of Strings
     - Rhea identifiers
     - 
   * - ``model.rxnBiGGID``
     - ``n x 1``
     - Column Cell Array of Strings
     - BiGG identifiers
     - 
   * - ``model.rxnSBOTerms``
     - ``n x 1``
     - Column Cell Array of Strings
     - SBO terms for reactions
     - 
   * - ``model.subSystems``
     - ``n x 1``
     - Column Cell Array of Cell Arrays
     - Subsystem annotations
     - 
   * - ``model.description``
     - ``string``
     - String
     - General description of the model
     - 
   * - ``model.modelVersion``
     - ``string``
     - Struct
     - Version metadata
     - 
   * - ``model.modelName``
     - ``string``
     - String
     - Descriptive name
     - 
   * - ``model.modelID``
     - ``string``
     - String
     - Short identifier
     - 
   * - ``model.E``
     - ``m x evars``
     - Sparse or Full Matrix
     - Extra variable constraint matrix
     - 
   * - ``model.evarlb``
     - ``evars x 1``
     - Column Vector of Double
     - Lower bounds of extra variables
     - 
   * - ``model.evarub``
     - ``evars x 1``
     - Column Vector of Double
     - Upper bounds of extra variables
     - 
   * - ``model.evarc``
     - ``evars x 1``
     - Column Vector of Double
     - Objective coefficients for extra variables
     - 
   * - ``model.evars``
     - ``evars x 1``
     - Column Cell Array of Strings
     - Extra variable identifiers
     - 
   * - ``model.evarNames``
     - ``evars x 1``
     - Column Cell Array of Strings
     - Extra variable names
     - 
   * - ``model.C``
     - ``ctrs x n``
     - Sparse or Full Matrix
     - Additional constraints matrix
     - 
   * - ``model.ctrs``
     - ``ctrs x 1``
     - Column Cell Array of Strings
     - Constraint identifiers
     - 
   * - ``model.ctrNames``
     - ``ctrs x 1``
     - Column Cell Array of Strings
     - Constraint names
     - 
   * - ``model.d``
     - ``ctrs x 1``
     - Column Vector of Double
     - Right-hand side values for constraints
     - 
   * - ``model.dsense``
     - ``ctrs x 1``
     - Column Vector of Chars
     - Constraint senses
     - 
   * - ``model.D``
     - ``ctrs x evars``
     - Sparse or Full Matrix
     - Coupling terms between extra variables and constraints
     - 

.. raw:: html

   <div style="clear: both;"></div>

Model Specific Fields
~~~~~~~~~~~~~~~~~~~~~~~~

Some models may contain additional fields that are not part of the COBRA Toolbox standard. Such fields are not used by core functions, and using toolbox operations may cause inconsistencies if these fields depend on reaction or metabolite counts.

Field Support
~~~~~~~~~~~~~~~

All fields listed above are supported by COBRA Toolbox methods. Toolbox functions will preserve consistency, but manual editing of the model structure may not.  
Use ``verifyModel(model)`` to check whether a model meets the COBRA Toolbox structural requirements.

Additional fields
~~~~~~~~~~~~~~~~~~~

Fields beginning with ``met``, ``rxn``, ``comp``, ``protein`` or ``gene`` that are not defined above are treated as annotation fields.  
Input and output functions will attempt to map these to identifiers in registered databases where possible.
