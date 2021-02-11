import glm
import nimgl/glfw
import nimgl/opengl
import utils
import utils/gl


proc keyProc(window: GLFWWindow, key: int32, scancode: int32, action: int32, mods: int32): void {.cdecl.} =
  if key == GLFWKey.Escape and action == GLFWPress:
    window.setWindowShouldClose(true)
  if key == GLFWKey.Space:
    glPolygonMode(GL_FRONT_AND_BACK, if action != GLFWRelease: GL_LINE else: GL_FILL)


proc main* =
  # GLFW
  doAssert glfwInit()

  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_FALSE)

  let w: GLFWWindow = glfwCreateWindow(800, 600, "NimGL", nil, nil)
  doAssert w != nil

  discard w.setKeyCallback(keyProc)
  w.makeContextCurrent

  # Opengl
  doAssert glInit()
  gl.printOpenGLVersion()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

  var mesh: tuple[vbo, vao, ebo: uint32]
  var vert = [
     0.3f,  0.3f,
     0.3f, -0.3f,
    -0.3f, -0.3f,
    -0.3f,  0.3f
  ]
  var ind = [
    0'u32, 1'u32, 3'u32,
    1'u32, 2'u32, 3'u32
  ]

  glGenBuffers(1, mesh.vbo.addr)
  glGenBuffers(1, mesh.ebo.addr)
  glGenVertexArrays(1, mesh.vao.addr)

  glBindVertexArray(mesh.vao)

  glBindBuffer(GL_ARRAY_BUFFER, mesh.vbo)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mesh.ebo)

  glBufferData(GL_ARRAY_BUFFER, cint(sizeof(cfloat) * vert.len), vert[0].addr, GL_STATIC_DRAW)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, cint(sizeof(cuint) * ind.len), ind[0].addr, GL_STATIC_DRAW)

  glEnableVertexAttribArray(0)
  glVertexAttribPointer(0'u32, 2, EGL_FLOAT, false, sizeof(cfloat) * 2, nil)
  
  let programID = linkProgram(
    compileShader(GL_VERTEX_SHADER, static ~"shaders/square/vertex_shader.glsl"),
    compileShader(GL_FRAGMENT_SHADER, static ~"shaders/square/fragment_shader.glsl"),
  )

  let uColor = glGetUniformLocation(programID, "uColor")
  let uMVP = glGetUniformLocation(programID, "uMVP")
  var mvp = ortho(-2f, 2f, -1.5f, 1.5f, -1f, 1f)
  var colors = (
    bg: vec3f(33, 33, 33).toRGB,
    square: vec3f(50, 205, 50).toRGB
  )

  while not w.windowShouldClose:
    gl.clearColorRGB(colors.bg, 1f)
    glClear(GL_COLOR_BUFFER_BIT)

    glUseProgram(programID)
    glUniform3fv(uColor, 1, colors.square.caddr)
    glUniformMatrix4fv(uMVP, 1, false, mvp.caddr)

    glBindVertexArray(mesh.vao)
    glDrawElements(GL_TRIANGLES, ind.len.cint, GL_UNSIGNED_INT, nil)

    w.swapBuffers
    glfwPollEvents()

  w.destroyWindow
  glfwTerminate()

  glDeleteVertexArrays(1, mesh.vao.addr)
  glDeleteBuffers(1, mesh.vbo.addr)
  glDeleteBuffers(1, mesh.ebo.addr)

