================================
Running ACCESS-OM2 Models at NCI
================================

:subtitle: Using payu to run ACCESS-OM2 models
:author: Aidan Heerdegen
:description: A training course to introduce running ACCESS-OM2 models using payu
:date: 18 May 2021


Outline
=======

* payu recap
* quickstart guide
* other useful stuff


What is Payu?
=============

Payu is
-------

 ... a python based "scientific workflow manager"

Huh?
----

That means it runs your model for you. In short:

* Setup model run directory (``work``)
* Run the model
* Move outputs/restarts to ``archive`` directory
* Clean up the run directory
* Run again (if instructed to do so)
  

ACCESS-OM2
==========

ACCESS-OM2 model suite includes 1, 0.25 and 0.1 degree global Ocean/Sea Ice
models forced with atmospheric data and almost identical model parameters.

Single ``access-om2`` repository with all code and configs

https://github.com/COSIMA/access-om2


Components
----------

The model is a number of separate component models that run independently and
share information via a coupler

========== ===========================
Ocean      ``MOM5``        
Ice        ``CICE5``       
Atmosphere ``libaccessom2`` + ``yatm``
Coupler    ``OASIS3-MCT``  
========== ===========================


Code
----

All models are open source

================ =========================================
``MOM5``         https://github.com/mom-ocean/MOM5
``CICE5``        https://github.com/COSIMA/cice5
``libaccessom2`` https://github.com/COSIMA/libaccessom2
``OASIS3-MCT``   https://github.com/COSIMA/oasis3-mct
================ =========================================


Forcing Data
------------

* The model does not have a free-running atmospheric model. Atmospheric
  forcing is input from a data source by ``libaccessom2+yatm`` and passed to 
  the ice model 
* Atmosphere uses JRA55 reanalysis derivative product JRA55-do v1.4

http://jra.kishou.go.jp/JRA-55/index_en.html
https://www.sciencedirect.com/science/article/pii/S146350031830235X

* IAF (Interannual Forcing) : JRA55-do (1955-present) 
* RYF (Repeat Year Forcing) : RYF8485, RYF9091, RYF0304


Configurations
==============

* All model configurations are global, and there are three supported resolutions
* At each resolution interannual and repeat year forcing is supported

ACCESS-OM2
----------

* Nominal 1 degree global resolution
* JRA55 RYF and IAF

https://github.com/COSIMA/1deg_jra55_iaf
https://github.com/COSIMA/1deg_jra55_ryf


ACCESS-OM2-025
--------------

* Nominal 0.25 degree global resolution
* JRA55 RYF and IAF configurations

https://github.com/COSIMA/025deg_jra55_ryf
https://github.com/COSIMA/025deg_jra55_iaf


ACCESS-OM2-01
--------------

.. notes:: 
   Don't suggest anyone runs this without contacting COSIMA
     as runs are expensive

* Nominal 0.1 degree global resolution
* JRA55 RYF and IAF configurations
* Minimal JRA55 IAF configuration (fewer cores)

https://github.com/COSIMA/01deg_jra55_iaf
https://github.com/COSIMA/01deg_jra55_ryf
https://github.com/COSIMA/minimal_01deg_jra55_iaf


Running the model
=================

.. notes:: 
   Can run in a branch to keep config clean
   Can fork 

* Follow the Quick Start instructions in the ACCESS-OM2 Wiki on github

https://github.com/COSIMA/access-om2/wiki/Getting-started#quick-start

-----

Use the 1 deg JRA55 IAF configuration:

.. code::bash

    module use /g/data3/hh5/public/modules
    module load conda
    git clone https://github.com/COSIMA/1deg_jra55_iaf
    cd 1deg_jra55_iaf 

-----

* Could run but would be wasteful as test. Change model run time from 5 years to 
  1 month: in ``accessom2.nml`` 

.. code::yaml

    restart_period = 0, 1, 0

* Run the model

.. code::bash

    payu run

-----

The PBS options for ``normal`` queue

.. code::yaml
    
    # PBS configuration
    queue: normal
    walltime: 3:00:00
    jobname: 1deg_jra55_iaf
    mem: 1000GB

-----

The model options

