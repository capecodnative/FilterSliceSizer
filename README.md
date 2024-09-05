This set of MATLAB scripts is used to determine the angle of a filter wedge cut and the area of the created wedge(s).
A series of test images are provided in ./TestImages. Call
CalculateWedgesAllFilesInFolder('./TestImages/');
to run the primary script on all images in that subdirectory. This will also save the output of the wedge calcs
using the writeStructToText function included.

AngleFinderSliceSizer does most of the work--
Prompts for the user to set the image zoom level.
Prompts for two lines (via four points)
  Calculates their predicted intersection (even if the drawn segments don't cross) and the angle of the cut.
Prompts for a wedge polygon.
  Calculates the area of the polygon in pixels.

BUG: Sometimes seems to return the exterior rather than interior angle--use the annotated images to confirm, and if
incorrect, you can subtract the provided result (in the annotate image or text file output) from 180 degrees
