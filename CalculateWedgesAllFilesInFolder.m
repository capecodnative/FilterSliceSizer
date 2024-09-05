% A function that goes through all files in a directory specified
% calls AngleFinderSliceSizer on each, and saves the struct output
% of each to a .csv named after the file as filename_wedges.csv

function CalculateWedgesAllFilesInFolder(folderPath)
    % Get a list of all jpg files in the specified folder
    files = dir(fullfile(folderPath, '*.jpg'));
    
    % Loop through each file in the folder
    for i = 1:length(files)
        % Get the full file path
        filePath = fullfile(folderPath, files(i).name);
        
        % Call AngleFinderSliceSizer on the current file
        wedgesData = AngleFinderSliceSizer(filePath);
        
        % Save the output struct to a .csv file
        outputFileName = [files(i).name(1:end-4) '_wedges.csv'];
        writeStructToTxt(wedgesData,outputFileName);
    end
end