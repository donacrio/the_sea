import java.util.LinkedList;
import java.util.Queue;

float PERLIN_FACTOR = 0.005;
float SEPARATION_FACTOR = 0.2;

class FlowField {
  Vector2D[][] flowGrid;
  float dSep;
  ArrayList<Coordinate>[][] occupationGrid;
  ArrayList<FlowLine> lines;
  
  FlowField(float dSep) {
    this.flowGrid = new Vector2D[width][height];
    for(int i=0; i<width; i++) {
      for(int j=0; j<height; j++) {
        float noiseValue = noise(i*PERLIN_FACTOR, j*PERLIN_FACTOR);
        float angle = map(noiseValue, 0, 1, 0, 2*PI);
        Vector2D vector = Vector2D.create(0,1).rotate(angle);
        this.flowGrid[i][j] = vector;
      }
    }
    this.dSep = dSep;
    int nRows = (int) (width / dSep) + 1;
    int nCols = (int) (height / dSep) + 1;
    this.occupationGrid = new ArrayList[nRows][nCols];
    for(int i=0; i<nRows; i++) {
      for(int j=0; j<nCols; j++) {
        this.occupationGrid[i][j] = new ArrayList<Coordinate>();
      }
    }
    this.growLines();
  }
  
  void growLines() {
    this.lines = new ArrayList<FlowLine>();
    Queue<FlowLine> queue = new LinkedList<FlowLine>();
    FlowLine initialLine = this.growLine(new Coordinate(random(width), random(height)));
    this.lines.add(initialLine);
    queue.add(initialLine);
    
    while(queue.size() != 0) {
      FlowLine line = queue.poll();
      for(int i=1; i<line.path.size(); i++) {
        Coordinate prev = line.path.get(i-1);
        Coordinate curr = line.path.get(i);
        Vector2D direction = Vector2D.create(prev, curr).normalize().multiply(this.dSep);
        
        Coordinate left = Vector2D.create(curr).add(direction.rotate(PI/2)).toCoordinate();
        boolean testLeft = isValid(left);
        if(testLeft) {
          FlowLine newLine = this.growLine(left);
          this.lines.add(newLine);
          queue.add(newLine);
        }
        
        Coordinate right = Vector2D.create(curr).add(direction.rotate(-PI/2)).toCoordinate();
        boolean testRight = isValid(right);
        if(testRight) {
          FlowLine newLine = this.growLine(right);
          this.lines.add(newLine);
          queue.add(newLine);
        }
      }
    }
  }
  
  FlowLine growLine(Coordinate origin) {
    FlowLine line = new FlowLine(this, origin);
    boolean shouldGrowStart = true;
    boolean shouldGrowEnd = true;
    while(shouldGrowStart || shouldGrowEnd) {
      Coordinate nextStart = line.nextStart();
      shouldGrowStart = this.isValid(nextStart);
      if(shouldGrowStart) {
        line.updateStart(nextStart);
        
      }
      Coordinate nextEnd = line.nextEnd();
      shouldGrowEnd = this.isValid(nextEnd);
      if(shouldGrowEnd) {
        line.updateEnd(nextEnd);
      }
    }
    for(Coordinate coord : line.path) {
      int i = (int) (coord.x / this.dSep);
      int j = (int) (coord.y / this.dSep);
      this.occupationGrid[i][j].add(coord);
    }
    return line;
  }
  
  boolean isValid(Coordinate coord) {
    if(coord.x < 0 || coord.x >= width || coord.y < 0 || coord.y >= height) {
      return false;
    }
    
    int i = (int) (coord.x / this.dSep);
    int j = (int) (coord.y / this.dSep);
    for(int k=-1; k<2; k++) {
      for(int l=-1; l<2; l++) {
        if(i+k>=0 && i+k<this.occupationGrid.length && j+l>=0 && j+l < this.occupationGrid[0].length) {
          ArrayList<Coordinate> neighbours = this.occupationGrid[i+k][j+l];
          for(Coordinate neighbour : neighbours) {
            if(coord.distance(neighbour) < SEPARATION_FACTOR * this.dSep) {
              return false;
            }
          }
        }
      }
    }
    return true;
  }
  
  Vector2D getDirection(Coordinate coord) {
    return this.flowGrid[(int) coord.x][(int) coord.y];
  }
}

class FlowLine {
  FlowField flowField;
  Vector2D start;
  Vector2D end;
  
  ArrayList<Coordinate> path;
  
  FlowLine(FlowField flowField, Coordinate origin) {
    this.flowField = flowField;
    this.start = Vector2D.create(origin);
    this.end = Vector2D.create(origin);
    this.path = new ArrayList<Coordinate> () {{
      add(origin);
      add(origin);
    }};
  }
  
  Coordinate nextStart() {
    Vector2D direction = this.flowField.getDirection(this.start.toCoordinate());
    return this.start.add(direction).toCoordinate();
  }
  
  Coordinate nextEnd() {
    Vector2D direction = this.flowField.getDirection(this.end.toCoordinate()).multiply(-1);
    return this.end.add(direction).toCoordinate();
  }
  
  void updateStart(Coordinate start) {
    this.start = Vector2D.create(start);
    this.path.add(0, start);
  }
  
  void updateEnd(Coordinate end) {
    this.end = Vector2D.create(end);
    this.path.add(end);
  }
}
