elas
===========

Toolbox for localization and assignment of intracranial electrodes. This is done by using SPM12 (see below). Post-implantation and pre-implantation (only for depth electrodes) images are needed for processing. Details for use of software see manual and:

Kern, Behncke et al. 

This version runs with MATLAB SPM (statistical parametric mapping).


installation
============

1. Install SPM12 from http://www.fil.ion.ucl.ac.uk/spm/software/spm12/

2. Install ELAS, e.g.:

.. code-block:: bash

  git clone https://github.com/joosbehncke/elas

3. Edit:	.../elas/startup_elas.m	
  
    set local SPM path at section “EDIT SPM PATH HERE!!!” 


documentation
=============

Documentation is online under https://github.com/joosbehncke/elas/tree/master/manuals
