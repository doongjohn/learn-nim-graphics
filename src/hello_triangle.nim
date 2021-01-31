import os
import glm
import nimgl/glfw
import nimgl/opengl
import utils/gl
# import utils/shader


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
  glfwWindowHint(GLFWResizable, GLFW_FALSE)

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

  # Hello triangle!
  var vao: uint32
  glGenVertexArrays(1, vao.addr)
  glBindVertexArray(vao)

  # my first triangle!
  var vertices = @[
    -1.0f, -1.0f, 0.0f,
     1.0f, -1.0f, 0.0f,
     0.0f,  1.0f, 0.0f,
  ]

  var vertexBuffer: uint32
  glGenBuffers(1, vertexbuffer.addr)
  glBindBuffer(GL_ARRAY_BUFFER, vertexbuffer)
  glBufferData(GL_ARRAY_BUFFER, cint(cfloat.sizeof * vertices.len), vertices[0].addr, GL_STATIC_DRAW)

  var colors = (
    bg: vec3(33f, 33f, 33f).toRgb(),
    triangle: vec3(50f, 205f, 50f).toRgb()
  )

  # app loop
  while not w.windowShouldClose:
    # clear background
    glClearColorRGB(colors.bg, 1f)
    glClear(GL_COLOR_BUFFER_BIT)
    
    glEnableVertexAttribArray(0)
    glBindBuffer(GL_ARRAY_BUFFER, vertexbuffer)
    glVertexAttribPointer(0, 3, EGL_FLOAT, false, 0, nil)
    glDrawArrays(GL_TRIANGLES, 0, 3)
    glDisableVertexAttribArray(0)

    # swap buffers
    w.swapBuffers()
    glfwPollEvents()
  
  # app exit
  w.destroyWindow()
  glfwTerminate()

  glDeleteVertexArrays(1, vao.addr)
