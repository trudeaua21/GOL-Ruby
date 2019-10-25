#***********************************************************************
#Filename: GOL.rb
#
#Contains a Game class which implements functions to similuate Conway's
#Game of life, as well as the logic to allow basic user input such as 
#iteration to subsequent generations, saving, and loading.
#
#@author Aaron Trudeau (except for logic given to me and lines cited)
#@version April 2019
#***********************************************************************

require 'json'


# Program 'constants', where '0' is a live cell and '.' is a dead cell
LIVE = "0"
DEAD = "."

#***********************************************************************
#Game class provides structure for a grid and grid actions to simulate
#Conway's Game of Life.
#
#@author Aaron Trudeau
#@version April 2019
#***********************************************************************
class Game
    
    # Accessor for instance variable height
    attr_reader :height
    
    # Accessor for instance variable width
    attr_reader :width
    
    # Accessor for instance variable grid
    attr_reader :grid
    
    
    #*******************************************************************
    #Creates an instance of Game using the given array value
    #@param height the height of the grid
    #@param width the width of the grid
    #@param array the grid value
    #*******************************************************************
    def initialize(height, width, array)
        # Height refers to the number of rows in the grid
        @height = height
        # Width refers to the number of columns in the grid
        @width = width
        # Grid refers to the 2D array which holds the cells
        #@grid = Array.new(@height) {Array.new(@width)}
        @grid = Marshal.load(Marshal.dump(array))
    end

    
    #*******************************************************************
    #Prints out the current state of the grid to the console.
    #*******************************************************************
    def print_grid
        for i in 0..@height-1
            for j in 0..@width-1
                print @grid[i][j]
                print " "
            end
            print "\n"
        end
    end
    
    
    #*******************************************************************
    #Takes the current grid and mutates it according to Conway's rules.
    #@return the mutated grid state after one application of Conway's
    #rules to the current grid
    #*******************************************************************
    def mutate
        # Creates a deep copy of the grid to examine without issue
        copy = JSON.parse(JSON.generate(@grid))
        
        # Using neighbors instead of num_neighbors to avoid a potential
        # naming conflict with get_neighbors' num_neighbors
        neighbors = 0
        
        # Uses copy as a function to update the grid
        # Note: the state of copy does not change
        for i in 0..@height-1
            for j in 0..@width-1
                neighbors = get_neighbors(i, j, copy)
                if copy[i][j] == LIVE
                    if neighbors < 2 or neighbors > 3
                        # Cell dies
                        @grid[i][j] = DEAD
                    else
                        # Cell stays alive
                        @grid[i][j] = LIVE
                    end
                elsif copy[i][j] == DEAD
                    if neighbors == 3
                        # Cell comes back to life
                        @grid[i][j] = LIVE
                    end
                end
            end
        end
    end
    
    
    #*******************************************************************
    #A helper method that returns the number of live neighbors a cell 
    #has.
    #@param height the height of the grid
    #@param width the width of the grid
    #@return the number of living neighbors the cell has
    #*******************************************************************
    def get_neighbors(x, y, array)
        
        # Ensures that no cell outside of the grid is called
        if x < 0 or x > @height - 1 or y < 0 or y > @width - 1
            return -1
        end
        
        num_neighbors = 0
        
        # Since not all cells can have 8 neighbors due to the bounds of 
        # the grid, the cell given by x and y is tested to see which of 
        # the 8 neighbors it can and cannot have
        if x > 0 and y > 0
            if array[x-1][y-1] == LIVE
                num_neighbors += 1
            end
        end
        if x > 0
            if array[x-1][y] == LIVE
                num_neighbors += 1;
            end
        end
        if x > 0 && y < @width - 1
            if array[x-1][y+1] == LIVE
                num_neighbors += 1;
            end
        end
        if y > 0
            if array[x][y-1] == LIVE
                num_neighbors += 1;
            end
        end
        if y < @width - 1
            if array[x][y+1] == LIVE
                num_neighbors += 1;
            end
        end
        if x < @height - 1 && y > 0
            if array[x+1][y-1] == LIVE
                num_neighbors += 1;
            end
        end
        if x < @height - 1
            if array[x+1][y] == LIVE
                num_neighbors += 1;
            end
        end
        if x < @height - 1 && y < @width - 1
            if array[x+1][y+1] == LIVE
                num_neighbors += 1;
            end
        end
        
        # Unneccessary, but here for readability purposes
        return num_neighbors
    end
end


#***********************************************************************
#A modification of the String class to test if a string is an integer.
#Code from https://stackoverflow.com/questions/1235863/test-if-a-string
#-is-basically-an-integer-in-quotes-using-ruby
#***********************************************************************
class String

    
    #*******************************************************************
    #Tests if a string can be accurately converted into an integer.
    #@return bool true if the string can be an integer, false otherwise
    #*******************************************************************
    def is_integer?
        self.to_i.to_s == self
    end
end


########################################################################
#Beginning of the main code
########################################################################


#***********************************************************************
#A helper method that saves the current state of the grid to a file
#as a json string.
#@param filename the desired name of the file to be written to
#@param array the the grid to be saved to a file
#***********************************************************************
def save_file(filename, array)
    file = File.new(filename, "w")
        file.write(JSON.generate(array))
    file.close
end


#***********************************************************************
#A helper method that loads a json string from a file to obtain the 
#state of a Game class.
#@param filename the desired name of the file to be read from
#@return a newly constructed Game object holding info from the file
#***********************************************************************
def load_file(filename)
    file = File.open(filename, "r")
       grid = JSON.parse(file.read)
    file.close
    return Game.new(grid.length, grid[0].length, grid)
end


#The program requires a file name to start
if ARGV.length != 1
    abort("This program requires a file name and no other parameters to start \n")
end

# Retrieves the file name from the command line
load_name = ARGV[0]

# Ensures existence of the file
if !File.file?(ARGV[0])
    puts("Error: file does not exist")
    exit(1)
end

# Creates a new Game object and loads the object saved to a json file in
game = load_file(load_name)
game.print_grid

while true
    puts "Press q to quit, w to save to disk"
    puts "n to iterate multiple times, or any other"
    puts "key to continue to the next generation"
    
    # STDIN specification avoids command line argument interference
    # Code from https://stackoverflow.com/questions/27453569/using
    #-gets-gives-no-such-file-or-directory-error-when-i-pass-
    #arguments-to-my/27453657
    val = STDIN.gets.chomp
    
    if(val == "q")
        exit
    elsif(val == "w")
        puts "Enter a file name. "
        name = STDIN.gets.chomp
        save_file(name, game.grid)
    elsif(val == "n")
        puts "How many iterations? "
        times = STDIN.gets.chomp
        if times.is_integer?
            for i in 0..times.to_i
                game.mutate 
                game.print_grid
            end
        else
            puts "Invalid Input: iteration value must be an integer"
        end
    else
        game.mutate
        game.print_grid
    end
end





