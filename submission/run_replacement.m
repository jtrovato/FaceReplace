%run_replacement.m
% Run face_replace.m on every test set image

outputdir = 'output/'; %location to save output images

testdir = '../TestSet/'; %location of test images
folders = {'blending/','more/','pose/'};

im2 = imread('replacers/justin_glasses.jpg'); %replacer face


for ii = 1:length(folders)
    fprintf(['Replacing faces from test set "',folders{ii},'".\n'])
    testims = dir([testdir,folders{ii}]);

    for jj = 3:length(testims)
        filename = [testdir,folders{ii},testims(jj).name];
        if isempty(strfind(filename,'.jpg'))
            continue % not a .jpg file
        end
        fprintf(['file: ',testims(jj).name,'\n'])
        im1 = imread(filename);

        output = face_replace(im1,im2);
        imwrite(output,[outputdir,testims(jj).name]);
        %{
        fprintf('Replacement finished. Press any button to continue.\n\n')
        pause;
        %}
    end
end