(in-package :varjo)

(defgeneric compile-form (code env))
(defgeneric compile-place (code env &key allow-unbound))
(defgeneric compile-literal (code env &key errorp))
(defgeneric v-place-function-p (f))
(defgeneric type->type-spec (type))
(defgeneric v-true-type (object))
(defgeneric v-glsl-size (type))
(defgeneric v-type-eq (a b &optional env))
(defgeneric v-typep (a b &optional env))
(defgeneric v-casts-to (from-type to-type env))
(defgeneric v-casts-to-p (from-type to-type env))
(defgeneric post-initialise (object))
(defgeneric v-code-type-eq (a b &optional env))
(defgeneric v-make-value (type env &key glsl-name function-scope read-only))
(defgeneric get-flow-id-for-stem-cell (stem-cell-symbol e))
(defgeneric used-external-functions (e))
(defgeneric valid-for-contextp (func env))
(defgeneric add-symbol-macro (macro-name macro context env))
(defgeneric %get-symbol-macro-spec (macro-name env))
(defgeneric add-compiler-macro (macro env))
(defgeneric add-symbol-binding (var-name val env))
(defgeneric %add-symbol-binding (var-name val env))
(defgeneric add-equivalent-name (existing-name new-name))
(defgeneric add-form-binding (func/macro env))
(defgeneric %add-function (func-name func-spec env))
(defgeneric ast-kindp (node kind))
(defgeneric ast-typep (node type))
(defgeneric origin-name (origin))
(defgeneric val-origins (node &optional error-on-missingp))
(defgeneric indent (input &optional count))
(defgeneric v-fake-type (object))
(defgeneric v-special-functionp (func))
(defgeneric v-element-type (object))
(defgeneric merge-obs (objs &key type current-line to-block
                              return-set multi-vals
                              stemcells out-of-scope-args
                              place-tree mutations node-tree))
(defgeneric copy-code (code-obj &key type current-line to-block
                                  return-set multi-vals
                                  stemcells out-of-scope-args
                                  place-tree mutations node-tree))
(defgeneric flow-id-origins (node &optional error-on-missingp context))

(defgeneric func-need-arguments-compiledp (func))
(defgeneric get-macro (macro-name env))
(defgeneric get-symbol-macro (macro-name env))
(defgeneric get-compiler-macro (macro-name env))
(defgeneric get-symbol-binding (symbol respect-scope-rules env))
(defgeneric raw-ids (flow-id))
(defgeneric add-external-function (name in-args uniforms code
                                   &optional valid-glsl-versions))
(defgeneric delete-external-function (name in-args-types))
(defgeneric record-func-usage (func env))
(defgeneric v-name-map (env))
(defgeneric functions (object))
(defgeneric all-functions (object))
(defgeneric v-type-of (func))
(defgeneric compiled-functions (e key))
(defgeneric (setf compiled-functions) (val e key))
(defgeneric all-cached-compiled-functions (e))
(defgeneric map-environments (func e))
(defgeneric build-external-function (func env))
(defgeneric find-form-binding-by-literal (name env))
(defgeneric cast-code-inner (varjo-type src-obj cast-to-type env))
(defgeneric to-arg-form (uniform))
(defgeneric shadow-function (func shadowed-type new-type &key))
(defgeneric all-bound-symbols (env))
(defgeneric variables-in-scope (env))
(defgeneric variable-in-scope-p (name env))
(defgeneric variable-type (name env))
(defgeneric argument-type (name env))
(defgeneric variable-is-uniform-p (name env))
(defgeneric argument-is-uniform-p (name env))
(defgeneric variable-uniform-name (name env))
(defgeneric argument-uniform-name (name env))
(defgeneric add-lisp-form-as-uniform (form type-spec env &optional name))
(defgeneric metadata-for-variable (name metadata-key env))
(defgeneric %uniform-name (thing env))
(defgeneric metadata-for-flow-id (metadata-kind flow-id env))
(defgeneric (setf metadata-for-flow-id) (value flow-id env))
(defgeneric binding-in-higher-scope-p (binding env))
(defgeneric get-form-binding (name env))
(defgeneric add-fake-struct (var env))
(defgeneric get-stemcell-name-for-flow-id (id env))
(defgeneric metadata-for-argument (name metadata-key env))
(defgeneric v-superclass (type))
(defgeneric extract-stage-type (stage))
