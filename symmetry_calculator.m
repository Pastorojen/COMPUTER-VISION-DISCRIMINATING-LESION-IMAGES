function output = symmetry_calculator(img,mask)
% This function is created to calculate symmetry rates for both up-down and
% left-right side

%Find the center point of the lesion
[cr ,cc] = center_finder(mask);

% Divide the mask into two equal horizontal parts 
top_part = mask(1:cr, :, :);
bottom_part = mask(cr:end, :, :);
% Divide the image into two equal horizontal parts 
color_top_part = img(1:cr, :, :);
color_bottom_part = img(cr:end, :, :);
% Divide the mask into two equal vertical parts
right_part = mask(:, 1:cc, :);
left_part = mask(:, cc:end, :);
% Divide the image into two equal vertical parts
color_right_part = img(:, 1:cc, :);
color_left_part = img(:, cc:end, :);

% Calculate the top part color histogram on 8 color base
top = eigth_color(color_top_part,top_part);
% Calculate the bottom part color histogram on 8 color base
bottom = eigth_color(color_bottom_part,bottom_part);
% Calculate the right part color histogram on 8 color base
right =eigth_color(color_right_part,right_part);
% Calculate the left part color histogram on 8 color base
left =eigth_color(color_left_part,left_part);

% Calculate the difference between top and bottom histograms
horizontal_match  = sum(abs(top-bottom));
% Calculate the difference between right and left histograms
vertical_match = sum(abs(right-left));
% Give the output as 1x2 for both horizantal and vertical differences
output = cat(2,horizontal_match,vertical_match);

end