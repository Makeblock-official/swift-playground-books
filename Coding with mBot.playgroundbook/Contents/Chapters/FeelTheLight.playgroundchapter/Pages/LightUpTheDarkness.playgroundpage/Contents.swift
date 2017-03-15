/*:
 
 Try by yourself:
 Tell the robot to light up in the darkness.
 
 Hint: 
 Make sure to use `if` clause and one of
 `lightBoth`, `lightRight`, `lightLeft`
 commands.
 
 */
//#-hidden-code
runWithCommands()
//#-code-completion(everything, hide)
//#-code-completion(keyword, if)
//#-code-completion(identifier, show, lightLeft(color:), lightRight(color:), lightBoth(color:))
execiseWithViewController = { viewController in
//#-end-hidden-code
    
func onLightSensor(light: Float) {
    //#-editable-code Tell the mBot to open the light in the darkness!
    //#-end-editable-code
}
    
//#-hidden-code
    subscribeLightnessSensor(callback: onLightSensor)
}
//#-end-hidden-code

