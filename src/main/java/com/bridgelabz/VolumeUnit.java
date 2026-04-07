package com.bridgelabz;
public enum VolumeUnit implements IMeasurable {
    LITRE(1.0), MILLILITRE(0.001), GALLON(3.78541);
    private final double conversionFactor;
    VolumeUnit(double f) { this.conversionFactor = f; }
    @Override public double convertToBaseUnit(double value) { return value * conversionFactor; }
    @Override public double convertFromBaseUnit(double base) { return base / conversionFactor; }
    @Override public String getUnitName() { return name(); }
    @Override public String getMeasurementType() { return "VOLUME"; }
}