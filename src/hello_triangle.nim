import glm
import nimgl/glfw
import nimgl/opengl
import utils
import utils/gl


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
  gl.printOpenGLVersion()

  # my first triangle!
  let vpositions = [
    vec3f(-0.5, -0.5, 0.0),
    vec3f( 0.5, -0.5, 0.0),
    vec3f( 0.0,  0.5, 0.0)
  ]
  let vcolors = [
    vec4f(1, 0, 0, 1),
    vec4f(0, 1, 0, 1),
    vec4f(0, 0, 1, 1)
  ]
  var vertices = ...(
    vpositions[0], vcolors[0],
    vpositions[1], vcolors[1],
    vpositions[2], vcolors[2]
  )

  # create vao
  var vao = gl.genVertexArrays(1)
  glBindVertexArray(vao)
  
  # create vbo
  var vbo = gl.genBuffers(1)
  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBufferData(GL_ARRAY_BUFFER, cint(sizeof(cfloat) * vertices.len), vertices[0].addr, GL_STATIC_DRAW)

  # set vertex positions
  glEnableVertexAttribArray(0)
  glVertexAttribPointer(0, 3, EGL_FLOAT, false, 7 * sizeof(cfloat), nil)
  
  # set vertex colors
  glEnableVertexAttribArray(1)
  glVertexAttribPointer(1, 4, EGL_FLOAT, false, 7 * sizeof(cfloat), cast[pointer](3 * sizeof(cfloat)))
  
  # deselect vbo, vao
  glBindBuffer(GL_ARRAY_BUFFER, 0)
  glBindVertexArray(0)
  
  # compile shaders
  let programID = linkProgram(
    compileShader(GL_VERTEX_SHADER, ~"shaders/triangle/vertex_shader.glsl"),
    compileShader(GL_FRAGMENT_SHADER, ~"shaders/triangle/fragment_shader.glsl")
  )

  # app main loop
  while not w.windowShouldClose:
    # clear background
    gl.clearColorRGB(vec3f(33, 33, 33).toRGB, 1f)
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
    
    # use shader
    glUseProgram(programID)

    # select vao
    glBindVertexArray(vao)
    glDrawArrays(GL_TRIANGLES, 0, 3) # draw triangle
    
    # deselect vao
    glBindVertexArray(0)

    
    # swap buffers
    w.swapBuffers()

    # poll events
    glfwPollEvents()
    
  # app exit
  w.destroyWindow()
  glfwTerminate()

  glDeleteVertexArrays(1, vao.addr)
