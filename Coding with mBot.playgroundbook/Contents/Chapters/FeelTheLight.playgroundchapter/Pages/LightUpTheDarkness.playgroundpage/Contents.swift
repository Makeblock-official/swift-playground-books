/*:
 
 Try by yourself:
 Tell the robot to light up in the darkness.
 
 Hint: 
 Make sure to use `if` clause and one of
 `lightBoth`, `lightRight`, `lightLeft`
 commands.
 
 */
//#-hidden-code


//#-code-completion(everything, hide)
//#-code-completion(keyword, if)
//#-code-completion(identifier, show, lightLeft(color:), lightRight(color:), lightBoth(color:))
//#-end-hidden-code
func onLightSensor(light: Int) {
    
    //#-editable-code Tell the mBot to open the light in the darkness!
    //#-end-editable-code

}
//#-hidden-code
    


subscribeLightnessSensor(onLightSensor)

//#-end-hidden-code

