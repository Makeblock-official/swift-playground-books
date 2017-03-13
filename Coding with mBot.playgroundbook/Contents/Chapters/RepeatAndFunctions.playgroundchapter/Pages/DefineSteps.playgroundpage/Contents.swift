/*:
 Many small steps make a dance.
 Using words like "Sway" or "Step", rather than tell exactly how to move fingers and toes,
 makes it easier to tell people how to dance.
 
 The robot use the same idea. You can group actions into **Functions**
 So you can tell the robot how to move
 without saying the same word again and again.
 
 The following code teaches the robot a move called "jiggle()"
 See what does it do.
 
 You can also add more actions if you want.
 
 
*/
//#-hidden-code

execiseCode = {

//#-code-completion(everything, hide)
//#-code-completion(identifier, show, beepDo(), beepMi(), beepSol(), moveForward(), moveBack(), moveLeft(), moveRight(), lightLeft(color:), lightRight(color:), lightBoth(color:))
    //#-end-hidden-code
    
    func jiggle() {
        moveForward()
        moveBack()
        //#-editable-code You can add more actions
        //#-end-editable-code
    }
    
    jiggle()
    moveRight()
    jiggle()
//#-hidden-code
    
}

runWithCommands()
//#-end-hidden-code
