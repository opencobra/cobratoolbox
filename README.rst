.. raw:: html


The COBRA Toolbox |br| COnstraint-Based Reconstruction and Analysis Toolbox
---------------------------------------------------------------------------

.. raw:: html

   <table>
     <tr>
     <td><div align="center"><a href="https://opencobra.github.io/cobratoolbox/latest/tutorials/index.html"><img src="https://img.shields.io/badge/COBRA-tutorials-blue.svg?maxAge=0"></a>
       <a href="https://opencobra.github.io/cobratoolbox/latest"><img src="https://img.shields.io/badge/COBRA-docs-blue.svg?maxAge=0"></a>
       <a href="https://groups.google.com/forum/#!forum/cobra-toolbox"><img src="https://img.shields.io/badge/COBRA-forum-blue.svg?maxAge=0"></a></div></td>
       <td><div align="center"><a href="https://king.nuigalway.ie/jenkins/job/COBRAToolbox-branches-auto-linux/"><img src="https://king.nuigalway.ie/cobratoolbox/badges/linux.svg"></a>
       <a href="https://king.nuigalway.ie/jenkins/job/COBRAToolbox-branches-auto-macOS/"><img src="https://king.nuigalway.ie/cobratoolbox/badges/macOS.svg"></a>
       <a href="https://king.nuigalway.ie/jenkins/job/COBRAToolbox-branches-auto-windows7/"><img src="https://king.nuigalway.ie/cobratoolbox/badges/windows.svg"></a>
       <a href="http://opencobra.github.io/cobratoolbox/docs/builds.html"><img src="http://concordion.org/img/benefit-links.png?maxAge=0" height="20px" alt="All continuous integration builds"></a>
       </div></td>
       <td><div align="center"><img src="https://king.nuigalway.ie/cobratoolbox/codegrade/codegrade.svg" alt="Ratio of the number of inefficient code lines and the total number of lines of code (in percent). A: 0-3%, B: 3-6%, C: 6-9%, D: 9-12%, E: 12-15%, F: > 15%.">
       <a href="https://codecov.io/gh/opencobra/cobratoolbox/branch/master"><img src="https://codecov.io/gh/opencobra/cobratoolbox/branch/master/graph/badge.svg?maxAge=0"></a></div></td>
     </tr>
   </table>
   <br>


System Requirements and Solver Installation
-------------------------------------------

.. begin-requirements-marker

|warning| Please follow `this guide <https://opencobra.github.io/cobratoolbox/docs/requirements.html>`__ in order to configure your system properly.

|warning| Please make sure you install a compatible solver. Check the compatibility `here <https://opencobra.github.io/cobratoolbox/docs/compatibility.html>`__.

You may install ``TOMLAB``, ``IBM ILOG CPLEX``, ``GUROBI``, or ``MOSEK`` by following these `detailed instructions <https://opencobra.github.io/cobratoolbox/docs/solvers.html>`__.

.. end-requirements-marker

Installation
------------

.. begin-installation-marker

1. Download this repository (the folder ``./cobratoolbox/`` will be
   created). You can clone the repository using:

   .. code-block:: console

      $ git clone --depth=1 https://github.com/opencobra/cobratoolbox.git cobratoolbox


   |warning| Please note the ``--depth=1`` in the clone command. Run this command in ``Terminal`` (on |macos| and |linux|) or in ``Git Bash`` (on |windows|) -
   **not** in |matlab|. Although not recommended, you can download the
   repository as a `compressed archive <https://king.nuigalway.ie/cobratoolbox/releases/theCOBRAToolbox.zip>`__.

2. Change to the folder ``cobratoolbox/`` and run from |matlab|

   .. code-block:: matlab

      >> initCobraToolbox

.. end-installation-marker


Tutorials, Documentation, and Support
-------------------------------------

-  Consult all tutorials in the section |tutorials|. All tutorials can be run from
   the
   `/tutorials <https://github.com/opencobra/cobratoolbox/tree/master/tutorials>`__
   directory.

-  All functions are documented in the |latest|.

-  If you need support, please feel free to post your question in our |forum|.

-  Answers to Frequently Asked Questions (**FAQ**) are
   `here <https://opencobra.github.io/cobratoolbox/stable/faq.html>`__.


How to contribute
-----------------

.. begin-how-to-contribute-marker

