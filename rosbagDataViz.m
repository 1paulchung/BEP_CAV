% Change the name to desired bag
bag = rosbag('test_2021-03-28-trial1.bag');
% Line below views information about a rosbag log file
% rosbag info 'test_2021-03-28-trial1.bag'
% Topics we want data from: 
% /synchronized_data 
% /tracking_data (contains only timestamps)

% Parse the rosbag to get syncedData
bSel = select(bag,'Topic','/synchronized_data');
msgStructs = readMessages(bSel,'DataFormat','struct');

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
    for j = 1:38
        % detection accesses the fields Dx, Dy, Vx, Vy
        detection = radarData.Detections(j);
        if detection.FlagValid   
            detVector = zeros(1,4);
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
% Max of i will be changed. Do not worry about for now. 
for i = 1:1
    if detection.FlagValid
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
end

% Parse the rosbags to gather timestamps
bSel2 = select(bag,'Topic','/tracking_data');
msgStructs2 = readMessages(bSel2,'DataFormat','struct');

% Timestamps holds the times in a vector
timestamps = zeros(size(syncedData, 2));

% Max of i is the number of columns in syncedData
for i = 1:size(syncedData,2)
    timestamps(i) = msgStructs2{i}.Timestamp;
end

















