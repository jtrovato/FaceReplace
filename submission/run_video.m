%run_replacement.m
% Run face_replace.m on every test set image

testdir = '../TestSet/';

im2 = imread('replacers/justin_glasses.jpg');

videoin = VideoReader('../TestSet/video/videoclip.avi');
framerate = videoin.frameRate;
frames = read(videoin);

numframes = size(frames,4);

output_frames = frames;

for ii = 1:numframes
    fprintf(['frame ',num2str(ii),': '])
    im1 = frames(:,:,:,ii);
    output_frames(:,:,:,ii) = face_replace(im1,im2);
end

videoout = VideoWriter('videoreplaced.avi');
set(videoout,'FrameRate',framerate)
open(videoout)
for ii = 1:numframes
    writeVideo(videoout,output_frames(:,:,:,ii));
end
close(videoout)