|thumbsup| |tada| First off, thanks for taking the time to contribute to `The COBRA
Toolbox <https://github.com/opencobra/cobratoolbox>`__! |tada| |thumbsup|

.. raw:: html

   <p align="center">
   <img src="https://cdn.jsdelivr.net/gh/opencobra/MATLAB.devTools@e735bd91310e8ef10fab4d3c21833a85bf4b8159/docs/source/_static/img/logo_devTools.png" height="120px" alt="devTools"/>
   </p>


You can install the
`MATLAB.devTools <https://github.com/opencobra/MATLAB.devTools>`__ from
within MATLAB by typing:

.. code-block:: matlab

    >> installDevTools()

|bulb| Check out `MATLAB.devTools
<https://github.com/opencobra/MATLAB.devTools>`__ - and contribute the smart
way! The **official documentation** is `here <https://opencobra.github.com/MATLAB.devTools>`__.

|thumbsup| Contribute to the ``opencobra/cobratoolbox`` repository by following `these
instructions
<https://opencobra.github.io/MATLAB.devTools/stable/contribute.html#the-cobra-toolbox>`__:

.. code-block:: matlab

    >> contribute('opencobra/cobratoolbox');

|thumbsup| Contribute to the ``opencobra/COBRA.tutorials`` repository by following `these
instructions
<https://opencobra.github.io/MATLAB.devTools/stable/contribute.html#cobra-tutorials>`__:

.. code-block:: matlab

    >> contribute('opencobra/COBRA.tutorials');

-  Please follow the `Style
   Guide <https://opencobra.github.io/cobratoolbox/docs/styleGuide.html>`__.
-  More information on writing a **test** is
   `here <https://opencobra.github.io/cobratoolbox/docs/testGuide.html>`__
   and a template is
   `here <https://opencobra.github.io/cobratoolbox/docs/testTemplate.html>`__.
-  More information on formatting the documentation is
   `here <https://opencobra.github.io/cobratoolbox/docs/documentationGuide.html>`__
-  A guide for reporting an **issue** is `here <https://opencobra.github.io/cobratoolbox/docs/issueGuide.html>`__.

If you want to use ``git`` via the command line interface and need help,
this
`guide <https://www.digitalocean.com/community/tutorials/how-to-create-a-pull-request-on-github>`__
or the official `GitHub
guide <https://help.github.com/articles/creating-a-pull-request/>`__
come in handy.


.. end-how-to-contribute-marker

How to cite the COBRA Toolbox
-----------------------------

.. begin-how-to-cite-marker

When citing the COBRA Toolbox, it is important to cite the original
paper where an algorithm was first reported, as well as its
implementation in the COBRA Toolbox. This is important, because the
objective of the COBRA Toolbox is to amalgamate and integrate the
functionality of a wide range of COBRA algorithms and this will be
undermined if contributors of new algorithms do not get their fair share
of citations. The following is one example how to approach this within
the methods section of a paper (**not** the supplemental material
please):

*To generate a context-specific model the FASTCORE algorithm [1],
implemented in The COBRA Toolbox v3.0 [2], was employed.*

    [1] = Vlassis N, Pacheco MP, Sauter T (2014) Fast Reconstruction of
    Compact Context-Specific Metabolic Network Models. PLoS Comput Biol
    10(1): e1003424.

..

    [2] Laurent Heirendt & Sylvain Arreckx, Thomas Pfau, Sebastian N.
    Mendoza, Anne Richelle, Almut Heinken, Hulda S. Haraldsdottir, Jacek
    Wachowiak, Sarah M. Keating, Vanja Vlasov, Stefania Magnusdottir,
    Chiam Yu Ng, German Preciat, Alise Zagare, Siu H.J. Chan, Maike K.
    Aurich, Catherine M. Clancy, Jennifer Modamio, John T. Sauls,
    Alberto Noronha, Aarash Bordbar, Benjamin Cousins, Diana C. El
    Assal, Luis V. Valcarcel, Inigo Apaolaza, Susan Ghaderi, Masoud
    Ahookhosh, Marouen Ben Guebila, Andrejs Kostromins, Nicolas
    Sompairac, Hoai M. Le, Ding Ma, Yuekai Sun, Lin Wang, James T.
    Yurkovich, Miguel A.P. Oliveira, Phan T. Vuong, Lemmer P. El Assal,
    Inna Kuperstein, Andrei Zinovyev, H. Scott Hinton, William A.
    Bryant, Francisco J. Aragon Artacho, Francisco J. Planes, Egils
    Stalidzans, Alejandro Maass, Santosh Vempala, Michael Hucka, Michael
    A. Saunders, Costas D. Maranas, Nathan E. Lewis, Thomas Sauter,
    Bernhard Ø. Palsson, Ines Thiele, Ronan M.T. Fleming, **Creation and
    analysis of biochemical constraint-based models: the COBRA Toolbox
    v3.0**, Nature Protocols, volume 14, pages 639–702, 2019
    `doi.org/10.1038/s41596-018-0098-2 <https://doi.org/10.1038/s41596-018-0098-2>`__.

