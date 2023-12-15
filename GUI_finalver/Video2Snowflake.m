function Video2Snowflake(videoFilePath)
    % Main function to add snowflakes to video
    clc;
    addSnowflakesToVideo(videoFilePath);
end

function addSnowflakesToVideo(videoFilePath)
    % Function to process video frames and add snowflakes
    xyloObj = VideoReader(videoFilePath);
    nFrames = xyloObj.NumberOfFrames;
    video_imagesPath = fullfile(pwd, 'video_images');
    if ~exist(video_imagesPath, 'dir')
        mkdir(video_imagesPath);
    end

    % Initialize snowflake parameters
    numSnowflakes = 100;
    snowflakePositions = initializeSnowflakes(numSnowflakes, xyloObj.Width, xyloObj.Height);
    fallSpeed = 2;

    h = waitbar(0, 'Adding Snowflakes to Frames...', 'Name', 'Processing Video...');
    for step = 1 : nFrames
        temp = read(xyloObj, step);
        temp_str = fullfile(video_imagesPath, [num2str(step),'.jpg']);

        % Update snowflake positions and draw them on the frame
        [temp, snowflakePositions] = updateSnowflakes(temp, snowflakePositions, fallSpeed);

        imwrite(temp, temp_str);
        pause(0.01);
        waitbar(step/nFrames, h, sprintf('Processed：%d%%', round(step/nFrames*100)));
    end
    close(h);
end

function positions = initializeSnowflakes(num, width, height)
    % Initialize snowflake positions randomly above the frame
    positions = [randi(width, num, 1), randi([-height 0], num, 1)];
end

function [frame, positions] = updateSnowflakes(frame, positions, speed)
    % Update snowflake positions and draw them on the frame

    % Update positions
    positions(:,2) = positions(:,2) + speed;

    % Draw snowflakes and reinitialize if they move out of the frame
    for i = 1:size(positions, 1)
        if positions(i,2) > size(frame, 1)
            positions(i,:) = [randi(size(frame, 2)), 0];
        else
            frame = placeSnowflake(frame, positions(i,1), positions(i,2));
        end
    end
end

function frame = placeSnowflake(frame, x, y)
    % Draw a simple snowflake pattern at position (x, y)

    pattern = [
        0 1 0;
        1 1 1;
        0 1 0
    ];

    % Get the size of the frame and the pattern
    [height, width, ~] = size(frame);
    [pHeight, pWidth] = size(pattern);

    % Place the pattern on the frame
    for i = 1:pHeight
        for j = 1:pWidth
            if pattern(i, j) == 1
                % Check boundaries
                posY = round(y - ceil(pHeight/2) + i);
                posX = round(x - ceil(pWidth/2) + j);
                if posY > 0 && posY <= height && posX > 0 && posX <= width
                    frame(posY, posX, :) = 255;
                end
            end
        end
    end
end
