% Parses rosbag data and plots out the detections from the vehicle's
% camera.
% Link to the videos of the trials from 5/23/21
% https://drive.google.com/drive/u/0/folders/1-XZBVAryCgdyee2YG5mZtXdyyugeyW8p

% Change the name to desired bag
testname = 'B25-2021-5-23_processed.bag';

bag = rosbag(testname);

bSel = select(bag,'Topic','/cam_det_data');
msgStructs = readMessages(bSel,'DataFormat','struct');

% msgStructs only has one column and rows dependent on rosbag
% Label it as columns for synchedData
columns = size(msgStructs, 1);

% Preallocate space for cell array
synchedData = cell(1, columns);

for i = 1:size(msgStructs)
        % Detection is a 3 x 1 cell array with 'MessageType', 'Tracks', and
        % 'Timestamp'
        struct = msgStructs{i};
        % struct.Tracks is a 6 x 1 cell array with fields 'MessageType',
        % 'TrackId', 'Dx', 'Vx', 'Dy', and 'Vy'
        % len checks to see if Tracks has information in it
        len = size(struct.Tracks, 2);
        detVector = zeros(1,4);
        if len > 0
            % detVector holds the [Dx, Dy, Vx, Vy] information 
            detVector(1) = struct.Tracks.Dx;
            detVector(2) = struct.Tracks.Dy;
            detVector(3) = struct.Tracks.Vx;
            detVector(4) = struct.Tracks.Vy;
        else 
            detVector(1) = 0;
            detVector(2) = 0;
            detVector(3) = 0;
            detVector(4) = 0;
        end
        synchedData{i} = detVector;
end

% Bird's Eye Plotting in real time
bep = birdsEyePlot('XLimits', [-5, 140], 'YLimits', [-15, 15]);
detPlotter = detectionPlotter(bep);

% Regular speed is .1 sec and twice as fast is .05 sec and so on
playback = 0.1;
% To parse data from syncedData
% Max of for loop is the number of vectors within syncedData
for i = 1:size(synchedData,2)
    sensorData = synchedData{i};
    position = [sensorData(1) sensorData(2)];
    velocity = [sensorData(3) sensorData(4)];
    plotDetection(detPlotter, position, velocity);
    pause(playback)
end






