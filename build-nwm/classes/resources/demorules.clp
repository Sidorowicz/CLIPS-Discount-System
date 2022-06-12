(deftemplate vehicle-is
   (slot value)
)

(defrule MAIN::is-bicycle
	(vehicle-has-wheels 2)
=>
	(assert (vehicle-is (value bicycle)))
)

(defrule MAIN::is-car
	(vehicle-has-wheels 4)
=>
	(assert (vehicle-is (value car)))
)

(deffunction MAIN::get-vehicle-type ()
	(find-all-facts ((?f vehicle-is)) TRUE)
)


   