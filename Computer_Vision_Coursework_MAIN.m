% NOTE: Other than PCA, LBP, and edge detection(since morphological methods
% gave worse results) functions, all of the algorithms and the functions 
% are developed by F217699. For these 3 functions, Matlab image processing 
% toolbox's functions have been used.
%% SECTION 1
% DATA IMPORT SECTION
%% 
% In this part the data which is given by tutor is imported in the matlab environment.

% Import color images into lesion_imgs
lesion_imgs = imageDatastore('lesionimages/images');
% Take the color images into lesions matrix
lesions     = readall(lesion_imgs);
% Import mask images into lesion_imgs
masks       = imageDatastore('masks/masks');
%Take the masks into masks matrix
masks       = readall(masks);
% Import groundtruth table
load('groundtruth.mat');
%% *SECTION 2*
% *FEATURE EXTRACTION ABCDE RULES SECTION*
% A RULE ASYMMETRY
%% 
% In this part all of the color images divided into 2 different parts depending 
% on their center point;
% 
% 1-) Reduced color image is divide into two parts as rigth and left and compare 
% their differences,
% 
% 2-) Reduced color image is divide into two parts as up and down and compare 
% their differences,
% 
% Both results are stored in the symmetric_result matrix(matrix shape is 200x2)

symmetric_result = []; %Initial symmetric_result matrix set as empty
for i = 1:200 % 200 loop arranged to calculate 200 image's symmetry rates

    %symmetry_calculator function is used
    sp = symmetry_calculator(lesions{i},masks{i}); 
    %Result is added the result matrix
    symmetric_result = [symmetric_result;sp];

end
% *B RULE BORDER*
%% 
% One of the other features that is useful to make a classification between 
% benign and malignant lesions is the lesion’s circularity. Benign lesions have 
% a more circular shape while malignant lesions commonly have uncircular shapes. 
% 
% To understand the circularity of the lesion; the optimum radius is calculated 
% using the area of the lesion. After finding the optimum radius, the center point 
% of the lesion is calculated( Far Left Column– Far Right Column, Top Row – Bottom 
% Row). All of the radius between the center point and the boundary pixel are 
% compared to the optimum radius and the absolute values of differences are summed 
% together to create circularity parameters.

% Create an empty circularity features array
circularity_list=[];
% Take all images circularity rate and store into circularity_list array
for i = 1:200
    query = circularity_rate(masks{i});
    circularity_list = cat(2, circularity_list, query);
end
% C RULE COLOR
%% 
% There are a total of 16.777.216 different colors in the (256x256x256) RGB 
% matrix. All images can be represented using this image's values without losing 
% any specific colors. But in this work taking a histogram using all of these 
% colors can be too much complex and time-consuming. Also understanding commonly 
% used colors could be difficult to understand since there are too many values 
% in their histograms. One alternative way is using a 4 or 2 bins RGB matrix to 
% reduce time consumption and complexity. Since all color has significant meaning 
% to classify to lesion whether is benign or malignant 2 bins(8 colors) color 
% histograms are used to create color features. The final feature matrix is a 
% 200x8 matrix after this statement, because of the size of the feature array, 
% the PCA method(explained in the PCA section) applied for this result feature 
% matrix to reduce the dimension 200x2 matrix.

%Initial color histogram matrix set empty
colormapresult = [];

for i = 1:200 % Loop is created to take all images color histogram rates

    %eigth_color function is applied
    arr = eigth_color(lesions{i},masks{i});
    %Result is added to the final matrix
    colormapresult = [colormapresult,arr];

end
% DOMINANT COLOR FEATURE
%% 
% Having multiple colors or a single dominant color is one of the other important 
% features. Most of the benign lesions have one dominant color whereas malignant 
% lesions have more than one color. In this work, the threshold value for having 
% multiple or one dominant color is set as 0.6 because if a lesion has one dominant 
% color the rate must be more than 50 percent. If a lesion image has more than 
% 50 percent of any color in 8 colors histogram the dominant color feature parameter 
% is defined as 1 if not the parameter is defined as 0.

%Res array is created to store if there is any dominant color in the image
res_array = [];

for k = 1:200 % For loop is created to apply this statement for all images
    %Take the images color histogram
    eightcolormap = colormapresult(:,k);
    %Look if there is any dominant color(which is occur more than threshold
    %value 0.6)
    rr = sum(eightcolormap > 0.6);
    %Add the result in result matrix
    res_array = [res_array,rr];
end
% LBP RULE
%% 
% Local binary pattern has a significant impact on making classification between 
% lesion types. In this work for all of the 200 images grayscale versions are 
% used to calculate their LBP feature matrix. As a result for each image, there 
% is a 1X59 array created to store their LBP feature values.

%Initial LBP matrix set as empty
lbp_results = [];

for i = 1:200 % For loop arranged to store all images feature
    %Convert the image into grayscale
    img = rgb2gray(lesions{i});
    %Take the LBP values of the image
    lbp = extractLBPFeatures(img);
    %Add the features into final result matrix
    lbp_results = [lbp_results;lbp];
end
% *SVM SECTION*

%To create features, zscore is used to make normalization or standardization.
%Set the dominant color feature as feature1
feature1 = zscore(transpose(res_array));
%Set the circularity feature as feature2
feature2 = zscore(transpose(circularity_list));
%Set the asymmetry feature as feature3
feature3 = zscore(symmetric_result);
%Set the color feature as feature4
feature4 = zscore(transpose(colormapresult));
%Set the LBP feature as feature5
feature5 = zscore(lbp_results);
%%
% Apply PCA color feature to reduce feature dimension from 8 to 2 column
% Take the coefficients of feature4
coeff = pca(feature4);
% Take 2 column matrix with using coefficients
feature4 = feature4 * coeff(:, 1:2);
%%
% Create new feature matrix with using 4 features except LBP feature since
% it does not give better result with PCA
imfeatures = [feature1,feature2,feature3,feature4];
% Perform PCA for new combination of the features
coeff = pca(imfeatures);
% Reduce to 3 principal components from 5
imfeatures = imfeatures * coeff(:, 1:3);
%%
%Creating imfeature with using all features
imfeatures = [ imfeatures , feature5];
% perform classification using 10CV
rng(1); % let's all use the same seed for the random number generator
%Train the SVM model
svm = fitcsvm(imfeatures, groundtruth);
%Apply cross validation
cvsvm = crossval(svm);
%Make predictions
pred = kfoldPredict(cvsvm);
%Compare predictions and the actual variables
[cm, order] = confusionmat(groundtruth, pred);
%Draw the confusion matrix
confusionchart (cm, order);