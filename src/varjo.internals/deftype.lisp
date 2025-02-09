(in-package :varjo.internals)
(in-readtable :fn.reader)

(defmacro define-vari-type (name args type-form
                            &key valid-metadata-kinds)
  (let ((ephemeral (null type-form))
        (valid-metadata-kinds (listify valid-metadata-kinds)))
    (assert (not args) () "args not supported yet")
    (assert (symbolp type-form) () "compound & array types not yet supported")
    ;; If this ↑↑↑↑↑ changes then v-type-eq has to change too.
    (if ephemeral
        `(progn
           (eval-when (:compile-toplevel :load-toplevel :execute)
             (define-v-type-class ,name (v-ephemeral-type) ()))
           (v-def-glsl-template-fun ,name () nil () ,name)
           (defmethod meta-kinds-to-infer ((varjo-type ,name))
             (declare (ignore varjo-type))
             ',valid-metadata-kinds)
           ',name)
        (let ((shadowed-type (type-spec->type type-form)))
          `(progn
             (eval-when (:compile-toplevel :load-toplevel :execute)
               (define-v-type-class ,name (v-shadow-type)
                 ((shadowed-type :initform ,shadowed-type)
                  (glsl-string :initform ,(v-glsl-string shadowed-type)))))
             (defmethod meta-kinds-to-infer ((varjo-type ,name))
               (declare (ignore varjo-type))
               ',valid-metadata-kinds))))))

(defmacro v-deftype (name args type-form
                     &key valid-metadata-kinds)
  `(define-vari-type ,name ,args ,type-form :valid-metadata-kinds ,valid-metadata-kinds))

(defmacro define-shadow-type-functions (shadow-type &body function-identifiers)
  (flet ((func-form-p (x)
           (and (listp x) (eq (first x) 'function) (= (length x) 2))))
    (assert (v-typep (type-spec->type shadow-type) 'v-shadow-type) (shadow-type)
            'shadowing-funcs-for-non-shadow-type
            :name 'define-shadow-type-functions
            :shadow-type shadow-type)
    (assert (every #'func-form-p function-identifiers) ()
            'def-shadow-non-func-identifier
            :name 'def-shadow-non-func-identifier
            :func-ids (remove-if #'func-form-p function-identifiers))
    (let ((function-identifiers (mapcar #'second function-identifiers)))
      `(shadow-functions ',shadow-type ',function-identifiers))))

(defmacro define-shadow-type-constructor (shadow-type function-identifier)
  (flet ((func-form-p (x)
           (and (listp x) (eq (first x) 'function) (= (length x) 2))))
    (assert (func-form-p function-identifier) ()
            'def-shadow-non-func-identifier
            :name 'def-shadow-non-func-identifier
            :func-ids (list function-identifier))
    (let ((function-identifier (second function-identifier)))
      `(shadow-constructor-function ',shadow-type ',function-identifier))))

(defmacro def-shadow-type-constructor (shadow-type function-identifier)
  (warn 'v-deprecated
        :old 'def-shadow-type-constructor
        :new 'define-shadow-type-constructor)
  `(define-shadow-type-constructor ,shadow-type ,function-identifier))

#+nil
(v-deftype zoob () ())

#+nil
(v-deftype foob () :vec4)

#+nil
(v-deftype flart () :float)

#+nil
(define-shadow-type-functions flart
  #'(sin :float))

#+nil
(define-shadow-type-constructor flart #'(float :int))
