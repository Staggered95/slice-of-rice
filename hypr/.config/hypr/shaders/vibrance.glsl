#version 300 es
// vibrance.glsl
// A simple shader to increase color saturation

precision mediump float;
out vec4 fragColor;
in vec2 v_texcoord;
uniform sampler2D tex;

// Set the intensity of the saturation effect
// 1.0 = no change, > 1.0 = more saturation, < 1.0 = less saturation
const float saturation_adjustment = 1.2;

void main() {
    // Get the original color of the pixel
    vec4 original_color = texture(tex, v_texcoord);

    // Calculate the grayscale value (luminance)
    float gray = dot(original_color.rgb, vec3(0.299, 0.587, 0.114));
    vec3 grayscale = vec3(gray);

    // Blend the original color with the grayscale version
    // The saturation_adjustment controls how much of the original color is kept
    vec3 final_color = mix(grayscale, original_color.rgb, saturation_adjustment);

    fragColor = vec4(final_color, original_color.a);
}
