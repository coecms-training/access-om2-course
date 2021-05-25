================================
Running ACCESS-OM2 Models at NCI
================================

:subtitle: Using payu to run ACCESS-OM2 models
:author: Aidan Heerdegen
:description: A training course to introduce running ACCESS-OM2 models using payu
:date: 18 May 2021


Outline
=======

* ACCESS-OM2 Model
* Configurations
* Running the model
* Other useful stuff


ACCESS-OM2
==========


* Model suite includes 1, 0.25 and 0.1 degree global Ocean/Sea Ice
models forced with atmospheric data and almost identical model parameters.

* Single ``access-om2`` repository with all code and configs

https://github.com/COSIMA/access-om2

* Well documented in wiki 

https://github.com/COSIMA/access-om2/wiki


Components
----------

The model consists of separate component models that run independently and
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

* Atmosphere is not free-running model. 
* Atmospheric forcing is input from a data source by ``libaccessom2+yatm`` and passed to 
  the ice model 
* Atmosphere uses JRA55 reanalysis derivative product JRA55-do v1.4

http://jra.kishou.go.jp/JRA-55/index_en.html
https://www.sciencedirect.com/science/article/pii/S146350031830235X

* IAF (Interannual Forcing) : JRA55-do (1955-present) 
* RYF (Repeat Year Forcing) : RYF9091 (RYF8485, RYF0304 also available)


Configurations
==============

All model configurations are global, and there are three supported resolutions

At each resolution interannual and repeat year forcing is supported

-----

COSIMA Model name: ACCESS-OM2

* Nominal 1 degree global resolution

* JRA55 RYF and IAF

https://github.com/COSIMA/1deg_jra55_iaf
https://github.com/COSIMA/1deg_jra55_ryf


-----

COSIMA Model name: ACCESS-OM2-025

* Nominal 0.25 degree global resolution

* JRA55 RYF and IAF configurations

https://github.com/COSIMA/025deg_jra55_ryf
https://github.com/COSIMA/025deg_jra55_iaf


-----

.. notes:: 
   Don't suggest anyone runs this without contacting COSIMA
     as runs are expensive

COSIMA Model name: ACCESS-OM2-01

* Nominal 0.1 degree global resolution

* JRA55 RYF and IAF configurations

https://github.com/COSIMA/01deg_jra55_iaf
https://github.com/COSIMA/01deg_jra55_ryf


Running the model
=================

.. notes:: 
   Can run in a branch to keep config clean
   Can fork on GitHub and push config changes back to fork

Follow the Quick Start instructions in the ACCESS-OM2 Wiki on github

https://github.com/COSIMA/access-om2/wiki/Getting-started#quick-start

-----

As an example, using the 1 deg JRA55 IAF configuration:

.. code::bash

    module use /g/data3/hh5/public/modules
    module load conda
    git clone https://github.com/COSIMA/1deg_jra55_iaf
    cd 1deg_jra55_iaf 

-----

The ``libaccessom2`` namelist ``accessom2.nml`` controls logging, timesetp, forcing dates and
model run length (``restart_period``)

.. code::yaml

    &accessom2_nml
        log_level = 'DEBUG'

        ! ice_ocean_timestep defines the MOM baroclinic timestep, CICE thermodynamic timestep
        ! and MOM-CICE coupling interval, in seconds.
        ! ice_ocean_timestep is normally a factor of the JRA55-do forcing period of 3hr = 10800s,
        ! e.g. one of 100, 108, 120, 135, 144, 150, 180, 200, 216, 225, 240, 270, 300, 360, 400, 432,
        ! 450, 540, 600, 675, 720, 900, 1080, 1200, 1350, 1800, 2160, 2700, 3600 or 5400 seconds.
        ! The model is usually stable with a 5400s timestep, including in the initial spinup from rest.
        ice_ocean_timestep = 5400
    &end

    &date_manager_nml
        forcing_start_date = '1958-01-01T00:00:00'
        forcing_end_date = '2019-01-01T00:00:00'

        ! Runtime for a single segment/job/submit, format is years, months, seconds,
        ! two of which must be zero.
        restart_period = 5, 0, 0
    &end


-----

