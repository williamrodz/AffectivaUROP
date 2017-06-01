## Instructions

There are three files:
- An Xcode project file named AffectivaUROP . The is the core of the Affectiva SDK and is coded in Objective-C. I made edits in the AffdexMeViewController.m file to write into a text file that stores the emotion metrics into a txt file. 

- A txt file named  emotionJSON.txt . This file stores a JSON list of dictionaries, where each dictionary represents one detected face with values corresponding to analyzed emotion data for that face. 

- A Python file named emotionJSONDataParser.py . This file parses the emotionJSON.txt file and let's you work with the emotion data in Python.

This is how you get it to work:

1) Launch the Xcode project by opening the AffdexMe.xcworkspace file within the project folder. Then hit the play button at the top-left to start the application that will capture emotion data from the faces detected in the camera. This will create the emotionJSON.txt file in the ~/Library/Containers/com.affectiva.AffdexMeOSX/Data/ directory. It will actively update as long as the application is running, at rate of 5 frames per second. It's very fluid and this is the recommended frame rate by the original developers. I've documented the edits I made in the Xcode project in the AffdexMeViewController.m file

2)  Place the emotionJSONDataParser.py file in the ~/Library/Containers/com.affectiva.AffdexMeOSX/Data/ directory. In this same directory, you should see the emotionJSON.txt file if you have run the Xcode application at least once. 

3) Run the emotionJSONDataParser.py python file. Right now it is set to continuously print out average emotion data for all emotions the Affectiva SDK can analyze. This includes 'anger', 'contempt', 'disgust', 'engagement', 'fear', 'joy', 'sadness', 'surprise', and 'valence'. However, there is much more data that the SDK can give out. I've documented this in this python file.

## Contributors

Affectiva, inc
William A. Rodriguez, MIT '18, william.a@mit.edu
under supervision of Dr. Ognjen (Oggi) Rudovic

## License

MIT License# AffectivaUROP
