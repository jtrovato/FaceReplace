CIS581 - Computer Vision and Computational Photography
Final Project
Joe Trovato and Justin Yim

Summary: open matlab. In face-release1.0-basic, run complie.m for specific operating system. run run_replacement for image replacement. run run_video for video replacement. 

Detailed: 

first the image recognition software must be compiled. To compile the software, set up mex, then run compile.m in face-release1.0-basic with options for your specific operating system. 

The code has a few scripts required to achieve face replacement. run_replacement.m runs the face_replace.m script on the test set images. The face_replace.m script makes calls to the face-release library to detect faces in both target and source images. This is third party software used to recognize faces and to collect control points that can then be passed to morph.m. morph.m is a slightly modified version of the trianglulation morph in project 2. If the program is able to replace a face in the destiantion image with the specified source face the program displays the final image, otherwise an error is returned and the program skips to the next image. 

Finally, run run_video to run the video face replace script on the test video given.