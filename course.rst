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

* The model does not have a free-running atmospheric model. The atmospheric
  forcing is input from a data source by ``libaccessom2+yatm`` and passed to 
  the ice model 
* Uses JRA55 reanalysis derivative product JRA55-do v1.4

http://jra.kishou.go.jp/JRA-55/index_en.html
https://www.sciencedirect.com/science/article/pii/S146350031830235X

* IAF (Interannual Forcing) : JRA55-do (1955-present) 
* RYF (Repeat Year Forcing) : RYF8485, RYF9091, RYF0304


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


Running an ACCESS-OM2 model
---------------------------

.. notes:: 
   Can run in a branch to keep config clean
   Can fork 

* Follow the Quick Start instructions in the ACCESS-OM2 Wiki on github

https://github.com/COSIMA/access-om2/wiki/Getting-started#quick-start

Use the 1 deg JRA55 IAF configuration:

.. code::bash

    module load payu/0.10
    git clone https://github.com/COSIMA/1deg_jra55_iaf
    cd 1deg_jra55_iaf 
    payu run

-----

The PBS and platform specific options for ``normalbw`` queue

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

Miscellaneous options (including collation)

.. code::yaml
    
    # Misc
    collate: true
    stacksize: unlimited
    collate_walltime: 1:00:00
    collate_exe: /short/public/access-om2/bin/mppnccombine
    qsub_flags: -lother=hyperthread -W umask=027
    # postscript: sync_output_to_gdata.sh


Other Useful Stuff
===============

Diagnostics
-----------

Analysis
--------

outputs (join groups)

cosima cookbook

explorer

cosima recipes

