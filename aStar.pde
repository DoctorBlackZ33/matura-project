// 2D Array of objects
Cell[][] grid;

// Number of columns and rows in the grid
int cols = 10;
int rows = 10;
int size = 50;

//Grid with weight ranging from 0 to PI because it is displayed using a cosin
float[][] weight = { {  1,  1,  1,  1,  1,  1,  1,  1,  1,  0},
                     {  2,  1,  1,  1,  1,  1,  1,  1,  1,  1},
                     {  2,  2,  1,  1,  1,  1,  1,  1,  1,  1},
                     {  2,  2,  2,  3,  3,  3,  3,  3,  1,  1},
                     {  2,  2,  2,  2,  1,  1,  1,  3,  1,  1},
                     {  2,  2,  2,  2,  2,  1,  1,  3,  1,  1},
                     {  2,  2,  2,  2,  2,  2,  1,  1,  1,  1},
                     {  2,  2,  2,  2,  2,  2,  2,  1,  1,  1},
                     {  2,  2,  2,  2,  2,  2,  2,  2,  1,  1},
                     {  3,  2,  2,  2,  2,  2,  2,  2,  2,  1}  };

void setup() {
  size(500,500);
  noLoop();
  //cols equals y and rows equals x !!!!!! IT'S WRONG PAY ATTENTION
  grid = new Cell[cols][rows];
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      // Initialize each object
      grid[i][j] = new Cell(i,j,size,size,weight[j][i]);
    }
  }
}

void draw() {
  background(0);

  for (int i = 0; i < cols; i++) 
  {
    for (int j = 0; j < rows; j++) 
    {
      grid[i][j].display();
    }
  }
  //didn't know how to give the standard openSet with the start cell in it as an ArrayList
  ArrayList<Cell> xxx = new ArrayList<Cell>();
  xxx.add(grid[0][9]);
  A aStar = new A(grid, grid[9][0], grid[0][9], xxx); //<>//
  aStar.searchPath();
}

class Cell {

  float x,y;   
  float w,h;   
  float angle; 
  boolean isOpen = false;
  boolean isClosed = false;
  float fScore;
  Cell parent;
  
  Cell(float tempX, float tempY, float tempW, float tempH, float tempAngle) {
    x = tempX;
    y = tempY;
    w = tempW;
    h = tempH;
    angle = tempAngle;
  }

  void display() {
    stroke(255);
    fill(127+127*cos(angle));
    rect(x*size,y*size,w,h);
  }
}

class A
{
  //openSet needs to be an ArrayList since you can't expand an Array easily
  Cell[][] grid;
  ArrayList<Cell> openSet;
  Cell endCell;
  Cell startCell;
  
  A(Cell[][] tempGrid, Cell tempEndCell, Cell tempStartCell, ArrayList<Cell> tempOpenSet)
  {
    grid = tempGrid;
    endCell = tempEndCell;
    startCell = tempStartCell;
    openSet = tempOpenSet;
  }
  
  float calculateFScore(Cell currentCell, Cell parentCell) 
  {
    //calculates the fScore with the help of the weight, the distance to the endCell and the cost of the path to the current object
    float estimatedFScore = sqrt(sq(currentCell.x-endCell.x)+sq(currentCell.y-endCell.y));
    float fScore = parentCell.fScore + currentCell.angle + estimatedFScore;
    return fScore;
  } 
  
