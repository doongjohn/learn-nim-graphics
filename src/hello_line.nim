import glm
import nimgl/glfw
import nimgl/opengl
import utils
import utils/gl


proc keyProc(window: GLFWWindow, key: int32, scancode: int32, action: int32, mods: int32): void {.cdecl.} =
  if key == GLFWKey.Escape and action == GLFWPress:
    window.setWindowShouldClose(true)


template use(vao, vbo: uint32, body: untyped) =
  glBindVertexArray(vao)
  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  body
  glBindBuffer(GL_ARRAY_BUFFER, 0)
  glBindVertexArray(0)


proc main* =
  # init GLFW
  doAssert glfwInit()

  # GLFW settings
  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE) # To make MacOS happy
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE) # We don't want the old OpenGL
  glfwWindowHint(GLFWResizable, GLFW_FALSE) # disable window resize

  # create window
  let w: GLFWWindow = glfwCreateWindow(800, 800, "NimGL", nil, nil)
  doAssert w != nil

  discard w.setKeyCallback(keyProc)
  w.makeContextCurrent()

  # init OpenGL
  doAssert glInit()
  gl.printOpenGLVersion()

  # my first line!
  let positions = [
    vec3f(0.0, 0.0, 0.0),
    vec3f(0.5, 0.0, 0.0)
  ]
  var vertices = ...(
    positions[0],
    positions[1]
  )

  var vao = gl.genVertexArrays(1)
  var vbo = gl.genBuffers(1)
  var ebo = gl.genBuffers(1)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo)

  use vao, vbo:
    glBufferData(GL_ARRAY_BUFFER, cint(sizeof(cfloat) * vertices.len), vertices[0].addr, GL_STATIC_DRAW)
    glEnableVertexAttribArray(0)
    glVertexAttribPointer(0, 3, EGL_FLOAT, false, sizeof(cfloat) * 3, nil)

  let programID = linkProgram(
    compileShader(GL_VERTEX_SHADER, static ~"shaders/square/vertex_shader.glsl"),
    compileShader(GL_FRAGMENT_SHADER, static ~"shaders/square/fragment_shader.glsl")
  )

  let uColor = glGetUniformLocation(programID, "uColor")
  let uMVP = glGetUniformLocation(programID, "uMVP")
  var mvp = ortho(-2f, 2f, -1.5f, 1.5f, -1f, 1f)
  var colors = (
    bg: vec3f(33, 33, 33).toRGB,
    square: vec3f(50, 205, 50).toRGB
  )

  # app main loop
  while not w.windowShouldClose:
    # clear background
    gl.clearColorRGB(colors.bg, 1)
    glClear(GL_COLOR_BUFFER_BIT)

    # apply shader
    glUseProgram(programID)
    glUniform3fv(uColor, 1, colors.square.caddr)
    glUniformMatrix4fv(uMVP, 1, false, mvp.caddr)

    # draw line
    use vao, vbo:
      var point1 = vec4f(vertices[0], vertices[1], vertices[2], 1)
      var point2 = vec4f(vertices[3], vertices[4], vertices[5], 1)
      var dir = vec4f(normalize(point2 - point1).xyz, 0)
      dir = mat4f(1).rotate(0.01, vec3f(0, 0, 1)) * dir
      echo dir.length
      vertices[3] = dir.x
      vertices[4] = dir.y
      vertices[5] = dir.z
      glBufferData(GL_ARRAY_BUFFER, cint(sizeof(cfloat) * vertices.len), vertices[0].addr, GL_DYNAMIC_DRAW)
      glDrawArrays(GL_LINES, 0, 2)

    # swap buffers
    w.swapBuffers()

    # poll events
    glfwPollEvents()

  # app exit
  w.destroyWindow()
  glfwTerminate()

  glDeleteVertexArrays(1, vao.addr)
  glDeleteBuffers(1, vbo.addr)
  glDeleteBuffers(1, ebo.addr)
