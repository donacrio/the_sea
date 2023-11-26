class Obstacle {
  Geometry geometry;
  
  // TODO: Delaunay triangulation
  Obstacle(Coordinate position, float radius) {
    GeometricShapeFactory gsf = new GeometricShapeFactory(GF);
    gsf.setCentre(position);
    gsf.setSize(radius);
    this.geometry = gsf.createSquircle();
  }
}
