import nimgl/opengl


template shaderPath*(path: string): string =
  when nimvm:
    "../shaders/" & path & ".glsl"
  else:
    "shaders/" & path & ".glsl"


proc shaderCompileStatus*(shader: uint32) =
  var status: int32
  glGetShaderiv(shader, GL_COMPILE_STATUS, status.addr);
  if status != GL_TRUE.ord:
    var
      log_length: int32
      message = newSeq[char](1024)
    glGetShaderInfoLog(shader, 1024, log_length.addr, message[0].addr);
    for c in message:
      stdout.write c


template checkResult(checkType: untyped, checkExeType: GLenum, id: uint32) =
  var compileResult: int32
  `glGet checkType iv`(id, checkExeType, compileResult.addr)
  if compileResult != GL_TRUE.ord:
    var
      log_length: int32
      message = newSeq[char](1024)
    `glGet checkType InfoLog`(id, 1024, log_length.addr, message[0].addr);
    for c in message:
      stdout.write c
  # var infoLogLength: int32
  # `glGet checkType iv`(id, GL_INFO_LOG_LENGTH, infoLogLength.addr)
  # if infoLogLength > 0:
  #   var errorMessage: cstring = newString(infoLogLength)
  #   `glGet checkType InfoLog`(id, infoLogLength, nil, errorMessage[0].addr)
  #   if errorMessage[0] != '\0':
  #     echo errorMessage
  #     quit()


template compileShader*(path: string, id: uint32) =
  echo "compiling shader: \"" & path & "\""
  var shaderCode: cstring = readFile(path)
  glShaderSource(id, 1'i32, shaderCode.addr, nil)
  glCompileShader(id)
  checkResult(Shader, GL_COMPILE_STATUS, id)


proc loadShaders*(vertShaderPath, fragShaderPath: string): uint32 =
  echo "compling shaders"
  var vertShaderID: uint32 = glCreateShader(GL_VERTEX_SHADER)
  var fragShaderID: uint32 = glCreateShader(GL_FRAGMENT_SHADER)
  compileShader(vertShaderPath, vertShaderID)
  compileShader(fragShaderPath, fragShaderID)

  echo "linking program"
  var programID: uint32 = glCreateProgram()
  glAttachShader(programID, vertShaderID);
  glAttachShader(programID, fragShaderID);
  glLinkProgram(programID);
  checkResult(Program, GL_LINK_STATUS, programID)

  echo "done"

  glDetachShader(programID, vertShaderID);
  glDetachShader(programID, fragShaderID);
  glDeleteShader(vertShaderID);
  glDeleteShader(fragShaderID);
  return programID
