import os
import glm
import nimgl/glfw
import nimgl/opengl
import utils/gl
import utils/shader


proc keyProc(window: GLFWWindow, key: int32, scancode: int32, action: int32, mods: int32): void {.cdecl.} =
  if key == GLFWKey.Escape and action == GLFWPress:
    window.setWindowShouldClose(true)
  if key == GLFWKey.Space:
    glPolygonMode(GL_FRONT_AND_BACK, if action != GLFWRelease: GL_LINE else: GL_FILL)


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
  # check window creation
  doAssert w != nil

  discard w.setKeyCallback(keyProc)
  w.makeContextCurrent()

  # init OpenGL
  doAssert glInit()
  printOpenGLVersion()

  # OpenGL settings
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

  # Hello square!
  var vertices = @[
     0.3f,  0.3f,
     0.3f, -0.3f,
    -0.3f, -0.3f,
    -0.3f,  0.3f
  ]

  var indices = @[
    0'u32, 1'u32, 3'u32,
    1'u32, 2'u32, 3'u32
  ]

  var mesh: tuple[vbo, vao, ebo: uint32]
  mesh.vao = gl.genVertexArrays(1)
  mesh.vbo = gl.genBuffers(1)
  glBindVertexArray(mesh.vao)
  glBindBuffer(GL_ARRAY_BUFFER, mesh.vbo)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mesh.ebo)
  glBufferData(GL_ARRAY_BUFFER, cint(sizeof(cfloat) * vertices.len), vertices[0].addr, GL_STATIC_DRAW)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, cint(sizeof(cuint) * indices.len), indices[0].addr, GL_STATIC_DRAW)

  glEnableVertexAttribArray(0)
  glVertexAttribPointer(0'u32, 2, EGL_FLOAT, false, cfloat.sizeof * 2, nil)

  var vertShaderID = compileShader(GL_VERTEX_SHADER, static shaderPath"square/vertex_shader")
  var fragShaderID = compileShader(GL_FRAGMENT_SHADER, static shaderPath"square/fragment_shader")
  var programID: uint32 = linkProgram(vertShaderID, fragShaderID)

  let uColor = glGetUniformLocation(programID, "uColor")
  let uMVP = glGetUniformLocation(programID, "uMVP")
  var mvp = ortho(-2f, 2f, -1.5f, 1.5f, -1f, 1f)
  var colors = (
    bg: vec3(33f, 33f, 33f).toRgb(),
    square: vec3(50f, 205f, 50f).toRgb()
  )

  # app main loop
  while not w.windowShouldClose:
    # clear background
    glClearColorRGB(colors.bg, 1f)
    glClear(GL_COLOR_BUFFER_BIT)

    glUseProgram(programID)
    glUniformMatrix4fv(uMVP, 1, false, mvp.caddr)
    glUniform3fv(uColor, 1, colors.square.caddr)

    glBindVertexArray(mesh.vao)
    glDrawElements(GL_TRIANGLES, indices.len.cint, GL_UNSIGNED_INT, nil)

    # swap buffers
    w.swapBuffers()
    glfwPollEvents()
  
  # app exit
  w.destroyWindow()
  glfwTerminate()

  glDeleteVertexArrays(1, mesh.vao.addr)
  glDeleteBuffers(1, mesh.vbo.addr)
  glDeleteBuffers(1, mesh.ebo.addr)
