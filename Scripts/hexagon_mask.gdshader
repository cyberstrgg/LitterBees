shader_type canvas_item;

// We will pass the aspect ratio of the panel from the script
uniform float aspect_ratio = 1.0;

// SDF function to calculate distance from a hexagon's edge
float sdf_hexagon(vec2 p, float r) {
    const vec3 k = vec3(-0.866025404, 0.5, 0.577350269);
    p = abs(p);
    p -= 2.0 * min(dot(k.xy, p), 0.0) * k.xy;
    p -= vec2(clamp(p.x, -k.z * r, k.z * r), r);
    return length(p) * sign(p.y);
}

void fragment() {
    vec4 panel_color = texture(TEXTURE, UV);

    vec2 centered_uv = UV - vec2(0.5);
    // Apply the aspect ratio correction to the x-coordinate
    centered_uv.x *= aspect_ratio;

    // Calculate the distance from the hexagon shape
    float distance = sdf_hexagon(centered_uv, 0.48);

    // Use the screen derivative to get a consistent 1.5 pixel soft edge
    float softness = length(fwidth(centered_uv));
    float alpha = 1.0 - smoothstep(-softness, softness, distance);

    COLOR = vec4(panel_color.rgb, panel_color.a * alpha);
}