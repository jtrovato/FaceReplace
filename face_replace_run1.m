%face_replace_run1.m

%{
easy: 
0013729928e6111451103c.jpg
1407162060_59511.jpg
1d198487f39d9981c514f968619e9c91.jpg
bc.jpg
celebrity-couples-01082011-lead.jpg
inception-shared-dreaming.jpg
Iron-Man-Tony-Stark-the-avengers-29489238-2124-2560.jpg
iu.jpg
jennifer.jpg
yao.jpg

hard:
0b4e3684ebff3455f471bb82a0173f48.jpg  69daf49a8beb63dc35bf65b4e408cde9.jpg
0lliviaa.jpg                          beard-champs4.jpg
14b999d49e77c6205a72ca87c2c2e5df.jpg  jennifer_xmen.jpg
314eeaedbe5732558841972afdbaf32f.jpg  mj.jpg
4b5d69173e608408ecf97df87563fd34.jpg  star-trek-2009-sample-003.jpg
53e34a746d54adb574ab169d624ccd0a.jpg

blending:
060610-beard-championships-bend-stroomer-0002.jpg
b1.jpg
bc.jpg
Jennifer_lawrence_as_katniss-wide.jpg
jennifer-lawrences-mystique-new-x-men-spin-off-movie.jpg
Michael-Jordan.jpg
Official_portrait_of_Barack_Obama.jpg

more: 
burn-marvel-s-the-avengers.jpg
jkweddingdance-jill_and_kevin_wedding_party.jpg
marvels-the-avengers-wallpapers-01-700x466.jpg
real_madrid_2-wallpaper-960x600.jpg

pose:
golden-globes-jennifer-lawrence-0.jpg
Michael_Jordan_Net_Worth.jpg
p1.jpg
p2.jpg
Pepper-and-Tony-tony-stark-and-pepper-potts-9679158-1238-668.jpg
robert-downey-jr-5a.jpg
star-trek-2009-sample-003.jpg
%}


% INITIALIZE ==============================================
% Load the replacer and replacee faces, initialize miscellaneous others.
% INPUTS: NONE
% OUTPUTS:
%   im1: source image with replacee face
%   im2: source image with replacer face
%   -parameters, face selection

% Paths to face files and third party source
addpath face-release1.0-basic/

addpath 'SampleSet/easy/'
addpath 'SampleSet/hard/'
addpath 'SampleSet/us/'
addpath 'TestSet/blending/'
addpath 'TestSet/more'
addpath 'TestSet/pose'

% Replacee and replacement faces
im1 = imread('jkweddingdance-jill_and_kevin_wedding_party.jpg');
im2 = imread('justin_glasses.jpg');

im1_orig = im1;
im2_orig = im2;

im1 = imresize(im1,2);


% FACE FEATURES ===========================================
% Generate control points on the replacer and replacee faces for face
% extraction and warping.
% INPUTS:
%   im1
%   im2
% OUTPUTS:
%   ctrlpts1: control points on the replacee face in image 1
%   ctrlpts2: control points on the replacer face in image 2

% Prepare Models and Detectors
load face_p146_small.mat
model.interval = 3; % 5 levels for each octave
model.thresh = min(-1, model.thresh); % set up the threshold 
if length(model.components)==13
    posemap = 90:-15:-90;
elseif length(model.components)==18
    posemap = [90:-15:15 0 0 0 0 0 0 -15:-15:-90];
else
    error('Can not recognize this model');
end

detectors.face = vision.CascadeObjectDetector();

% Parameters
warp_pts = [6,   12,  23,  35,41, 52];
%           nose,eyeR,eyeL,mouth,chin
hull_pts = [16,19, 27,30, 53,62, 59,67];
%           browR, browL, chin,  jaw
index = 1;

% Detect faces
bbox1 = step(detectors.face, im1);
bbox1 = round(bbox1(index,:).*[1,1,1.4,1.4] - bbox1(index,[3,4,1,2]).*[0.2,0.2,0,0]);
bbox1([1,2]) = max(bbox1([1,2]),1);
bbox1([3,4]) = min(bbox1([3,4]),[size(im1,2),size(im1,1)]-bbox1([1,2]));

face1.pos = bbox1([1,2]);
face1.im = im1(bbox1(2) + (1:bbox1(3)),bbox1(1) + (1:bbox1(4)),:);

bbox2 = step(detectors.face, im2);
bbox2 = round(bbox2(1,:).*[1,1,1.4,1.4] - bbox2(1,[3,4,1,2]).*[0.2,0.2,0,0]);
bbox2([1,2]) = max(bbox2([1,2]),1);
bbox2([3,4]) = min(bbox2([3,4]),[size(im2,2),size(im2,1)]-bbox2([1,2]));

face2.pos = bbox2([1,2]);
face2.im = im2(bbox2(2) + (1:bbox2(3)),bbox2(1) + (1:bbox2(4)),:);

% Resize
face2.im = imresize(face2.im,size(face1.im,1)/size(face2.im,1));

