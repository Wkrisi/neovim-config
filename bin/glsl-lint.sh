#!/usr/bin/env bash
# GLSL linter: determines shader stage and runs glslangValidator.
# Emits normalized `file:line: message` diagnostics on stdout.

set -u

FILE="${1:-}"
if [[ -z "$FILE" ]]; then
  echo "usage: glsl-lint.sh <file>" >&2
  exit 1
fi

if ! command -v glslangValidator >/dev/null 2>&1; then
  echo "$FILE:1:error: glslangValidator not found in PATH (install glslang-tools)"
  exit 0
fi

EXT="${FILE##*.}"

detect_stage_from_ext() {
  case "$EXT" in
    vert|vs)            echo "vert" ;;
    frag|fs)            echo "frag" ;;
    geom|gs)            echo "geom" ;;
    tesc)               echo "tesc" ;;
    tese)               echo "tese" ;;
    comp|cs)            echo "comp" ;;
    mesh)               echo "mesh" ;;
    task)               echo "task" ;;
    rgen|rchit|rahit|rmiss|rinters|rcall)
                        echo "raygen" ;;
    *)                  echo "" ;;
  esac
}

# Heuristic stage detection for extensionless/generic .glsl files
detect_stage_from_content() {
  local content
  content="$(cat "$FILE" 2>/dev/null)"
  if [[ -z "$content" ]]; then
    echo ""
    return
  fi
  if grep -qE 'gl_FragColor|gl_FragDepth' <<<"$content"; then
    echo "frag"
  elif grep -qE 'out[[:space:]]+vec[234]' <<<"$content" && ! grep -qE 'gl_Position|gl_VertexID' <<<"$content"; then
    echo "frag"
  elif grep -qE 'gl_Position|gl_VertexID|gl_Vertex|gl_InstanceID' <<<"$content"; then
    echo "vert"
  elif grep -qE 'gl_TessCoord|gl_PatchVerticesIn' <<<"$content"; then
    echo "tese"
  elif grep -qE 'gl_out\s*\[' <<<"$content"; then
    echo "tesc"
  elif grep -qE 'gl_PrimitiveID|gl_Layer' <<<"$content" && grep -qE 'gl_in\s*\[' <<<"$content"; then
    echo "geom"
  elif grep -qE 'gl_GlobalInvocationID|gl_LocalInvocationID|gl_WorkGroupID' <<<"$content"; then
    echo "comp"
  elif grep -qE 'gl_MeshVerticesEXT|gl_PrimitiveTriangleIndicesEXT|gl_MeshPrimitivesEXT' <<<"$content"; then
    echo "mesh"
  elif grep -qE 'gl_TaskGroupSharedARB|gl_MeshVerticesEXT' <<<"$content"; then
    echo "task"
  fi
}

STAGE="$(detect_stage_from_ext)"

ARGS=()
if [[ -n "$STAGE" ]]; then
  ARGS=(-S "$STAGE")
else
  STAGE="$(detect_stage_from_content)"
  if [[ -n "$STAGE" ]]; then
    ARGS=(-S "$STAGE")
  fi
fi

OUT="$(glslangValidator "${ARGS[@]}" "$FILE" 2>&1)"
RC=$?

if [[ $RC -eq 0 ]]; then
  exit 0
fi

# glslangValidator prints:
#   ERROR: 0:<line>: '<token>' : <message>
#   WARNING: 0:<line>: '<token>' : <message>
# Normalize 0:<line> to <file>:<line>
while IFS= read -r line; do
  if [[ "$line" =~ ^(ERROR|WARNING):[[:space:]]*[0-9]+:([0-9]+):[[:space:]]*(.*)$ ]]; then
    lvl="${BASH_REMATCH[1]}"
    lnum="${BASH_REMATCH[2]}"
    msg="${BASH_REMATCH[3]}"
    if [[ "$lvl" == "ERROR" ]]; then
      echo "$FILE:$lnum:error: $msg"
    else
      echo "$FILE:$lnum:warning: $msg"
    fi
  fi
done <<< "$OUT"

exit 0