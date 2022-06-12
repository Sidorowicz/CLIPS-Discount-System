/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package clipsdemo;
import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.nio.file.Path;
import java.nio.file.Paths;

import java.util.*;
import java.util.List;
import javax.swing.*;
import javax.swing.border.*;
import javax.swing.table.*;

import net.sf.clipsrules.jni.*;

/* TBD module qualifier with find-all-facts */

/*

Notes:

This example creates just a single environment. If you create multiple environments,
call the destroy method when you no longer need the environment. This will free the
C data structures associated with the environment.

   clips = new Environment();
      .
      .
      .
   clips.destroy();

Calling the clear, reset, load, loadFacts, run, eval, build, assertString,
and makeInstance methods can trigger CLIPS garbage collection. If you need
to retain access to a PrimitiveValue returned by a prior eval, assertString,
or makeInstance call, retain it and then release it after the call is made.

   PrimitiveValue pv1 = clips.eval("(myFunction foo)");
   pv1.retain();
   PrimitiveValue pv2 = clips.eval("(myFunction bar)");
      .
      .
      .
   pv1.release();

*/


/**
 *
 * @author marekpk
 */
public class CLIPSDemo {
    static Thread executionThread;
    static boolean isExecuting = true;

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        Double totalprice = 0.00;
        Double discountprice = 0.00;
        String property = System.getProperty("java.library.path");
        StringTokenizer parser = new StringTokenizer(property, ";");
        while (parser.hasMoreTokens()) {
            System.err.println(parser.nextToken());
        }
        Environment clips = new Environment();
        clips.loadFromResource("/resources/demorules.clp");
        clips.reset(); // usuniecie faktow nie regul
        ArrayList<String> prod = new ArrayList<String>();


        clips.eval("(set-fact-duplication TRUE)");
        clips.assertString("(item (name milk))");
        clips.assertString("(item (name bread))");
        clips.assertString("(item (name bread))");
        Runnable runThread = new Runnable() {
            @Override
            public void run() {
                clips.run();
                isExecuting = false;
            }
        };


        try {
            isExecuting = true;
            executionThread = new Thread(runThread);
            executionThread.start();
            while (isExecuting) {
                Thread.sleep(1000);
            }

            String evalStr = "(get-offeritems)";
            MultifieldValue pv = (MultifieldValue) clips.eval(evalStr);
            for (int i = 0; i < pv.size(); i++) {
                FactAddressValue fv = (FactAddressValue) pv.get(i);
                String typeName = fv.getFactSlot("name").toString(); //fv.getFactAddress()[1].toString();
                prod.add(typeName);
                System.out.println(typeName);
            }



        } catch (Exception e) {
            e.printStackTrace();
        }



        //Creating the Frame
        JFrame f = new JFrame("Bezdomka");
        JPanel p = new JPanel();
        JLabel l = new JLabel("Produkty");
        Object[] products = prod.toArray();

        JList productlist = new JList(products);
        productlist.setPreferredSize(new Dimension(300, 600));
        productlist.setBorder(BorderFactory.createLineBorder(Color.black));
        productlist.setLayoutOrientation(JList.VERTICAL);
        p.add(productlist);

        JPanel buttons = new JPanel();
        JButton add = new JButton("add");
        add.setPreferredSize(new Dimension(100, 50));
        JButton delete = new JButton("delete");
        delete.setPreferredSize(new Dimension(100, 50));
        JButton finish = new JButton("finish");
        finish.setPreferredSize(new Dimension(100, 50));
        JButton reset = new JButton("reset");
        reset.setPreferredSize(new Dimension(100, 50));
        buttons.add(add);

        buttons.add(finish);

        buttons.setPreferredSize(new Dimension(100, 600));
        p.add(buttons);


        JPanel paragon = new JPanel();
        paragon.setLayout(new BoxLayout(paragon, BoxLayout.PAGE_AXIS));
        paragon.setPreferredSize(new Dimension(500, 600));
        paragon.setBorder(BorderFactory.createLineBorder(Color.black));
        JLabel par = new JLabel(" ");
        //par.setLineWrap(true);
        par.setVerticalAlignment(JLabel.CENTER);
        par.setHorizontalAlignment(JLabel.CENTER);
        paragon.add(par);

        p.add(paragon);

        f.setSize(1000, 650);
        f.add(p);
        f.show();

