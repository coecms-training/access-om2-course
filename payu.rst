=========================
Payu Features and Configs
=========================

:subtitle: New features and running ACCESS-OM2 models
:author: Aidan Heerdegen
:description: A training course to introduce new and upcoming features
:date: 17 October 2018


Outline
=======

-----

* payu recap

* New payu features

* Upcoming payu features

* Running ACCESS-OM2 models


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
  


New features
============


Fast MOM collation
==================

----

There is a new mppnccombine in town ... and it's fast.

How fast? 

----

Probably not faster than the Waco Kid

.. image:: img/waco_kid.gif


----

.. notes::
   That is it collates tiled outputs to multiple files, which makes model input and output faster

   Directly copies the compressed chunks from one file to another, skipping the decompress/recompress step

   Example of the raison d'etre of CMS, to improve researcher  productivity



But seriously fast, hence the name **mppnccombine-fast**

https://github.com/coecms/mppnccombine-fast

* Written by Scott Wales

* Collates any tiled FMS model output (MOM5/MOM6/GOLD)

* Particularly fast with netCDF4 compressed data


Requirements
------------

* Copy ``/short/public/aph502/mppnccombine-fast`` to ``/short/$PROJECT/$model/bin`` 

or 

* Specify full path in ``config.yaml``

* A version of ``payu`` of ``0.10`` or greater (``module load payu/0.10`` on ``raijin``)

* Updated ``config.yaml`` syntax


Old Syntax
----------

.. code:: yaml

    collate: true
    collate_mem: 16GB
    collate_queue: express
    collate_ncpus: 4
    collate_flags: -n4 -r


New syntax
----------

.. notes::
   Must specify mpi to use mppnccombine-fast.
   Minimum of 2 cpus, so can't use copyq
   ncpus per thread is ncpus / nthreads
   nthreads defaults to 1
   ncpus defaults to 2
   enable defaults to true
   Don't need to specify flags, enable or exe
   Fewer flags, as mppnccombine-fast has fewer options
   Don't get your hopes up Ryan, I haven't written restart
     collation, but when it is done, adding restart:true
     will collate restarts when the restart cleaning is done
   

Replaces ``collate_`` options with dictionary

.. code:: yaml

    collate:
         enable: true
         queue: express
         memory: 4GB
         walltime: 00:30:00
         mpi: true
         ncpus: 4
         threads: 2
         # flags: -v
         # exe: /full/path/to/mppnccombine-fast
         # restart: true


Resource requirements
---------------------

.. notes:: 
    Memory use should only depend on chunksize in the compressed file, not on the overall size of the 
    file being written, so resolution independent.

    Unfortunately a memory leak bug in the underlying ``HDF5`` library means memory use will go up with 
    the number of times data is written to a collated file. It is difficult to predict, but 2-4GB per 
    thread has been the upper limit observed so far.

    No speed-up for low resolution outputs (MPI overhead swamps fast run times). Quarter degree 10-50x faster. 
    Tenth 100x faster.

* Memory independent of resolution (<4GB per thread)

* Walltime in minutes

* No speed-up for low resolution (1 deg global model) 

* Minimum of 2 cpus


Layout affects efficiency
-------------------------

* Chunk sizes chosen automatically by netCDF4 and depend on tile size

* Inconsistent tile sizes => inconsistent chunk sizes

* Inconsistent chunk sizes makes program slow (has to uncompress/compress)

* Make processor layout an integer divisor of grid

* Make io_layout an integer divisor of layout  


Example
-------

.. notes:: 
    Might think with io_layout would make consistent tile sizes, but the 
    decomposition algorithm has already chosen some distribution of different
    tile sizes that cannot be evenly combined with io_layout
    Surprise to me to!
    

Quarter degree MOM-SIS model: 1440 x 1080. 

.. code:: fortran

    layout = 64, 30
    io_layout = 8, 6

* 1920 CPUs

* Tiles are 22 x 36 and 23 x 36

