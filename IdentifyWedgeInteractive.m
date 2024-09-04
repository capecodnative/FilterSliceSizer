function roiMask = IdentifyWedgeInteractive(image)
    % IDENTIFYWEDGEINTERACTIVE allows the user to interactively select ROIs.
    % Displays the image and overlays masked regions on user clicks.
    % Left-click to select new regions, right-click to finish.

    figure;
    imshow(image, 'InitialMagnification', 'fit');
    hold on;

    % Initialize the binary mask to store the selected regions
    roiMask = false(size(image, 1), size(image, 2));
    
    % Keep track of whether the user has finished
    isFinished = false;

    while ~isFinished
        title('Left click to select a region, right click to finish.');

        % Use drawpolygon to interactively select a region of interest (ROI)
        h = drawpolygon('Color', 'cyan', 'LineWidth', 1, 'FaceAlpha', 0.3);

        % Wait for the user to confirm or cancel
        if isempty(h.Position)
            % If no position is given, break the loop
            break;
        end

        % Create a binary mask from the polygon
        currentMask = createMask(h);

        % Add the new mask to the ROI mask
        roiMask = roiMask | currentMask;

        % Overlay the current selection as a semi-transparent mask
        imshow(image, 'InitialMagnification', 'fit');
        hold on;
        redChannel = cat(3, ones(size(image, 1), size(image, 2)), zeros(size(image, 1), size(image, 2)), zeros(size(image, 1), size(image, 2)));
        transparency = 0.3;
        imshow(redChannel, 'AlphaData', transparency * roiMask);
        hold on;

        % Ask the user if they want to continue
        answer = questdlg('Do you want to select another region?', 'Continue', 'Yes', 'No', 'Yes');
        if strcmp(answer, 'No')
            isFinished = true;
        end
    end

    % Output the final mask
    title('Final selected regions');
    hold off;
end