.. code::yaml

    # Model configuration
    name: common
    model: access-om2
    input: /g/data/ik11/inputs/access-om2/input_20201102/common_1deg_jra55
    submodels:
        - name: atmosphere
          model: yatm
          exe: /g/data/ik11/inputs/access-om2/bin/yatm_5b6c697d.exe
          input:
                - /g/data/ik11/inputs/access-om2/input_20201102/yatm_1deg
                - /g/data/qv56/replicas/input4MIPs/CMIP6/OMIP/MRI/MRI-JRA55-do-1-4-0/atmos/3hr/rsds/gr/v20190429
                - /g/data/qv56/replicas/input4MIPs/CMIP6/OMIP/MRI/MRI-JRA55-do-1-4-0/atmos/3hr/rlds/gr/v20190429
                - /g/data/qv56/replicas/input4MIPs/CMIP6/OMIP/MRI/MRI-JRA55-do-1-4-0/atmos/3hr/prra/gr/v20190429
                - /g/data/qv56/replicas/input4MIPs/CMIP6/OMIP/MRI/MRI-JRA55-do-1-4-0/atmos/3hr/prsn/gr/v20190429
                - /g/data/qv56/replicas/input4MIPs/CMIP6/OMIP/MRI/MRI-JRA55-do-1-4-0/atmos/3hrPt/psl/gr/v20190429
                - /g/data/qv56/replicas/input4MIPs/CMIP6/OMIP/MRI/MRI-JRA55-do-1-4-0/land/day/friver/gr/v20190429
                - /g/data/qv56/replicas/input4MIPs/CMIP6/OMIP/MRI/MRI-JRA55-do-1-4-0/atmos/3hrPt/tas/gr/v20190429
                - /g/data/qv56/replicas/input4MIPs/CMIP6/OMIP/MRI/MRI-JRA55-do-1-4-0/atmos/3hrPt/huss/gr/v20190429
                - /g/data/qv56/replicas/input4MIPs/CMIP6/OMIP/MRI/MRI-JRA55-do-1-4-0/atmos/3hrPt/uas/gr/v20190429
                - /g/data/qv56/replicas/input4MIPs/CMIP6/OMIP/MRI/MRI-JRA55-do-1-4-0/atmos/3hrPt/vas/gr/v20190429
                - /g/data/qv56/replicas/input4MIPs/CMIP6/OMIP/MRI/MRI-JRA55-do-1-4-0/landIce/day/licalvf/gr/v20190429
          ncpus: 1

        - name: ocean
          model: mom
          exe: /g/data/ik11/inputs/access-om2/bin/fms_ACCESS-OM_af3a94d4_libaccessom2_5b6c697d.x
          input: /g/data/ik11/inputs/access-om2/input_20201102/mom_1deg
          ncpus: 216

        - name: ice
          model: cice5
          exe: /g/data/ik11/inputs/access-om2/bin/cice_auscom_360x300_24p_2572851d_libaccessom2_5b6c697d.exe
          input: /g/data/ik11/inputs/access-om2/input_20201102/cice_1deg
          ncpus: 24

----

Collation options include collating restarts, and using multiple CPUs to speed up collation

.. code::yaml

    # Collation
    collate:
      restart: true
      walltime: 1:00:00
      mem: 30GB
      ncpus: 4
      queue: normal
      exe: /g/data/ik11/inputs/access-om2/bin/mppnccombine

----

Miscellaneous options

.. code::yaml

    # Misc
    runlog: true
    stacksize: unlimited
    restart_freq: 1  # use tidy_restarts.py instead
    mpirun: --mca io ompio --mca io_ompio_num_aggregators 1
    qsub_flags: -W umask=027
    # set number of cores per node (28 for normalbw, 48 for normal on gadi)
    platform:
        nodesize: 48
    # sweep and resubmit on specific errors - see https://github.com/payu-org/payu/issues/241#issuecomment-610739771
    userscripts:
        error: resub.sh
        run: rm -f resubmit.count

    # DANGER! Do not uncomment this without checking the script is syncing to the correct location!
    # postscript: sync_data.sh


Restart from a previous experiment
----------------------------------

* payu will examine the ``archive`` directory and if there is an existing restart directory it will use it
* Using the restart option in ``config.yaml`` would be best, but doesn't currently work for ACCESS-OM2
* See the `ACCESS-OM2 wiki for details <https://github.com/COSIMA/access-om2/wiki/Tutorials#starting-a-new-experiment-using-restarts-from-a-previous-experiment>`_


Other Useful Stuff
==================

Diagnostics
-----------

* Only a fraction of the possible diagnostic (and tracer) fields are output
* MOM diagnostics determined by the ``diag_table`` which is generated programmatically
* CICE diagnostics are definted in ``cice_in.nml``

Available data
--------------

* Some data is published and available via THREDDS from NCI 

https://geonetwork.nci.org.au/geonetwork/srv/eng/catalog.search#/metadata/f1296_4979_4319_7298

* Always preferable (faster) to access directly on disk
* Need to go to https://my.nci.org.au and join groups: ``hh5``, ``ik11`` and ``cj50``

Analysis
--------

* COSIMA provides the `COSIMA Cookbook <https://github.com/COSIMA/cosima-cookbook>`_, a database to 
find and load COSIMA datasets
* The `COSIMA Recipes repository <https://cosima-recipes.readthedocs.io/en/latest/>`_ contains
Tutorials and Documented Examples
* Cookbook includes an interactive `Data Explorer tool <https://cosima-recipes.readthedocs.io/en/latest/tutorials/Using_Explorer_tools.html#gallery-tutorials-using-explorer-tools-ipynb>`_ 
to find and load available datasets in the COSIMA collection at NCI

