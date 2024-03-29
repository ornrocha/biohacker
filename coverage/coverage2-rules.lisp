(rule :IMPLIED-BY ((nutrient ?x) :var ?def)
      (rassert! (compound ?x)
		(:NUTRIENT-IS-COMPOUND ?def)))

(rule :IMPLIED-BY ((reaction ?reaction ?reactants . ?products) :var ?def)
      (let ((inputs (mapcar #'(lambda (reactant)
				`(compound ,reactant))
			    ?reactants)))
	(dolist (product ?products)
	  (assert! `(compound ,product)
		   `(:PRODUCT-OF-REACTION ,?def ,@inputs)))))

(rule :IMPLIED-BY ((experiment ?outcome ?nutrients . ?genes-off) :var ?def)
      (dolist (nutrient ?nutrients)
	(assert! `(nutrient ,nutrient)
		 `(:EXPERIMENT-SETUP ,?def)))
      (dolist (gene-form (fetch '(gene ?g)))
	(let ((gene (cadr gene-form)))
	  (unless (find gene ?genes-off)
	    (assert! `(gene-on ,gene)
		     `(:EXPERIMENT-SETUP ,?def))))))
