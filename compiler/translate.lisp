(in-package :varjo)
(in-readtable fn:fn-reader)

;;----------------------------------------------------------------------

(defgeneric translate (stage)
  (:method ((stage stage))
    (with-slots (stemcells-allowed) stage
      (flow-id-scope
        (let ((env (%make-base-environment
                    stage :stemcells-allowed stemcells-allowed)))
          (pipe-> (stage env)
            #'set-env-context
            #'process-primitive-type
            #'add-context-glsl-vars
            #'expand-input-variables
            #'process-uniforms
            #'compile-pass
            #'make-post-process-obj
            #'check-stemcells
            #'post-process-ast
            #'filter-used-items
            #'gen-in-arg-strings
            #'gen-in-decl-strings
            #'gen-out-var-strings
            #'process-output-primtive
            #'final-uniform-strings
            #'dedup-used-types
            #'final-string-compose
            #'package-as-final-result-object))))))

;;----------------------------------------------------------------------

(defun set-env-context (stage env)
  (setf (v-context env) (context stage))
  (values stage env))

;;----------------------------------------------------------------------

(defun add-context-glsl-vars (stage env)
  (values stage (add-glsl-vars env)))

;;----------------------------------------------------------------------

(defmethod expand-input-variable ((stage stage)
                                  (var-type v-ephemeral-type)
                                  (input-variable input-variable)
                                  (env environment))
  (declare (ignore stage env))
  ;; {TODO} Proper error
  (error "Varjo: Cannot have stage arguments with ephemeral types:~%~a has type ~a"
         (name input-variable) var-type))

(defmethod expand-input-variable ((stage stage)
                                  (var-type v-type)
                                  (input-variable input-variable)
                                  (env environment))
  (let* ((type (set-flow-id var-type (flow-id!)))
         (type (if (and (typep stage 'geometry-stage) (typep type 'v-array))
                   (make-into-block-array type *in-block-instance-name*)
                   type)))
    (values (v-make-value type env :glsl-name (glsl-name input-variable))
            (list (make-instance 'input-variable
                                 :name (name input-variable)
                                 :glsl-name (glsl-name input-variable)
                                 :type type
                                 :qualifiers (qualifiers input-variable)))
            nil)))

;; mutates env
(defun expand-input-variables (stage env)
  (mapcar (lambda (var)
            (vbind (input-value expanded-vars expanded-funcs)
                (expand-input-variable stage (v-type-of var) var env)
              ;;
              (%add-symbol-binding (name var) input-value env)
              ;;
              (add-lisp-name (name var) env (glsl-name input-value))
              ;;
              (setf (expanded-input-variables env)
                    (append (expanded-input-variables env) expanded-vars))
              ;;
              (loop :for func :in expanded-funcs :do
                 (%add-function (name func) func env))
              ;;
              ;; dont allow glsl name duplication
              (loop :for var :in expanded-vars :do
                 (declare-glsl-name-taken env (glsl-name var)))))
          (input-variables stage))
  (values stage env))

;;----------------------------------------------------------------------

(defun process-uniforms (stage env)
  (let ((uniforms (uniform-variables stage)))
    (map nil
         λ(with-slots (name type qualifiers glsl-name) _
            (case-member qualifiers
              (:ubo (process-ubo-uniform name glsl-name type qualifiers env))
              (:fake (add-fake-struct stage env))
              (otherwise (process-regular-uniform name glsl-name type
                                                  qualifiers env))))
         uniforms)
    (values stage env)))

;; mutates env
(defun process-regular-uniform (name glsl-name type qualifiers env)
  (let* ((true-type (set-flow-id (v-true-type type) (flow-id!)))
         (glsl-name (or glsl-name (safe-glsl-name-string name))))
    (%add-symbol-binding
     name
     (v-make-value true-type env :glsl-name glsl-name :read-only t)
     env)
    (add-lisp-name name env glsl-name)
    (let ((type-with-flow (set-flow-id type (flow-ids true-type))))
      (push (list name type-with-flow qualifiers glsl-name) (v-uniforms env))))
  env)

;; mutates env
(defun process-ubo-uniform (name glsl-name type qualifiers env)
  (let* ((true-type (set-flow-id (v-true-type type) (flow-id!)))
         (glsl-name (or glsl-name (safe-glsl-name-string name))))
    (%add-symbol-binding
     name (v-make-value true-type env :glsl-name glsl-name
                                 :function-scope 0 :read-only t)
     env)
    (let ((type-with-flow (set-flow-id type (flow-ids true-type))))
      (push (list name type-with-flow qualifiers glsl-name) (v-uniforms env))))
  env)

;;----------------------------------------------------------------------

(defgeneric %process-primitive-type (stage primitive env)
  ;;
  (:method ((stage vertex-stage) primitive env)
    (declare (ignore stage env))
    primitive)

  (:method ((stage tesselation-control-stage)
            primitive env)
    (declare (ignore stage env))
	(assert (typep primitive 'patches) ()
            'invalid-primitive-for-tesselation-stage
            :prim (type-of primitive))
	primitive)

  (:method ((stage tesselation-evaluation-stage)
            primitive env)
    (declare (ignore stage env))
    (assert (typep primitive 'patches) ()
            'invalid-primitive-for-tesselation-stage
            :prim (type-of primitive))
	primitive)

  (:method ((stage geometry-stage) primitive env)
    (declare (ignore env))
    (assert (typep primitive 'geometry-primitive) ()
            'invalid-primitive-for-geometry-stage
            :prim (type-of primitive))
    primitive)

  (:method ((stage fragment-stage) primitive env)
    (declare (ignore stage primitive env))
    nil))

(defun process-primitive-type (stage env)
  (let* ((prim (primitive-in stage))
         (prim (etypecase prim
                 (null nil)
                 ((or symbol list) (primitive-name-to-instance prim))
                 (primitive prim))))
    (setf (primitive-in stage) (%process-primitive-type stage prim env)))
  (values stage env))

;;----------------------------------------------------------------------

(defun compile-pass (stage env)
  (values (build-function :main () (lisp-code stage) nil env)
          stage
          env))

;;----------------------------------------------------------------------

(defgeneric establish-out-set-for-stage (stage main-func)
  ;;
  (:method ((stage geometry-stage) main-func)
    (assert (emptyp (return-set main-func)) ()
            'returns-in-geometry-stage :return-set (return-set main-func))
    (when (slot-boundp main-func 'emit-set)
      (or (slot-value main-func 'emit-set) #())))
  ;;
  (:method ((stage tesselation-control-stage) main-func)
    (assert (emptyp (return-set main-func)) ()
            'returns-in-geometry-stage :return-set (return-set main-func))
    (when (slot-boundp main-func 'emit-set)
      (or (%array-the-emit-vals-for-size '* (slot-value main-func 'emit-set))
          #())))

  (:method (stage main-func)
    (declare (ignore stage))
    (return-set main-func)))

(defun make-post-process-obj (main-func stage env)
  (make-instance
   'post-compile-process
   :stage stage
   :env env
   :used-external-functions (remove-duplicates (used-external-functions env))
   :all-functions (cons main-func (all-cached-compiled-functions env))
   :out-set (establish-out-set-for-stage stage main-func)
   :main-metadata (top-level-scoped-metadata main-func)))

;;----------------------------------------------------------------------

(defun check-stemcells (post-proc-obj)
  "find any stemcells in the result that that the same name and
   a different type. Then remove duplicates"
  (let ((stemcells
         (reduce #'append (mapcar #'stemcells (all-functions post-proc-obj)))))
    (mapcar
     (lambda (x)
       (with-slots (name (string string-name) type flow-id) x
         (declare (ignore string flow-id))
         (when (find-if (lambda (x)
                          (with-slots ((iname name) (itype type)) x
                            (and (equal name iname)
                                 (not (equal type itype)))))
                        stemcells)
           (error "Symbol ~a used with different implied types" name))))
     ;; {TODO} Proper error here
     stemcells)
    (setf (stemcells post-proc-obj)
          (remove-duplicates stemcells :test #'equal
                             :key (lambda (x)
                                    (slot-value x 'name))))
    post-proc-obj))

;;----------------------------------------------------------------------

(defun post-process-func-ast
    (func env flow-origin-map val-origin-map node-copy-map)
  ;; prime maps with args (env)
  ;; {TODO} need to prime expanded-input-variables & structs/array elements
  (labels ((uniform-raw (val)
             (slot-value (first (ids (first (listify (flow-ids val)))))
                         'val)))
    (let ((env (get-base-env env)))
      (loop :for (name) :in (v-uniforms env) :do
         (let ((binding (get-symbol-binding name nil env)))
           ;; {TODO} proper errror
           (assert (not (typep binding 'v-symbol-macro)) ()
                   "Varjo: Compiler Bug: Unexpanded symbol-macro found in ast")
           (let ((key (uniform-raw binding))
                 (val (make-uniform-origin :name name)))
             (setf (gethash key flow-origin-map) val)
             (setf (gethash key val-origin-map) val))))))

  (labels ((post-process-node (node walk parent &key replace-args)
             ;; we want a new copy as we will be mutating it
             (let ((new (copy-ast-node
                         node
                         :parent (gethash parent node-copy-map))))
               ;; store the lookup tables with every node
               (setf (slot-value new 'flow-id-origins) flow-origin-map
                     (slot-value new 'val-origins) val-origin-map)
               (with-slots (args val-origin flow-id-origin kind) new
                 ;;    maintain the relationship between this copied
                 ;;    node and the original
                 (setf (gethash node node-copy-map) new
                       ;; walk the args. OR, if the caller pass it,
                       ;; walk the replacement args and store them instead
                       args (mapcar λ(funcall walk _ :parent node)
                                    (or replace-args (ast-args node)))
                       ;;
                       val-origin (val-origins new)
                       ;; - - - - - - - - - - - - - - - - - - - - - -
                       ;; flow-id-origins gets of DESTRUCTIVELY adds
                       ;; the origin of the flow-id/s for this node.
                       ;; - - - - - - - - - - - - - - - - - - - - - -
                       ;; {TODO} redesign this madness
                       ;; - - - - - - - - - - - - - - - - - - - - - -
                       flow-id-origin (flow-id-origins new))
                 ;;
                 (when (typep (ast-kind new) 'v-function)
                   (setf kind (name (ast-kind new)))))
               new))

           (walk-node (node walk &key parent)
             (cond
               ;; remove progns with one form
               ((and (ast-kindp node 'progn) (= (length (ast-args node)) 1))
                (funcall walk (first (ast-args node)) :parent parent))

               ;; splice progns into let's implicit progn
               ((ast-kindp node 'let)
                (let ((args (ast-args node)))
                  (post-process-node
                   node walk parent :replace-args
                   `(,(first args)
                      ,@(loop :for a :in (rest args)
                           :if (and (typep a 'ast-node)
                                    (ast-kindp a 'progn))
                           :append (ast-args a)
                           :else :collect a)))))

               ;; remove return nodes
               ((ast-kindp node 'return)
                (funcall walk (first (ast-args node)) :parent parent))

               (t (post-process-node node walk parent)))))

    (let ((ast (walk-ast #'walk-node (ast func) :include-parent t)))
      (setf (slot-value func 'ast) ast))))

(defun post-process-ast (post-proc-obj)
  (let ((flow-origin-map (make-hash-table))
        (val-origin-map (make-hash-table))
        (node-copy-map (make-hash-table :test #'eq)))
    (map nil λ(post-process-func-ast _ (env post-proc-obj)
                                     flow-origin-map
                                     val-origin-map
                                     node-copy-map)
         (all-functions post-proc-obj)))
  post-proc-obj)

;;----------------------------------------------------------------------

(defun find-used-user-structs (functions env)
  (declare (ignore env))
  (let* ((used-types (normalize-used-types
                      (reduce #'append (mapcar #'used-types functions))))
         (struct-types
          (remove nil
                  (loop :for type :in used-types
                     :if (or (typep type 'v-struct)
                             (and (typep type 'v-array)
                                  (typep (v-element-type type) 'v-struct)))
                     :collect type)))
         (result (order-structs-by-dependency struct-types)))
    result))

(defun filter-used-items (post-proc-obj)
  "This changes the code-object so that used-types only contains used
   'user' defined structs."
  (with-slots (env) post-proc-obj
    (setf (used-user-structs post-proc-obj)
          (find-used-user-structs (all-functions post-proc-obj) env)))
  post-proc-obj)

;;----------------------------------------------------------------------

(defun calc-locations (types)
  ;;   "Takes a list of type objects and returns a list of positions
  ;; - usage example -
  ;; (let ((types (mapcar #'type-spec->type '(:mat4 :vec2 :float :mat2 :vec3))))
  ;;          (mapcar #'cons types (calc-positions types)))"
  (labels ((%calc-location (sizes type)
             (cons (+ (first sizes) (v-glsl-size type)) sizes)))
    (reverse (reduce #'%calc-location (butlast types) :initial-value '(0)))))


(defun gen-in-arg-strings (post-proc-obj)
  (with-slots (env stage) post-proc-obj
    (let* ((expanded-vars (expanded-input-variables env))
           (is-geom (typep (stage post-proc-obj) 'geometry-stage))
           (instance-name (when is-geom *in-block-instance-name*))
           (block-arr-length (when is-geom
                               (first
                                (v-dimensions
                                 (v-type-of
                                  (first expanded-vars))))))
           (locations (if (typep (stage post-proc-obj) 'vertex-stage)
                          (calc-locations (mapcar #'v-type-of expanded-vars))
                          (n-of nil (length expanded-vars))))
           (glsl-decls
            (mapcar (lambda (var location)
                      (gen-in-var-string (or (glsl-name var) (name var))
                                         (v-type-of var)
                                         (qualifiers var)
                                         location))
                    expanded-vars
                    locations)))
      ;;
      (setf (input-variable-glsl post-proc-obj)
            (if (requires-in-interface-block (stage post-proc-obj))
                (when glsl-decls
                  (list (write-interface-block
                         :in (in-block-name-for (stage post-proc-obj))
                         glsl-decls
                         :instance-name instance-name
                         :length block-arr-length)))
                glsl-decls))))
  post-proc-obj)

;;----------------------------------------------------------------------

(defun gen-in-decl-strings (post-proc-obj)
  (when (typep (stage post-proc-obj) 'geometry-stage)
    (setf (in-declarations post-proc-obj)
          (list (gen-geom-input-primitive-string
                 (primitive-in post-proc-obj)))))
  post-proc-obj)

;;----------------------------------------------------------------------

(defun gen-out-var-strings (post-proc-obj)
  (with-slots (stage out-set env) post-proc-obj
    (let* ((out-types (map 'list #'v-type-of out-set))
           (locations (if (typep stage 'fragment-stage)
                          (calc-locations out-types)
                          (loop for i below (length out-types) collect nil))))
      (dbind (glsl-decls output-variables)
          (loop :for out-val :across out-set
             :for location :in locations
             :for i :from 0
             :for glsl-name := (if (typep out-val 'external-return-val)
                                   (out-name out-val)
                                   (nth-return-name i stage))

             :collect (gen-out-var-string glsl-name
                                          (v-type-of out-val)
                                          (qualifiers out-val)
                                          location)
             :into glsl

             :collect (make-instance
                       'output-variable
                       :name (make-symbol glsl-name)
                       :glsl-name glsl-name
                       :type (v-type-of out-val)
                       :qualifiers (qualifiers out-val)
                       :location location)
             :into output-variables

             :finally (return (list glsl output-variables)))

        (setf (output-variable-glsl post-proc-obj)
              (if (requires-out-interface-block stage)
                  (when glsl-decls
                    (list (write-interface-block
                           :out
                           (out-block-name-for stage)
                           (if (typep stage 'vertex-stage)
                               (rest glsl-decls)
                               glsl-decls))))
                  glsl-decls))

        (setf (output-variables post-proc-obj) output-variables))

      post-proc-obj)))

;;----------------------------------------------------------------------

(defun process-output-primtive (post-proc-obj)
  (with-slots (main-metadata stage) post-proc-obj
    (typecase stage

      (geometry-stage
       (let* ((tl (find 'output-primitive main-metadata :key #'type-of)))
         ;; {TODO} proper error
         (assert tl () "Varjo: The function used as a geometry stage must have a top level output-primitive declaration")
         (setf (out-declarations post-proc-obj)
               (list (gen-geom-output-primitive-string tl)))
         (setf (primitive-out post-proc-obj)
               (primitive-name-to-instance (slot-value tl 'kind)))))

      (tesselation-control-stage
       (let* ((tl (find 'output-patch main-metadata :key #'type-of)))
         ;; {TODO} proper error
         (assert tl () "Varjo: The function used as a tesselation control stage must have a top level output-primitive declaration")
         (setf (out-declarations post-proc-obj)
               (list (gen-tess-con-output-primitive-string tl)))
         (setf (primitive-out post-proc-obj)
               (primitive-name-to-instance (list :patch (slot-value tl 'vertices))))))

      (tesselation-evaluation-stage
       ;; need to generate something that the geom shader could accept
       ;; (frag shader doesnt care so no need to think about it)
       (error "IMPLEMENT ME!"))

      (t (setf (primitive-out post-proc-obj)
               (primitive-in (stage post-proc-obj))))))

  post-proc-obj)

;;----------------------------------------------------------------------

(defun final-uniform-strings (post-proc-obj)
  (with-slots (env) post-proc-obj
    (let* ((final-strings nil)
           (structs (used-user-structs post-proc-obj))
           (uniforms (v-uniforms env))
           (implicit-uniforms nil))

      (loop :for (name type-obj qualifiers glsl-name) :in uniforms :do
         (let ((string-name (or glsl-name (safe-glsl-name-string name))))
           (push (make-instance
                  'uniform-variable
                  :name name
                  :qualifiers qualifiers
                  :glsl-name string-name
                  :type type-obj
                  :glsl-decl (cond
                               ((member :ubo qualifiers)
                                (write-ubo-block :uniform string-name
                                                 (v-slots type-obj)))
                               ((ephemeral-p type-obj) nil)
                               (t (gen-uniform-decl-string string-name type-obj
                                                           qualifiers))))
                 final-strings))
         (when (and (v-typep type-obj 'v-user-struct)
                    (not (find type-obj structs :key #'type->type-spec
                               :test #'v-type-eq)))
           (push type-obj structs)))

      (loop :for s :in (stemcells post-proc-obj) :do
         (with-slots (name string-name type cpu-side-transform) s
           (when (eq type :|unknown-type|) (error 'symbol-unidentified :sym name))
           (let ((type-obj (type-spec->type type)))
             (push (make-instance
                    'implicit-uniform-variable
                    :name name
                    :glsl-name string-name
                    :type type-obj
                    :cpu-side-transform cpu-side-transform
                    :glsl-decl (unless (ephemeral-p type-obj)
                                 (gen-uniform-decl-string
                                  (or string-name (error "stem cell without glsl-name"))
                                  type-obj
                                  nil)))
                   implicit-uniforms)

             (when (and (v-typep type-obj 'v-user-struct)
                        (not (find type-obj structs
                                   :key #'type->type-spec
                                   :test #'v-type-eq)))
               (push type-obj structs)))))
      ;;
      (setf (used-user-structs post-proc-obj) structs)
      (setf (uniforms post-proc-obj) final-strings)
      (setf (stemcells post-proc-obj) implicit-uniforms)
      post-proc-obj)))

;;----------------------------------------------------------------------

(defun dedup-used-types (post-proc-obj)
  (with-slots (main-env) post-proc-obj
    (setf (used-user-structs post-proc-obj)
          (remove-duplicates
           (mapcar #'v-signature (used-user-structs post-proc-obj))
           :test #'equal)))
  post-proc-obj)

;;----------------------------------------------------------------------

(defun final-string-compose (post-proc-obj)
  (values (gen-shader-string post-proc-obj)
          post-proc-obj))

;;----------------------------------------------------------------------

(defun package-as-final-result-object (final-glsl-code post-proc-obj)
  (with-slots (env stage) post-proc-obj
    (let* ((context (process-context-for-result (v-context env))))
      (make-instance
       (compiled-stage-type-for (stage post-proc-obj))
       ;; stage slots
       :input-variables (input-variables (stage post-proc-obj))
       :uniform-variables (uniforms post-proc-obj)
       :context context
       :lisp-code (lisp-code stage)
       :stemcells-allowed (allows-stemcellsp env)
       :primitive-in (primitive-in (stage post-proc-obj))
       ;; compiled-stage slots
       :glsl-code final-glsl-code
       :output-variables (output-variables post-proc-obj)
       :starting-stage (stage post-proc-obj)
       :implicit-uniforms (stemcells post-proc-obj)
       :used-external-functions (used-external-functions post-proc-obj)
       :function-asts (mapcar #'ast (all-functions post-proc-obj))
       :primitive-out (primitive-out post-proc-obj)))))

(defun process-context-for-result (context)
  ;; {TODO} having to remove this is probably a bug
  (remove :main context))
