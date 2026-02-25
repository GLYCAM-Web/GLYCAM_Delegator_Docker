# Geometric Limitation in the Current Implementation
Written on 2026-02-25 by BLFoley

This system is part of a test. The output is used to ensure that the program performs in the same 
manner for this system.

The system was chosen for its small size. Doing that makes the test run quickly. But, it was found 
that this system is not handled well under the current modeling conditions. Rather than ignore this 
system, it remains the subject of a test. One day, the GP builder will treat this system in a more 
realistic manner. At that time, the test and this text should be updated.

**Note!**

The structure provided is not incorrect. It is very likely to be a valid structure. But its 
glycosidic geometry is not a member of the overwhelmingly dominant geometry class. 

## Briefly

The current implementation of the GlycoProtein Builder finds a reasonable structure that is free 
from significant steric clashes. It does not attempt any further refinement. If further refinement 
is desired, additional criteria need to be employed.

The dominant geometry in the system being highlighted here requires consideration of the electronic 
structure, mostly the electrostatic aspects, though some quantum effects might apply. 

The image below shows the 4-way hydrogen bonding system that locks the glycosidic geometry into the 
observed structure. This geometry has been observed in solution NMR and in unrestrained molecular 
dynamics simulations. In the image, only the locally relevant atoms are shown. Note the highlighted
oxygen (red spheres) and hydrogen (white spheres) atoms. The two hydrogens are, essentially, 'held' 
in place by the two oxygens.

The nitrogens (blue spheres) are highlighted for clarity in the next image.

![[2mk7_native_vmdscene.dat.tga.jpg]]

In the next image, there is a rotation around the bond to the left of the uppermost highlighted 
oxygen. The rotation turns the DGalpNAca- around so that the nitrogen in its NAc group is on the 
other side. This would happen if only sterics were involved, and this is why this software returns
this structure rather than the one above.

![[2mk7_GP-Build_vmdscene.dat.tga.jpg]]

## What you can do

For this, you can start with the structure in 2MK7. It already contains the GalNAc glycans in the
correct orientations. You can also run MD simulations. Those will quickly put the GalNAc back where
it should be.

## For more or updated info

You can view the report on GitHub here:
[[https://github.com/GLYCAM-Web/gmml2/issues/39]]

There you will find discussions and updates.
