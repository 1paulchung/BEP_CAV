# Data Visualization of Rosbags

This repo is for my research project. I am creating a real-time bird's-eye plot of rosbags from vehicle testing. Rosbags include sensor data and sensor fusion results. Another research team collects the rosbags from real-world tests (i.e. Vehicle travels 25 m/s 10 m behind a car going 25 m/s). I parse /synchronized_data, which includes four radars (front, right, left , rear) and one camera, from the rosbags then visualize the data in real time. However, parsing /synchronized_data proves uneffecive because there is a lot of "garbage" data that results in scattered and repeated data. Each detection is displayed every 100 ms and is composed of two parts- a circle and a line. A single circle represents the x-position and y-position and the line represents the x-velocity and y-velocity.   

![Hnet-image (1)](https://user-images.githubusercontent.com/72935428/120573567-a42ea180-c3d2-11eb-82e5-77386dc8d25e.gif)

Thus, I rather parse data from /cam_det_data, which only includes the vehicle's camera. This results in a much cleaner real-time bird's eye plot. 

![Hnet-image (2)](https://user-images.githubusercontent.com/72935428/120573928-3afb5e00-c3d3-11eb-8811-cd626b1fc757.gif)

In future projects, I plan to implement real-time plotting for the vehicle's four radars. 

I implemented the option to play different types of detections, playback speed, and bird's-eye plot dimensions. 
![image](https://user-images.githubusercontent.com/72935428/120873993-4ed0cc80-c559-11eb-8351-2aa6bfece8aa.png)



