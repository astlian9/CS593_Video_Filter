function Video2Images(videoFilePath)
clc;
nFrames = GetVideoImgList(videoFilePath);

function nFrames = GetVideoImgList(videoFilePath)
xyloObj = VideoReader(videoFilePath);
nFrames = xyloObj.NumberOfFrames;
video_imagesPath = fullfile(pwd, 'video_images');
rmdir(video_imagesPath, 's');
% audio_imagesPath = fullfile(pwd, 'audio/audio.wav');
% [audioData,audio_samplerate] = audioread(videoFilePath);
% audiowrite(audio_imagesPath, audioData, audio_samplerate);
if ~exist(video_imagesPath, 'dir')
    mkdir(video_imagesPath);
end
% files = dir(fullfile(video_imagesPath, '*.jpg'));
% if length(files) == nFrames
%     return;
% end
h = waitbar(0, '', 'Name', 'getting frames from video...');
steps = nFrames;
for step = 1 : nFrames
    temp = read(xyloObj, step);
    temp_str = fullfile(video_imagesPath, [num2str(step),'.jpg']);
    imwrite(temp, temp_str);
    pause(0.01);
    waitbar(step/steps, h, sprintf('processed%d%%', round(step/nFrames*100)));
end
close(h)