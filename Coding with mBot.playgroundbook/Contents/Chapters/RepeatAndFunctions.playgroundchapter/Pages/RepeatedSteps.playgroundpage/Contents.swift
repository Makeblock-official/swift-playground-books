/*:
 Sometimes Dancers jiggle or swing again,
 again, and again.
 
 Using **For loops**, you can tell the robot  
 jiggle or swing
 again, again, and again,  
 by any times you want.
 
 Give a number to tell the robot jiggle 5 times.
 
 Try it by yourself!
 
*/
//#-hidden-code



execiseCode = {

//#-code-completion(everything, hide)
//#-code-completion(literal, show, color, array)
//#-code-completion(identifier, show, lightLeft(color:), lightRight(color:), lightBoth(color:))
    //#-end-hidden-code
    func jiggle() {
        moveForward()
        moveBack()
    }
    
    for i in 1 ... /*#-editable-code*/<#T##Tap here##Int#>/*#-end-editable-code*/ {
        jiggle()
    }
    
//#-hidden-code
    
}

runWithCommands()

//#-end-hidden-code