To run the model as a test change model run time from 5 years to 1 month: in ``accessom2.nml`` 

.. code::yaml

    restart_period = 0, 1, 0

Run the model

.. code::bash

    payu run

-----

* payu prints the the command it is submitting and some other information to the terminal

* Some errors can be picked up by inspecting this command: incorrect payu path, insufficient
  storage flags for all the locations required to run the model, inefficient processor count
  for physical processor layout

.. code::sh

    $ payu run -f
    payu: warning: Job request includes 47 unused CPUs.
    payu: warning: CPU request increased from 241 to 288            
    Loading input manifest: manifests/input.yaml    
    Loading restart manifest: manifests/restart.yaml
    Loading exe manifest: manifests/exe.yaml         
    payu: Found modules in /opt/Modules/v4.3.0     
    qsub -q normal -P w97 -l walltime=10800 -l ncpus=288 -l mem=1000GB -N 1deg_jra55_iaf -l wd -j n -v PAYU_PATH=/g/data3/hh5/public/apps/miniconda3/envs/analysis3-21.04/bin,PAYU_FORCE=True,MODULES
    HOME=/opt/Modules/v4.3.0,MODULES_CMD=/opt/Modules/v4.3.0/libexec/modulecmd.tcl,MODULEPATH=/g/data3/hh5/public/modules:/opt/Modules/modulefiles:/opt/Modules/v4.3.0/modulefiles:/apps/Modules/modu
    lefiles -W umask=027 -l storage=gdata/hh5+gdata/ik11+gdata/qv56+scratch/w97 -- /g/data3/hh5/public/apps/miniconda3/envs/analysis3-21.04/bin/python3.8 /g/data3/hh5/public/apps/miniconda3/envs/an
    alysis3-21.04/bin/payu-run                      


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

* payu will examine the ``archive`` directory and if there is an existing restart 
  directory it will use it

* Using the restart option in ``config.yaml`` would be best, but doesn't currently 
  work for ACCESS-OM2

* Copy or link previous restart and output directories into your ``archive``. See 
  the `ACCESS-OM2 wiki for details <https://github.com/COSIMA/access-om2/wiki/Tutorials#starting-a-new-experiment-using-restarts-from-a-previous-experiment>`_


Has my model crashed
--------------------

Signs your model has crashed:

* ``work/`` directory still present in control directory

* ``access-om2.out`` and ``access-om2.err`` still present in control directory 

* Non-zero return code in PBS log file

..code::

    ======================================================================================
                    Resource Usage on 2021-05-25 17:02:12:
    Job Id:             22990186.gadi-pbs
    Project:            w97
    Exit Status:        1
    Service Units:      6.88
    NCPUs Requested:    288                    NCPUs Used: 288             
                                            CPU Time Used: 00:21:24                                   
    Memory Requested:   1000.0GB              Memory Used: 121.07GB        
    Walltime requested: 03:00:00            Walltime Used: 00:00:43        
    JobFS requested:    600.0MB                JobFS used: 0B              
    ======================================================================================



Diagnosing crashes
------------------

* Check ``access-om2.err`` and find the first error message that looks like this

..code::sh

    FATAL from PE   178: ==>Error: time step instability detected for baroclinic gravity waves in ocean_model_mod                                                                                   

    Image              PC                Routine            Line        Source
    fms_ACCESS-OM_af3  0000000001C458BA  Unknown               Unknown  Unknown
    fms_ACCESS-OM_af3  0000000001825DAC  mpp_mod_mp_mpp_er          58  mpp_util_mpi.inc
    fms_ACCESS-OM_af3  0000000000D8FF91  ocean_velocity_mo         886  ocean_velocity.F90
    fms_ACCESS-OM_af3  0000000000466493  ocean_model_mod_m        1258  ocean_model.F90
    fms_ACCESS-OM_af3  0000000000410FDB  MAIN__                    358  ocean_solo.F90
    fms_ACCESS-OM_af3  000000000040F662  Unknown               Unknown  Unknown
    libc-2.28.so       000014E858A3D7B3  __libc_start_main     Unknown  Unknown
    fms_ACCESS-OM_af3  000000000040F56E  Unknown               Unknown  Unknown

