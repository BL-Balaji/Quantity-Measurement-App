package com.bridgelabz;
import java.util.Objects;
public class QuantityMeasurementApp {
    public static final class Feet {
        private final double value;
        public Feet(double value) { this.value = value; }
        public double getValue() { return value; }
        @Override public boolean equals(Object obj) {
            if (this == obj) return true;
            if (obj == null || getClass() != obj.getClass()) return false;
            Feet other = (Feet) obj;
            return Double.compare(this.value, other.value) == 0;
        }
        @Override public int hashCode() { return Objects.hash(value); }
        @Override public String toString() { return value + " ft"; }
    }
    public static void main(String[] args) {
        Feet a = new Feet(1.0); Feet b = new Feet(1.0);
        System.out.println("Equal: " + a.equals(b));
    }
}