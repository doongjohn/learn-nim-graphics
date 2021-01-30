import nimgl/glfw
import nimgl/opengl


proc toRGB(vec: tuple[x, y, z: float32]): tuple[x, y, z: GLfloat] =
  return (vec.x / 255f, vec.y / 255f, vec.z / 255f)


var bgColor = (51f, 190f, 255f).toRGB
var isRed = false


proc keyProc(window: GLFWWindow, key: int32, scancode: int32, action: int32, mods: int32): void {.cdecl.} =
  if key == GLFWKey.Escape and action == GLFWPress:
    window.setWindowShouldClose(true)
  elif key == GLFWKey.Enter and action == GLFWPress:
    defer: isRed = not isRed
    bgColor = 
      if not isRed: 
        (235f, 64f, 52f).toRGB 
      else: 
        (51f, 190f, 255f).toRGB


proc main() =
  assert glfwInit()

  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE) # Used for Mac
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_FALSE)

  let w: GLFWWindow = glfwCreateWindow(800, 600, "NimGL")
  if w == nil:
    quit(-1)

  discard w.setKeyCallback(keyProc)
  w.makeContextCurrent()

  assert glInit()

  while not w.windowShouldClose:
    glfwPollEvents()
    glClearColor(bgColor.x, bgColor.y, bgColor.z, 1f)
    glClear(GL_COLOR_BUFFER_BIT)
    w.swapBuffers()

  w.destroyWindow()
  glfwTerminate()


main()