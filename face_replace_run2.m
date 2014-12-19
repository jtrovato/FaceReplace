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
%im1_orig = imread('robert-downey-jr-5a.jpg');
%im1_orig = imread('beard-champs4.jpg');
%im2_orig = imread('justin_glasses.jpg');

im1_orig = imread('mj.jpg');
im2_orig = imread('justin_glasses.jpg');

im1 = im1_orig;
im2 = im2_orig;

%im1 = imresize(im1,2);
%im1 = imresize(im1,0.5);

% FACE DETECTION ==========================================
% Detect and select faces in image 1 (assumes there is only one replacer
% face in image 2).
% INPUTS: 
%   im1
%   im2
% OUTPUTS:
%   bbox1full: bounding boxes of all faces in image 1
%   bbox2: bounding box of replacer face in image 2

% PARAMETERS
warp_pts = [6,   12,  23,  35,41, 52]; %59,67];%
%           nose,eyeR,eyeL,mouth,chin,  jaw (OPTIONAL)
hull_pts = [16,19, 27,30, 54,62, 59,67];
%           browR, browL, chin,  jaw

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

% Detect faces
bbox1full = step(detectors.face, im1);

%{a
% Face resizing
if isempty(bbox1full) % try looking for small faces
    im1 = imresize(im1,2);
    bbox1full = step(detectors.face, im1);
end
if isempty(bbox1full) % try looking for big faces
    im1 = imresize(im1,1/4);
    bbos1full = step(detectors.face, im1);
end
if isempty(bbox1full) % no faces of any close size could be found
    disp('No faces detected: exiting.')
    return
end

mean_height = mean(bbox1full(:,3));
if mean_height < 50
    im1 = imresize(im1,50/mean_height);
    bbox1full = step(detectors.face, im1);
elseif mean_height > 400
    im1 = imresize(im1,400/mean_height);
    bbox1full = step(detectors.face, im1);
end
%}

bbox2 = step(detectors.face, im2);
bbox2 = round(bbox2(1,:).*[1,1,1.4,1.4] - bbox2(1,[3,4,1,2]).*[0.2,0.2,0,0]);
bbox2([1,2]) = max(bbox2([1,2]),1);
bbox2([3,4]) = min(bbox2([3,4]),[size(im2,2),size(im2,1)]-bbox2([1,2]));

im2_face_orig = im2(bbox2(2) + (1:bbox2(3)),bbox2(1) + (1:bbox2(4)),:);

