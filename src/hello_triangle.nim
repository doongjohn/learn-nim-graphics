import std/os
import glm
import nimgl/glfw
import nimgl/opengl
import utils/gl
import utils/shader


var bgColor = vec3(33f, 33f, 33f).toRgb


proc keyProc(window: GLFWWindow, key: int32, scancode: int32, action: int32, mods: int32): void {.cdecl.} =
  if key == GLFWKey.Escape and action == GLFWPress:
    window.setWindowShouldClose(true)


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
  let w: GLFWWindow = glfwCreateWindow(800, 600, "NimGL", nil, nil)
  doAssert w != nil

  discard w.setKeyCallback(keyProc)
  w.makeContextCurrent()

  # init OpenGL
  doAssert glInit()
  printOpenGLVersion()

  # my first triangle!
  var vertices = [
    -1.0f, -1.0f, 0.0f,
     1.0f, -1.0f, 0.0f,
     0.0f,  1.0f, 0.0f,
  ]

  # create vao
  #var vao = gl.genVertexArrays(1)
  #glBindVertexArray(vao)

  # create vbo
  var vbo = gl.genBuffers(1)
  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBufferData(GL_ARRAY_BUFFER, cint(cfloat.sizeof * vertices.len), vertices[0].addr, GL_STATIC_DRAW)

  glEnableVertexAttribArray(0)
  glVertexAttribPointer(0, 3, EGL_FLOAT, false, 0, nil)

  # compile shaders
  let programID = linkProgram(
    compileShader(
      GL_VERTEX_SHADER,
      shaderPath"triangle/vertex_shader"),
    compileShader(
      GL_FRAGMENT_SHADER,
      shaderPath"triangle/fragment_shader")
  )

  # app main loop
  while not w.windowShouldClose:
    glfwPollEvents()

    # clear background
    glClearColorRGB(bgColor, 1f)
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
    
    # use shader
    glUseProgram(programID)

    # draw triangle
    #glBindBuffer(GL_ARRAY_BUFFER, vbo)
    glDrawArrays(GL_TRIANGLES, 0, 3)
    #glDisableVertexAttribArray(0)

    # swap buffers
    w.swapBuffers()
  
  # app exit
  w.destroyWindow()
  glfwTerminate()

  #glDeleteVertexArrays(1, vao.addr)
