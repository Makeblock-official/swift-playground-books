/*:
 It's time to put them together!
 * You can use **functions** to group actions together;
 * You can use **For loops** to let the robot repeat itself.
 
 Try anything by yourself!
 
*/
//#-hidden-code

execiseCode = {
    
//#-code-completion(everything, hide)
//#-code-completion(identifier, show, beepDo(), beepMi(), beepSol(), moveForward(), moveBack(), moveLeft(), moveRight(), lightLeft(color:), lightRight(color:), lightBoth(color:))
    //#-end-hidden-code
//#-editable-code Tap to write your code
    
    func jiggle() {
        moveForward()
        moveBack()
    }
    
    for i in 1 ... 4 {
        jiggle()
    }
    
//#-end-editable-code
//#-hidden-code

}

runWithCommands()

//#-end-hidden-code
