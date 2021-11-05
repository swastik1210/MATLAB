clc
clear

%% Load Image
imageLocation=fullfile('C:','Users','intel','IAP',{'(00).jpg','(01).jpg','(02).jpg','(03).jpg','(04).jpg','(05).jpg','(06).jpg','(07).jpg','(08).jpg','(09).jpg'});
imgSet = imageSet(imageLocation);

%montage(imgSet.ImageLocation)
I = read(imgSet, 1);

%% Initiate
% gray scale image
grayimg = rgb2gray(I);

%returns a SURFPoints object,points,containing information about SURF features detected in the 2-D grayscale input.
%basically used to gather information about the images
points = detectSURFFeatures(grayimg);

%returns extracted feature vectors, also known as descriptors, and their corresponding locations, from a binary or intensity image.
[features, points] = extractFeatures(grayimg, points);

%2D affine transformation of image count size
%sets the property T with a valid projective transformation defined by 3x3 identity matrix
%eye sets 3x3 identity matrix
%The affine transformation technique is typically used to correct for geometric distortions or deformations that occur with non-ideal camera angles.
tforms(imgSet.Count) = projective2d(eye(3)); 

%we want some way to find corelation between 2 set of images
%do the same for all images

for n= 2:imgSet.Count
    %store the I(n-1) previous image features and points data to new variable
    featuresPrev=features;
    pointsPrev=points;
    
    %read new image in I(n) variable (over-write)
    I = read(imgSet, n);
    grayimg = rgb2gray(I);
    points = detectSURFFeatures(grayimg);
    [features, points] = extractFeatures(grayimg, points);
    
    %correspondences between I(n) and I(n-1).
    %returns indices of the matching features in the two input feature sets. 
    %The input feature must be either binaryFeatures objects or matrices.
    %return only unique matches between features and featuresPrev.
    indexPairs = matchFeatures(features, featuresPrev, 'Unique', true);
    matchedPoints = points(indexPairs(:,1), :);
    matchedPointsPrev = pointsPrev(indexPairs(:,2), :);
    
    %finding geometric-transformation for 2 image pair
    %returns a 2-D geometric transform object, tform. 
    %The tform object maps the inliers in matchedPoints to the inliers in matchedPointsPrev.
    tforms(n) = estimateGeometricTransform(matchedPoints, matchedPointsPrev,...
        'projective', 'Confidence', 99.9, 'MaxNumTrials', 1500);
   
    %recurvively finding the tranformation operation for given set of images
    %we need to multiply the tforms of prev and new 
    tforms(n).T = tforms(n-1).T * tforms(n).T;
    c=n;
end
    imageSize = size(I);  % all the images are the same size
    % Compute the output limits  for each transform
    
    %estimates the output spatial limits corresponding to a set of input spatial limits, xlim and ylim, given 2-D geometric transformation tform.
for i = 1:numel(tforms)
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(2)], [1 imageSize(1)]);
end

%averaging x limit and y limit
avgXLim = mean(xlim, 2);
[~, idx] = sort(avgXLim);
centerIdx = floor((numel(tforms)+1)/2);   
%rounds each element of X to the nearest integer less than or equal to that element.

centerImageIdx = idx(centerIdx);

%returns the inverse of the geometric transformation tform.
Tinv = invert(tforms(centerImageIdx));
for i = 1:numel(tforms)
    c=i+13;
    tforms(i).T = Tinv.T * tforms(i).T;
end
    
%% Initiating the panorama
for i = 1:numel(tforms)  %returns the number of elements, i, in geometric transforms tform
    c=i+25;
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(2)], [1 imageSize(1)]);
end

% minimum and maximum output x-limits
xMin = min([1; xlim(:)]);
xMax = max([imageSize(2); xlim(:)]);

% minimum and maximum output y-limits
yMin = min([1; ylim(:)]);
yMax = max([imageSize(1); ylim(:)]);

% Width and height of panorama taken using min max values of the dimensions
wid  = round(xMax - xMin); %rounding the width to the nearest integer value
ht = round(yMax - yMin);   %rounding the height to the nearest integer value

% Initialize the "empty" panorama.
Panorama = zeros([ht wid 3], 'like', I);

%% Render the panorama data
render = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');
%which combines two images, overlays one image over another

% Create a 2-D spatial reference object defining the size of the panorama.
xLim = [xMin xMax];
yLim = [yMin yMax];
panoramaView = imref2d([ht wid], xLim, yLim);

% Create the panorama.
for i = 1:imgSet.Count
    c=i+38;
    I = read(imgSet, i);

    % Transform I into the panorama.
    warpedImage = imwarp(I, tforms(i), 'OutputView', panoramaView);
    %transforms the numeric, logical, or categorical image A according to the geometric transformation tform. 
    %The function returns the transformed image in B.

    % Overlay the warpedImage onto the panorama.
    Panorama = step(render, Panorama, warpedImage, warpedImage(:,:,1));
end

%% image
imwrite(Panorama,'P.jpg');



    


