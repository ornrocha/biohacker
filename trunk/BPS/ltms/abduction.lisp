;; Ex 3, Chapter 10

; a literal is a unique pair (<node> . <label>)
; where <label> is either :TRUE or :FALSE.

; the needs of a literal are a disjunctive set of conjunctive sets
; of literals, which if known, would force the literal to be true

; literal-needs is an association list of (<literal> . <needs>)

(defun unknown-literals (clause &optional except-nodes)
  ;; returns all unknown literals of the given clause
  ;; except those whose node is in the except-nodes list
  (remove-if
   #'(lambda (literal) 
       (let ((node (car literal)))
	(or (known-node? node)
	    (find node except-nodes))))
   (clause-literals clause)))

(defun node-literal (node label)
  ;; retrieves the literal corresponding (node . label)
  (funcall
   (ecase label (:TRUE #'tms-node-true-literal) (:FALSE #'tms-node-false-literal))
   node))

(defun negate-literal (literal &aux node fun)
  ;; retrieves the literal corresponding to the negation of the given literal
  (setq node (car literal))
  (node-literal (car literal) (ecase (cdr literal) (:TRUE :FALSE) (:FALSE :TRUE))))

(defun node-needs-1 (node label &aux node-list clauses)
  ;; returns the immediate needs of (node . label)
  (when (unknown-node? node)
    (setq clauses ;; unsatisfied clauses in which (node . label) appears
	  (remove-if #'satisfied-clause?
	   (funcall
	    (ecase label (:TRUE #'tms-node-true-clauses) (:FALSE #'tms-node-false-clauses))
	    node)))
    (setq node-list (list node))
    (mapcar #'(lambda (clause)
		;; setting of the unknown literals which would force (node . label)
		(mapcar #'negate-literal (unknown-literals clause node-list)))
	    clauses)))

(defun literal->fact (literal &aux form)
  ;; the pretty representation of a literal
  (setq form (datum-lisp-form (tms-node-datum (car literal))))
  (ecase (cdr literal)
    (:TRUE form)
    (:FALSE (list :NOT form))))

(defun literal-set->fact-set (set)
  (mapcar #'literal->fact set))

(defun literal-sets->fact-sets (sets)
  (mapcar #'literal-set->fact-set sets))

(defun needs-1 (fact label &aux node)
  (setq node (get-tms-node fact))
  (literal-sets->fact-sets (node-needs-1 node label)))

(defun union-to-each (set ssets)
  ;; returns all unions of the given set with each set in ssets
  (do ((ssets ssets (cdr ssets))
       (result nil (cons (union set (car ssets)) result)))
      ((null ssets) result)))

(defun all-possible-unions (sssets)
  ;; given a set of sets of sets, returns a set of sets
  ;; representing all possible unions of one set from each set of sets
  (do ((sssets sssets (cdr sssets))
       (result (list nil)
	       (mapcan 
		#'(lambda (set)
		    (union-to-each set result))
		(car sssets))))
      ((null sssets) result)))

(defun all-variations-on-set (set literal-needs)
  (all-possible-unions
   (mapcar 
    #'(lambda (literal)
	(cdr (assoc literal literal-needs)))
    set)))

(defun function-variations-on-set (literal-needs)
  #'(lambda (set) 
      (mapcar #'remove-duplicates (all-variations-on-set set literal-needs))))

(defun remove-supersets (sets &aux new-sets new-todo new-keep)
  (do ((sets sets new-sets)
       (keep nil new-keep)
       (todo nil new-todo))
      ((and (null sets) (null todo))
       keep)
    (cond 
     ((null sets)
      (setq new-sets sets)
      (setq new-keep (cons (car todo) keep))
      (setq new-todo (cdr todo)))
     ((null todo)
      (setq new-sets (cdr sets))
      (setq new-keep keep)
      (setq new-todo (cons (car sets) todo)))
     ((some #'(lambda (set) (subsetp set (car sets)))
	       todo)
      (setq new-sets (cdr sets))
      (setq new-keep keep)
      (setq new-todo todo))
     ((some #'(lambda (set) (subsetp (car sets) set))
	       todo)
      (setq new-sets (cdr sets))
      (setq new-keep keep)
      (setq new-todo
	    (cons (car sets)
		  (remove-if #'(lambda (set) (subsetp (car sets) set))
			     todo))))
     (t
      (setq new-sets (cdr sets))
      (setq new-keep keep)
      (setq new-todo (cons (car sets) todo))))))

(defun all-variations-on-sets (sets literal-needs)
  (remove-supersets
   (mapcan (function-variations-on-set literal-needs)
	   (remove-supersets sets))))

(defun add-literal-as-set-if (matching-patterns literal sets)
  (if (or (null matching-patterns)
	  (funcall matching-patterns (literal->fact literal)))
      (cons (list literal) sets)
    sets))

(defun add-literal-needs (literal
			    &optional (matching-patterns nil)
			     (literal-needs-list nil)
			       &aux sets-1 sub-literals sets)
  (setq literal-needs-list
	(acons literal :PENDING literal-needs-list))
  (setq sets-1 (node-needs-1 (car literal)
			      (cdr literal)))
  (setq sub-literals (remove-duplicates (apply #'append sets-1)))
  (dolist (sub-literal sub-literals)
    (unless (assoc sub-literal literal-needs-list)
      (setq literal-needs-list
	    (add-literal-needs
	     sub-literal
	     matching-patterns
	     literal-needs-list))))
  (setq sets-1
	(remove-if
	 #'(lambda (set)
	     (some 
	      #'(lambda (sub-literal) (eq :PENDING (cdr (assoc sub-literal literal-needs-list))))
	      set))
	 sets-1))
  (setq sets (all-variations-on-sets sets-1 literal-needs-list))
  (setq sets (add-literal-as-set-if matching-patterns literal sets))
  (acons literal sets literal-needs-list))

(defun node-needs (node label &optional (matching-patterns nil) &aux literal)
  (setq literal (node-literal node label))
  (cdr (assoc literal (add-literal-needs literal matching-patterns nil))))

(defun function-matches (a)
  #'(lambda (b) (not (eq :FAIL (unify a b)))))

(defun function-matching-patterns (patterns)
  #'(lambda (form) (some (function-matches form) patterns)))

(defun needs (fact label &optional (patterns nil) &aux matching-patterns node sets)
  (setq node (get-tms-node fact))
  (run-rules)
  (setq matching-patterns (when patterns (function-matching-patterns patterns)))
  (setq sets (literal-sets->fact-sets (node-needs node label matching-patterns)))
  sets)

(defun form-cost (form pattern-cost-list)
  (cdr (assoc-if (function-matches form) pattern-cost-list)))

(defun explanation-cost (exp pattern-cost-list)
  (apply #'+ (mapcar #'(lambda (form) (form-cost form pattern-cost-list)) exp)))

(defun labduce (fact label pattern-cost-list &aux patterns sets min-cost-exp min-cost cost)
  (setq patterns (mapcar #'car pattern-cost-list))
  (setq sets (needs fact label patterns))
  (when sets
    (setq min-cost-exp (car sets))
    (setq min-cost (explanation-cost min-cost-exp pattern-cost-list))
    (dolist (set (cdr sets) (cons min-cost-exp min-cost))
      (when (< (setq cost (explanation-cost set pattern-cost-list)) 
	       min-cost)
	(setq min-cost-exp set)
	(setq min-cost cost)))))

(defun alphalessp (x y)
  (string-lessp
   (format nil "~A" x)
   (format nil "~A" y)))

(defun sort-fact-sets (sets)
  (sort (mapcar #'(lambda (set) (sort set #'alphalessp)) sets) #'alphalessp))

(defun pp-sets (sets &optional (st t))
  (dolist (set sets)
    (format st "~%(")
    (dolist (fact set)
      (format st " ~A " fact))
    (format st ")")))