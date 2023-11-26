// DIMENSIONS
int WIDTH = 1080;
int HEIGHT = 765;
float MARGIN_FACTOR = 0.10; // Take a margin to let flows evolve
// FLOW GENERATION
float PERLIN_FACTOR = 0.0025;
// AGENTS
int N_WATER_PARTICLES = 7000;
int N_STEPS = 15;

GeometryFactory GF;
void setup() {
  size(1080, 765);
  
  float min_x = WIDTH * MARGIN_FACTOR;
  float max_x = WIDTH * (1-MARGIN_FACTOR);
  float min_y = HEIGHT * MARGIN_FACTOR;
  float max_y = HEIGHT * (1-MARGIN_FACTOR);
  
   GF = new GeometryFactory();
   
  // Flow field
  float[][] waterFlow = new float[WIDTH][HEIGHT];
  for(int i=0; i<WIDTH; i++) {
    for(int j=0; j<HEIGHT; j++) {
      float noiseValue = noise(i*PERLIN_FACTOR, j*PERLIN_FACTOR);
      float angle = map(noiseValue, 0, 1, 0, 2*PI);
      waterFlow[i][j] = angle;
    }
  }
  
  // Obstacles
  ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();
  for(int i=0; i<5; i++) {
    // TODO: avoid obstacle self collision
    obstacles.add(new Obstacle(new Coordinate(random(min_x, max_x), random(min_y, max_y)), 75));
  }
  
  // Autonomous agent with repeling force
  // TODO: line packing
  ArrayList<WaterParticle> waterParticles = new ArrayList<WaterParticle>();
  for(int i=0; i<N_WATER_PARTICLES; i++) {
    // TODO : avoid generating inside obstacles
    Point position = GF.createPoint(new Coordinate(random(min_x, max_x), random(min_y, max_y)));
    for(Obstacle obstacle : obstacles) {
      while(obstacle.geometry.contains(position)) {
        position = GF.createPoint(new Coordinate(random(min_x, max_x), random(min_y, max_y)));
      }
    }
    waterParticles.add(new WaterParticle(position.getCoordinate()));
  }
  
  for(int i=0; i<N_STEPS; i++) {
    for(WaterParticle waterParticle : waterParticles) {
      if(waterParticle.position.getX() >= 0
        && waterParticle.position.getX() < WIDTH
        && waterParticle.position.getY() >= 0
        && waterParticle.position.getY() < HEIGHT
      ){
        float angle = waterFlow[(int) waterParticle.position.getX()][(int) waterParticle.position.getY()];
        waterParticle.follow(angle);
        for(Obstacle obstacle : obstacles) {
          waterParticle.avoid(obstacle);
        }
        waterParticle.update();
      }
    }
  }
  
  background(234,230,218);
  
  for(Obstacle obstacle : obstacles) {
    fill(200,136,11);
    noStroke();
    beginShape();
    for(Coordinate coord : obstacle.geometry.getCoordinates()) {
      vertex((float) coord.x, (float) coord.y);
    }
    endShape();
  }
  
  for(WaterParticle waterParticle : waterParticles) {
    noFill();
    stroke(0, 76, 92);
    strokeWeight(1);
    beginShape();
    for(Coordinate coord : waterParticle.path) {
      vertex((float) coord.x, (float) coord.y);
    }
    endShape();
  }
  
  noLoop();
}

void draw() {}
