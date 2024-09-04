% This function displays the input image, allows the user to click on
% the image to select the center of any wedges to be calculated, and then
% returns the wedge ROIs as a vector which can be passed to CalculateWedgeRadii.
% The user clicks on the image to select the center of each wedge to be calculated, and 
% the function tries to identify a wedge-shaped object near that click. It then overlays a red
% ROI over the image to show the user where the wedge is located and adds a number.
% Right-clicking removes the last wedge center selected. Clicking outside the image or hitting enter
% ends the selection process.

function wedgeRadii = WedgeChooser(image)
    % Display the image
    figure;
    imshow(image);
    hold on;
    
    % Initialize the wedge radii vector
    wedgeRadii = [];
    
    % Initialize the wedge number
    wedgeNumber = 1;
    
    % Loop until the user hits enter
    while true
        % Get the user's click
        [x, y, button] = ginput(1);
        
        % If the user hit enter, exit the loop
        if isempty(button)
            break;
        end
        
        % If the user right-clicked, remove the last wedge
        if button == 3
            if wedgeNumber > 1
                wedgeNumber = wedgeNumber - 1;
                wedgeRadii = wedgeRadii(1:end-1);
                % Remove the last wedge from the image
                h = findobj('Type', 'text', 'String', num2str(wedgeNumber));
                delete(h);
                h = findobj('Type', 'rectangle', 'Tag', num2str(wedgeNumber));
                delete(h);
            end
            continue;
        end
        
        % If the user clicked outside the image, exit the loop
        if x < 1 || x > size(image, 2) || y < 1 || y > size(image, 1)
            break;
        end
        
        % Identify the wedge near the click
        wedge = IdentifyWedge(image, x, y);
        
        % If a wedge was found, add it to the list
        if ~isempty(wedge)
            wedgeRadii = [wedgeRadii, wedge];
            
            % Draw the wedge on the image
            rectangle('Position', wedge, 'EdgeColor', 'r', 'Tag', num2str(wedgeNumber));
            
            % Add the wedge number to the image
            text(wedge(1) + wedge(3)/2, wedge(2) + wedge(4)/2, num2str(wedgeNumber), 'Color', 'r', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
            
            % Increment the wedge number
            wedgeNumber = wedgeNumber + 1;
        end
    end
end