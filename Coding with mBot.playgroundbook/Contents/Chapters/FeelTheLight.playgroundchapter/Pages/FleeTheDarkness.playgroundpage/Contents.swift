/*:
 
 You can use `if` command to let the robot  
 behave in different conditions.
 
 Try tell the robot `moveForward()` when
 it is placed in the dark place.
 
 */
//#-hidden-code
runWithCommands()

execiseWithViewController = { viewController in
//#-end-hidden-code
    
func onLightSensor(light: Float) {
    if light < Float(/*#-editable-code*/20.0/*#-end-editable-code*/) {
        //#-editable-code Tell the mBot to moveForward()!
        //#-end-editable-code
    }
}
    
//#-hidden-code
    subscribeLightnessSensor(callback: onLightSensor)
}
//#-end-hidden-code
