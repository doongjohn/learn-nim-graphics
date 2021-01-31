import nimgl/opengl


template shaderPath*(path: string): string = "../shaders/" & path & ".glsl"


proc shaderCompileStatus*(shader: uint32) =
  var status: int32
  glGetShaderiv(shader, GL_COMPILE_STATUS, status.addr);
  if status != GL_TRUE.ord:
    var
      log_length: int32
      message = newSeq[char](1024)
    glGetShaderInfoLog(shader, 1024, log_length.addr, message[0].addr);
    echo message
