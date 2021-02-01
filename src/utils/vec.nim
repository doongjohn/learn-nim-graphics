import glm


template toSeq*[T](args: varargs[Vec3[T]]): seq[T] =
  var result: seq[T]
  for arg in args:
    result.add arg.x
    result.add arg.y
    result.add arg.z
  result


template toSeq*[T](args: varargs[Vec4[T]]): seq[T] =
  var result: seq[T]
  for arg in args:
    result.add arg.x
    result.add arg.y
    result.add arg.z
    result.add arg.w
  result