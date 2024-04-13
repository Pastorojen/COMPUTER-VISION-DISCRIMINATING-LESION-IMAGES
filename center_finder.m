function [center_row, center_column] = center_finder(img)
% This function is created to find the center point of the object
% It firstly finds object edges and with these values it finds first and
% last row and column values to find the average which is the center point
    % Find the edges
    edgeImage = edge(img, 'Canny');
    % Find the row index 
    max_row = max(edgeImage, [], 2);
    % Find the column index
    max_column = max(edgeImage, [], 1);
    % Find start_row
    start_row = find(max_row, 1, 'first');
    % Find end_row
    end_row = find(max_row, 1, 'last');
    % Find start_column
    start_column = find(max_column, 1, 'first');
    % Find end_column
    end_column = find(max_column, 1, 'last');
    % Calculate center_row and center_column
    center_row = floor((end_row + start_row) / 2);
    center_column = floor((end_column + start_column) / 2);
end
