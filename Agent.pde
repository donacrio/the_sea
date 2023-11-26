float MAX_VELOCITY = 2;
float MAX_STEER_FORCE = 1.5;
float VISIBILITY_DISTANCE = 15;

class WaterParticle {
  ArrayList<Coordinate> path;
  Vector2D position;
  Vector2D velocity;
  Vector2D acceleration;
  double angle;
  double maxVelocity;
  double maxSteerForce;
  double visibilityDistance;
  
  WaterParticle(double x, double y) {
    this.path = new ArrayList<Coordinate>();
    this.position = new Vector2D(x, y);
    this.velocity = new Vector2D();
    this.acceleration = new Vector2D();
    this.angle = Angle.normalizePositive(this.velocity.angle());
    this.maxVelocity = MAX_VELOCITY;
    this.maxSteerForce = MAX_STEER_FORCE;
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
    if(steerForce.length() > this.maxSteerForce) {
      steerForce = steerForce.normalize().multiply(this.maxSteerForce);
    }
    this.applyForce(steerForce);
  }
  
  void avoid(Geometry obstacle) {
    Coordinate position = this.position.toCoordinate();
    Coordinate[] closestPoints = new DistanceOp(GF.createPoint(position), obstacle).nearestPoints();
    Coordinate closestPoint = closestPoints[0];
    if(closestPoint == position) {
      closestPoint = closestPoints[1];
    }
    Vector2D obstaclePosition = Vector2D.create(closestPoint);
    
    Vector2D desiredPosition = obstaclePosition.subtract(this.position);
    double distance = desiredPosition.length();
    if(distance < this.visibilityDistance) {
      Vector2D steerForce = desiredPosition.subtract(this.velocity);
      if(steerForce.length() > this.maxSteerForce) {
        steerForce = steerForce.normalize().multiply(this.maxSteerForce);
      }
      this.applyForce(steerForce);
    }
  }
}
