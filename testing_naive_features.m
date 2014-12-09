addpath 'SampleSet/easy/'
addpath 'SampleSet/hard/'
addpath 'SampleSet/us/'

faceDetector = vision.CascadeObjectDetector();

%I = imread('visionteam.jpg');
I = imread('celebrity-couples-01082011-lead.jpg');

justin = imread('justin_glasses.jpg');
bbox = step(faceDetector, justin);
justin_face = justin(bbox(1,2) + (1:bbox(1,3)),bbox(1,1) + (1:bbox(1,4)),:);
justin_corners = corner(rgb2gray(justin_face),'QualityLevel',0.001);
[justin_features, justin_corners] = extractHOGFeatures(justin,justin_corners,'CellSize',[16,16]);

bboxes = step(faceDetector, I);

[num_faces,~] = size(bboxes);
face_subblock = cell(num_faces,1);
face_corners = cell(num_faces,1);
face_features = cell(num_faces,1);

face_matches = cell(num_faces,1);

figure(1)
subplot(1,num_faces+1,1)
imshow(I)

for ii = 1:num_faces
    face_subblock{ii} = I(bboxes(ii,2) + (1:bboxes(ii,3)),bboxes(ii,1) + (1:bboxes(ii,4)),:);
    face_corners{ii} = corner(rgb2gray(face_subblock{ii}),'QualityLevel',0.001);
    [face_features{ii}, face_corners{ii}] = extractHOGFeatures(face_subblock{ii},face_corners{ii},'CellSize',[16,16]);
    
    face_matches{ii} = matchFeatures(face_features{ii},justin_features,...
        'MaxRatio',0.8,'MatchThreshold',50.0);
    disp(face_matches{ii})
    
    subplot(1,num_faces+1,ii+1)
    imshow(face_subblock{ii});
    hold on
    plot(face_corners{ii}(:,1),face_corners{ii}(:,2),'+g');
    hold off
end



figure(2)
for ii = 1:num_faces
    subplot(num_faces,1,ii)
    width = size(justin_face,2);
    scaling = size(justin_face,1)/size(face_subblock{ii},1);
    concat_faces = [justin_face,imresize(face_subblock{ii},scaling)];
    imshow(concat_faces);
    hold on
    justin_matched = justin_corners(face_matches{ii}(:,2),:);
    face_matched = face_corners{ii}(face_matches{ii}(:,1),:);
    for jj = 1:size(face_matches{ii},1)
        plot([justin_matched(jj,1),face_matched(jj,1)*scaling+width],...
              [justin_matched(jj,2),face_matched(jj,2)*scaling],'g')
    end
end


