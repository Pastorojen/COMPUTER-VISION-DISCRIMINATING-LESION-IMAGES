function colormap = eigth_color(img,mask)
%This function is created to give color histograms of images for 2 bins
%(eight color base)

%Convert the pixels value between 0 -127 to 64
img(img >= 0 & img <= 127) = 64;
%Convert the pixels value between 128 -255 to 192
img(img >= 128 & img <= 255) = 192;
%Set initial 2bin(2x2x2) color matrix with full zeros
counter = zeros(2,2,2);
%Take all red pixel values into array R
R = img(:,:,1);
%Take all green pixel values into array G
G = img(:,:,2);
%Take all blue pixel values into array B
B = img(:,:,3);

%Find all 255 values location in the mask which shows the lesion area
%In this part we ignore the background in our process only lesion area
[row_indices, col_indices] = find(mask == 255);
%Take the size of values
rs = size(row_indices);

for i = 1: rs(1) %Arrange a for loop depends on variable size
    
    %Take the red pixel value in lesion area for each loop
    x = R(row_indices(i,:),col_indices(i,:));
    %Take the green pixel value in lesion area for each loop
    y = G(row_indices(i,:),col_indices(i,:));
    %Take the blue pixel value in lesion area for each loop
    z = B(row_indices(i,:),col_indices(i,:));     
    %Increase the location of the 2bins(2x2x2) matrix depending on the
    %color value it is used to group 16.7 million colors into 8 color group
    counter(((x+64)/128),((y+64)/128),((z+64)/128)) = 1 + counter(((x+64)/128),((y+64)/128),((z+64)/128));
end
%Make normalisation to give all color variables value in range [0-1]
%And the total colormap variable is 1 for all the images
colormap = counter(:) / (rs(1));
end
