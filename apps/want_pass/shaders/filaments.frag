#include <flutter/runtime_effect.glsl>
uniform vec2 uSize;
uniform float uTime;
uniform vec2 uPointer;
uniform vec4 uBackground;
uniform vec4 uLine;
out vec4 fragColor;
void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  uv += uPointer * 0.018;
  float light = 0.0;
  for (int i = 0; i < 10; i++) {
    float strand = float(i);
    float depth = 0.5 + 0.5 * sin(strand * 1.7 + uTime * 0.08);
    float y = 0.16 + strand * 0.071;
    y += sin(uv.x * 4.5 + strand * 0.46 + uTime * 0.10) * 0.15;
    y += sin(uv.x * 9.0 - strand * 0.21 - uTime * 0.06) * 0.026;
    float distance = abs(uv.y - y) * uSize.y;
    float core = exp(-distance / (0.55 + depth * 0.7));
    float halo = exp(-distance / (4.0 + depth * 5.0));
    light += (core * 0.42 + halo * 0.045) * (0.35 + depth * 0.65);
  }
  vec2 calm = (uv - vec2(0.5, 0.5)) / vec2(0.25, 0.19);
  float mask = 1.0 - 0.86 * exp(-dot(calm, calm));
  fragColor = vec4(mix(uBackground.rgb, uLine.rgb, clamp(light * mask, 0.0, 0.75)), 1.0);
}
