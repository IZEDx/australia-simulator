part of australiasim;

class Vector
{
    double _x = 0.0;
    double _y = 0.0;

    set x(double x) => _x = x;
    double get x => _x;

    set y(double x) => _y = y;
    double get y => _y;

    Vector(this._x, this._y);
    Vector.zero() : _x = 0.0, _y = 0.0;

    double dot(Vector other) => this.x * other.x + this.y * other.y;

    double size() => sqrt(this.x * this.x + this.y * this.y);

    Vector normalized()
    {
        final size = this.size();
        return new Vector(this.x / size, this.y / size);
    }

    double dist(Vector other) => (other - this).size();

    Vector operator *(double a) => new Vector(this.x * a, this.y * a);

    Vector operator /(double a) => new Vector(this.x / a, this.y / a);

    Vector operator -() => new Vector(-this.x, -this.y);

    Vector operator +(Vector other) => new Vector(this.x + other.x, this.y + other.y);
    Vector operator -(Vector other) => this + -other;


    static Vector rotatePointAround(Vector point, Vector center, double radians)
    {
        final offset = point - center;

        final x = (offset.x * cos(radians) - (offset.y * sin(radians)));
        final y = (offset.x * sin(radians) + (offset.y * cos(radians)));

        return (new Vector(x, y)) + center;
    }

    String toString() => "x = " + this.x.toString() + ", y = " + this.y.toString();

}