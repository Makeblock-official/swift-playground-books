/*:

 mBot uses its lightness sensor to feel light.
 
 Try put your hand on top of the mBot,  
 or put the mBot to a dark or bright place,  
 and see what shows up in the graph.
 
*/
//#-hidden-code
//TODO: there should be a graph / Line chart showing the lightness sensor's value


//#-code-completion(everything, hide)
//#-code-completion(keyword, if)
//#-code-completion(identifier, show, beepDo(), beepMi(), beepSol(), moveForward(), moveBack(), moveLeft(), moveRight(), lightLeft(color:), lightRight(color:), lightBoth(color:))

//#-end-hidden-code
func onLightnessSensor(light: Int) {
    plotValueInChart(light)
}
//#-hidden-code
    


subscribeLightnessSensor(onLightnessSensor)

//#-end-hidden-code
