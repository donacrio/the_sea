import processing.svg.*;

// DIMENSIONS
int WIDTH = 1080;
int HEIGHT = 765;
float MARGIN_FACTOR = 0.20; // Take a margin to let flows evolve
// FLOW GENERATION
float PERLIN_FACTOR = 0.01;
// AGENTS
int N_WATER_PARTICLES = 1000;
int N_AGENT_CREATION_RETRIES = 50;
int N_STEPS = 50;
float PARTICLE_WEIGHT = 4;
// OBSTACLES
int N_OBSTACLES = 0;

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
  for(int i=0; i<N_OBSTACLES; i++) {
    // TODO: avoid obstacle self collision
    obstacles.add(new Obstacle(new Coordinate(random(min_x, max_x), random(min_y, max_y)), 75));
  }
  
  // Autonomous agents
  ArrayList<WaterParticle> waterParticles = new ArrayList<WaterParticle>();
  for(int i=0; i<N_WATER_PARTICLES; i++) {
    // Generating point outside of obstacles and other particles
    WaterParticle waterParticle = null;
    boolean isValid = false;
    int attempt = 0;
    while(!isValid && attempt < N_AGENT_CREATION_RETRIES) {
      waterParticle = new WaterParticle(new Coordinate(random(min_x, max_x), random(min_y, max_y)));
      isValid = isValid(waterParticle, obstacles, waterParticles);
      attempt++;
    }
    
    if(waterParticle != null) {
      int step = 0;
      while(isValid && step < N_STEPS) {
        float angle = waterFlow[(int) waterParticle.position.getX()][(int) waterParticle.position.getY()];
        waterParticle.follow(angle);
        for(Obstacle obstacle : obstacles) {
          waterParticle.avoid(obstacle);
        }
        waterParticle.update();
        step++;
        isValid = isValid(waterParticle, obstacles, waterParticles);
      }
      waterParticles.add(waterParticle);
    }
  }
  
  beginRecord(SVG, "out/final.svg");
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
    strokeWeight(PARTICLE_WEIGHT);
    beginShape();
    for(Coordinate coord : waterParticle.path) {
      vertex((float) coord.x, (float) coord.y);
    }
    endShape();
  }
  
  endRecord();
  noLoop();
}

boolean isValid(WaterParticle waterParticle, ArrayList<Obstacle> obstacles, ArrayList<WaterParticle> waterParticles) {
  Point position = GF.createPoint(waterParticle.position.toCoordinate());
  if(
    waterParticle.position.getX() < 0
    || waterParticle.position.getX() >= WIDTH
    || waterParticle.position.getY() < 0
    || waterParticle.position.getY() >= HEIGHT
  ) {
    return false;
  }
  for(Obstacle obstacle : obstacles) {
    if(obstacle.geometry.contains(position)) {
      return false;
    }
  }
  for(WaterParticle other : waterParticles) {
    if(
      waterParticle != other
      && DistanceOp.isWithinDistance(position, other.getLineString(), (double) 2*PARTICLE_WEIGHT)
    ) {
      return false;
    }
  }
  return true;
}

void draw() {}
