package com.bridgelabz;
public class QuantityMeasurementApp {
    public static void main(String[] args) {
        QuantityWeight w1 = new QuantityWeight(1.0, WeightUnit.KILOGRAM);
        QuantityWeight w2 = new QuantityWeight(1000.0, WeightUnit.GRAM);
        System.out.println("1kg == 1000g: " + w1.equals(w2));
        System.out.println("1kg in pounds: " + w1.convertTo(WeightUnit.POUND));
        System.out.println("1kg + 1000g: " + w1.add(w2));
    }
}