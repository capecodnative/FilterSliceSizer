% This function uses image processing techniques to identify a wedge-shaped object near a given point in the image.
% It returns the bounding box of the identified wedge, or an empty array if no wedge is found.

function wedge = IdentifyWedge(image, x, y)
    % Convert the image to grayscale
    grayImage = rgb2gray(image);
    
    % Threshold the image to create a binary mask
    binaryImage = grayImage > 0.5;
    
    % Fill holes in the binary mask
    filledImage = imfill(binaryImage, 'holes');
    
    % Find connected components in the filled image
    cc = bwconncomp(filledImage);
    
    % Initialize the wedge bounding box
    wedge = [];
    
    % Loop through each connected component
    for i = 1:cc.NumObjects
        % Get the bounding box of the current connected component
        bbox = regionprops(cc, 'BoundingBox');
        
        % Check if the click point is inside the bounding box
        if x >= bbox(i).BoundingBox(1) && x <= bbox(i).BoundingBox(1) + bbox(i).BoundingBox(3) && ...
           y >= bbox(i).BoundingBox(2) && y <= bbox(i).BoundingBox(2) + bbox(i).BoundingBox(4)
            % If the click point is inside the bounding box, set the wedge bounding box
            wedge = bbox(i).BoundingBox;
            break;
        end
    end
end