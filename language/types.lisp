
(in-package :varjo)

;;----------------------------------------------------------------------

;; [TODO] ensure all cast lists have the correct order.

;; spec types are to handle the manifest ugliness of the glsl spec.
;; dear god just one txt file with every permutation of every glsl
;; function would have save me so many hours work.
(def-v-type-class v-tfd (v-spec-type) ())
(def-v-type-class v-tf (v-tfd) ()) ;; float vec*
(def-v-type-class v-td (v-tfd) ()) ;; double dvec*
(def-v-type-class v-tb (v-spec-type) ()) ;; bool bvec*
(def-v-type-class v-tiu (v-spec-type) ())
(def-v-type-class v-i-ui (v-spec-type) ()) ;; int uint
(def-v-type-class v-ti (v-tiu) ()) ;; int ivec*
(def-v-type-class v-tu (v-tiu) ()) ;; uint uvec*
(def-v-type-class v-tvec (v-spec-type) ()) ;;vec* uvec* ivec* [notice no dvec]
(def-v-type-class v-gvec4 (v-spec-type) ()) ;;vec4 uvec4 ivec4
(def-v-type-class v-gsampler-1d-array (v-spec-type) ())
(def-v-type-class v-gsampler-2d-array (v-spec-type) ())
(def-v-type-class v-gsampler-1d-shadow (v-spec-type) ())
(def-v-type-class v-gsampler-2d-shadow (v-spec-type) ())
(def-v-type-class v-gsampler-1d-array-shadow (v-spec-type) ())
(def-v-type-class v-gsampler-2d-array-shadow (v-spec-type) ())
(def-v-type-class v-gsampler-cube-array (v-spec-type) ())
(def-v-type-class v-gsampler-2d-ms-array (v-spec-type) ())
(def-v-type-class v-gsampler-rect-shadow (v-spec-type) ())
(def-v-type-class v-gsampler-cube-shadow (v-spec-type) ())
(def-v-type-class v-gsampler-cube-array-shadow (v-spec-type) ())
(def-v-type-class v-gimage-1d (v-spec-type) nil)
(def-v-type-class v-gimage-2d (v-spec-type) nil)
(def-v-type-class v-gimage-3d (v-spec-type) nil)
(def-v-type-class v-gimage-rect (v-spec-type) nil)
(def-v-type-class v-gimage-cube (v-spec-type) nil)
(def-v-type-class v-gimage-2d-ms (v-spec-type) nil)
(def-v-type-class v-gimage-buffer (v-spec-type) nil)
(def-v-type-class v-gimage-2d-rect (v-spec-type) nil)
(def-v-type-class v-gimage-1d-array (v-spec-type) nil)
(def-v-type-class v-gimage-2d-array (v-spec-type) nil)
(def-v-type-class v-gimage-cube-array (v-spec-type) nil)
(def-v-type-class v-gimage-2d-ms-array (v-spec-type) nil)



(def-v-type-class v-void (v-t-type)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "void" :reader v-glsl-string)))

(def-v-type-class v-bool (v-type v-tb)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "bool" :reader v-glsl-string)))

(def-v-type-class v-number (v-type) ())
(def-v-type-class v-int (v-number v-ti v-i-ui)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "int" :reader v-glsl-string)
   (casts-to :initform '(v-uint v-float v-double))))
(def-v-type-class v-uint (v-number v-tu v-i-ui)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "uint" :reader v-glsl-string)
   (casts-to :initform '(v-float v-double))))
(def-v-type-class v-float (v-number v-tf)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "float" :reader v-glsl-string)
   (casts-to :initform '(v-double))))
(def-v-type-class v-short-float (v-number)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "short-float" :reader v-glsl-string)))
(def-v-type-class v-double (v-number v-td)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "double" :reader v-glsl-string)))

