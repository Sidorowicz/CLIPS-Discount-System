                ;;;======================================================
                ;;;   Discount system
                ;;;   System calculates certain promo in a shop like Biedronka
                ;;;   CLIPS Version 6.3 Example
                ;;;======================================================

                ;;; ***************************
                ;;; * DEFTEMPLATES & DEFFACTS *
                ;;; ***************************

(defglobal ?*price* = 0.0)

(defglobal ?*discount* = 0.0)

(deftemplate discount
   (slot value (type FLOAT) (default 0.0))
)

(deftemplate price
   (slot value (type FLOAT) (default 0.0))
)

(deftemplate item
    (slot name)
    (slot quantity (type INTEGER)(default 0))
    (slot price (type FLOAT) (default 0.0))
)
                ;;;****************
                ;;;* STARTUP RULE *
                ;;;****************

;;;(defrule MAIN::start-discount ""
;;;  =>(assert (discount(value 0)))
;;;)

                ;;;****************
                ;;;* Functions *
                ;;;****************

(deffunction is-odd (?n))
(deffunction is-even (?n)
        (if (= ?n 0)
        then TRUE
        else (is-odd (- (abs ?n) 1))))
 (deffunction is-odd (?n)
        (if (= ?n 0)
        then FALSE
        else (is-even (- (abs ?n) 1))))



                ;;;****************
                ;;;*     RULES     *
                ;;;****************
;;;(defrule MAIN::start-discount ""
;;;=>(assert (discount(value (fact-slot-value 1 price))))
;;; )

(defrule total ""
=>
   (do-for-all-facts ((?i item)) TRUE
        (bind ?*price* (+ ?*price* (* ?i:quantity ?i:price)))
))

;;;Promocja 2+1
(defrule MAIN::beer-promo ""
=>
(do-for-all-facts ((?i item)) TRUE
(if (str-compare ?i:name "beer")
then
    (bind ?beers ?i:quantity)
    (while (> ?beers 2)
        (if (= (mod ?beers 3) 0)
            then
            (bind ?*discount* (+ ?*discount* ?i:price))
        )
        (bind ?beers (- ?beers 1))
))))

;;;Wnioski o itemaskach
(defrule MAIN::items-on-recipt ""
=>
(do-for-all-facts ((?i item)) TRUE
(assert (item (name ?i:name)(quantity ?i:quantity)(price ?i:price)))
))
)

;;;pierwszy wniosek musi byc total drugi discount
(defrule MAIN::asserting-values ""
=>
(assert (price(value ?*price*)))
(assert (discount(value ?*discount*)))
)

;;;(loop-for-count (?cnt1 2 4) do
;;;(loop-for-count (?cnt2 1 3) do
;;;(println ?cnt1 " " ?cnt2)))

                ;;;*************************
                ;;;* Java calling Function *
                ;;;*************************

(deffunction MAIN::get-discount ()
	(find-all-facts ((?f discount)) TRUE)
)
(deffunction MAIN::get-price ()
	(find-all-facts ((?f price)) TRUE)
)

(deffunction MAIN::get-recipt ()
(find-all-facts ((?f item)) TRUE)
)



   