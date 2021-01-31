import glm
import nimgl/glfw
import nimgl/opengl
import utils/gl


var bgColor = vec3(51f, 190f, 255f).toRGB
var isRed = false


proc keyProc(window: GLFWWindow, key: int32, scancode: int32, action: int32,
    mods: int32): void {.cdecl.} =
  if key == GLFWKey.Escape and action == GLFWPress:
    window.setWindowShouldClose(true)
  elif key == GLFWKey.Space and action == GLFWPress:
    defer: isRed = not isRed
    bgColor =
      if not isRed:
        vec3(235f, 64f, 52f).toRGB
      else:
        vec3(51f, 190f, 255f).toRGB


proc main* =
  doAssert glfwInit()

  # GLFW settings
  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE) # To make MacOS happy
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE) # We don't want the old OpenGL 
  glfwWindowHint(GLFWResizable, GLFW_FALSE) # disable window resize

  let w: GLFWWindow = glfwCreateWindow(800, 600, "NimGL")
  if w == nil:
    quit(-1)

  discard w.setKeyCallback(keyProc)
  w.makeContextCurrent()

  doAssert glInit()

  # app main loop
  while not w.windowShouldClose:
    glfwPollEvents()
    glClearColor(bgColor.x, bgColor.y, bgColor.z, 1f)
    glClear(GL_COLOR_BUFFER_BIT)
    w.swapBuffers()
  
  # app exit
  w.destroyWindow()
  glfwTerminate()
