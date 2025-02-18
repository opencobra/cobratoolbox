Solver Installation Guide
-------------------------
.. begin-solver-installation-marker

-  `TOMLAB <#tomlab>`__
-  `IBM ILOG CPLEX <#ibm-ilog-cplex>`__
-  `GUROBI <#gurobi>`__
-  `MOSEK <#mosek>`__

|warning| Please make sure that you install a compatible solver. Check the
compatibility
`here <https://opencobra.github.io/cobratoolbox/docs/compatibility.html>`__.

Platform-specific instructions are marked with

- **Windows** - |windows|
- **macOS** - |macos|
- **linux** - |linux|

|warning| Most steps require superuser or administrator rights (``sudo``).

|pencil| Make sure that you replace ``<ver>`` with the respective
``version`` of the installed solver when setting the environment
variables.

TOMLAB
~~~~~~

1) Download ``TOMLAB/CPLEX`` from
   `here <https://tomopt.com/scripts/register.php>`__, where you can also
   download ``TOMLAB/SNOPT``. You must purchase the ``tomlab.lic``
   license separately.

2) |linux| In a terminal window, navigate to the download directory of
   ``Tomlab`` and do the following:

   .. code-block:: console

      $ chmod +x <filename>.bin
      $ sudo ./<filename>.bin

   |windows| Run the ``tomlab-win64-setup_<ver>.exe`` as an administrator.

   |macos| Double-click on ``tomlab-osx64-setup.app``.

3) Follow the installation instructions and install ``tomlab`` in:

   - |linux|: ``/opt`` such that you will have a folder ``/opt/tomlab``.
   - |windows|: ``C:\`` such that you will have a folder ``C:\tomlab``.
   - |macos|: ``/Applications`` such that you will have a folder ``/Applications/tomlab``.

4) |linux| Copy the ``tomlab.lic`` license to the folder ``/opt/tomlab`` and
   change its permissions (you must have superuser or ``sudo`` rights):

   .. code-block:: console

      $ sudo chmod 644 tomlab.lic

   |windows| Copy the ``tomlab.lic`` license to the folder ``C:\tomlab``. |macos| Copy the ``tomlab.lic`` license to the
   folder ``/Applications/tomlab``.

5) |macos| |linux| Set the environment variable by editing your ``~/.bashrc`` file:

   .. code-block:: console

      $ nano ~/.bashrc

   Append the following lines, hit the
   ``ESC`` key, then save and exit by typing ``CTRL-X`` and hitting ``ENTER``:

   .. code-block:: console

      export TOMLAB_PATH="/opt/tomlab"

   Reload your ``~/.bashrc``:

   .. code-block:: console

      $ source ~/.bashrc

   |windows| In order to set the
   environment variables on Windows, please follow the instructions
   `here <https://www.computerhope.com/issues/ch000549.htm>`__.

IBM ILOG CPLEX
~~~~~~~~~~~~~~

1) Download the ``CPLEX`` installation binary. The limited community
   edition is
   `here <https://www.ibm.com/products/ilog-cplex-optimization-studio>`__.
   CPLEX is free for students (and academics) and further information
   how to register and download is
   `here <https://www.ibm.com/developerworks/community/blogs/jfp/entry/CPLEX_Is_Free_For_Students?lang=en>`__.

2) |macos| |linux| Add ``execute`` permission to binary

   .. code-block:: console

      $ chmod +x <cplexbinary>.bin

3) |macos| |linux| Run the installer binary as superuser, follow the installation
   procedure, and accept the default installation path.

   .. code-block:: console

      $ sudo ./<cplexbinary>.bin

   |windows| Run
   ``cplex_studio<ver>.win-x86-64.exe`` as an administrator. Follow the
   installation instructions and install ``CPLEX`` in
   ``C:\Program Files\IBM\ILOG\CPLEX_Studio<ver>``.

4) |macos| |linux| Set the environment variable by editing your ``~/.bashrc`` file:

   .. code-block:: console

      $ nano ~/.bashrc

   Append the following lines, hit the
   ``ESC`` key, then save and exit by typing ``CTRL-X`` and hitting ``ENTER``.

   On |linux|:

   .. code-block:: console

      export ILOG_CPLEX_PATH="/opt/ibm/ILOG/CPLEX_Studio<ver>"

   On |macos|:

   .. code-block:: console

      export ILOG_CPLEX_PATH="/Applications/IBM/ILOG/CPLEX_Studio<ver>"

   Reload your ``~/.bashrc``:

   .. code-block:: console

      $ source ~/.bashrc

   |windows| |#ff0000| Make sure that you select ``Yes, update the PATH variable.``. You can
   also follow the instructions
   `here <https://www.ibm.com/support/knowledgecenter/SSSA5P_12.6.1/ilog.odms.cplex.help/CPLEX/GettingStarted/topics/set_up/Windows.html>`__.

   |windows| |warning| If you installed cplex in a non default folder (or if you are using the community version) please make sure, that you create an environment variable ``ILOG_CPLEX_PATH`` pointing to the directory containing the CPLEX matlab bindings. This can also be done by creating a `startup.m` file as detailed here `here <https://nl.mathworks.com/help/matlab/ref/startup.html>`__.
   In this startup file add the following command:
   ``setenv('ILOG_CPLEX_PATH','C:\<yourCPLEXPath>\CPLEX_Studio<ver>\cplex\matlab\<arch>')``
   where ``<yourCPLEXPath>`` is the path to cplex, ``<ver>`` is the installed version and ``<arch>`` is the architecture identifier.

