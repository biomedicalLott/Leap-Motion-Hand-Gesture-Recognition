# Leap-Motion-Hand-Gesture-Recognition
An app I was designing that allows leap motion to speak to Matlab and Matlab sends commands to Blender. This was ideally to be used to create an AR interface for controlling mesh manipulation in real time 3D. It somewhat works, but is convoluted at the moment to make room for a classifier my teammate was designing in Matlab. In the future I plan to make this functional should I find the time to work on it, I think this project was very promising and we were doing very well with the time that was given. 

finalProjectApp.m is in /Matlab App/
leapProject1.exe is in /Unity Leap Motion App/


1. Install Ultraleap SDK
2. Plug in Leap Motion Controller
3. Make Sure Leap Motion Controller has infrared lights on
4. run finalProjectApp.m
5. Click "Start Receive Data"
6. Run leapProject1.exe
	a. If you have Leap Motion Visualizer, set to Desktop Mode
7. Click "Turn On TCP" to activate server
	a. Green = Connected to finalProjectApp
	b. Red = Disconnected
	c. You can disconnect at any time by pressing "Turn Off TCP"
8. Wave hands back and forth to see if it picks you up
9. If it works, you may not see very much, 
	a. Classification is spotty
	b. The plot randomly erases
10. To enter Create mode draw a circle with your right hand 
	a. Confirm by flattening your right palm such that all digits are extended on the right hand for 3 seconds
11. Draw a Circle, Square, or Triangle to draw a geometric shape, using your right hand.
	a. Flatten hand to send data to be processed
12. Draw one of the Base Operations to enter their respective mode. 
13. During a Base Operations mode the tip of your index finger of your right hand will be tracked 
14. At any time during Base Operations Mode you made return to Neutral state by flattening your palm once more

