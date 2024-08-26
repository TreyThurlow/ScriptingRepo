#Declare characters used by this game
define e = Character("Eileen")

#The game starts here
label start:

    #Show a background
    scene bg room

    #This shows a character sprite
    show eileen happy

    #These display lines of dialogue
    e "You've created a new Ren'Py game"
    e "Once you add a story, pictures, and music, you can release it to the world!"

    #This ends the game.
    return