* IO tiles are 184 x 180, and 176 x 180

* Slow for collating normal data and slow for untiled data (restarts and regional output) 


Improved Layout
---------------

Quarter degree MOM-SIS model: 1440 x 1080. 

.. code:: fortran

    layout = 60, 36
    io_layout = 10, 6

* 2160 CPUs

* Tiles are 24 x 10

* IO tile is 144 x 180

* Fast for collating tiled and untiled output


Runs per submit
===============

----

.. notes:: 
    Don't agree with Marshall from first payu training session
    nf_limits -P project -q queue -n ncpus
    48 hrs < 256 CPUs
    255 < 24 hrs < 512
    512 < 10 hrs < 1024

* For low CPU count model: walltime up to 48 hours

* Maximise walltime to reduce effect of queue time

* A single 48 hour model run: What if crashes? Output non optimal?


runspersub
----------

.. notes:: 
     Runspersub to the rescue!
     Being conservative with walltime in case some runs take > 2hr
     When last run crashes, only time of last run is lost
    
.. code:: yaml

    runspersub: 23
    walltime: 48:00:00

* Say model takes 2hr per run 

* Above config would run the model 23 times per PBS submit

* ``walltime`` must allow for ``runspersub`` runs of the model

* If ``walltime`` exceeded last run will crash. ``payu`` will not resubmit


Resubmission
------------

* ``payu`` can resubmit itself with ``-n`` command line option

* Using same model example if I wanted 50 runs of the model:

.. code:: bash

    payu run -n 50

* ``runspersub: 1`` => 50 PBS submissions, single run in each

* ``runspersub: 23`` => 3 PBS submissions, 23/23/4 model runs respectively


Upcoming features
=================

File Tracking
-------------

Wanted to do this for a long long time


Key Advantages
--------------

.. notes:: 
     Very early in this job, there was a "dodgy aerosol file" that had
         been used in some simulations, but hard/impossible to say which
         runs/files were affected

* Track input files used for each model run

* Reproducibly re-run previous experiment

* Share experiments more easily as input files all specified

* Flexibility with specifying path to input files

* Identify all runs using specified file (possible future feature)


What is tracked?
----------------

.. notes:: 
   Executables and inputs are not expected to change. Can specify a flag to either warn 
   if they do and stop, or update manifest and continue
   
   Restarts are the opposite, and by default are always expected to be different for each
   run, unless a flag is specified to reproduce a run, in which case any difference will
   flag an error and stop

=========== ===================
Executables ``mf_exe.yaml``
Inputs      ``mf_inputs.yaml``    
Restarts    ``mf_restarts.yaml``
=========== ===================


How is it tracked?
------------------

* Uses yamanifest 

* Creates a ``YaML`` file 

* Each file (symlink) in ``work`` is dictionary key 


Example
-------

.. notes:: 
   Note there is a header and a version string, can ignore
   All files in work are either config files (which are tracked
     by git) or symbolic links to files elsewhere on filesystem
   Issues with getting this working has to do with enforcing this
     for all models - can be difficult with hardwired paths etc
     
* ``fullpath`` is the actual location of the file 

* The hashes uniquely identify file

.. code::yaml

    format: yamanifest
    version: 1.0
    ---
    work/fms_MOM_SIS.intel14:
      fullpath: /short/v45/aph502/mom/bin/fms_MOM_SIS.intel14
      hashes:
        binhash: 74b079574d3160fd2024ca928f3097a0
        md5: e10bf223ae2564701ae310d341bbe63b


Hierachy of hashes
------------------

.. notes:: 
   binhash uses datestamp and size combined with first 100MB of a file.
   Not guaranteed unique, but likely to detect if the file has changed

* yamanifest supports multiple hashes => hierachy of hashes

* Unique hashes (md5, sha128) take too long on large files

* Fast hashing to check for file changes

* Use unique hash check when necessary (or periodically?)


ACCESS-OM2
==========

