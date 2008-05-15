;; biohacker/trunk/network-debugger/presentation/demo-negative.lisp

(experiment 
 negative 
 (a) 
 :growth? nil 
 :essential-compounds (a e))
#|
Focusing on experiment NEGATIVE.
Experiment is consistent with model.
|#

(explain 'experiment-consistent)
#|
  1 (FOCUS-EXPERIMENT NEGATIVE)         ()   Assumption
  2 SIMPLIFY-INVESTIGATIONS             ()   Assumption
  3 (:NOT (NUTRIENT E))              (1 2)  (:OR (:NOT (NUTRIENT E)) (:NOT SIMPLIFY-INVESTIGATIONS) (:NOT (FOCUS-EXPERIMENT NEGATIVE)))
  4 (:NOT (NUTRIENT D))              (1 2)  (:OR (:NOT (NUTRIENT D)) (:NOT SIMPLIFY-INVESTIGATIONS) (:NOT (FOCUS-EXPERIMENT NEGATIVE)))
  5 (:NOT EXPERIMENT-GROWTH)           (1)  (:OR (:NOT EXPERIMENT-GROWTH) (:NOT (FOCUS-EXPERIMENT NEGATIVE)))
  6 (:NOT (REACTION-ENABLED R2))       (5)  (:OR EXPERIMENT-GROWTH (:NOT (REACTION-ENABLED R2)))
  7 (:NOT (REACTION-FIRED R2))         (6)  (:OR (REACTION-ENABLED R2) (:NOT (REACTION-FIRED R2)))
  8 ASSUME-UNKNOWNS-AS-CONVENIENT       ()   Assumption
  9 (:NOT (REACTION-REVERSIBLE R3))  (8 5)  (:OR EXPERIMENT-GROWTH (:NOT ASSUME-UNKNOWNS-AS-CONVENIENT) (:NOT (REACTION-REVERSIBLE R3)))
 10 (:NOT (REVERSE-REACTION-FIRED R3)) (9)  (:OR (REACTION-REVERSIBLE R3) (:NOT (REVERSE-REACTION-FIRED R3)))
 11 (:NOT (COMPOUND-PRESENT D))   (4 7 10)  (:OR (:NOT (COMPOUND-PRESENT D)) (REVERSE-REACTION-FIRED R3) (REACTION-FIRED R2) (NUTRIENT D))
 12 (:NOT (REACTION-FIRED R3))        (11)  (:OR (COMPOUND-PRESENT D) (:NOT (REACTION-FIRED R3)))
 13 (:NOT (NUTRIENT F))              (1 2)  (:OR (:NOT (NUTRIENT F)) (:NOT SIMPLIFY-INVESTIGATIONS) (:NOT (FOCUS-EXPERIMENT NEGATIVE)))
 14 (:NOT (REACTION-REVERSIBLE R4))  (8 5)  (:OR EXPERIMENT-GROWTH (:NOT (REACTION-REVERSIBLE R4)) (:NOT ASSUME-UNKNOWNS-AS-CONVENIENT))
 15 (:NOT (REVERSE-REACTION-FIRED R4))(14)  (:OR (REACTION-REVERSIBLE R4) (:NOT (REVERSE-REACTION-FIRED R4)))
 16 (:NOT (COMPOUND-PRESENT F))    (13 15)  (:OR (:NOT (COMPOUND-PRESENT F)) (REVERSE-REACTION-FIRED R4) (NUTRIENT F))
 17 (:NOT (REACTION-FIRED R4))        (16)  (:OR (COMPOUND-PRESENT F) (:NOT (REACTION-FIRED R4)))
 18 (:NOT (COMPOUND-PRESENT E))  (3 12 17)  (:OR (REACTION-FIRED R4) (:NOT (COMPOUND-PRESENT E)) (REACTION-FIRED R3) (NUTRIENT E))
 19   (:NOT GROWTH)                 (1 18)  (:OR (COMPOUND-PRESENT E) (:NOT GROWTH) (:NOT (FOCUS-EXPERIMENT NEGATIVE)))
 20 EXPERIMENT-CONSISTENT           (1 19)  (:OR GROWTH EXPERIMENT-CONSISTENT (:NOT (FOCUS-EXPERIMENT NEGATIVE)))
|#

(all-antecedents 'experiment-consistent '((:NOT (compound-present ?c))))
;((:NOT (COMPOUND-PRESENT F)) (:NOT (COMPOUND-PRESENT D)) (:NOT (COMPOUND-PRESENT E)))