fprintf([num2str(size(bbox1full,1)),' faces detected\n'])
for index = 1:size(bbox1full,1)
    fprintf(['face ',num2str(index),'/',num2str(size(bbox1full,1))])
        
    % FACE FEATURES ===========================================
    % Generate control points on the replacer and replacee faces for face
    % extraction and warping.
    % INPUTS:
    %   im1
    %   im2
    % OUTPUTS:
    %   im1_face: selected replacee face in im1
    %   im2_face: selected replacer face in im2
    %   h1, w1: dimensions of im1_face
    %   h2, w2: dimensions of im2_face
    %   ctrlpts1: control points on the replacee face in image 1
    %   ctrlpts2: control points on the replacer face in image 2
    %   extpts1: boundary edge points on replacee face in image 1
    %   exrerior2: boundary edge points on replacer face in image 2

    % Extract replacee face
    bbox1 = round(bbox1full(index,:).*[1,1,1.4,1.4] - bbox1full(index,[3,4,1,2]).*[0.2,0.2,0,0]);
    bbox1([1,2]) = max(bbox1([1,2]),1);
    bbox1([3,4]) = min(bbox1([3,4]),[size(im1,1),size(im1,2)]-bbox1([2,1]));

    im1_face = im1(bbox1(2) + (1:bbox1(3)),bbox1(1) + (1:bbox1(4)),:);

    % Resize faces
    if size(im1_face,1) > 200
        im2_face = imresize(im2_face_orig,size(im1_face,1)/size(im2_face_orig,1));
    else
        im1_face = imresize(im1_face,200/size(im1_face,1));
        im2_face = imresize(im2_face_orig,200/size(im2_face_orig,1));
    end
        
    % Control and boundary points
    % Feature points in image 1
    bs1 = detect(im1_face, model, model.thresh);
    if isempty(bs1) % Face feature detection failure - try another face
        fprintf(' skip: common detection fail\n')
        continue
    end
    bs1 = clipboxes(im1_face, bs1);
    bs1 = nms_face(bs1,0.3);
    bs1 = bs1(1);
    if length(bs1.xy) < 68
        fprintf(' skip: over-rotation\n')
        continue
    end

    % Feature points in image 2
    bs2 = detect(im2_face, model, model.thresh);
    if isempty(bs2) % Face feature detection failure - try another face
        fprintf(' skip: replacer detection fail (potential bad size)\n')
        continue
    end
    bs2 = clipboxes(im2_face, bs2);
    bs2 = nms_face(bs2,0.3);
    bs2 = bs2(1);
    if length(bs2.xy) < 68
        fprintf(' skip: replacer over rotation (potential bad size)\n')
        continue
    end

    % Control points
    ctrlpts1 = 0.5*(bs1.xy(warp_pts,[1,2]) + bs1.xy(warp_pts,[3,4]));
    ctrlpts2 = 0.5*(bs2.xy(warp_pts,[1,2]) + bs2.xy(warp_pts,[3,4]));

    % Boundary points
    extpts1 = 0.5*(bs1.xy(hull_pts,[1,2]) + bs1.xy(hull_pts,[3,4]));
    extpts2 = 0.5*(bs2.xy(hull_pts,[1,2]) + bs2.xy(hull_pts,[3,4]));

    % Face image dimensions
    [h1,w1,~] = size(im1_face);
    [h2,w2,~] = size(im2_face);
    

    % FACE ADJUSTMENT =========================================
    % Extract, color adjust, (and blend) the replacer face to match the
    % appearance of the replacee appearance.
    % INPUTS:
    %   im1_face
    %   im2_face
    %   h1, w1
    %   h2, w2
    %   ctrlpts1
    %   ctrlpts2
    %   extpts1
    %   extpts2
    % OUTPUTS: 
    %   mask2: region of im2 containing replacer face (including blend)
    %   im2adj: adjusted im2 to match colors of im1

    convpts1 = extpts1(convhull(extpts1(:,1),extpts1(:,2)),:);
    mask1 = poly2mask(convpts1(:,1),convpts1(:,2),h1,w1);

    convpts2 = extpts2(convhull(extpts2(:,1),extpts2(:,2)),:);
    mask2 = poly2mask(convpts2(:,1),convpts2(:,2),h2,w2);

    means1 = zeros(size(im2_face));
    means2 = zeros(size(im2_face));
    color_scale = zeros(size(im2_face));
    for ii = 1:3
        color1 = double(im1_face(:,:,ii));
        color2 = double(im2_face(:,:,ii));
        means1(:,:,ii) = median(color1(mask1));
        means2(:,:,ii) = median(color2(mask2));
        color_scale(:,:,ii) = std(color1(mask1))/std(color2(mask2));
    end

    color_scale = 1/2*(color_scale+1);
    im2adj = (double(im2_face) - means2).*color_scale + means1;


    % WARP ====================================================
    % Warp the replacer face to match the geometry of the replacee face.
    % INPUTS:
    %   im1_face
    %   im2_face
    %   h1, w1
    %   h2, w2
    %   ctrlpts1
    %   ctrlpts2
    %   mask2
    %   im2adj
    % OUTPUTS:
    %   mask2warp: warped mask2 to geometry of replacee face
    %   im2warp: warped im2adj to geometry of replacee face

    % PARAMETERS
    erode_frac = 1/30;
    gaus_width = 1/5;
    gaus_sig = 1/25;
    
    im1pts = [[1,1; 1,h1; w1,1; w1,h1];ctrlpts1];
    im2pts = [[1,1; 1,h2; w2,1; w2,h2];ctrlpts2];

    mean_pts = (im1pts+im2pts)/2;
    tri = delaunay(mean_pts);

    im2warp = morph(double(im1_face), im2adj, im1pts, im2pts, tri, 0, 1);
    im2warp = im2warp(1:h1,1:w1,:);

    mask2warp = morph(double(im1_face(:,:,1)), mask2, im1pts, im2pts, tri, 0, 1);
    mask2warp = mask2warp(1:h1,1:w1);
    output_mask = mask2warp.*mask1;
    output_mask = imerode(output_mask,ones(round(h1*erode_frac)));
    output_mask = conv2(double(output_mask),...
        fspecial('gaussian',round(h1*gaus_width)*ones(1,2), h1*gaus_sig),'same');
    output_mask = cat(3,output_mask,output_mask,output_mask);

    % REPLACEMENT =============================================
    % Replacement & blending to produce final output image
    % INPUTS:
    %   im1_face
    %   im2warp
    % OUTPUTS:
    %   im1, output: final image
    
    first = double(im1_face);
    second = double(im2warp);

    face_swap = zeros(h1,w1,3);
    face_swap = face_swap + double(first).*(1-output_mask);
    face_swap = face_swap + double(second).*output_mask;

    face_swap = imresize(face_swap,bbox1(3)/size(face_swap,1));

    output = im1;
    output(bbox1(2) + (1:bbox1(4)) - 1, bbox1(1) + (1:bbox1(3)) - 1,:) = uint8(face_swap);

    im1 = output;
    fprintf(' done\n')
    figure(99)
    imshow(im1);
    
    % DEBUGGING ===============================================
    % Display & other final debugging
    %{a
    figure(2)
    subplot(2,3,1)
    showboxes(im2_face, bs2, posemap);
    hold on; 
    plot(convpts2(:,1),convpts2(:,2),'.b-');
    plot(ctrlpts2(:,1),ctrlpts2(:,2),'.g'); 
    hold off
    title('Replacer feature points')
    subplot(2,3,4)
    showboxes(im1_face, bs1, posemap);
    hold on; 
    plot(convpts1(:,1),convpts1(:,2),'.b-');
    plot(ctrlpts1(:,1),ctrlpts1(:,2),'.g');  
    hold off
    title('Replacee feature points')

    subplot(2,3,2)
    imshow(im2_face - 30 + 60*uint8(cat(3,mask2,mask2,mask2)));
    title('Replacer unwarped mask')
    subplot(2,3,5)
    imshow(im1_face - 30 + 60*uint8(output_mask));
    hold on
    plot([convpts1(:,1);convpts1(1,1)],[convpts1(:,2);convpts1(1,2)],'b')
    hold off
    title('Replacee warped mask')
    
    subplot(2,3,3)
    imshow(im2warp/255 - 0.1 + 0.2*double(cat(3,mask2warp,mask2warp,mask2warp)))
    hold on
    plot(im1pts(:,1),im1pts(:,2),'.g')
    hold off
    title('Replacer face warped')
    subplot(2,3,6)
    imshow(face_swap/255)
    title('Replacee face replaced')
    %}
    
    drawnow
end






