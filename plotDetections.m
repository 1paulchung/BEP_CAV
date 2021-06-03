% Parses rosbag data and plots out the front radar detections from
% SYNCHRONIZED DATA; however, this implementation contains a lot of garbage
% data and is much more complicated. 

% Change the name to desired bag
testname = 'B15_2021-05-21.bag';
rosbag info 'B15_2021-05-21.bag'

bag = rosbag(testname);

bSel = select(bag,'Topic','/synchronized_data');
msgStructs = readMessages(bSel,'DataFormat','struct');

kRadarWeight = 1;
kMobileEyeWeight = 1;
% syncedData is a cell array which holds detections in format
% [x, y, x_vel, y_vel]
synchedData = {};


% Iterate through radar data and add it to the detections.
% i max is the number of synchronized_data msgs in the testname rosbag
for i = 1:size(msgStructs)
    struct = msgStructs{i};
    % The max is 1 because Radar(1) is referring to the front radar
    % 2 refers to right and 2 refers to left
    for j = 1:1
        % radarData contains all of the detections for one radar
        radarData = struct.Radar(j);
        % Max is 38 because max number of detections with given radar data
        for k = 1:38
            % detection accesses the fields Dx, Dy, Vx, Vy
            detection = radarData.Detections(k);
            if detection.FlagValid
                detVector = zeros(1, 4);        
                detVector(1) = detection.Dx;
                detVector(2) = detection.Dy;
                detVector(3) = detection.Vx;
                detVector(4) = detection.Vy;
                for w = 1:kRadarWeight
                    synchedData{end+1} = detVector;
                end
            end
        end 
    end
end

% Bird's Eye Plotting in real time
% Change the x and y limits accordingly 
bep = birdsEyePlot('XLimits', [-150, 150], 'YLimits', [-150, 150]);
detPlotter = detectionPlotter(bep);

% Regular speed is .1 sec and twice as fast is .05 sec and so on
playback = 0.1;
% To parse data from syncedData
% Max of for loop is the number of synchronized_data msgs for now, but
% I'm unsure why the size of syncedData is so large
for i = 1:size(msgStructs)
    sensorData = synchedData{i};
    position = [sensorData(1) sensorData(2)];
    velocity = [sensorData(3) sensorData(4)];
    plotDetection(detPlotter, position, velocity);
    pause(playback)
end









