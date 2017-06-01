# Coded by William A. Rodriguez, MIT '18
# for UROP Project with Dr. Ognjen (Oggi) Rudovic

# ast is a module that allows to parse strings directy into
# python objects. Here's it used to parse a list of dictionaries
import ast

# Place this python file in the same folder that the emotionJSON.txt is in
fileName = "emotionJSON.txt"
file_object  = open(fileName, 'r')
jsonString = file_object.read()
file_object.close()


# Each face dictionary is a dictionary of dictionaries
listOfFaceDictionaries = ast.literal_eval(jsonString)

def updateFaceData():
	file_object  = open(fileName, 'r')
	jsonString = file_object.read()
	file_object.close()
	istOfFaceDictionaries = ast.literal_eval(jsonString)



def getAverageEmotion(emotion):
	sumOfEmotionValues = 0
	for face in listOfFaceDictionaries:
		emotionLevel = float(face["emotions"][emotion])
		sumOfEmotionValues +=emotionLevel
	return sumOfEmotionValues/numberOfDetectedFaces


while True:
	# Average data points
	updateFaceData()
	## Emotions
	numberOfDetectedFaces = len(listOfFaceDictionaries)
	averageAnger = getAverageEmotion("anger")
	averageContempt = getAverageEmotion("contempt")
	averageDisgust = getAverageEmotion("disgust")
	averageEngagement = getAverageEmotion("engagement")
	averageFear = getAverageEmotion("fear")
	averageJoy = getAverageEmotion("joy")
	averageSadness = getAverageEmotion("sadness")
	averageSurprise = getAverageEmotion("surprise")
	averageValence = getAverageEmotion("valence")


	# The Affectiva SDK offers a rich breadth of emotion data points
	# Keys to each face dictionary include:
	# 'orientation', 'appearance', 'emotions', 'faceQuality', 'expressions', 'emojis', 'faceId'
	# See the emotionJSON.txt file for more insight regarding the breadth of available data
	print ("averageAnger",averageAnger )
	print ("averageContempt",averageContempt)
	print ("averageDisgust",averageDisgust)
	print ("averageEngagement",averageEngagement)
	print ("averageFear",averageFear)
	print ("averageJoy",averageJoy)
	print ("averageSadness",averageSadness)
	print ("averageSurprise",averageSurprise)
	print ("averageValence",averageValence)
	print(listOfFaceDictionaries[0]["emotions"].keys())
	print("\n")








