% PROCEDURE:
% 1 Initialize:
%   A: detectors (all levels)
%   B: images
% 2 Cascaded detection:
%   A: faces (need resizing)
%   B: components (need resizing)
%   C: features (need resizing)
%   D: ctrl points are centroids
% 3 Regions:
%   A: convex hull
%   B: extraction & blending
%   C: color adjustment
% 4 Replacement:
%   A: warp
%   B: replacement

% 1-: File Paths
addpath 'SampleSet/easy/'
addpath 'SampleSet/hard/'
addpath 'SampleSet/us/'

% 1B: Image
face_image1 = imread('iu.jpg');%'jennifer.jpg');%'justin_glasses.jpg');%'yao.jpg');%
%face_image = imread('0lliviaa.jpg');%'beard-champs4.jpg');%'jennifer_xmen.jpg');%'mj.jpg');%
%face_image = imresize(face_image,0.5);
[height1,width1,~] = size(face_image1);

face_image2 = imread('yao.jpg');%

[ctrl_pts1, face1, components1] = facepts(face_image1);
[face_height1,face_width1,~] = size(face1.im);
face_size1 = mean(size(face1.im));

[ctrl_pts2, face2, components2] = facepts(face_image2);
[face_height2,face_width2,~] = size(face2.im);
face_size2 = mean(size(face2.im));

% 3A: Convex Hull
box_pts1 = [bb2pts(components1.nose);bb2pts(components1.mout);...
    bb2pts(components1.eyeL);bb2pts(components1.eyeR)];
conv_inds1 = convhull(box_pts1);
conv_pts1 = box_pts1(conv_inds1,:);

% 3B: Blending
hard_mask1 = poly2mask(conv_pts1(:,1),conv_pts1(:,2),face_height1,face_width1);
kernel = fspecial('gaussian',round(face_size1/5)*ones(1,2),face_size1/25);
mask1 = conv2(double(imerode(hard_mask1,ones(round(face_size1/5)))),kernel,'same');

% 4: Warp
H = est_homography(ctrl_pts2(:,1),ctrl_pts2(:,2),ctrl_pts1(:,1),ctrl_pts1(:,2));
[ctrl_pts1xnew,ctrl_pts1ynew] = apply_homography(H,ctrl_pts1(:,1),ctrl_pts1(:,2));

corners = [0,0; 0,face_height1; face_width1, face_height1; face_width1,0];
udata = [0 face_width1];  vdata = [0 face_height1];
[cx,cy] = apply_homography(H,corners(:,1),corners(:,2));
T_corners = [cx,cy];

figure(99)
plot(ctrl_pts1(:,1),ctrl_pts1(:,2),'r',ctrl_pts1xnew,ctrl_pts1ynew,'m',...
    corners(:,1),corners(:,2),'g',cx,cy,'b')

tform = maketform('projective',corners,T_corners);

[T_im,xdata,ydata] = imtransform(face1.im, tform, 'bicubic', 'udata', udata, 'vdata', vdata, ...
    'fill', 0, 'XYScale', 1);
T_mask = imtransform(hard_mask1, tform, 'udata', udata, 'vdata', vdata, ...
    'fill', 0, 'XYScale', 1);
[h,w,unused] = size(T_mask);

T_mask(:,1:ceil(xdata(1))) = 0;
T_mask(1:ceil(ydata(1)),:) = 0;
T_mask(floor(xdata(2)):face_height1,:) = 0;
T_mask(:,floor(ydata(2)):face_width1) = 0;
figure(98)
imshow(T_mask)

output_temp = zeros(ceil(ydata(2))-floor(ydata(1)),ceil(xdata(2))-floor(xdata(1)));
offset = round(-min([xdata(1),ydata(1)],[0,0]));
output_temp((1:face_height2) + offset(2), (1:face_width2) + offset(1),1) = ...
    double(face2.im(:,:,1))/255;
output_temp((1:face_height2) + offset(2), (1:face_width2) + offset(1),2) = ...
    double(face2.im(:,:,2))/255;
output_temp((1:face_height2) + offset(2), (1:face_width2) + offset(1),3) = ...
    double(face2.im(:,:,3))/255;

red_chan = output_temp(:,:,1);
green_chan = output_temp(:,:,2);
blue_chan = output_temp(:,:,3);

redin_chan = double(T_im(:,:,1))/255;
greenin_chan = double(T_im(:,:,2))/255;
bluein_chan = double(T_im(:,:,3))/255;

red_chan(T_mask) = redin_chan(T_mask);
green_chan(T_mask) = greenin_chan(T_mask);
blue_chan(T_mask) = bluein_chan(T_mask);
output_temp2 = cat(3,red_chan,green_chan,blue_chan);
figure(100)
imshow(output_temp2)


% --: Display
figure(1)
faced = double(face1.im)/255;
toshow = cat(3,faced(:,:,1).*mask1,faced(:,:,2).*mask1,faced(:,:,3).*mask1);
imshow(toshow)

% Component centroids
hold on
plot(ctrl_pts1(1,1),ctrl_pts1(1,2),'.r')
plot(ctrl_pts1(2,1),ctrl_pts1(2,2),'.b')
plot(ctrl_pts1(3,1),ctrl_pts1(3,2),'.c')
plot(ctrl_pts1(4,1),ctrl_pts1(4,2),'.g')
hold off

% Convex hull
%{
hold on
plot(box_pts1(:,1),box_pts1(:,2),'.y')
plot([conv_pts1(:,1);conv_pts1(1,1)],[conv_pts1(:,2);conv_pts1(1,2)],'y');
hold off
%}


% --: Display
figure(2)
faced = double(face2.im)/255;
toshow = faced;
imshow(toshow)

% Component centroids
hold on
plot(ctrl_pts2(1,1),ctrl_pts2(1,2),'.r')
plot(ctrl_pts2(2,1),ctrl_pts2(2,2),'.b')
plot(ctrl_pts2(3,1),ctrl_pts2(3,2),'.c')
plot(ctrl_pts2(4,1),ctrl_pts2(4,2),'.g')
hold off

% Convex hull
%{
hold on
plot(box_pts1(:,1),box_pts1(:,2),'.y')
plot([conv_pts1(:,1);conv_pts1(1,1)],[conv_pts1(:,2);conv_pts1(1,2)],'y');
hold off
%}