  void addNeighbors(Cell currentCell)
  {
    //makes a 3x3 field around the current Cell and then checks if the neighbors are still open. If they are a parent is added, the cell added to openSet and the fScore is calculated. If it isn't open it updates parent and fScore only if the fScore is smaller than the previous one
    //int for coordinates not needed because they are already int
    int gridX = int(currentCell.x);
    int gridY = int(currentCell.y);
    
    for(int i = -1; i < 2; i++)
    {
      for(int j = -1; j < 2; j++)
      {
        //checks if it is the same cell or not since I only want the neighbors
        if(i != 0 || j != 0)
        {
          //checks if the cell coordinates are contained within the grid
          if(gridY + i >= 0 && gridY + i < grid.length && gridX + j >= 0 && gridX + j < grid[gridY+i].length) //<>//
          {
            float tempFScore = calculateFScore(grid[int(gridY+i)][int(gridX+j)], grid[int(gridY)][int(gridX)]);
            //check if the cell isn't already in the closed set or if it is in the open set
            if(grid[int(gridY+i)][int(gridX+j)].isOpen == false && grid[int(gridY+i)][int(gridX+j)].isClosed == false) //<>//
            {
              //there might be referencing problems. Array should be pointers but it doesnt work with a reference to a grid object but with an openSet object it works? TO DO: needs further inverstigation
              openSet.add(grid[int(gridX+j)][int(gridY+i)]);
              openSet.get(openSet.size()-1).isOpen = true;
              grid[int(gridY+i)][int(gridX+j)].isOpen = true;
              openSet.get(openSet.size()-1).fScore = tempFScore;
              openSet.get(openSet.size()-1).parent = currentCell;
              int removeIndex = -1;
              //searches for the current cell in openSet. might need to move it else where since it could cause problems in a specific scenario where there is no neighbor and therefore the currentCell will not be removed form openSet.
              for(Cell c : openSet)
              {
                if(c.x == currentCell.x && c.y == currentCell.y)
                {
                  removeIndex = openSet.indexOf(c);
                }
              }
              if(removeIndex >= 0 && removeIndex < openSet.size())
              {
                openSet.remove(removeIndex);
                grid[int(gridY)][int(gridX)].isClosed = true;
              }
            }
            //at cell x = 6 and y = 3 the check fails repeatedly but every condition is met, isOpen is true, fScore is 8.0 in both instances and isClosed is false according to the debug window
            else if(grid[int(gridY+i)][int(gridX+j)].isOpen && //<>//
              grid[int(gridY+i)][int(gridX+j)].fScore >= tempFScore &&
              !grid[int(gridY+i)][int(gridX+j)].isClosed)
            {
              grid[int(gridY+i)][int(gridX+j)].fScore = tempFScore;
              grid[int(gridY+i)][int(gridX+j)].parent = currentCell;
            }
          }
        }
        //TO DO: do I even need this? use?
        else if(i == 1 && j == 1)
        {
          grid[int(gridY+i)][int(gridX+j)].isOpen = true;
        }
      }
    }
  }
  
  Cell searchCheapestCell()
  {
    //searches the cheapest cell based on the fScore of each cell where the default lowest fScore is the fScore of the first element in openSet
    Cell cheapestCell = openSet.get(0);
    float lowestFScore = openSet.get(0).fScore;
    for(Cell c : openSet)
    {
      if(c.fScore <= lowestFScore)
      {
        cheapestCell = c; //<>//
        print(" " + cheapestCell.x + " " + cheapestCell.y + " ");
        lowestFScore = c.fScore;
      }
    }
    return cheapestCell;
  }
  void reconstructPath(Cell currentCell)
  {
    //should reconstruct the cheapest path
    //TO DO: needs testing, was never tested
    ArrayList<Cell> path = null;
    while(currentCell != startCell)
    {
      path.add(currentCell);
      currentCell = currentCell.parent;
    }
    
    for(int i = path.size()-1; i >= 0; i--)
    {
      line(currentCell.x*size, currentCell.y*size, path.get(i).x*size, path.get(i).y*size);
      currentCell = path.get(i);
    }
  }
  void searchPath()
  {
    //executes a full search for the shortest path
    Cell currentCell = startCell; //<>//
    currentCell.fScore = calculateFScore(currentCell, currentCell);
    print(currentCell.fScore);
    while(currentCell != endCell || openSet.size() != 0)
    {
      addNeighbors(currentCell); //<>//
      currentCell = searchCheapestCell(); //<>//
    }
    reconstructPath(currentCell);
    print(openSet);
  }
}
