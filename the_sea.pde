// DIMENSIONS
int WIDTH = 720;
int HEIGHT = 510;
float MARGIN_FACTOR = 0.10; // Take a margin to let flows evolve
// FLOW GENERATION
float PERLIN_FACTOR = 0.005;
// AGENTS
int N_WATER_PARTICLES = 5000;
int N_STEPS = 10;

GeometryFactory GF;
void setup() {
  size(720, 510);
  
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
  
  // Autonomous agent with repeling force
  ArrayList<WaterParticle> waterParticles = new ArrayList<WaterParticle>();
  for(int i=0; i<N_WATER_PARTICLES; i++) {
    // TODO : avoid generating inside obstacles
    waterParticles.add(new WaterParticle(random(min_x, max_x), random(min_y, max_y)));
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
        waterParticle.update();
      }
    }
  }
  
  background(0);
  
  for(WaterParticle waterParticle : waterParticles) {
    beginShape();
    noFill();
    stroke(255);
    for(Coordinate coord : waterParticle.path) {
      vertex((float) coord.x, (float) coord.y);
    }
    endShape();
  }
  
  noLoop();
}

void draw() {}
