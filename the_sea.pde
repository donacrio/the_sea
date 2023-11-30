import processing.svg.*;


float LINE_WEIGHT = 2;
float LINE_SEPARATION = 10;

GeometryFactory GF;
void setup() {
  size(1080, 765);
  
  GF = new GeometryFactory();
   
  FlowField water = new FlowField(LINE_SEPARATION);
  
  beginRecord(SVG, "out/final.svg");
  
  background(234,230,218); 
  noFill();
  stroke(0, 76, 92);
  strokeWeight(LINE_WEIGHT);
  for(FlowLine line : water.lines) {
    beginShape();
    for(Coordinate coord : line.path) {
      vertex((float) coord.x, (float) coord.y);
    }  
    endShape();
  }
  
  endRecord();
  noLoop();
}
