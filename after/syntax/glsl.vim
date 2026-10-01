" GLSL syntax highlighting
if exists("b:current_syntax")
  finish
endif

" Keywords
syn keyword glslKeyword contained return if else for while do break continue
syn keyword glslKeyword contained in out uniform attribute varying
syn keyword glslKeyword contained const struct void bool int float double
syn keyword glslKeyword contained vec2 vec3 vec4 ivec2 ivec3 ivec4
syn keyword glslKeyword contained bvec2 bvec3 bvec4 mat2 mat3 mat4
syn keyword glslKeyword contained sampler1D sampler2D sampler3D
syn keyword glslKeyword contained samplerCube sampler1DShadow sampler2DShadow
syn keyword glslKeyword contained lowp mediump highp precision
syn keyword glslKeyword contained invariant discard
syn keyword glslKeyword contained layout centroid flat smooth noperspective
syn keyword glslKeyword contained patch sample
syn keyword glslKeyword contained subroutine common partition active
syn keyword glslKeyword contained filter
syn keyword glslKeyword contained image1D image2D image3D
syn keyword glslKeyword contained imageCube imageRect
syn keyword glslKeyword contained uimage1D uimage2D uimage3D
syn keyword glslKeyword contained uimageCube uimageRect
syn keyword glslKeyword contained sampler1DArray sampler2DArray
syn keyword glslKeyword contained sampler1DArrayShadow sampler2DArrayShadow
syn keyword glslKeyword contained samplerBuffer sampler2DRect
syn keyword glslKeyword contained sampler2DRectShadow samplerBufferShadow
syn keyword glslKeyword contained usampler1D usampler2D usampler3D
syn keyword glslKeyword contained usamplerCube usampler1DArray
syn keyword glslKeyword contained usampler2DArray usamplerBuffer
syn keyword glslKeyword contained usampler2DRect
syn keyword glslKeyword contained atomic_uint
syn keyword glslKeyword contained image1DArray image2DArray
syn keyword glslKeyword contained image1DArrayShadow image2DArrayShadow
syn keyword glslKeyword contained uimage1DArray uimage2DArray
syn keyword glslKeyword contained uimage1DArrayShadow uimage2DArrayShadow

" Types
syn keyword glslType contained void bool int float double
syn keyword glslType contained vec2 vec3 vec4 ivec2 ivec3 ivec4 bvec2 bvec3 bvec4
syn keyword glslType contained mat2 mat3 mat4
syn keyword glslType contained sampler1D sampler2D sampler3D samplerCube
syn keyword glslType contained sampler1DShadow sampler2DShadow samplerCubeShadow
syn keyword glslType contained sampler2DRect sampler2DRectShadow
syn keyword glslType contained lowp mediump highp

" Preprocessor
syn region glslPreProc start="^\s*#" keepend contains=glslPreProcStatement
syn keyword glslPreProcStatement defined else endif elif endextension
syn keyword glslPreProcStatement extension error line pragma version
syn keyword glslPreProcStatement if ifdef ifndef

" Numbers
syn match glslNumber "\d\+\+\([eE][+-]\=\?\d\+\+\)\=\|\.\d\+\+\([eE][+-]\=\?\d\+\+\)\=\|[eE][+-]\=\?\d\+\+"

" Strings
syn region glslString start=+"\+ skip=+\\\\\|\\"+ end=+"+ contains=glslEscape
syn region glslString start=+'+ skip=+\\\\\|\\'+ end=+'+ contains=glslEscape
syn match glslEscape "\\.\|\\\"\|\\'\|\\\\\|\\\$"

" Comments
syn region glslComment start=+"\+" end="+/" contains=glslTodo
syn region glslComment start="//" end="$" contains=glslTodo

" Special
syn match glslSpecial "[{}();[],]"
syn match glslSpecial "+=\|-=\|\*=\|/=\|%=\|&\|=\|\|\|=\|^=\|<<=\|>>=\|>>>=\|&&\|||\|==\|!=\|<\|>\|<=\|>="

" Highlighting links
highlight link glslKeyword Keyword
highlight link glslType Type
highlight link glslPreProc PreProc
highlight link glslNumber Number
highlight link glslString String
highlight link glslComment Comment
highlight link glslSpecial Special
highlight link glslTodo Todo

" Define the syntax
let b:current_syntax = "glsl"

" Define common highlight groups that might be missed
highlight def link glslPreProcStatement PreProc
highlight def link glslEscape SpecialChar