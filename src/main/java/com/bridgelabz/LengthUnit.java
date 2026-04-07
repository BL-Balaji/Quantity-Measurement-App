package com.bridgelabz;
public enum LengthUnit {
    FEET(1.0), INCH(1.0 / 12.0), YARDS(3.0), CENTIMETERS(1.0 / 30.48);
    private final double conversionFactor;
    LengthUnit(double conversionFactor) { this.conversionFactor = conversionFactor; }
    public double convertToBaseUnit(double value) { return value * conversionFactor; }
    public double convertFromBaseUnit(double baseValue) { return baseValue / conversionFactor; }
}