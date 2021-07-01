"""
File: sample_turtle_program.py
By: Nicole
Date: 2020-04-19
Description: Program that uses the turtle module to draw shapes based on user
             input until they choose to stop.
"""

# Import required modules -----------------------------------------------------
import turtle
from termcolor import cprint

# Open the program and define the shape
crush = turtle.Turtle()
crush.shape('turtle')

# Ask for the user's name to personalize the welcome message
name = input("What's your name? ")
print("Hello," + name + "!")
crush.write("Hello "+name+"!")
crush.penup()
crush.setpos(0, -20)

# Ask for the shape the user would like the turtle to draw
shape = input("What shape would you like Turtle to draw? ")
exit_option = ""
crush.clear()
pos = -20

# Begin a loop to draw the shapes entered as input until user enters 'stop'
while exit_option != "stop":
    accepted_shapes = ["circle", "square", "triangle"]
    if shape in accepted_shapes:
        shape = shape
        if shape == "circle":
            crush.pendown()
            crush.circle(50)
        elif shape == "square":
            crush.pendown()
            crush.forward(100)
            crush.left(90)
            crush.forward(100)
            crush.left(90)
            crush.forward(100)
            crush.left(90)
            crush.forward(100)
            crush.left(90)
        elif shape == "triangle":
            crush.pendown()
            crush.forward(100)
            crush.left(120)
            crush.forward(100) 
            crush.left(120)
            crush.forward(100)
            crush.left(120)
        crush.penup()
        pos = pos+10
        crush.setpos(0, pos)
    else:
        cprint("Oh no! Turtle does not accept "+shape+" as a shape at the moment.", 'red')
        cprint("When prompted again, please select of the following shapes: 'circle', 'square', or 'triangle'", 'red')
    exit_option = input("What shape would you like Turtle to draw? Enter 'stop' if you would like to exit. ")
    if exit_option != "stop":
        shape = exit_option
    else:
        print("Okay. Goodbye!")
        turtle.bye()






        
