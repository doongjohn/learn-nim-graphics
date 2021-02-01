import glm
import nimgl/glfw
import nimgl/opengl
import utils/gl


var colors =(
  skyblue: vec3f(51, 190, 255).toRGB,
  lightpink: vec3f(235, 64, 52).toRGB
)
var bgColor = colors.skyblue


proc keyProc(window: GLFWWindow, key: int32, scancode: int32, action: int32, mods: int32): void {.cdecl.} =
  var isPink {.global.} = false
  if key == GLFWKey.Escape and action == GLFWPress:
    window.setWindowShouldClose(true)
  elif key == GLFWKey.Space and action == GLFWPress:
    defer: isPink = not isPink
    bgColor = (if isPink: colors.skyblue else: colors.lightpink)


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