* This is a backtrace (or stacktrace) that shows the location in the code where the error occurred.
  The code was compiled to include human readable source code names which makes it easier to debug

* There will be a lot of other stack traces as this is an MPI program running multiple copies of
  the models, and each will be signalled to "die" when there is a fatal error

-----

..code::sh

    FATAL from PE   142:  Error: salinity out of range with value    -9.223462738696E-01 at (i,j,k) = ( 214, 184, 21),  (lon,lat,dpt) = (  -66.5000,   17.8501,  261.0993 m)

    Image              PC                Routine            Line        Source             
    fms_ACCESS-OM_af3  0000000001C458BA  Unknown               Unknown  Unknown
    fms_ACCESS-OM_af3  0000000001825DAC  mpp_mod_mp_mpp_er          58  mpp_util_mpi.inc
    fms_ACCESS-OM_af3  00000000005EC1D5  ocean_tempsalt_mo        1360  ocean_tempsalt.F90
    fms_ACCESS-OM_af3  00000000008440CC  ocean_tracer_mod_        2540  ocean_tracer.F90
    fms_ACCESS-OM_af3  000000000044795F  ocean_model_mod_m        1864  ocean_model.F90
    fms_ACCESS-OM_af3  0000000000416592  MAIN__                    468  ocean_solo.F90
    fms_ACCESS-OM_af3  000000000040F662  Unknown               Unknown  Unknown
    libc-2.28.so       0000148096D7A7B3  __libc_start_main     Unknown  Unknown
    fms_ACCESS-OM_af3  000000000040F56E  Unknown               Unknown  Unknown


* If the cause of the crash isn't obvious might have to dig into log files within the 
  model subdirectories in ``work/``


Other Useful Stuff
==================

Diagnostics
-----------

* Only a fraction of the possible diagnostic (and tracer) fields are output

* MOM diagnostics determined by the ``diag_table`` which is generated programmatically

* CICE diagnostics are definted in ``cice_in.nml``


Perturbations
-------------

* Possible to add offsets to atmospheric forcing fields, and also multiply by scale
  factors, either single value, spatially and or temporally varying e.g.

..code::json

    {
    "description": "JRA55-do V1.3 RYF 1990-91 forcing",
    "inputs": [
        {
        "filename": "/g/data/ua8/JRA55-do/RYF/v1-3/RYF.rsds.1990_1991.nc",
        "fieldname": "rsds",
        "cname": "swfld_ai",
        "perturbations": [
            {
            "type": "scaling",
            "dimension": "spatiotemporal",
            "value": "../test_data/scaling.RYF.rsds.1990_1991.nc",
            "calendar": "forcing"
            },
            {
            "type": "offset",
            "dimension": "constant",
            "value": 5,
            "calendar": "forcing"
            }
        ]
        }
    ]
    }

* See the wiki for details

https://github.com/COSIMA/access-om2/wiki/Tutorials#Scaling-the-forcing-fields


Available data
--------------

* Some data is published and available via THREDDS from NCI 

http://dx.doi.org/10.4225/41/5a2dc8543105a

* Always preferable (faster) to access directly on disk

* Need to go to https://my.nci.org.au and join groups: ``hh5``, ``ik11``, ``cj50`` and ``qv56``


Analysis
--------

* COSIMA provides the `COSIMA Cookbook <https://github.com/COSIMA/cosima-cookbook>`_, a database to 
find and load COSIMA datasets

* The `COSIMA Recipes repository <https://cosima-recipes.readthedocs.io/en/latest/>`_ contains
Tutorials and Documented Examples

* Cookbook includes an interactive `Data Explorer tool <https://cosima-recipes.readthedocs.io/en/latest/tutorials/Using_Explorer_tools.html#gallery-tutorials-using-explorer-tools-ipynb>`_ 
to find and load available datasets in the COSIMA collection at NCI


Compiling Executables
---------------------

* The models are compiled and then published to a shared area in ``ik11``

* Build scripts Andrew Kiss has developed link the codebase to the executable name via
  ``git`` commit hashes

* Best to use published executables with known provenance

* If compiling own executables keep the ``access-om2`` source tree separate from
  control directories 