        par.setText("<html><div style='text-align:center'>Dodaj produkt</div></html>");
        add.addActionListener(new ActionListener() {

            @Override
            public void actionPerformed(ActionEvent e) {
                try {

                par.setText((String) productlist.getSelectedValue());
                    clips.assertString("(item (name "+(String) productlist.getSelectedValue()+"))");


                    String evalStr = "(get-recipt)";
                    MultifieldValue pv = (MultifieldValue) clips.eval(evalStr);
                    String te="Produkty:<br>";
                    for (int i = 0; i < pv.size(); i++) {
                        FactAddressValue fv = (FactAddressValue) pv.get(i);
                        String typeName = null; //fv.getFactAddress()[1].toString();
                        try {
                            typeName = fv.getFactSlot("name").toString()+ "<br>";
                            te+=typeName;


                        } catch (Exception ex) {
                            throw new RuntimeException(ex);
                        }
                    }
                    par.setText("<html>"+te+"</html>");
                } catch (Exception ex) {
                    throw new RuntimeException(ex);
                }

            }
        });

        finish.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                String fin = "";
                double dis = 0.00;
                String promos = "";
                double tot = 0.00;
                try{

                    isExecuting = true;
                    executionThread = new Thread(runThread);
                    executionThread.start();
                    while (isExecuting) {
                        Thread.sleep(10000);
                    }
                    String evalStr = "(get-recipt)";
                    MultifieldValue pv = (MultifieldValue) clips.eval(evalStr);

                    for (int i = 0; i < pv.size(); i++) {
                        FactAddressValue fv = (FactAddressValue) pv.get(i);
                        String typeName = null; //fv.getFactAddress()[1].toString();

                            typeName = fv.getFactSlot("name").toString();
                            typeName += " " + fv.getFactSlot("price").toString();
                            tot+=Double.parseDouble(fv.getFactSlot("price").toString());
                            System.out.println("Total: " + typeName);
                            fin += typeName + "<br>";

                    }

                    evalStr = "(get-applied-promos)";
                    pv = (MultifieldValue) clips.eval(evalStr);
                    // System.out.println("Ilosc wykorzystanych regół: " + pv.size());

                    for (int i = 0; i < pv.size(); i++) {
                        FactAddressValue fv = (FactAddressValue) pv.get(i);
                        String typeName = null; //fv.getFactAddress()[1].toString();

                            typeName = fv.getFactSlot("name").toString();
                            typeName += " -" + fv.getFactSlot("value").toString();
                            dis +=Double.parseDouble(fv.getFactSlot("value").toString());
                            System.out.println("Total: " + typeName);
                            promos += typeName + "<br>";

                    }
//                    evalStr = "(get-discount)";
//                    pv = (MultifieldValue) clips.eval(evalStr);
//                    for (int i = 0; i < pv.size(); i++) {
//                        FactAddressValue fv = (FactAddressValue) pv.get(i);
//
//                            String typeName = fv.getFactSlot("value").toString(); //fv.getFactAddress()[1].toString();
//                            dis +=Double.parseDouble(typeName);
//                            System.out.println(dis);
//                    }

//                     evalStr = "(get-price)";
//                     pv = (MultifieldValue) clips.eval(evalStr);
//                    for (int i = 0; i < pv.size(); i++) {
//                        FactAddressValue fv = (FactAddressValue) pv.get(i);
//                        String typeName = fv.getFactSlot("value").toString(); //fv.getFactAddress()[1].toString();
//                        tot = typeName;
//                        System.out.println(tot);
//                    }
                } catch (Exception ex) {
                    throw new RuntimeException(ex);
                }
                par.setText(

                        "<html>" +
                                "<div style='text-align:center'><b>Bezdomka 'WItamy promocjami!' 2060</b> </div>" +
                                "<div style='text-align:center'>15-324 Białystok UL. Bezdomkowa 55 </div>" +
                                "<div style='text-align:center'>Oho firma bez nazwy sa </div>" +
                                "<div style='text-align:center'>NIP 0000000000000 nr.99999 </div>" +
                                "<div style='text-align:center'>PARAGON FISKALNY </div>" +
                                "______________________Products____________________ <br>" +
                                fin + "<br>" +
                                "____________________Applied_Promos________________ <br>" +
                                promos + "<br>" +
                                "________________________Total_____________________ <br>" +
                                "Obniżka: " + dis + " <br>" +
                                "Cena: " + tot + " <br>" +
                                "Suma: " + (tot- dis) + " <br>" +
                                "__________________________________________________ <br>" +
                                "Dziękujemy za zakupy, zapraszamy ponownie! <br>" +
                                "</html>"

                );
            }
        });




    }}


