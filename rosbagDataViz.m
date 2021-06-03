% Parse rosbag and store information into syncedData, 
% which contains information from radar detections. 
% SyncedData is visualized using MATLAB's Bird's-Eye Plotting. 
% This implementation is incorrect. 

% Change the name to desired bag
testname = 'A25-2021-5-23.bag';

bag = rosbag(testname);
% Line below views information about a rosbag log file
% rosbag info 'test_2021-03-28-trial1.bag'
% Topics we want data from: 
% /synchronized_data 
% /tracking_data (contains only timestamps)

bSel = select(bag,'Topic','/synchronized_data');
msgStructs = readMessages(bSel,'DataFormat','struct');
% Checks the number of num obs per struct
% check = msgStructs2{1}.Camera.NumObs

kRadarWeight = 1;
kMobileEyeWeight = 1;
% syncedData is a cell array which holds detections in format
% [x, y, x_vel, y_vel]
syncedData = {};

% Iterate through radar data and add it to the detections.
% NOTE: update max i to 4 once rear radar is implemented
for i = 1:1
    % radarData contains all of the detections for one radar
    radarData = msgStructs{i}.Radar(i);
    % Max is 38 because max number of detections with given radar data
    for j = 1:38
        % detection accesses the fields Dx, Dy, Vx, Vy
        detection = radarData.Detections(j);
        if detection.FlagValid
            detVector = zeros(1, 4);        
            detVector(1) = detection.Dx;
            detVector(2) = detection.Dy;
            detVector(3) = detection.Vx;
            detVector(4) = detection.Vy;
            for m = 1:kRadarWeight
                syncedData{end+1} = detVector;
            end
        end
    end   
end

% Iterates through the mobile eye data and add it to the detections
% Unsure of how to get numObs for each struct
for i = 1:1
    detection = msgStructs{1}.Camera.ObstacleData(i);
    detVector = zeros(1,4);
    detVector(1) = detection.ObsPosX;
    detVector(2) = detection.ObsPosY;
    detVector(3) = detection.ObsRelVelX;
    detVector(4) = 0.0; % placeholder for y velocity
    for j = 1:kMobileEyeWeight
       syncedData{end+1} = detVector;
    end
end

bSel2 = select(bag,'Topic','/tracking_data');
msgStructs2 = readMessages(bSel2,'DataFormat','struct');

% Timestamps holds the times in a vector
timestamps = zeros(size(syncedData, 2));

% Max of i is the number of columns in syncedData
for i = 1:size(syncedData,2)
    timestamps(i) = msgStructs2{i}.Timestamp;
end

% Bird's Eye Plotting in real time
bep = birdsEyePlot('XLimits', [-500, 500], 'YLimits', [-500, 500]);
detPlotter = detectionPlotter(bep);

% Regular speed is .1 sec and twice as fast is .05 sec and so on
playback = 0.1;
% To parse data from syncedData
% Max of for loop is the number of vectors within syncedData
for i = 1:size(syncedData,2)
    sensorData = syncedData{i};
    position = [sensorData(1) sensorData(2)];
    velocity = [sensorData(3) sensorData(4)];
    plotDetection(detPlotter, position, velocity);
    pause(playback)
end




%url = 'https://www.youtube.com/watch?v=5qap5aO4i9A'
%web(url)













