const zalgebra = @import("zalgebra");
const Vec3 = zalgebra.Vec3;
pub fn hermite(start_vertex: Vec3, start_tangent: Vec3, end_vertex: Vec3, end_tangent: Vec3, interp_value: f32) Vec3 {
    const t2 = interp_value * interp_value;
    const t3 = t2 * interp_value;

    const h1 = 2 * t3 - 3 * t2 + 1;
    const h2 = -2 * t3 + 3 * t2;
    const h3 = t3 - 2 * t2 + interp_value;
    const h4 = t3 - t2;

    return start_vertex.scale(h1)
    .add(end_vertex.scale(h2))
    .add(start_tangent.scale(h3))
    .add(end_tangent.scale(h4));
}