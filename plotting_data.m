% Parses rosbag data and plots /tracking_data, /cam_det_data, and
% /front_det_data. 

% Settings:
% Choose to which detections to play
play_tracking_data = true;
play_cam_det_data = true;
play_front_det_data = true;
% Regular speed is .1 sec and twice as fast is .05 sec and so on
playback = 0.1;
% Determines the dimensions for the bird's-eye plot
xmin = -5;
xmax = 140;
ymin = -15;
ymax = 15;

% Change name to desired MP4 to play
vid_name = 'B25-2021-5-23.mp4';

% Change the name to desired bag
testname = 'B25-2021-5-23_processed.bag';

bag = rosbag(testname);

% Finding tracking data dectections
bSel = select(bag,'Topic','/tracking_data');
msgStructs = readMessages(bSel,'DataFormat','struct');

% msgStructs only has one column and rows dependent on rosbag
columns = size(msgStructs, 1);

% Preallocate space for cell array
trackingData = cell(1, columns);

for i = 1:size(msgStructs)
        % Detection is a 3 x 1 cell array with 'MessageType', 'Tracks', and
        % 'Timestamp'
        struct = msgStructs{i};
        % struct.Tracks is a 6 x 1 cell array with fields 'MessageType',
        % 'TrackId', 'Dx', 'Vx', 'Dy', and 'Vy'
        % len checks to see if Tracks has information in it
        len = size(struct.Tracks, 2);
        trackingDet = zeros(1,4);
        if len > 0
            % detVector holds the [Dx, Dy, Vx, Vy] information 
            trackingDet(1) = struct.Tracks.Dx;
            trackingDet(2) = struct.Tracks.Dy;
            trackingDet(3) = struct.Tracks.Vx;
            trackingDet(4) = struct.Tracks.Vy;
        else 
            trackingDet(1) = 0;
            trackingDet(2) = 0;
            trackingDet(3) = 0;
            trackingDet(4) = 0;
        end
        trackingData{i} = trackingDet;
end

% Finding camera detections
bSel2 = select(bag,'Topic','/cam_det_data');
msgStructs2 = readMessages(bSel2,'DataFormat','struct');

% msgStructs only has one column and rows dependent on rosbag
% Label it as columns for synchedData
columns2 = size(msgStructs2, 1);

% Preallocate space for cell array
camData = cell(1, columns2);

for i = 1:size(msgStructs2)
        % Detection is a 3 x 1 cell array with 'MessageType', 'Tracks', and
        % 'Timestamp'
        struct = msgStructs2{i};
        % struct.Tracks is a 6 x 1 cell array with fields 'MessageType',
        % 'TrackId', 'Dx', 'Vx', 'Dy', and 'Vy'
        % len checks to see if Tracks has information in it
        len = size(struct.Tracks, 2);
        cameraDet = zeros(1,4);
        if len > 0
            % cameraDet holds the [Dx, Dy, Vx, Vy] information 
            cameraDet(1) = struct.Tracks.Dx;
            cameraDet(2) = struct.Tracks.Dy;
            cameraDet(3) = struct.Tracks.Vx;
            cameraDet(4) = struct.Tracks.Vy;
        else 
            cameraDet(1) = 0;
            cameraDet(2) = 0;
            cameraDet(3) = 0;
            cameraDet(4) = 0;
        end
        camData{i} = cameraDet;
end 


% Finding front detections
bSel3 = select(bag,'Topic','/front_det_data');
msgStructs3 = readMessages(bSel3,'DataFormat','struct');

% msgStructs only has one column and rows dependent on rosbag
% Label it as columns for synchedData
columns3 = size(msgStructs3, 1);

% Preallocate space for cell array
frontData = cell(1, columns3);

for i = 1:size(msgStructs3)
        % Detection is a 3 x 1 cell array with 'MessageType', 'Tracks', and
        % 'Timestamp'
        struct = msgStructs3{i};
        % struct.Tracks is a 6 x 1 cell array with fields 'MessageType',
        % 'TrackId', 'Dx', 'Vx', 'Dy', and 'Vy'
        % len checks to see if Tracks has information in it
        len = size(struct.Tracks, 2);
        frontDet = zeros(1,4);
        if len > 0
            % frontDet holds the [Dx, Dy, Vx, Vy] information 
            frontDet(1) = struct.Tracks.Dx;
            frontDet(2) = struct.Tracks.Dy;
            frontDet(3) = struct.Tracks.Vx;
            frontDet(4) = struct.Tracks.Vy;
        else 
            frontDet(1) = 0;
            frontDet(2) = 0;
            frontDet(3) = 0;
            frontDet(4) = 0;
        end
        frontData{i} = frontDet;
end


% Bird's Eye Plotting in real time
bep = birdsEyePlot('XLimits', [xmin, xmax], 'YLimits', [ymin, ymax]);

detPlotter = detectionPlotter(bep, 'DisplayName', 'Tracking Data', 'MarkerFaceColor', 'b');
detPlotter2 = detectionPlotter(bep, 'DisplayName', 'Camera Data', 'MarkerFaceColor', 'r');
detPlotter3 = detectionPlotter(bep, 'DisplayName', 'Front Radar Data', 'MarkerFaceColor', 'g');

% Play video side by side with BEP
% handle = implay(vid_name);
% handle.Parent.Position = [100 100 700 550];
% h = findall(0, 'tag', 'spcui_scope_framework');
% set(h, 'position', [150 150 700 550]);
% play(handle.DataSource.Controls);

% Using VideoReader to get frames
vid = VideoReader(vid_name);
numFrames = ceil(vid.FrameRate * vid.Duration);
frameInterval = ceil(numFrames / size(msgStructs, 1));
vid.currentTime = 0;

% Create a new figure for video
figure;
ax = axes;

% Plots data from parsed data
for i = 1:size(msgStructs)
    % Collecting tracking data to plot
    t_data = trackingData{i};
    position_tracking = [t_data(1) t_data(2)];
    velocity_tracking = [t_data(3) t_data(4)];
    % Collecting camera data to plot
    cam_data = camData{i};
    position_cam = [cam_data(1) cam_data(2)];
    velocity_cam = [cam_data(3) cam_data(4)];
    % Collecting front data to plot
    front_data = frontData{i};
    position_front = [front_data(1) front_data(2)];
    velocity_front = [front_data(3) front_data(4)];
    % Plots detections on one plot
    if play_tracking_data
        plotDetection(detPlotter, position_tracking, velocity_tracking);
    end
    if play_cam_det_data
        plotDetection(detPlotter2, position_cam, velocity_cam);
    end
    if play_front_det_data
        plotDetection(detPlotter3, position_front, velocity_front);
    end
    % Synchronize video with BEP
    for j = 1:frameInterval
        if vid.hasFrame()
            temp = vid.readFrame();
            imshow(temp,'Parent',ax);
            % pause(1.0/vid.FrameRate);
        end 
    end
    pause(playback)
end







