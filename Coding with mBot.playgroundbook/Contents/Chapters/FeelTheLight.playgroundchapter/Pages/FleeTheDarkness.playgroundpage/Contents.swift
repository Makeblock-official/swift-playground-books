/*:
 
 You can use `if` command to let the robot  
 behave in different conditions.
 
 Try tell the robot `moveForward()` when
 it is placed in the dark place.
 
 */
//#-hidden-code


//#-code-completion(everything, hide)
//#-code-completion(identifier, show, moveForward(), moveBack(), moveLeft(), moveRight())
//#-end-hidden-code
func onLightSensor(light: Int) {
    if light < /*#-editable-code*/<#T##20##Int#>/*#-end-editable-code*/ {
        //#-editable-code Tell the mBot to moveForward()!
        //#-end-editable-code
    }
}
//#-hidden-code
    


subscribeLightnessSensor(onLightSensor)

//#-end-hidden-code
