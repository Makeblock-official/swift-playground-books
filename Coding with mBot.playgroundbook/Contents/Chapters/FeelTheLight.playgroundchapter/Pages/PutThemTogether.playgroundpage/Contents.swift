/*:
 It's time to put them together!
 * You can use **if** to let the robot react to the environment;
 * Write code in onLightnessSensor(light) to read the light sensor;
 * You can use **functions** to group actions together;
 * You can use **For loops** to let the robot repeat itself.
 
 Try anything by yourself!
 
*/

//#-hidden-code
runWithCommands()
//#-code-completion(everything, hide)
//#-code-completion(keyword, if)
//#-code-completion(identifier, show, beepDo(), beepMi(), beepSol(), moveForward(), moveBack(), moveLeft(), moveRight(), lightLeft(color:), lightRight(color:), lightBoth(color:))
execiseWithViewController = { viewController in
//#-end-hidden-code
    
func onLightSensor(light: Float) {
    //#-editable-code Write anything you want!
    //#-end-editable-code
    viewController.setHintInfo(content: "light:\(light)");
}
    
//#-hidden-code
    subscribeLightnessSensor(callback: onLightSensor)
}
//#-end-hidden-code
