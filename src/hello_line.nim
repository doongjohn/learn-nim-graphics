import std/os
import glm
import nimgl/glfw
import nimgl/opengl
import utils/gl
import utils/shader
import utils/vec


proc keyProc(window: GLFWWindow, key: int32, scancode: int32, action: int32, mods: int32): void {.cdecl.} =
  if key == GLFWKey.Escape and action == GLFWPress:
    window.setWindowShouldClose(true)


proc main* =
  if os.getEnv("CI") != "":
    quit()

  # init GLFW
  doAssert glfwInit()

  # GLFW settings
  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE) # To make MacOS happy
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE) # We don't want the old OpenGL
  glfwWindowHint(GLFWResizable, GLFW_FALSE) # disable window resize

  # create window
  let w: GLFWWindow = glfwCreateWindow(800, 600, "NimGL", nil, nil)
  doAssert w != nil

  discard w.setKeyCallback(keyProc)
  w.makeContextCurrent()

  # init OpenGL
  doAssert glInit()
  printOpenGLVersion()

  # my first line!
  var vertices = toSeq(
    vec3f(0, 0, 0),
    vec3f(1, 0, 0)
  )

  var vao = glGenVao(1)
  var vbo = glGenVbo(1)
  glBindVertexArray(vao)
  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBufferData(GL_ARRAY_BUFFER, cint(sizeof(cfloat) * vertices.len), vertices[0].addr, GL_STATIC_DRAW)

  glVertexAttribPointer(0, 3, EGL_FLOAT, false, sizeof(cfloat) * 3, nil)
  glEnableVertexAttribArray(0)
  glBindBuffer(GL_ARRAY_BUFFER, 0)
  glBindVertexArray(0)

  var vertShaderID = compileShader(GL_VERTEX_SHADER, static shaderPath"square/vertex_shader")
  var fragShaderID = compileShader(GL_FRAGMENT_SHADER, static shaderPath"square/fragment_shader")
  var programID: uint32 = linkProgram(vertShaderID, fragShaderID)

  let uColor = glGetUniformLocation(programID, "uColor")
  let uMVP = glGetUniformLocation(programID, "uMVP")
  var mvp = ortho(-2f, 2f, -1.5f, 1.5f, -1f, 1f)
  var colors = (
    bg: vec3(33f, 33f, 33f).toRgb(),
    line: vec3(50f, 205f, 50f).toRgb()
  )

  # app main loop
  while not w.windowShouldClose:
    # clear background
    glClearColorRGB(colors.bg, 1f)
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

    # apply shader
    glUseProgram(programID)

    glUniformMatrix4fv(uMVP, 1, false, mvp.caddr)
    glUniform3fv(uColor, 1, colors.line.caddr)

    # draw line
    glBindVertexArray(vao)
    glDrawArrays(GL_LINES, 0, 2)

    # swap buffers
    w.swapBuffers()
    glfwPollEvents()
  
  # app exit
  w.destroyWindow()
  glfwTerminate()

  glDeleteVertexArrays(1, vao.addr)
