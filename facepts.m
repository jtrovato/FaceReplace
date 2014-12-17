function [ctrlpts,face,component] = facepts(im)

index = 1;

% 1A: Face and component detectors
detectors.face = vision.CascadeObjectDetector();
detectors.nose = vision.CascadeObjectDetector('Nose');
detectors.mout = vision.CascadeObjectDetector('Mouth');
detectors.eyeL = vision.CascadeObjectDetector('LeftEye');
detectors.eyeR = vision.CascadeObjectDetector('RightEye');

% 2A: Detect Face
bbox = step(detectors.face, im);
bbox = bbox(index,:);
face.pos = bbox([1,2]);
face.im = im(bbox(2) + (1:bbox(3)),bbox(1) + (1:bbox(4)),:);

% 2B: Detect Components
face.nose = step(detectors.nose,face.im);
face.mout = step(detectors.mout,face.im);
face.eyeL = step(detectors.eyeL,face.im);
face.eyeR = step(detectors.eyeR,face.im);

% 2B: Centroids
centroids.nose = [face.nose(:,1) + 0.5*face.nose(:,3), face.nose(:,2) + 0.5*face.nose(:,4)];
centroids.mout = [face.mout(:,1) + 0.5*face.mout(:,3), face.mout(:,2) + 0.5*face.mout(:,4)];
centroids.eyeL = [face.eyeL(:,1) + 0.5*face.eyeL(:,3), face.eyeL(:,2) + 0.5*face.eyeL(:,4)];
centroids.eyeR = [face.eyeR(:,1) + 0.5*face.eyeR(:,3), face.eyeR(:,2) + 0.5*face.eyeR(:,4)];

num_nose = size(centroids.nose,1);
num_mout = size(centroids.mout,1);
num_eyeL = size(centroids.eyeL,1);
num_eyeR = size(centroids.eyeR,1);

disp([num_nose,num_mout,num_eyeL,num_eyeR])
if any(~[num_nose,num_mout,num_eyeL,num_eyeR])
    figure(2)
    subplot(2,1,1)
    imshow(face_image)
    subplot(2,1,2)
    imshow(face.im)
    disp('could not find')
    return
end

% 2B: Select components
scores = zeros(num_nose,num_mout,num_eyeL,num_eyeR);
for nn = 1:num_nose
    for mm = 1:num_mout
        for ll = 1:num_eyeL
            for rr = 1:num_eyeR
                n = centroids.nose(nn,:);
                m = centroids.mout(mm,:);
                l = centroids.eyeL(ll,:);
                r = centroids.eyeR(rr,:);
                
                % Distances
                nm = norm(n-m);
                nl = norm(n-l);
                nr = norm(n-r);
                ml = norm(m-l);
                mr = norm(m-r);
                lr = norm(l-r);
                
                scale = mean([nm,nl,nr,ml,mr,lr]);
                
                nms = nm/scale;
                nls = nl/scale;
                nrs = nr/scale;
                mls = ml/scale;
                mrs = mr/scale;
                lrs = lr/scale;
                
                % Face handedness (left/right eyes)
                angle = cross([n-l,0]/scale,[n-r,0]/scale);
                angle_cost = angle(3) > 0;
                
                scores(nn,mm,ll,rr) = abs(nms-0.5) + abs(nls-1) + abs(nrs-1) + ...
                    abs(mls-1.25) + abs(mrs-1.25) + abs(lrs-1) + 10*angle_cost;
                
            end
        end
    end
end

[min_score, min_ind] = min(scores(:));
min_ind = min_ind(1);
[nn,mm,ll,rr] = ind2sub([num_nose,num_mout,num_eyeL,num_eyeR],min_ind);

component.nose = face.nose(nn,:);
component.mout = face.mout(mm,:) + ...
    [-0.1*face.mout(mm,3),-0.2*face.mout(mm,4),0.2*face.mout(mm,3),0.2*face.mout(mm,4)];
component.eyeL = face.eyeL(ll,:) + ...
    [-0.2*face.eyeL(ll,3),-0.6*face.eyeL(ll,4),0.2*face.eyeL(ll,3),0.6*face.eyeL(ll,4)];
component.eyeR = face.eyeR(rr,:) + ...
    [0,-0.6*face.eyeR(rr,4),0.2*face.eyeR(rr,3),0.6*face.eyeR(rr,4)];

% 2C: 

% 2D: Control points
nose = centroids.nose(nn,:);
eyeL = centroids.eyeL(ll,:);
eyeR = centroids.eyeR(rr,:);
mout = centroids.mout(mm,:);

ctrlpts = [nose;mout;eyeL;eyeR];