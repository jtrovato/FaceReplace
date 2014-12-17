% File Paths
addpath 'SampleSet/easy/'
addpath 'SampleSet/hard/'
addpath 'SampleSet/us/'

% Face and component detectors
faceDetector = vision.CascadeObjectDetector();
noseDetector = vision.CascadeObjectDetector('Nose');
mouthDetector = vision.CascadeObjectDetector('Mouth');
leftEyeDetector = vision.CascadeObjectDetector('LeftEye');
rightEyeDetector = vision.CascadeObjectDetector('RightEye');

% Replacement face
justin = imread('justin_glasses.jpg');
bbox = step(faceDetector, justin);
justin_face = justin(bbox(1,2) + (1:bbox(1,3)),bbox(1,1) + (1:bbox(1,4)),:);
justin_noseBB = step(noseDetector,justin_face);
justin_mouthBB = step(mouthDetector,justin_face);
justin_leftEyeBB = step(leftEyeDetector,justin_face);
justin_rightEyeBB = step(rightEyeDetector,justin_face);

% Original image
%I = imread('visionteam.jpg');
I = imread('celebrity-couples-01082011-lead.jpg');
bboxes = step(faceDetector, I);
[num_faces,~] = size(bboxes);
face_face = cell(num_faces,1);
face_noseBB = cell(num_faces,1);
face_mouthBB = cell(num_faces,1);
face_leftEyeBB = cell(num_faces,1);
face_rightEyeBB = cell(num_faces,1);

% Display
figure(1)
subplot(1,num_faces+1,1)
imshow(I)

for ii = 1:num_faces
    face_face{ii} = I(bboxes(ii,2) + (1:bboxes(ii,3)),bboxes(ii,1) + (1:bboxes(ii,4)),:);
    face_noseBB{ii} = step(noseDetector,face_face{ii});
    face_mouthBB{ii} = step(mouthDetector,face_face{ii});
    face_leftEyeBB{ii} = step(leftEyeDetector,face_face{ii});
    face_rightEyeBB{ii} = step(rightEyeDetector,face_face{ii});
    
    subplot(1,num_faces+1,ii+1)
    %imshow(face_face{ii});
    %hold on
    %hold off
    toshow = face_face{ii};
    
    for jj = 1:size(face_noseBB{ii},1)
        toshow = insertObjectAnnotation(toshow,'rectangle',face_noseBB{ii}(jj,:),'Nose');
    end
    for jj = 1:size(face_mouthBB{ii},1)
        toshow = insertObjectAnnotation(toshow,'rectangle',face_mouthBB{ii}(jj,:),'Mouth');
    end
    for jj = 1:size(face_leftEyeBB{ii},1)
        toshow = insertObjectAnnotation(toshow,'rectangle',face_leftEyeBB{ii}(jj,:),'Eye L');
    end
    for jj = 1:size(face_rightEyeBB{ii},1)
        toshow = insertObjectAnnotation(toshow,'rectangle',face_rightEyeBB{ii}(jj,:),'Eye R');
    end
    
    imshow(toshow)
end

figure(2)
toshow = justin_face;

for ii = 1:size(justin_noseBB,1)
    toshow = insertObjectAnnotation(toshow,'rectangle',justin_noseBB(ii,:),'Nose');
end
for ii = 1:size(justin_mouthBB,1)
    toshow = insertObjectAnnotation(toshow,'rectangle',justin_mouthBB(ii,:),'Mouth');
end
for ii = 1:size(justin_leftEyeBB,1)
    toshow = insertObjectAnnotation(toshow,'rectangle',justin_leftEyeBB(ii,:),'Eye L');
end
for ii = 1:size(justin_rightEyeBB,1)
    toshow = insertObjectAnnotation(toshow,'rectangle',justin_rightEyeBB(ii,:),'Eye R');
end

imshow(toshow)


