;;;*************************
                ;;;       Templates
                ;;;*************************
                (defglobal ?*p* = 0.00) (defglobal ?*c* = 0)
(deftemplate discount
    (slot value (type FLOAT) (default 0.00))
)

(deftemplate price
    (slot value (type FLOAT) (default 0.00))
)

(deftemplate item
    (slot name)
    (slot price (type FLOAT) (default 0.00))
    (slot inpromo (type INTEGER) (default 0))
)

(deftemplate promoinfo
    (slot name)
    (slot value(type INTEGER) (default 0))
    (slot onetimeonly(type INTEGER) (default 0))
)

(deftemplate offeritem
    (slot name)
    (slot totalprice (type FLOAT) (default 0.00))
)



                ;;;*************************
                ;;;  Item prices assertion
                ;;;*************************

(defrule MAIN::milk-price ""
    ?f <- (item (name ?name)(price ?price))
    (test (and (eq ?name milk) (eq ?price 0.00)))
    =>
    (modify ?f (price 5.00))
)

(defrule MAIN::bread-price ""
    ?f <- (item (name ?name)(price ?price))
    (test (and (eq ?name bread) (eq ?price 0.00)))
    =>
    (modify ?f (price 3.00))
)

(defrule MAIN::chips-price ""
    ?f <- (item (name ?name)(price ?price))
    (test (and (eq ?name chips) (eq ?price 0.00)))
    =>
    (modify ?f (price 2.00))
)

(defrule MAIN::beer-price ""
    ?f <- (item (name ?name)(price ?price))
    (test (and (eq ?name beer) (eq ?price 0.00)))
    =>
    (modify ?f (price 5.00))
)

(defrule MAIN::pizza-price ""
    ?f <- (item (name ?name)(price ?price))
    (test (and (eq ?name pizza) (eq ?price 0.00)))
    =>
    (modify ?f (price 16.00))
)

                ;;;*************************
                ;;;        Startup
                ;;;*************************

(defrule MAIN::startup ""
    =>
    ;;;nessesary facts
    (assert(discount))
    (assert(price))
    (assert (offeritem (name chips)(totalprice 2.99)))
    (assert (offeritem (name milk)(totalprice 5.59)))
    (assert (offeritem (name bread)(totalprice 3.33)))
    (assert (offeritem (name beer)(totalprice 5.00)))
    (assert (offeritem (name pizza)(totalprice 16.00)))
)

                ;;;*************************
                ;;;        Promotions
                ;;;*************************

(defrule MAIN::beerpluschips ""
    ?f <- (item (name ?fname)(price ?fprice)(inpromo ?fp))
    (test (and (eq ?fname beer) (eq ?fp 0)))

    ?d <- (item (name ?dname)(price ?dprice)(inpromo ?dp))
    (test (and (eq ?dname chips) (eq ?dp 0)))

    ?discount<-(discount(value ?value))

    =>
    (assert(promoinfo(name "Chips-For-Free-With-Beer")(value ?dprice)))
    (modify ?f (inpromo 1))
    (modify ?d (inpromo 1))
    (modify ?discount (value (+ ?value ?dprice)))
)

(defrule MAIN::BreakFeast ""
        ?f <- (item (name ?fname)(price ?fprice)(inpromo ?fp))
        (test (and (eq ?fname milk) (eq ?fp 0)))

        ?d <- (item (name ?dname)(price ?dprice)(inpromo ?dp))
        (test (and (eq ?dname bread) (eq ?dp 0)))

        ?g <- (item (name ?gname)(price ?gprice)(inpromo ?gp))
        (test (and (eq ?gname bread) (eq ?gp 0)))

        (test (neq (fact-index ?d) (fact-index ?g)))

    ?discount<-(discount(value ?value))

    =>
    (assert(promoinfo(name "BreakFeast")(value 4)))
    (modify ?f (inpromo 1))
    (modify ?d (inpromo 1))
    (modify ?d (inpromo 1))
    (modify ?discount (value (+ ?value 4)))
)

(defrule MAIN::threepizzas ""
    ?f <- (item (name ?fname)(price ?fprice)(inpromo ?fp))
    (test (and (eq ?fname pizza) (eq ?fp 0)))

    ?d <- (item (name ?dname)(price ?dprice)(inpromo ?dp))
    (test (and (eq ?dname pizza) (eq ?dp 0)))

    ?g <- (item (name ?gname)(price ?gprice)(inpromo ?gp))
    (test (and (eq ?gname pizza) (eq ?gp 0)))

    ?discount<-(discount(value ?value))

    (test (neq (fact-index ?f) (fact-index ?d)))
    (test (neq (fact-index ?f) (fact-index ?g)))
    (test (neq (fact-index ?d) (fact-index ?g)))

    =>
    (modify ?f (inpromo 1))
    (modify ?d (inpromo 1))
    (modify ?g (inpromo 1))
    (assert(promoinfo(name "Three-Pizzas")(value 8)))
    (modify ?discount (value (+ ?value (* ?gprice 0.5))))
)


                ;;;*************************
                ;;;     Total Calk
                ;;;*************************
(defrule reset-price
?q<-(price(value ?value))
(test(neq ?value 0.00))
(test(neq ?*c* 0))
 =>
 (retract ?q)
(assert(price))
(bind ?*c* 1)
 )
(defrule total ""
    ?q<-(price(value ?value))
    (test(eq ?value 0.00))
    =>
    (bind ?*p* 0)
    (do-for-all-facts ((?i item)) TRUE
    (bind ?*p* (+ ?*p* ?i:price))
    )
    (modify ?q (value (/ (* ?*p* 100) 100) ))
)



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

(deffunction MAIN::get-applied-promos ()
    (find-all-facts ((?f promoinfo)) TRUE)
)

(deffunction MAIN::get-offeritems ()
    (find-all-facts ((?f offeritem)) TRUE)
)