% This function accepts an image as an input, calls a function to calculate
% filter radii for wedge-shaped slices located in the image, then returns the
% filter radius for each slice as a vector, along with an image showing the
% number of degrees overlaid in each wedge located.

function [sliceSizes, sliceImage] = CalculateFilterSliceSizes(image)
    % Call the wedge chooser function to identify which wedges to calculate.
    % This function will return a vector of the radii of the wedges to be
    % calculated.
    wedgeRadii = WedgeChooser(image);

    % Calculate the filter radii for each slice
    sliceSizes = CalculateFilterRadii(image, wedgeRadii);
    
    % Create an image showing the number of degrees in each slice
    sliceImage = zeros(size(image));
    for i = 1:length(sliceSizes)
        sliceImage = DrawWedge(sliceImage, sliceSizes(i));
    end
end