GUROBI
~~~~~~

1) Register and log in `here <http://www.gurobi.com/>`__

2) Request license from the `download
   center <http://www.gurobi.com/downloads/download-center>`__ and
   retrieve ``YOUR-LICENSE-KEY-FROM-SITE``

3) Download the ``Gurobi`` optimizer from
   `here <http://www.gurobi.com/downloads/gurobi-optimizer>`__

4) |linux| Navigate to the directory where ``Gurobi`` was downloaded and enter

   .. code-block:: console

      $ tar -xvzf <archive>.tar.gz
      $ sudo mv gurobi<ver> /opt/.
      $ cd /opt/gurobi<ver>/linux64/bin/

   |windows| Run ``Gurobi-<ver>-win64.msi`` and follow the installation
   instructions. Accept the default path ``C:\gurobi<ver>\``.

   |macos| Run ``gurobi<ver>_mac64.pkg`` and follow the installation instructions.
   Accept the default path ``/Applications/gurobi<ver>/``.

5) |linux| Edit the ``bash`` settings to include paths

   .. code-block:: console

      $ nano ~/.bashrc

   Append the following lines, hit the
   ``ESC`` key, then save and exit by typing ``CTRL-X`` and hitting ``ENTER``:

   .. code-block:: console

      export GUROBI_HOME="/opt/gurobi<ver>"
      export PATH="${PATH}:${GUROBI_HOME}/bin"
      export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib"
      export GUROBI_PATH="${GUROBI_HOME}"

   Reload your ``~/.bashrc``:

   .. code-block:: console

      $ source ~/.bashrc

   |windows| In order to set the environment variables on Windows, please follow the
   instructions `here <https://www.computerhope.com/issues/ch000549.htm>`__.

6) |macos| |linux| Activate your license by running:

   .. code-block:: console

       $ grbgetkey YOUR-LICENSE-KEY-FROM-SITE

   You will be prompted

   ::

       In which directory would you like to store the Gurobi license key file?
       [hit Enter to store it in /home/<userid>]:

   Hit ``ENTER``.

   |windows| Browse to
   ``Start > All Programs > Gurobi < VER> > Gurobi Interactive Shell (<ver>)``.
   This should prompt to enter the license key
   ``YOUR-LICENSE-KEY-FROM-SITE``. Enter this key and hiter ``ENTER``.

7) |linux| Verify that ``Gurobi`` is successfully installed by launching the
   ``Gurobi`` prompt:

   .. code-block:: console

       $ gurobi.sh

   |windows| Browse to
   ``Start > All Programs > Gurobi < VER> > Gurobi Interactive Shell (<ver>)``.

   |macos| Browse to ``/Applications``\ and double-click on ``Gurobi<ver>`` to
   start the Gurobi shell.

   This command should give you the prompt for ``Gurobi``. Exit by
   entering ``exit()`` or hitting ``CTRL-D`` on your keyboard.


MOSEK
~~~~~

1) Download ``MOSEK`` as an archive
   `here <https://mosek.com/downloads>`__

2) Apply for a license
   `here <https://mosek.com/products/trial/>`__. A free academic
   license is `here <https://www.mosek.com/products/academic-licenses/>`__. You will
   receive an email with your ``mosek.lic`` file.

3) |linux| Save (or move) the downloaded archive ``tar.bz2`` to ``/opt/.`` (you
   must have superuser or ``sudo`` rights).
   |macos| Save (or move) the
   downloaded archive ``tar.bz2`` to ``/Applications/.`` (you must have
   superuser or ``sudo`` rights).

4) |linux| Navigate to ``/opt`` and extract the archive

   .. code-block:: console

      cd /opt
      $ tar xvjf <filename>.tar.bz2

   |windows| Run ``moseksetupwin64x86.msi`` and select ``Typical`` installation. This
   will install ``mosek`` in ``C:\Program Files\Mosek``.

   |macos| Browse to ``/Applications`` and double-click the archive to uncompress.
   |warning| It is important to run the script ``python /Applications/mosek/<ver>/tools/platform/osx64x86/bin/install.py``,
   which makes important updates to the installation.