(def-v-type-class v-matrix (v-container) ())
(def-v-type-class v-dmatrix (v-matrix) ())
(def-v-type-class v-mat2 (v-matrix)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "mat2" :reader v-glsl-string)
   (element-type :initform 'v-float)
   (dimensions :initform '(2 2) :reader v-dimensions)
   (glsl-size :initform 2)
   (casts-to :initform '(v-dmat2))))
(def-v-type-class v-mat3 (v-matrix)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "mat3" :reader v-glsl-string)
   (element-type :initform 'v-float)
   (dimensions :initform '(3 3) :reader v-dimensions)
   (glsl-size :initform 3)
   (casts-to :initform '(v-dmat3))))
(def-v-type-class v-mat4 (v-matrix)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "mat4" :reader v-glsl-string)
   (element-type :initform 'v-float)
   (dimensions :initform '(4 4) :reader v-dimensions)
   (glsl-size :initform 4)
   (casts-to :initform '(v-dmat4))))
(def-v-type-class V-MAT2X2 (v-matrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat2x2" :reader v-glsl-string)
   (element-type :initform 'V-FLOAT)
   (dimensions :initform '(2 2) :reader v-dimensions)
   (glsl-size :initform 2)))
(def-v-type-class V-MAT2X3 (v-matrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat2x3" :reader v-glsl-string)
   (element-type :initform 'V-FLOAT)
   (dimensions :initform '(2 3) :reader v-dimensions)
   (glsl-size :initform 2)
   (casts-to :initform '(v-dmat2x3))))
(def-v-type-class V-MAT2X4 (v-matrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat2x4" :reader v-glsl-string)
   (element-type :initform 'V-FLOAT)
   (dimensions :initform '(2 4) :reader v-dimensions)
   (glsl-size :initform 2)
   (casts-to :initform '(v-dmat2x4))))
(def-v-type-class V-MAT3X2 (v-matrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat3x2" :reader v-glsl-string)
   (element-type :initform 'V-FLOAT)
   (dimensions :initform '(3 2) :reader v-dimensions)
   (glsl-size :initform 3)
   (casts-to :initform '(v-dmat3x2))))
(def-v-type-class V-MAT3X3 (v-matrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat3x3" :reader v-glsl-string)
   (element-type :initform 'V-FLOAT)
   (dimensions :initform '(3 3) :reader v-dimensions)
   (glsl-size :initform 3)))
(def-v-type-class V-MAT3X4 (v-matrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat3x4" :reader v-glsl-string)
   (element-type :initform 'V-FLOAT)
   (dimensions :initform '(3 4) :reader v-dimensions)
   (glsl-size :initform 3)
   (casts-to :initform '(v-dmat3x4))))
(def-v-type-class V-MAT4X2 (v-matrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat4x2" :reader v-glsl-string)
   (element-type :initform 'V-FLOAT)
   (dimensions :initform '(4 2) :reader v-dimensions)
   (glsl-size :initform 4)
   (casts-to :initform '(v-dmat4x2))))
(def-v-type-class V-MAT4X3 (v-matrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat4x3" :reader v-glsl-string)
   (element-type :initform 'V-FLOAT)
   (dimensions :initform '(4 3) :reader v-dimensions)
   (glsl-size :initform 4)
   (casts-to :initform '(v-dmat4x3))))
(def-v-type-class V-MAT4X4 (v-matrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat4x4" :reader v-glsl-string)
   (element-type :initform 'V-FLOAT)
   (dimensions :initform '(4 4) :reader v-dimensions)
   (glsl-size :initform 4)))
(def-v-type-class v-dmat2 (v-dmatrix)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "mat2" :reader v-glsl-string)
   (element-type :initform 'v-double)
   (dimensions :initform '(2 2) :reader v-dimensions)
   (glsl-size :initform 2)
   (casts-to :initform '(v-dmat2))))
(def-v-type-class v-dmat3 (v-dmatrix)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "mat3" :reader v-glsl-string)
   (element-type :initform 'v-double)
   (dimensions :initform '(3 3) :reader v-dimensions)
   (glsl-size :initform 3)
   (casts-to :initform '(v-dmat3))))
(def-v-type-class v-dmat4 (v-dmatrix)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "mat4" :reader v-glsl-string)
   (element-type :initform 'v-double)
   (dimensions :initform '(4 4) :reader v-dimensions)
   (glsl-size :initform 4)
   (casts-to :initform '(v-dmat4))))
(def-v-type-class V-DMAT2X2 (v-dmatrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat2x2" :reader v-glsl-string)
   (element-type :initform 'V-DOUBLE)
   (dimensions :initform '(2 2) :reader v-dimensions)
   (glsl-size :initform 2)))
(def-v-type-class V-DMAT2X3 (v-dmatrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat2x3" :reader v-glsl-string)
   (element-type :initform 'V-DOUBLE)
   (dimensions :initform '(2 3) :reader v-dimensions)
   (glsl-size :initform 2)
   (casts-to :initform '(v-dmat2x3))))
(def-v-type-class V-DMAT2X4 (v-dmatrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat2x4" :reader v-glsl-string)
   (element-type :initform 'V-DOUBLE)
   (dimensions :initform '(2 4) :reader v-dimensions)
   (glsl-size :initform 2)
   (casts-to :initform '(v-dmat2x4))))
(def-v-type-class V-DMAT3X2 (v-dmatrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat3x2" :reader v-glsl-string)
   (element-type :initform 'V-DOUBLE)
   (dimensions :initform '(3 2) :reader v-dimensions)
   (glsl-size :initform 3)
   (casts-to :initform '(v-dmat3x2))))
(def-v-type-class V-DMAT3X3 (v-dmatrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat3x3" :reader v-glsl-string)
   (element-type :initform 'V-DOUBLE)
   (dimensions :initform '(3 3) :reader v-dimensions)
   (glsl-size :initform 3)))
(def-v-type-class V-DMAT3X4 (v-dmatrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat3x4" :reader v-glsl-string)
   (element-type :initform 'V-DOUBLE)
   (dimensions :initform '(3 4) :reader v-dimensions)
   (glsl-size :initform 3)
   (casts-to :initform '(v-dmat3x4))))
(def-v-type-class V-DMAT4X2 (v-dmatrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat4x2" :reader v-glsl-string)
   (element-type :initform 'V-DOUBLE)
   (dimensions :initform '(4 2) :reader v-dimensions)
   (glsl-size :initform 4)
   (casts-to :initform '(v-dmat4x2))))
(def-v-type-class V-DMAT4X3 (v-dmatrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat4x3" :reader v-glsl-string)
   (element-type :initform 'V-DOUBLE)
   (dimensions :initform '(4 3) :reader v-dimensions)
   (glsl-size :initform 4)
   (casts-to :initform '(v-dmat4x3))))
(def-v-type-class V-DMAT4X4 (v-dmatrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat4x4" :reader v-glsl-string)
   (element-type :initform 'V-DOUBLE)
   (dimensions :initform '(4 4) :reader v-dimensions)
   (glsl-size :initform 4)))

(def-v-type-class v-vector (v-container) ())
(def-v-type-class v-fvector (v-vector v-tf v-tvec) ())

(def-v-type-class v-vec2 (v-fvector)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "vec2" :reader v-glsl-string)
   (element-type :initform 'v-float)
   (dimensions :initform '(2) :reader v-dimensions)
   (casts-to :initform '(v-dvec2))))
(def-v-type-class v-vec3 (v-fvector)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "vec3" :reader v-glsl-string)
   (element-type :initform 'v-float)
   (dimensions :initform '(3) :reader v-dimensions)
   (casts-to :initform '(v-dvec3))))
(def-v-type-class v-vec4 (v-fvector v-gvec4)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "vec4" :reader v-glsl-string)
   (element-type :initform 'v-float)
   (dimensions :initform '(4) :reader v-dimensions)
   (casts-to :initform '(v-dvec4))))

(def-v-type-class v-bvector (v-vector v-tb) ())
(def-v-type-class v-bvec2 (v-bvector)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "bvec2" :reader v-glsl-string)
   (element-type :initform 'v-bool)
   (dimensions :initform '(2) :reader v-dimensions)))
(def-v-type-class v-bvec3 (v-bvector)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "bvec3" :reader v-glsl-string)
   (element-type :initform 'v-bool)
   (dimensions :initform '(3) :reader v-dimensions)))
(def-v-type-class v-bvec4 (v-bvector v-gvec4)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "bvec4" :reader v-glsl-string)
   (element-type :initform 'v-bool)
   (dimensions :initform '(4) :reader v-dimensions)))

(def-v-type-class v-uvector (v-vector v-tu) ())
(def-v-type-class v-uvec2 (v-uvector v-tvec)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "uvec2" :reader v-glsl-string)
   (element-type :initform 'v-uint)
   (dimensions :initform '(2) :reader v-dimensions)
   (casts-to :initform '(v-dvec2 v-vec2))))
(def-v-type-class v-uvec3 (v-uvector)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "uvec3" :reader v-glsl-string)
   (element-type :initform 'v-uint)
   (dimensions :initform '(3) :reader v-dimensions)
   (casts-to :initform '(v-dvec3 v-vec3))))
(def-v-type-class v-uvec4 (v-uvector v-gvec4)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "uvec4" :reader v-glsl-string)
   (element-type :initform 'v-uint)
   (dimensions :initform '(4) :reader v-dimensions)
   (casts-to :initform '(v-dvec4 v-vec4))))

(def-v-type-class v-ivector (v-vector v-ti) ())
(def-v-type-class v-ivec2 (v-ivector v-tvec)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "ivec2" :reader v-glsl-string)
   (element-type :initform 'v-int)
   (dimensions :initform '(2) :reader v-dimensions)
   (casts-to :initform '(v-uvec2 v-vec2 v-dvec2))))
(def-v-type-class v-ivec3 (v-ivector)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "ivec3" :reader v-glsl-string)
   (element-type :initform 'v-int)
   (dimensions :initform '(3) :reader v-dimensions)
   (casts-to :initform '(v-uvec3 v-vec3 v-dvec3))))
(def-v-type-class v-ivec4 (v-ivector v-gvec4)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "ivec4" :reader v-glsl-string)
   (element-type :initform 'v-int)
   (dimensions :initform '(4) :reader v-dimensions)
   (casts-to :initform '(v-uvec4 v-vec4 v-dvec4))))

(def-v-type-class v-dvector (v-vector) ())
(def-v-type-class v-dvec2 (v-dvector v-td)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "dvec2" :reader v-glsl-string)
   (element-type :initform 'v-dnt)
   (dimensions :initform '(2) :reader v-dimensions)
   (casts-to :initform '(v-uvec2 v-vec2 v-dvec2))))
(def-v-type-class v-dvec3 (v-dvector)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "dvec3" :reader v-glsl-string)
   (element-type :initform 'v-dnt)
   (dimensions :initform '(3) :reader v-dimensions)
   (casts-to :initform '(v-uvec3 v-vec3 v-dvec3))))
(def-v-type-class v-dvec4 (v-dvector v-gvec4)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "dvec4" :reader v-glsl-string)
   (element-type :initform 'v-dnt)
   (dimensions :initform '(4) :reader v-dimensions)
   (casts-to :initform '(v-uvec4 v-vec4 v-dvec4))))

(def-v-type-class v-sampler (v-type) ())
(def-v-type-class V-ISAMPLER-1D (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "isampler1D" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class V-ISAMPLER-1D-ARRAY (v-sampler v-gsampler-1d-array)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "isampler1DArray" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class V-ISAMPLER-2D (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "isampler2D" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class V-ISAMPLER-2D-ARRAY (v-sampler v-gsampler-2d-array)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "isampler2DArray" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class V-ISAMPLER-2D-MS (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "isampler2DMS" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class V-ISAMPLER-2D-MS-ARRAY (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "isampler2DMSArray" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class V-ISAMPLER-2D-RECT (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "isampler2DRect" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class V-ISAMPLER-3D (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "isampler3D" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class V-ISAMPLER-BUFFER (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "isamplerBuffer" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class V-ISAMPLER-CUBE (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "isamplerCube" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class V-ISAMPLER-CUBE-ARRAY (v-sampler v-gsampler-cube-array)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "isamplerCubeArray" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class v-sampler-1D (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler1D" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class v-sampler-1D-ARRAY (v-sampler v-gsampler-1d-array)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler1DArray" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class v-sampler-1D-ARRAY-SHADOW
    (v-sampler v-gsampler-1d-array-shadow)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler1DArrayShadow" :reader
                glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class v-sampler-1D-SHADOW (v-sampler v-gsampler-1d-shadow)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler1DShadow" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class v-sampler-2D (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler2D" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class v-sampler-2D-ARRAY (v-sampler v-gsampler-2d-array)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler2DArray" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class v-sampler-2D-ARRAY-SHADOW
    (v-sampler v-gsampler-2d-array-shadow)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler2DArrayShadow" :reader
                glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class v-sampler-2D-MS (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler2DMS" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class v-sampler-2D-MS-ARRAY (v-sampler v-gsampler-2d-ms-array)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler2DMSArray" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class v-sampler-2D-RECT (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler2DRect" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class v-sampler-2D-RECT-SHADOW (v-sampler v-gsampler-rect-shadow)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler2DRectShadow" :reader
                glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class v-sampler-2D-SHADOW (v-sampler v-gsampler-2d-shadow)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler2DShadow" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class v-sampler-3D (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler3D" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class v-sampler-BUFFER (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "samplerBuffer" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class v-sampler-CUBE (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "samplerCube" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class v-sampler-CUBE-ARRAY (v-sampler v-gsampler-cube-array)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "samplerCubeArray" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class v-sampler-cube-array-shadow
    (v-sampler v-gsampler-cube-array-shadow)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "samplerCubeArrayShadow" :reader
                glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class v-sampler-CUBE-SHADOW (v-sampler v-gsampler-cube-shadow)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "samplerCubeShadow" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class V-USAMPLER-1D (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "usampler1D" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class V-USAMPLER-1D-ARRAY (v-sampler v-gsampler-1d-array)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "usampler1DArray" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class V-USAMPLER-2D (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "usampler2D" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class V-USAMPLER-2D-ARRAY (v-sampler v-gsampler-2d-array)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "usampler2DArray" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class V-USAMPLER-2D-MS (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "usampler2DMS" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class V-USAMPLER-2D-MS-ARRAY (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "usampler2DMSArray" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class V-USAMPLER-2D-RECT (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "usampler2DRect" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class V-USAMPLER-3D (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "usampler3D" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class V-USAMPLER-BUFFER (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "usamplerBuffer" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class V-USAMPLER-CUBE (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "usamplerCube" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))
(def-v-type-class V-USAMPLER-CUBE-ARRAY (v-sampler v-gsampler-cube-array)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "usamplerCubeArray" :reader v-glsl-string)
   (element-type :initform 'V-VEC4)))

;;----------------------------------------------------------------------

(def-v-type-class v-atomic-uint (v-t-type)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "atomic_uint" :reader v-glsl-string)))

;;----------------------------------------------------------------------


(def-v-type-class v-image-1d (v-t-type v-gimage-1d)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "image1D" :reader v-glsl-string)))

(def-v-type-class v-iimage-1d (v-t-type v-gimage-1d)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "iimage1D" :reader v-glsl-string)))

(def-v-type-class v-uimage-1d (v-t-type v-gimage-1d)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "uimage1D" :reader v-glsl-string)))

(def-v-type-class v-image-2d (v-t-type v-gimage-2d)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "image2D" :reader v-glsl-string)))

(def-v-type-class v-iimage-2d (v-t-type v-gimage-2d)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "iimage2D" :reader v-glsl-string)))

(def-v-type-class v-uimage-2d (v-t-type v-gimage-2d)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "uimage2D" :reader v-glsl-string)))

(def-v-type-class v-image-3d (v-t-type v-gimage-3d)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "image3D" :reader v-glsl-string)))

(def-v-type-class v-iimage-3d (v-t-type v-gimage-3d)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "iimage3D" :reader v-glsl-string)))

(def-v-type-class v-uimage-3d (v-t-type v-gimage-3d)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "uimage3D" :reader v-glsl-string)))

(def-v-type-class v-image-2d-rect (v-t-type v-gimage-2d-rect)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "image2DRect" :reader v-glsl-string)))

(def-v-type-class v-iimage-2d-rect (v-t-type v-gimage-2d-rect)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "iimage2DRect" :reader v-glsl-string)))

(def-v-type-class v-uimage-2d-rect (v-t-type v-gimage-2d-rect)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "uimage2DRect" :reader v-glsl-string)))

(def-v-type-class v-image-cube (v-t-type v-gimage-cube)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "imageCube" :reader v-glsl-string)))

(def-v-type-class v-iimage-cube (v-t-type v-gimage-cube)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "iimageCube" :reader v-glsl-string)))

(def-v-type-class v-uimage-cube (v-t-type v-gimage-cube)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "uimageCube" :reader v-glsl-string)))

(def-v-type-class v-image-buffer (v-t-type v-gimage-buffer)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "imageBuffer" :reader v-glsl-string)))

(def-v-type-class v-iimage-buffer (v-t-type v-gimage-buffer)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "iimageBuffer" :reader v-glsl-string)))

(def-v-type-class v-uimage-buffer (v-t-type v-gimage-buffer)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "uimageBuffer" :reader v-glsl-string)))

(def-v-type-class v-image-1d-array (v-t-type v-gimage-1d-array)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "image1DArray" :reader v-glsl-string)))

(def-v-type-class v-iimage-1d-array (v-t-type v-gimage-1d-array)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "iimage1DArray" :reader v-glsl-string)))

(def-v-type-class v-uimage-1d-array (v-t-type v-gimage-1d-array)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "uimage1DArray" :reader v-glsl-string)))

(def-v-type-class v-image-2d-array (v-t-type v-gimage-2d-array)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "image2DArray" :reader v-glsl-string)))

(def-v-type-class v-iimage-2d-array (v-t-type v-gimage-2d-array)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "iimage2DArray" :reader v-glsl-string)))

(def-v-type-class v-uimage-2d-array (v-t-type v-gimage-2d-array)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "uimage2DArray" :reader v-glsl-string)))

(def-v-type-class v-image-cube-array (v-t-type v-gimage-cube-array)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "imageCubeArray" :reader v-glsl-string)))

(def-v-type-class v-iimage-cube-array (v-t-type v-gimage-cube-array)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "iimageCubeArray" :reader v-glsl-string)))

(def-v-type-class v-uimage-cube-array (v-t-type v-gimage-cube-array)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "uimageCubeArray" :reader v-glsl-string)))

(def-v-type-class v-image-2d-ms (v-t-type v-gimage-2d-ms)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "image2DMS" :reader v-glsl-string)))

(def-v-type-class v-iimage-2d-ms (v-t-type v-gimage-2d-ms)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "iimage2DMS" :reader v-glsl-string)))

(def-v-type-class v-uimage-2d-ms (v-t-type v-gimage-2d-ms)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "uimage2DMS" :reader v-glsl-string)))

(def-v-type-class v-image-2d-ms-array (v-t-type v-gimage-2d-ms-array)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "image2DMSArray" :reader v-glsl-string)))

(def-v-type-class v-iimage-2d-ms-array (v-t-type v-gimage-2d-ms-array)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "iimage2DMSArray" :reader v-glsl-string)))

(def-v-type-class v-uimage-2d-ms-array (v-t-type v-gimage-2d-ms-array)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "uimage2DMSArray" :reader v-glsl-string)))

;;----------------------------------------------------------------------
;; pretty sure these two are incorrect, but is what was in the scraped site

(def-v-type-class v-gbuffer-image (v-spec-type) nil)

(def-v-type-class v-buffer-image (v-t-type v-gbuffer-image)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "gbufferImage" :reader v-glsl-string)))
