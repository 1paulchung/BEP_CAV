% Below is the code to do bird's eye view of rosbag data
% bep = birdsEyePlot('XLimits', [0 100], 'YLimits', [-50, 50]);
% detPlotter = detectionPlotter(bep);
% testData = dlmread('trial1_test.txt');
% positions = testData(:,[2,3]);
% velocities = testData(:,[4,5]);
% Displays detections and their labels on a bird's-eye plot
% plotDetection(detPlotter, positions, velocities);

bag = rosbag('test_2021-03-28-trial1.bag');
% Line below views information about a rosbag log file
% rosbag info 'test_2021-03-28-trial1.bag'
% Topics: /synchronized_data and /tracking_data (contains only timestamps)
bSel = select(bag,'Topic','/tracking_data');
msgStructs = readMessages(bSel,'DataFormat','struct');
ans = msgStructs{1};
time = ans.Timestamp

bSel2 = select(bag,'Topic','/synchronized_data');
msgStructs2 = readMessages(bSel2,'DataFormat','struct');
ans2 = msgStructs2{1};
% check = ans2.Camera.ObstacleData.ObsPosX
% accesses the detections
check = ans2.Radar.Detections



for i = 1:1
    % radarData contains all of the detections for one radar
    radarData = msgStructs2{i}.Radar(i);
    for j = 1:2
        detVector = zeros(1, 4);        
        detection = radarData.Detections(j);
        detVector(1) = detection.Dx;
        detVector(2) = detection.Dy;
        detVector(3) = detection.Vx;
        detVector(4) = detection.Vy;
    end   
end

    









