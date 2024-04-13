function rate = circularity_rate(mask)
% In this function lesions will rated as a parameter depending on their
% shapes. The rate is calculated by using their different radius lengths.

% Find the center point of the lesion.
[cr cc] = center_finder(mask);
% Find the all edges
img = edge(mask, 'Canny');
% Find the position of the all edges
[row_indices, col_indices] = find(img == 1);
% Create an empty radius difference list the store all radius differences
Radius_Difference_list=[];
% Take all actual radius lengths(which calculated by edge point and center 
% point Euclidean distance)
for i = 1:size(row_indices)
    query = floor(sqrt((cr - row_indices(i))^2 + (cc - col_indices(i))^2));
    Radius_Difference_list = cat(2, Radius_Difference_list, query);
end
% Take all radius values(How many of how much length radius we have)
[counts, edges]  = hist(Radius_Difference_list,unique(Radius_Difference_list));

% Find the area
area = sum(mask(:) == 255);
% Calculate the optimum radius(imagine if the shape is circular)
est_radial = floor(sqrt(area / pi));
% Define counter total parameter as 0 initially
total = 0;
% Take the size of all radius stored array.
[t,sizer] = size(counts);
% Calculate all the actual radius variables with the optimum radius variable
% with using Manhattan distance
for i = 1:(t*sizer)-1
    total = total  + (counts(1,i) * abs(est_radial - edges(1,i)));
end
% Divide the counter parameter by the total number of radius to give the rate of
% circularity.
rate = total / (est_radial * sum(counts));

end
