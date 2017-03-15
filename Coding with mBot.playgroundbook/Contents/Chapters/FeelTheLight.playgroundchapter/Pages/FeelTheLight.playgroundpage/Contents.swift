/*:
 
 mBot uses its lightness sensor to feel light.
 
 Try put your hand on top of the mBot,
 or put the mBot to a dark or bright place,
 and see what shows up in the graph.
 
 */
//#-hidden-code
runWithCommands()
//#-code-completion(everything, hide)
//#-code-completion(keyword, if)
//#-code-completion(identifier, show, beepDo(), beepMi(), beepSol(), moveForward(), moveBack(), moveLeft(), moveRight(), lightLeft(color:), lightRight(color:), lightBoth(color:))
execiseWithViewController = { viewController in
    //#-end-hidden-code
    
    func plotValueInChart(light: Float){
        viewController.setHintInfo(content:"lightness:\(light)")
        viewController.appendValue(value:Double(light))
    }
    
    func onLightSensor(light: Float) {
        //#-editable-code Tell the mBot to open the light in the darkness!
        //#-end-editable-code
        plotValueInChart(light:light)
    }
    
    //#-hidden-code
    viewController.setShowGraphView(show: true)
    subscribeLightnessSensor(callback: onLightSensor)
}
//#-end-hidden-code