5) |macos| |linux| Configure the ``PATH`` and ``MOSEKLM_LICENSE_FILE`` environment
   variables in ``~/.bashrc`` by editing your ``bashrc`` file

   .. code-block:: console

      $ nano ~/.bashrc

   Append the following lines, hit the
   ``ESC`` key, then save and exit by typing ``CTRL-X`` and hitting
   ``ENTER``.

   On |linux|

   .. code-block:: console

      export PATH=/opt/mosek/<ver>/:$PATH
      export MOSEKLM_LICENSE_FILE=/opt/mosek/

   On |macos|

   .. code-block:: console

      export MOSEK_PATH=/Applications/mosek/<ver>
      export PATH=$MOSEK_PATH:$PATH
      export MOSEKLM_LICENSE_FILE=/Applications/mosek/

   Reload your ``~/.bashrc``:

   .. code-block:: console

      $ source ~/.bashrc

   |windows| In order to
   set the environment variables on Windows, please follow the
   instructions
   `here <https://www.computerhope.com/issues/ch000549.htm>`__.

6) |linux| Copy the license file ``mosek.lic`` to ``/opt/mosek/``. |windows| Copy the
   license file ``mosek.lic`` to ``C:\Users\<yourUsername>\mosek\``.
   |macos| Copy the license file ``mosek.lic`` to ``/Applications/mosek/``.

7) |linux| Verify that ``MOSEK`` is correctly installed by using the following
   command in your terminal

   .. code-block:: console

      $ /opt/mosek/<ver>/tools/platform/linux64x86/bin/./msktestlic

   This command should give an output similar to this:

   ::

      Problem
        Name                   :
        Objective sense        : min
        Type                   : LO (linear optimization problem)
        Constraints            : 1
        Cones                  : 0
        Scalar variables       : 5000
        Matrix variables       : 0
        Integer variables      : 0

      Optimizer started.
      Mosek license manager: License path: /opt/mosek/mosek.lic
      Mosek license manager:  Checkout license feature 'PTS' from flexlm.
      Mosek license manager:  Checkout time 0.01. r: 0 status: 0
      Interior-point optimizer started.
      Presolve started.
      Eliminator started.
      Freed constraints in eliminator : 0
      Eliminator terminated.
      Eliminator - tries                  : 1                 time                   : 0.00
      Lin. dep.  - tries                  : 0                 time                   : 0.00
      Lin. dep.  - number                 : 0
      Presolve terminated. Time: 0.00
      Interior-point optimizer terminated. Time: 0.00.

      Optimizer terminated. Time: 0.02
      ************************************
      A license was checked out correctly.
      ************************************

   |windows| By browsing to `Start > All Programs > Mosek Optimization Tools`, you can run `Test license system`. This should open a window and display the output as shown above.

   |macos| In a terminal, run:

   .. code-block:: console

      $ /Applications/mosek//tools/platform/osx64x86/bin/./msktestlic


   This should produce an output as shown above.

.. |#ff0000| image:: https://placehold.it/15/ff0000/000000?text=+


.. |macos| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/apple.png" height="20px" width="20px" alt="macOS">


.. |linux| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/linux.png" height="20px" width="20px" alt="linux">


.. |windows| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/windows.png" height="20px" width="20px" alt="windows">


.. |warning| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/warning.png" height="20px" width="20px" alt="warning">


.. |matlab| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/matlab.png" height="20px" width="20px" alt="matlab">


.. |tada| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/tada.png" height="20px" width="20px" alt="tada">


.. |thumbsup| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/thumbsUP.png" height="20px" width="20px" alt="thumbsup">


.. |bulb| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/bulb.png" height="20px" width="20px" alt="bulb">


.. |pencil| raw:: html

   <img src="https://prince.lcsb.uni.lu/cobratoolbox/img/pencil.png" height="20px" width="20px" alt="pencil">


.. |tutorials| raw:: html

   <a href="https://opencobra.github.io/cobratoolbox/latest/tutorials/index.html"><img src="https://img.shields.io/badge/COBRA-tutorials-blue.svg?maxAge=0"></a>


.. |latest| raw:: html

   <a href="https://opencobra.github.io/cobratoolbox/latest"><img src="https://img.shields.io/badge/COBRA-docs-blue.svg?maxAge=0"></a>


.. |forum| raw:: html

   <a href="https://groups.google.com/forum/#!forum/cobra-toolbox"><img src="https://img.shields.io/badge/COBRA-forum-blue.svg"></a>


.. |br| raw:: html

   <br>

.. end-solver-installation-marker
