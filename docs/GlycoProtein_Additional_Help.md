# Additional Help for GlycoProtein Issues

This file contains information about some workarounds and other mitigations for problems that users might
encounter. If you cannot find the solution you need, consider contacting us:

- Issues Page: `https://github.com/GLYCAM-Web/GLYCAM_Delegator_Docker/issues`
- Wiki: `https://github.com/GLYCAM-Web/GLYCAM_Delegator_Docker/wiki`

## Possible solutions for some messages

These common errors have fixes that might be easy to implement, but might not be obvious as solutions.

For example, the error \"Empty Sequence\" has a simple and obvious meaning and an equally simple and obvious
solution. However, \"Missing Element Definition\", while understandable, does not have a simple and obvious 
solution. This section, while not comprehensive, aims to help users with fixes to errors in the latter 
category. In some cases, the fixes might not make intuitive sense, and please just accept that.  If the 
suggested solution does not work for you, please let us know.

- Missing Element Definition - The element designation is unknown.

    - A workaround for this error is to remove all HETATM and ANISOU cards from the PDB file before processing.

    - Parts of the `Glycam_Delegator_Docker` utilities will do this for you, but if your workflow is highly
      individualized, you might need to implement this workaround for yourself.

- Missing Target Glycosite Residue - The residue to be glycosylated could not be found.

    This tool must have coordinates for any amino acids to be glycosylated.

    - If you are gathering data from an mmCIF file, it is important to ensure that amino acid residues to be
      glycosylated are present in the coordinates section. Residues that lack coordiates might still be 
      reported in the file. For example, an experimenter might have been able to report the entire protein 
      sequence but was unable to obtain experimental coordinates for some of the residues. 

      - If glycosylating such a residue is important to you, there are methods for estimating a likely set of
        coordinates for it. Please be sure to learn the likelihood that the coordinates are accurte. But, if 
        it has coordinates, this tool will attempt to glycosylate it.

    - Again, if using an mmCIF file, be sure to specify the reported residue identification. The mmCIF
      file might contain assigned identifiers as well. The latter tend to, for example, start at '1' and 
      proceed in increments of one. Reported identifiers might have identification schemes based on 
      information that is not present in the mmCIF.
