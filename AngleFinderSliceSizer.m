function wedgesData = AngleFinderSliceSizer(imageFile)
    % Load and display the image
    image = imread(imageFile);
    
    % Check if the image is already grayscale
    if size(image, 3) == 3
        grayImage = rgb2gray(image); % Convert to grayscale if necessary
    else
        grayImage = image; % Image is already grayscale
    end

    % Create a figure to show the image
    figureHandle = figure;
    imshow(image, 'InitialMagnification', 'fit');
    title(imageFile); % Update title to only show filename
    hold on;

    % Initialize variables for storing wedge data and tracking number of wedges
    wedgesData = struct('WedgeNumber', [], 'Angle', [], 'Area', []);
    wedgeCount = 0;
    annotatedImage = image;

    continueSelecting = true;
    while continueSelecting
        % Increment wedge count
        wedgeCount = wedgeCount + 1;
        disp('Set zoom level, then hit enter.');
        pause;

        % Step 2: Allow the user to select four points for the angle measurement
        disp('Select four points to define two lines (line1: point1 to point2, line2: point3 to point4)');
        
        linesConfirmed = false;
        while ~linesConfirmed
            try
                % Collect four points from user
                [x, y] = ginput(4); 
                
                if length(x) < 4
                    error('Not enough points selected. Please select four points.');
                end
                
                % Create two draggable lines
                line1 = drawline('Position', [x(1), y(1); x(2), y(2)], 'Color', 'r', 'LineWidth', 2);
                line2 = drawline('Position', [x(3), y(3); x(4), y(4)], 'Color', 'g', 'LineWidth', 2);
                
                % Add a "Done" button to allow resuming after adjustments
                uicontrol('Style', 'pushbutton', 'String', 'Done', ...
                          'Position', [20 20 100 30], 'Callback', @(src, event) uiresume(figureHandle));
                
                % Wait for user to finish adjusting or click "Done"
                uiwait(figureHandle);
                
                % After user confirms, retrieve updated positions
                x(1:2) = line1.Position(:, 1);
                y(1:2) = line1.Position(:, 2);
                x(3:4) = line2.Position(:, 1);
                y(3:4) = line2.Position(:, 2);
                
                % Extend the line segments and find the intersection point of their infinite extensions
                [xi, yi] = calculateExtendedIntersection(x(1), y(1), x(2), y(2), x(3), y(3), x(4), y(4));
                
                if isempty(xi)
                    error('The lines do not intersect.');
                end
                
                % Calculate the angle between the two lines at the intersection
                vector1 = [x(1) - xi, y(1) - yi]; % Vector from intersection to point1 of line1
                vector2 = [x(3) - xi, y(3) - yi]; % Vector from intersection to point3 of line2
                
                dotProd = dot(vector1, vector2);
                magV1 = norm(vector1);
                magV2 = norm(vector2);
                angleRadians = acosd(dotProd / (magV1 * magV2)); % Angle in degrees
                
                % Ensure the angle is the internal angle (less than 180 degrees)
                if angleRadians > 180
                    angleRadians = 360 - angleRadians; % Internal angle
                end
                
                % Plot the intersection point and the angle annotation
                plot(xi, yi, 'bo', 'MarkerSize', 10, 'LineWidth', 2);
                text(xi, yi, sprintf('%.2f°', angleRadians), 'Color', 'yellow', 'FontSize', 12, 'FontWeight', 'bold');
                
                % Insert the lines and intersection into the annotated image
                annotatedImage = insertShape(annotatedImage, 'Line', [x(1), y(1), x(2), y(2)], 'Color', 'red', 'LineWidth', 2);
                annotatedImage = insertShape(annotatedImage, 'Line', [x(3), y(3), x(4), y(4)], 'Color', 'green', 'LineWidth', 2);
                annotatedImage = insertText(annotatedImage, [xi, yi], sprintf('%.2f°', angleRadians), 'FontSize', 18, 'BoxColor', 'yellow', 'TextColor', 'white');
                
                linesConfirmed = true; % Lines confirmed
                
            catch e
                disp(['Error: ', e.message, ' Try again.']);
                if exist('line1', 'var'), delete(line1); end
                if exist('line2', 'var'), delete(line2); end
                continue; % Retry if something goes wrong
            end
        end

        % Step 4: Allow the user to define the wedge region using a polygon tool
        disp('Use the polygon tool to define the wedge region.');

        polygonConfirmed = false;
        while ~polygonConfirmed
            try
                h = drawpolygon('LineWidth', 1, 'FaceAlpha', 0.3); % Use a polygon tool to define the region
                disp('Polygon drawn. You can adjust the polygon if needed.');
                
                % Add "Done" button to allow resuming after adjustments
                uicontrol('Style', 'pushbutton', 'String', 'Done', ...
                          'Position', [20 20 100 30], 'Callback', @(src, event) uiresume(figureHandle));

                % Wait for user to finish adjusting or click "Done"
                uiwait(figureHandle);

                % Offer user options for feedback
                choice = questdlg('Would you like to adjust the polygon, confirm, or restart?', ...
                                  'Polygon Options', 'Adjust', 'Confirm', 'Restart', 'Confirm');
                
                switch choice
                    case 'Adjust'
                        disp('Adjust the polygon directly and click "Done" when finished.');
                        uiwait(figureHandle); % Wait again for user adjustments
                        continue; % Loop back to give the option again
                        
                    case 'Confirm'
                        polygonConfirmed = true; % User confirmed the polygon, exit loop
                        
                    case 'Restart'
                        delete(h); % Remove the current polygon
                        disp('Redrawing the polygon.');
                        continue; % Loop back to redraw
                end

            catch
                disp('Error in drawing or adjusting the polygon. Try again.');
                continue; % Retry if something goes wrong
            end
        end

        % After polygon is confirmed, continue with the mask and area calculation
        wedgeMask = createMask(h);
        wedgeAreaPixels = sum(wedgeMask(:)); % Area in pixels

        % Annotate the area in the center of the polygon
        centerX = mean(h.Position(:,1)); % X coordinate of ROI center
        centerY = mean(h.Position(:,2)); % Y coordinate of ROI center
        text(centerX, centerY, sprintf('%d px', wedgeAreaPixels), 'Color', 'cyan', 'FontSize', 12, 'FontWeight', 'bold');
        annotatedImage = insertText(annotatedImage, [centerX, centerY], sprintf('Wedge %d; %d px', wedgeCount, wedgeAreaPixels), 'FontSize', 18, 'BoxColor', 'cyan', 'TextColor', 'black');

        % Insert the polygon boundary into the annotated image
        annotatedImage = insertShape(annotatedImage, 'Polygon', h.Position, 'Color', 'cyan', 'LineWidth', 1);

        % Save wedge data
        wedgesData(wedgeCount).WedgeNumber = wedgeCount;
        wedgesData(wedgeCount).Angle = angleRadians;
        wedgesData(wedgeCount).Area = wedgeAreaPixels;

        % Step 7: Ask the user if they want to analyze another wedge
        answer = questdlg('Would you like to measure another wedge?', 'Continue', 'Yes', 'No', 'Yes');
        if strcmp(answer, 'No')
            continueSelecting = false;
        end
    end

    % Step 8: Save the annotated image to a new file with "_annotated" added
    [filepath, name, ext] = fileparts(imageFile);
    annotatedFilename = fullfile(filepath, [name, '_annotated', ext]);
    imwrite(annotatedImage, annotatedFilename);
    disp(['Annotated image saved as: ', annotatedFilename]);

    % Finish and close the figure when done
    hold off;
    disp('Analysis completed.');
end

% Helper function to calculate the intersection of two lines if extended
function [xi, yi] = calculateExtendedIntersection(x1, y1, x2, y2, x3, y3, x4, y4)
    % Line 1 equation: (x1, y1) to (x2, y2)
    % Line 2 equation: (x3, y3) to (x4, y4)
    
    % Calculate the denominator of the intersection point formula
    denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    
    if denom == 0
        xi = [];
        yi = [];
        return; % Lines are parallel and do not intersect
    end
    
    % Calculate the intersection point
    xi = ((x1*y2 - y1*x2) * (x3 - x4) - (x1 - x2) * (x3*y4 - y3*x4)) / denom;
    yi = ((x1*y2 - y1*x2) * (y3 - y4) - (y1 - y2) * (x3*y4 - y3*x4)) / denom;
end
