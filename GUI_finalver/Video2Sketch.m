function Video2Sketch(videoFilePath)
clc;
nFrames = GetVideoSketch(videoFilePath);

function nFrames = GetVideoSketch(videoFilePath)
xyloObj = VideoReader(videoFilePath);
nFrames = xyloObj.NumberOfFrames;
video_imagesPath = fullfile(pwd, 'video_images');
if ~exist(video_imagesPath, 'dir')
    mkdir(video_imagesPath);
end
% files = dir(fullfile(video_imagesPath, '*.jpg'));
% if length(files) == nFrames
%     return;
% end
h = waitbar(0, '', 'Name', 'Getting Frames From Video...');
steps = nFrames;
for step = 1 : nFrames
    temp = read(xyloObj, step);
    temp_str = fullfile(video_imagesPath, [num2str(step),'.jpg']);
    % Convert to grayscale and detect edges
    gray = rgb2gray(temp);
    sobel = [0,0,0; 1,1,1; 0,0,0];
    e = edge(gray);
    gray= gray +  uint8(e) * 255;
    reversed = 255 - gray;
    w = fspecial('gaussian',[5 5],5);
    reversed_filtered = imfilter(reversed,w);
    sketch_frame = uint8(min(uint16(gray) + (uint16(gray).*uint16(reversed_filtered)) ./ (255 - uint16(reversed_filtered)),255));

    imwrite(sketch_frame, temp_str);
    pause(0.01);
    waitbar(step/steps, h, sprintf('Processed：%d%%', round(step/nFrames*100)));
end
close(h)