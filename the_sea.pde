import processing.svg.*;

// DIMENSIONS
int WIDTH = 1080;
int HEIGHT = 765;
float MARGIN_FACTOR = 0.0; // Take a margin to let flows evolve
// FLOW GENERATION
float PERLIN_FACTOR = 0.005;
// AGENTS
int N_WATER_PARTICLES = 1000;
int N_AGENT_CREATION_RETRIES = 50;
int N_STEPS = 2000;
float PARTICLE_WEIGHT = 4;
// OBSTACLES
int N_OBSTACLES = 6;

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
    Coordinate coord = new Coordinate(random(min_x, max_x), random(min_y, max_y));
    int attempt = 0;
    while(!isValid(coord, obstacles, waterParticles) && attempt < N_AGENT_CREATION_RETRIES) {
      coord = new Coordinate(random(min_x, max_x), random(min_y, max_y));
      attempt++;
    }
    if(attempt < N_AGENT_CREATION_RETRIES) {
      WaterParticle waterParticle = new WaterParticle(coord);
      for(int step=0; step<N_STEPS; step++) {
        float angle = waterFlow[(int) waterParticle.position.getX()][(int) waterParticle.position.getY()];
        waterParticle.follow(angle);
        for(Obstacle obstacle : obstacles) {
          waterParticle.avoid(obstacle);
        }
        if(!isValid(waterParticle.getNextPosition(), obstacles, waterParticles)) {
          break;
        };
        waterParticle.update();
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

boolean isValid(Coordinate coord, ArrayList<Obstacle> obstacles, ArrayList<WaterParticle> others) {
  Point position = GF.createPoint(coord);
  if(
    position.getX() < 2*PARTICLE_WEIGHT
    || position.getX() >= WIDTH - 2*PARTICLE_WEIGHT
    || position.getY() < 2*PARTICLE_WEIGHT
    || position.getY() >= 2*HEIGHT - PARTICLE_WEIGHT
  ) {
    return false;
  }
  for(Obstacle obstacle : obstacles) {
    if(position.isWithinDistance(obstacle.geometry, 2*PARTICLE_WEIGHT)) {
      return false;
    }
  }
  for(WaterParticle other : others) {
    if(position.isWithinDistance(other.getLineString(), 2*PARTICLE_WEIGHT)) {
      return false;
    }
  }
  return true;
}

void draw() {}
