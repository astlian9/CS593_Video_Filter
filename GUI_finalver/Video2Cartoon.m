function Video2Cartoon(videoFilePath)
clc;
nFrames = GetVideoCartoon(videoFilePath);

function nFrames = GetVideoCartoon(videoFilePath)
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
    frame = imresize(temp, 0.5);
    grayFrame = rgb2gray(frame);
    edges = edge(grayFrame, 'Canny',[0.07,0.2]);

    % Remove noise and details
    w = fspecial('gaussian',[7 7],7);
    frame = imfilter(frame, w);

    % Reduce the color palette
    [indices, map] = rgb2ind(frame, 8); % Reducing colors to 8
    colorReducedFrame = ind2rgb(indices, map);

    % Combine edges and color-reduced frame
    edges = repmat(edges, [1 1 3]); % Convert edges to 3-channel image
    cartoonFrame = colorReducedFrame;
    cartoonFrame(edges) = 0; % Adding edges to the color-reduced frame

    imwrite(cartoonFrame, temp_str);
    pause(0.01);
    waitbar(step/steps, h, sprintf('Processed：%d%%', round(step/nFrames*100)));
end
close(h)