# GOL-Ruby

A terminal based implementation of Conway's Game of Life. Program can be run using the format './executableName fileName', where executableName is the name of the executable created from the .rb and fileName is the name of a .gol file within the same directory as the executable.

## Info on Saving/Loading
Boards are saved as JSON objects written to .gol files. An existing board is required to run the program; a sample board can be found as part of the repository. 

## Info on Implementation
This implementation of Conway's Game of Life allows for a variable board size and does not keep track of Cells' locations upon their deaths. 
