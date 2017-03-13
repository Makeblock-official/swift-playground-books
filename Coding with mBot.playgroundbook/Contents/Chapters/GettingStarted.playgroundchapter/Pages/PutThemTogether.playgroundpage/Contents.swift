/*:
 It's time to put them together!
 Make the robot dance using movement, light, and sound commands:
 * `moveForward()`, `moveBack()`, `moveLeft()`, `moveRight()` makes the robot move;
 * `lightLeft(color)`, `lightRight(color)`, `lightBoth(color)` lights up the robot;
 * `beepDo()`, `beepMi()`, `beepSol()` play some sound
 
 Try them by yourself!
 
*/
//#-hidden-code

execiseCode = {
    
//#-code-completion(everything, hide)
//#-code-completion(identifier, show, beepDo(), beepMi(), beepSol(), moveForward(), moveBack(), moveLeft(), moveRight(), lightLeft(color:), lightRight(color:), lightBoth(color:))
    //#-end-hidden-code
//#-editable-code Tap to write your code
    moveForward()
    beepDo()
    moveForward()
    lightLeft(color: #colorLiteral(red: 0.584313750267029, green: 0.823529422283173, blue: 0.419607847929001, alpha: 1.0))
    moveLeft()
    lightBoth(color: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1))
//#-end-editable-code
//#-hidden-code

}

runWithCommands()

//#-end-hidden-code
