package com.bridgelabz;
import java.util.Objects;
public class QuantityMeasurementApp {
    public static final class Feet {
        private final double value;
        public Feet(double value) { this.value = value; }
        @Override public boolean equals(Object obj) {
            if (this == obj) return true;
            if (obj == null || getClass() != obj.getClass()) return false;
            return Double.compare(this.value, ((Feet) obj).value) == 0;
        }
        @Override public int hashCode() { return Objects.hash(value); }
        @Override public String toString() { return value + " ft"; }
    }
    public static final class Inches {
        private final double value;
        public Inches(double value) { this.value = value; }
        @Override public boolean equals(Object obj) {
            if (this == obj) return true;
            if (obj == null || getClass() != obj.getClass()) return false;
            return Double.compare(this.value, ((Inches) obj).value) == 0;
        }
        @Override public int hashCode() { return Objects.hash(value); }
        @Override public String toString() { return value + " in"; }
    }
    public static boolean areFeetEqual(double a, double b) { return new Feet(a).equals(new Feet(b)); }
    public static boolean areInchesEqual(double a, double b) { return new Inches(a).equals(new Inches(b)); }
    public static void main(String[] args) {
        System.out.println("Feet equal: " + areFeetEqual(1.0, 1.0));
        System.out.println("Inches equal: " + areInchesEqual(1.0, 1.0));
    }
}