% Control points
bs1 = detect(face1.im, model, model.thresh);
bs1 = clipboxes(face1.im, bs1);
bs1 = nms_face(bs1,0.3);
bs1 = bs1(1);

bs2 = detect(face2.im, model, model.thresh);
bs2 = clipboxes(face2.im, bs2);
bs2 = nms_face(bs2,0.3);
bs2 = bs2(1);

ctrlpts1 = 0.5*(bs1.xy(warp_pts,[1,2]) + bs1.xy(warp_pts,[3,4]));
ctrlpts2 = 0.5*(bs2.xy(warp_pts,[1,2]) + bs2.xy(warp_pts,[3,4]));

exterior1 = 0.5*(bs1.xy(hull_pts,[1,2]) + bs1.xy(hull_pts,[3,4]));
exterior2 = 0.5*(bs2.xy(hull_pts,[1,2]) + bs2.xy(hull_pts,[3,4]));

% Face image dimensions
[h1,w1,~] = size(face1.im);
[h2,w2,~] = size(face2.im);


% FACE ADJUSTMENT =========================================
% Extract, color adjust, (and blend) the replacer face to match the
% appearance of the replacee appearance.
% INPUTS:
%   ctrlpts1
%   ctrlpts2
%   im1
%   im2
% OUTPUTS: 
%   mask2: region of im2 containing replacer face (including blend)
%   im2adj: adjusted im2 to match colors of im1

convpts1 = exterior1(convhull(exterior1(:,1),exterior1(:,2)),:);
mask1 = poly2mask(convpts1(:,1),convpts1(:,2),h1,w1);

convpts2 = exterior2(convhull(exterior2(:,1),exterior2(:,2)),:);
mask2 = poly2mask(convpts2(:,1),convpts2(:,2),h2,w2);

means1 = zeros(1,3);
means2 = zeros(1,3);
color_adjust = zeros(size(face2.im));
for ii = 1:3
    color1 = face1.im(:,:,ii);
    color2 = face2.im(:,:,ii);
    means1(ii) = mean(color1(mask1));
    means2(ii) = mean(color2(mask2));
    color_adjust(:,:,ii) = means1(ii)-means2(ii);
end

im2adj = double(face2.im) + color_adjust;


% WARP ====================================================
% Warp the replacer face to match the geometry of the replacee face.
% INPUTS:
%   ctrlpts1
%   ctrlpts2
%   mask2
%   im2adj
% OUTPUTS:
%   mask2warp: warped mask2 to geometry of replacee face
%   im2warp: warped im2adj to geometry of replacee face

im1pts = [[1,1; 1,h1; w1,1; w1,h1];ctrlpts1];
im2pts = [[1,1; 1,h2; w2,1; w2,h2];ctrlpts2];

mean_pts = (im1pts+im2pts)/2;
tri = delaunay(mean_pts);

im2warp = morph(double(face1.im), im2adj, im1pts, im2pts, tri, 0, 1);
im2warp = im2warp(1:h1,1:w1,:);

mask2warp = morph(double(face1.im(:,:,1)), mask2, im1pts, im2pts, tri, 1, 1);
mask2warp = mask2warp(1:h1,1:w1);
mask2warp = imerode(mask2warp,ones(round(h1/50)));
mask2warp = conv2(double(mask2warp),fspecial('gaussian',round(h1/5)*ones(1,2), h1/25),'same');
mask2warp = cat(3,mask2warp,mask2warp,mask2warp);

% REPLACEMENT =============================================
% Replacement & blending to produce final output image
first = double(face1.im);
second = double(im2warp);

face_swap = zeros(h1,w1,3);
face_swap = face_swap + double(first).*(1-mask2warp);
face_swap = face_swap + double(second).*mask2warp;

face_swap = imresize(face_swap,bbox1(3)/size(face_swap,1));

output = im1;
output(bbox1(2) + (1:bbox1(4)) - 1, bbox1(1) + (1:bbox1(3)) - 1,:) = uint8(face_swap);

figure(99)
imshow(output);

% DEBUGGING ===============================================
% Display & other final debugging
%{a
figure(2)
subplot(2,2,1)
showboxes(face1.im, bs1, posemap); hold on; 
plot(exterior1(:,1),exterior1(:,2),'.b');
plot(ctrlpts1(:,1),ctrlpts1(:,2),'.g'); 
hold off
subplot(2,2,2)
showboxes(face2.im, bs2, posemap); hold on; 
plot(exterior2(:,1),exterior2(:,2),'.b');
plot(ctrlpts2(:,1),ctrlpts2(:,2),'.g'); 
hold off

subplot(2,2,3)
imshow(face1.im + 50*uint8(mask2warp));
subplot(2,2,4)
imshow(face2.im + 50*uint8(cat(3,mask2,mask2,mask2)));
%}


figure(3)
subplot(1,2,1)
imshow(face_swap/255)
subplot(1,2,2)
imshow(im2warp/255)
hold on
plot(im1pts(:,1),im1pts(:,2),'.g')
hold off
