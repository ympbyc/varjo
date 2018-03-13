(in-package :varjo.internals)

;;------------------------------------------------------------
;; GLSL Structs
;;--------------

;; (vdefstruct thing ()
;;   (a v-float)
;;   (to-long-to-blah v-int :accessor b))

(defun true-type-name (name) (symb 'true_ name))
(defun fake-type-name (name) (symb 'fake_ name))

;;[TODO] should this use defun?
;;       pro: this is a global struct so global func
;;       con: shadowing.. add-function for global doesnt check.
(defmacro v-defstruct (name context &body slots)
  (destructuring-bind (name &key shadowing constructor) (listify name)
    (let* ((name-string (safe-glsl-name-string name))
           (class-name (or shadowing name))
           (true-type-name (true-type-name name))
           (fake-type-name (fake-type-name name))
           (slots-with-types
            (mapcar (lambda (slot)
                      (dbind (name type . rest) slot
                        `(,name
                          ,(type-spec->type type)
                          ,@rest)))
                    slots))
           (slot-transforms
            (mapcar (lambda (x)
                      (dbind (slot-name slot-type . acc) x
                        (let* ((accessor (if (eq :accessor (first acc))
                                             (second acc)
                                             (symb name '- slot-name)))
                               (transform
                                (format nil "~~a.~a"
                                        (safe-glsl-name-string slot-name))))
                          (list slot-name slot-type accessor transform))))
                    slots))
           (slot-transforms-type-obj
            (mapcar (lambda (x)
                      (dbind (name type acc tran) x
                        (list name (type-spec->type type) acc tran)))
                    slot-transforms))
           (constructor-name (symb 'make- (or constructor name))))
      `(progn
         (eval-when (:compile-toplevel :load-toplevel :execute)
           (define-v-type-class ,class-name (v-user-struct)
             ((glsl-string :initform ,name-string :initarg :glsl-string
                           :reader v-glsl-string)
              (signature :initform ,(gen-struct-sig
                                     name-string slots-with-types)
                         :initarg :signature :accessor v-signature)
              (slots :initform ',slot-transforms-type-obj
                     :reader v-slots)))
           (define-v-type-class ,true-type-name (,class-name) ())
           (define-v-type-class ,fake-type-name (,class-name)
             ((signature :initform ""))))
         ,(when shadowing `(add-alternate-type-name ',name ',class-name))
         (defmethod v-true-type ((object ,class-name))
           (make-instance ',true-type-name
                          :flow-ids (flow-ids object)
                          :qualifiers (qualifiers object)))
         (defmethod v-fake-type ((object ,class-name))
           (make-instance ',fake-type-name
                          :flow-ids (flow-ids object)
                          :qualifiers (qualifiers object)))
         (defmethod type->type-spec ((type ,true-type-name))
           ',name)
         (v-def-glsl-template-fun ,constructor-name
                                  ,(append (loop :for slot :in slots :collect (first slot))
                                           (when context `(&context ,@context)))
                                  ,(format nil "~a(~{~a~^,~^ ~})" name-string
                                           (n-of "~a" (length slots)))
                                  ,(loop :for slot :in slots :collect (second slot))
                                  ,true-type-name :v-place-index nil)
         ,@(make-struct-accessors name true-type-name context slot-transforms)
         ,(make-copy-structure name constructor-name slot-transforms)
         ',name))))

(defmethod v-glsl-size ((type v-user-struct))
  (reduce #'+ (mapcar #'v-glsl-size (mapcar #'second (v-slots type)))))

(defun make-copy-structure (name constructor-name transforms)
  `(v-defun copy-structure ((x ,name))
     (,constructor-name
      ,@(loop :for (nil nil accessor) :in transforms :collect
           `(,accessor x)))))

(defun make-struct-accessors (name true-type-name context transforms)
  (loop :for (nil slot-type accessor slot-transform) :in transforms :collect
     `(v-def-glsl-template-fun
       ,accessor
       (,(symb name '-ob) ,@(when context `(&context ,@context)))
       ,slot-transform
       (,true-type-name)
       ,slot-type
       :v-place-index 0)))

(defun gen-struct-sig (name-string slots-with-types)
  (format nil "struct ~a {~%~{~a~%~}};"
          name-string
          (mapcar #'gen-slot-string slots-with-types)))

(defun gen-slot-string (slot)
  (destructuring-bind (slot-name slot-type &key accessor) slot
    (declare (ignore accessor))
    (let ((name slot-name))
      (if (typep slot-type 'v-array)
          (format nil "    ~a ~a[~a];"
                  (v-glsl-string (v-element-type slot-type))
                  (safe-glsl-name-string name)
                  (v-dimensions slot-type))
          (format nil "    ~a ~a;"
                  (v-glsl-string slot-type)
                  (safe-glsl-name-string name))))))


(defmethod expand-input-variable ((stage stage)
                                  (var-type v-struct)
                                  (input-variable input-variable)
                                  (env environment))
  (declare (ignore stage))
  (assert (eq var-type (v-type-of input-variable)))
  (let* ((glsl-name (glsl-name input-variable))
         (fake-struct (set-flow-id (v-fake-type var-type) (flow-id!))))
    ;;
    (loop :for (slot-name slot-type accessor) :in (v-slots var-type)
       :for fake-slot-name = (fake-slot-name glsl-name slot-name)

       :collect (make-function-obj accessor
                                   fake-slot-name
                                   nil ;; {TODO} Must be context
                                   (list fake-struct)
                                   (make-type-set slot-type)
                                   :v-place-index nil
                                   :pure t)
       :into funcs

       :collect (make-instance
                 'input-variable
                 :name fake-slot-name
                 :glsl-name fake-slot-name
                 :type (qualify-type slot-type
                                     (qualifiers
                                      (v-type-of input-variable))))
       :into vars

       :finally (return
                  (values (v-make-value fake-struct env
                                        :glsl-name glsl-name
                                        :read-only t)
                          vars
                          funcs)))))

(defun fake-slot-name (in-var-name slot-name)
  (format nil "fk_~a_~a" (string-downcase (string in-var-name))
          (string-downcase (safe-glsl-name-string slot-name))))
