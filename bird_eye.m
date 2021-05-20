% Below is the code to do bird's eye view of rosbag data
% bep = birdsEyePlot('XLimits', [0 100], 'YLimits', [-50, 50]);
% detPlotter = detectionPlotter(bep);
% testData = dlmread('trial1_test.txt');
% positions = testData(:,[2,3]);
% velocities = testData(:,[4,5]);
% Displays detections and their labels on a bird's-eye plot
% plotDetection(detPlotter, positions, velocities);

% Change the name to desired bag
bag = rosbag('test_2021-03-28-trial1.bag');
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


x =[];
y = [];
x_vel = [];
y_vel = [];
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
            %x(end+1) = detection.Dx;
            detVector(2) = detection.Dy;
            %y(end+1) = detection.Dy;
            detVector(3) = detection.Vx;
            %x_vel(end+1) = detection.Vx;
            detVector(4) = detection.Vy;
            %y_vel(end+1) = detection.Vy;
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
timestamps = [];

% Max is number of columns in syncedData
for i = 1:size(syncedData,2)
    timestamps(end+1) = msgStructs2{i}.Timestamp;
end


bep = birdsEyePlot('XLimits', [-1000, 1000], 'YLimits', [-500, 500]);
detPlotter = detectionPlotter(bep);


% Dimension's first element is syncedData # of rows and second
% element is # of columns
dimensions = size(syncedData);
% To parse data from syncedData
% Max of for loop is the number of vectors within syncedData
for i = 1:dimensions(2)
    sensorData = syncedData{i};
    x = sensorData(1);
    y = sensorData(2);
    x_vel = sensorData(3);
    y_vel = sensorData(4);
    plotDetection(detPlotter, transpose([x;y]), transpose([x_vel;y_vel]))
    pause(.1)
end

% Test to see if iteration went well
positions = [x;y];
positions2 = transpose(positions);
velocities = [x_vel;y_vel];
velocities2 = transpose(velocities);


% Displays detections and their labels on a bird's-eye plot

%plot(detVector)

% Displays the very last plot... not sure how to plot each iteration
%for i = 1:size(xcoord)
    %xcoord = x(i)
    %ycoord = y(i)
    %positions3 = transpose([xcoord; ycoord])
    %xvel = x_vel(i)
    %yvel = y_vel(i)
    %velocities3 = transpose([xvel; yvel])
    %plotDetection(detPlotter, positions3, velocities3);
%end