.. end-how-to-cite-marker

Binaries and Compatibility
--------------------------

|warning| Please make sure you install a compatible solver. Check the
compatibility
`here <https://opencobra.github.io/cobratoolbox/docs/compatibility.html>`__.

.. begin-binaries-marker

For convenience, we provide
`glpk_mex <https://github.com/blegat/glpkmex>`__ and
`libSBML-5.17+ <http://sbml.org/Software/libSBML>`__ in
``/external``.

`Binaries <https://github.com/opencobra/COBRA.binary>`__ for these
libraries are provided in a submodule for Mac OS X 10.6 or later
(64-bit), GNU/Linux Ubuntu 14.0+ (64-bit), and Microsoft Windows 7+
(64-bit). For unsupported OS, please refer to their respective building
instructions
(`glpk_mex <https://github.com/blegat/glpkmex#instructions-for-compiling-from-source>`__,
`libSBML <http://sbml.org/Software/libSBML/5.17.0/docs//cpp-api/libsbml-installation.html>`__).

Read more on the compatibility with SBML-FBCv2
`here <https://opencobra.github.io/cobratoolbox/docs/notes.html>`__.

.. end-binaries-marker

Disclaimer
----------

*The software provided by the openCOBRA Project is distributed under the
GNU GPLv3 or later. However, this software is designed for scientific
research and as such may contain algorithms that are associated with
patents in the U.S. and abroad. If the user so chooses to use the
software provided by the openCOBRA project for commercial endeavors then
it is solely the user’s responsibility to license any patents that may
exist and respond in full to any legal actions taken by the patent
holder.*


.. icon-marker


.. |macos| raw:: html

   <img src="https://king.nuigalway.ie/cobratoolbox/img/apple.png" height="20px" width="20px" alt="macOS">


.. |linux| raw:: html

   <img src="https://king.nuigalway.ie/cobratoolbox/img/linux.png" height="20px" width="20px" alt="linux">


.. |windows| raw:: html

   <img src="https://king.nuigalway.ie/cobratoolbox/img/windows.png" height="20px" width="20px" alt="windows">


.. |warning| raw:: html

   <img src="https://king.nuigalway.ie/cobratoolbox/img/warning.png" height="20px" width="20px" alt="warning">


.. |matlab| raw:: html

   <img src="https://king.nuigalway.ie/cobratoolbox/img/matlab.png" height="20px" width="20px" alt="matlab">


.. |tada| raw:: html

   <img src="https://king.nuigalway.ie/cobratoolbox/img/tada.png" height="20px" width="20px" alt="tada">


.. |thumbsup| raw:: html

   <img src="https://king.nuigalway.ie/cobratoolbox/img/thumbsUP.png" height="20px" width="20px" alt="thumbsup">


.. |bulb| raw:: html

   <img src="https://king.nuigalway.ie/cobratoolbox/img/bulb.png" height="20px" width="20px" alt="bulb">


.. |tutorials| raw:: html

   <a href="https://opencobra.github.io/cobratoolbox/latest/tutorials/index.html"><img src="https://img.shields.io/badge/COBRA-tutorials-blue.svg?maxAge=0"></a>


.. |latest| raw:: html

   <a href="https://opencobra.github.io/cobratoolbox/latest"><img src="https://img.shields.io/badge/COBRA-docs-blue.svg?maxAge=0"></a>


.. |forum| raw:: html

   <a href="https://groups.google.com/forum/#!forum/cobra-toolbox"><img src="https://img.shields.io/badge/COBRA-forum-blue.svg"></a>


.. |br| raw:: html

   <br>


