CIS581 - Computer Vision and Computational Photography
Final Project
Joe Trovato and Justin Yim

Summary: Open matlab. From face-release1.0-basic, run compile.m. From the base directory, run run_replacement for image replacement. run run_video for video replacement. 

Detailed: 

First the third party face recognition library mex files must be compiled. To compile the software, set up mex, then run compile.m in face-release1.0-basic selecting one of the three fconv options at the bottom of the file. The included mex files were compiled for Matlab 2014a on Ubuntu 12.04.

The code has a few scripts required to achieve face replacement. run_replacement.m and run_video.m call the face_replace.m function on the test set images. The face_replace.m function uses the built in cascade object detector to detect faces in the source and destination images. It also makes use of the face-release library to determine orientation of faces in both target and source images. This is third party software used to collect control points that can then be passed to morph.m. morph.m is a slightly modified version of the trianglulation morph in project 2. If the program is able to replace a face in the destination image with the specified source face, the program displays the final image and returns the new image with the replaced face, otherwise the unmodified destination image is returned. The program will attempt to replace every face it finds in the destination image with the face from the source image.

run_replacement and run_video are the wrapper scripts that run face replacement and save the results to a directory.
