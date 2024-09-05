function writeStructToTxt(myStruct, filename)
    % Open the file for writing
    fileID = fopen(filename, 'w');
    
    % Check if the file opened successfully
    if fileID == -1
        error('Could not open the file for writing.');
    end
    
    % Call a helper function to recursively write the struct fields
    writeFields(fileID, myStruct, '');
    
    % Close the file
    fclose(fileID);
end

function writeFields(fileID, s, prefix)
    % Get all the field names of the struct
    fields = fieldnames(s);
    
    for i = 1:length(fields)
        fieldName = fields{i}; % Get the field name
        fieldValue = s.(fieldName); % Get the corresponding value
        
        % Create a prefix for nested structures
        fullFieldName = strcat(prefix, fieldName);
        
        if isstruct(fieldValue)
            % If the field is a struct, recursively call the function
            writeFields(fileID, fieldValue, strcat(fullFieldName, '.'));
        else
            % Write the field name and value to the file
            if isnumeric(fieldValue)
                fprintf(fileID, '%s: %f\n', fullFieldName, fieldValue);
            elseif ischar(fieldValue)
                fprintf(fileID, '%s: %s\n', fullFieldName, fieldValue);
            elseif islogical(fieldValue)
                fprintf(fileID, '%s: %d\n', fullFieldName, fieldValue);  % Print logical as 0/1
            else
                fprintf(fileID, '%s: %s\n', fullFieldName, mat2str(fieldValue));  % For other types
            end
        end
    end
end
