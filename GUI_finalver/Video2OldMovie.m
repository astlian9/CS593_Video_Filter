function Video2OldMovie(videoFilePath)
    clc;
    ProcessVideo(videoFilePath);

    function ProcessVideo(videoFilePath)
        xyloObj = VideoReader(videoFilePath);
        nFrames = xyloObj.NumberOfFrames;
        video_imagesPath = fullfile(pwd, 'video_images');
        if ~exist(video_imagesPath, 'dir')
            mkdir(video_imagesPath);
        end

        h = waitbar(0, '', 'Name', 'Applying Old Movie Filter...');
        for step = 1 : nFrames
            temp = read(xyloObj, step);
            temp_str = fullfile(video_imagesPath, [num2str(step),'.jpg']);

            % Convert to grayscale
            grayFrame = rgb2gray(temp);

            % Desaturate the image (adjust intensity)
            desaturatedFrame = imadjust(grayFrame, [], [], 0.5);

            % Add sepia tone
            sepiaFrame = uint8(double(desaturatedFrame) .* cat(3, 1.0, 0.8, 0.6));

            % Add noise
            noisyFrame = imnoise(sepiaFrame, 'gaussian', 0, 0.005);

            % Sharpen the image
            sharpenedFrame = imsharpen(noisyFrame);

            % Write the frame
            imwrite(sharpenedFrame, temp_str);
            pause(0.01);
            waitbar(step/nFrames, h, sprintf('Processed：%d%%', round(step/nFrames*100)));
        end
        close(h)
    end
end
