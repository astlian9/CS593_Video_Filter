function SaveVideo(frameRate, frameNum)
video_imagesPath = fullfile(pwd, 'filtered_videos');
if ~exist(video_imagesPath, 'dir')
    mkdir(video_imagesPath);
end
[FileName,PathName,FilterIndex] = uiputfile('*.*','save file as',...
          fullfile(pwd, 'filtered_videos/temp.mp4'));
if isequal(FileName, 0) || isequal(PathName, 0)
    return;
end
% outputAudioFile = fullfile(pwd, 'audio/audio.wav');
% [audioData, audio_sampleRate] = audioread(outputAudioFile);

fileStr = fullfile(PathName, FileName);
% 提取视频信息
vOut = VideoWriter(fileStr, 'MPEG-4');
vOut.FrameRate = frameRate;
open(vOut);
% 循环遍历每一帧
for k = 1:frameNum
    output_frame = imread(fullfile(pwd,['video_images/',num2str(k),'.jpg']));
    writeVideo(vOut, output_frame);
end
close(vOut);
% audiowrite(fileStr, audioData, audio_sampleRate);
msgbox('save video successful', 'inbox');