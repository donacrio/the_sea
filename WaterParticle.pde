float MAX_VELOCITY = 2;
float MAX_STEER_FLOW = 1.7;
float MAX_STEER_OBSTACLE = 1.7;
float VISIBILITY_DISTANCE = 10;

class WaterParticle {
  ArrayList<Coordinate> path;
  Vector2D position;
  Vector2D velocity;
  Vector2D acceleration;
  double angle;
  double maxVelocity;
  double maxSteerFlow;
  double maxSteerObstacle;
  double visibilityDistance;
  
  WaterParticle(Coordinate position) {
    this.path = new ArrayList<Coordinate>();
    this.path.add(position);
    this.position = Vector2D.create(position);
    this.velocity = new Vector2D();
    this.acceleration = new Vector2D();
    this.angle = Angle.normalizePositive(this.velocity.angle());
    this.maxVelocity = MAX_VELOCITY;
    this.maxSteerFlow= MAX_STEER_FLOW;
    this.maxSteerObstacle= MAX_STEER_OBSTACLE;
    this.visibilityDistance = VISIBILITY_DISTANCE;
  }
  
  void update() {
    this.velocity = this.velocity.add(acceleration);
    this.position = this.position.add(velocity);
    this.acceleration = new Vector2D();
    this.path.add(this.position.toCoordinate());
  }
  
  void applyForce(Vector2D force) {
    this.acceleration = this.acceleration.add(force);
  }
  
  void follow(double angle) {
    Vector2D desiredVelocity = Vector2D.create(0, this.maxVelocity);
    desiredVelocity = desiredVelocity.rotate(angle);
    Vector2D steerForce = desiredVelocity.subtract(this.velocity);
    if(steerForce.length() > this.maxSteerFlow) {
      steerForce = steerForce.normalize().multiply(this.maxSteerFlow);
    }
    this.applyForce(steerForce);
  }
  
  void avoid(Obstacle obstacle) {
    Coordinate position = this.position.toCoordinate();
    Coordinate[] closestPoints = new DistanceOp(GF.createPoint(position), obstacle.geometry).nearestPoints();
    Coordinate closestPoint = closestPoints[0];
    if(closestPoint == position) {
      closestPoint = closestPoints[1];
    }
    Vector2D obstaclePosition = Vector2D.create(closestPoint);
    
    Vector2D desiredVelocity = obstaclePosition.subtract(this.position);
    double distance = desiredVelocity.length();
    if(distance < this.visibilityDistance) {
      double velocityFactor = map((float) distance, 0,(float) this.visibilityDistance, -5, -2);
      desiredVelocity = desiredVelocity.multiply(velocityFactor);
      Vector2D steerForce = desiredVelocity.subtract(this.velocity);
      if(steerForce.length() > this.maxSteerObstacle) {
        steerForce = steerForce.normalize().multiply(this.maxSteerObstacle);
      }
      this.applyForce(steerForce);
    }
  }
}
