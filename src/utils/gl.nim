import nimgl/opengl
import glm


proc toRGB*(vec: Vec3[float32]): Vec3[float32] =
  vec3(vec.x / 255, vec.y / 255, vec.z / 255)


template glClearColorRGB*(rgb: Vec3[float32], alpha: float32) =
  glClearColor(rgb.r, rgb.b, rgb.b, alpha)