ACCESS-OM2 model suite from 1 degree global to 0.1 degree global, Ocean/Ice
model forced with atmospheric data and almost identical model parameters.

Single ``access-om2`` repository with all code and configs

https://github.com/OceansAus/access-om2


Components
----------

========== ================
Ocean      ``MOM5``        
Ice        ``CICE5``       
Atmosphere ``libaccessom2``
Coupler    ``OASIS3-MCT``  
========== ================


Code
----

================ =========================================
``MOM5``         https://github.com/mom-ocean/MOM5
``CICE5``        https://github.com/OceansAus/cice5
``libaccessom2`` https://github.com/OceansAus/libaccessom2
``OASIS3-MCT``   https://github.com/OceansAus/oasis3-mct
================ =========================================


Forcing Data
------------

* Uses JRA55 reanalysis derivative product JRA55-do

http://jra.kishou.go.jp/JRA-55/index_en.html
https://www.sciencedirect.com/science/article/pii/S146350031830235X

* IAF (Interannual Forcing) : JRA55-do (1955-present) 

* RYF (Repeat Year Forcing) : RYF8485, RYF9091, RYF0304


ACCESS-OM2
----------

* Nominal 1 degree global resolution
* JRA55 RYF and IAF, and CORE-II configurations

https://github.com/OceansAus/1deg_jra55_iaf
https://github.com/OceansAus/1deg_jra55_ryf
https://github.com/OceansAus/1deg_core_nyf


ACCESS-OM2-025
--------------

* Nominal 0.25 degree global resolution
* JRA55 RYF and IAF configurations

https://github.com/OceansAus/025deg_jra55_ryf
https://github.com/OceansAus/025deg_jra55_iaf


ACCESS-OM2-01
--------------

.. notes:: 
   Don't suggest anyone runs this without contacting COSIMA
     as runs are expensive and a bit tricky to get running
     on raijin. 

* Nominal 0.1 degree global resolution
* JRA55 RYF and IAF configurations
* Minimal JRA55 IAF configuration (fewer cores)

https://github.com/OceansAus/01deg_jra55_iaf
https://github.com/OceansAus/01deg_jra55_ryf
https://github.com/OceansAus/minimal_01deg_jra55_iaf


Running an ACCESS-OM2 model
---------------------------

.. notes:: 
   Can run in a branch to keep config clean
   Can fork 

* Follow the Quick Start instructions in the ACCESS-OM2 Wiki on github

https://github.com/OceansAus/access-om2/wiki/Getting-started#quick-start

.. notes:: 
   All executables and 
   Can fork 

Use the 1 deg JRA55 IAF configuration:

.. code::bash

    module load payu/0.10
    git clone https://github.com/OceansAus/1deg_jra55_iaf
    cd 1deg_jra55_iaf 
    payu run

-----

The PBS and platform specific options for ``normalbw`` queue

.. code::yaml
    
    # PBS configuration
    queue: normalbw
    walltime: 1:00:00
    jobname: 1deg_jra55_iaf
    ncpus: 252

    platform:
        nodesize: 28
        nodemem: 128


-----

The model options

.. code::yaml
    
    # Model configuration
    name: common
    model: access-om2
    input: /short/public/access-om2/input_2407a7bc/common_1deg_jra55
    submodels:
        - name: atmosphere
          model: yatm
          exe: /short/public/access-om2/bin/yatm_037e4b61.exe
          input: /short/public/access-om2/input_2407a7bc/yatm_1deg
          ncpus: 1

        - name: ocean
          model: mom
          exe: /short/public/access-om2/bin/fms_ACCESS-OM_304fe837.x
          input: /short/public/access-om2/input_2407a7bc/mom_1deg
          ncpus: 216

        - name: ice
          model: cice5
          exe: /short/public/access-om2/bin/cice_auscom_360x300_24p_5a56b59a.exe
          input: /short/public/access-om2/input_2407a7bc/cice_1deg
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



