import glm

let identityMat = mat4f(1)
echo identityMat

var quat1 = identityMat.rotate(360f.radians, vec3f(0, 1, 0))
echo quat1*vec4f(1, 0, 0, 0)

# import hello_window
# hello_window.main()

# import hello_triangle
# hello_triangle.main()

# import hello_square
# hello_square.main()