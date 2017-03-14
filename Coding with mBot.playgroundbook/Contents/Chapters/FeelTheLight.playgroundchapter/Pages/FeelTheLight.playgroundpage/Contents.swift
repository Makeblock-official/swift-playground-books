/*:

 mBot uses its lightness sensor to feel light.
 
 Try put your hand on top of the mBot,  
 or put the mBot to a dark or bright place,  
 and see what shows up in the graph.
 
*/
//TODO: there should be a graph / Line chart showing the lightness sensor's value
//#-hidden-code
runWithCommands()

execiseWithViewController = { viewController in
//#-end-hidden-code
 
func plotValueInChart(light: Float){
    
}
    
func onLightSensor(light: Float) {
    plotValueInChart(light:light)
}
    
//#-hidden-code
    subscribeLightnessSensor(callback: onLightSensor)
}
//#-end-hidden-code
