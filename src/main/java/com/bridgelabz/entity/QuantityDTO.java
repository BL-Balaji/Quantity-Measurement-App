package com.bridgelabz.entity;
public class QuantityDTO {
    private double value;
    private IMeasurableUnit unit;
    public interface IMeasurableUnit {
        String getUnitName();
        String getMeasurementType();
    }
    public enum LengthUnit implements IMeasurableUnit {
        FEET, INCH, YARDS, CENTIMETERS;
        @Override public String getUnitName() { return name(); }
        @Override public String getMeasurementType() { return "LENGTH"; }
    }
    public enum WeightUnit implements IMeasurableUnit {
        KILOGRAM, GRAM, POUND;
        @Override public String getUnitName() { return name(); }
        @Override public String getMeasurementType() { return "WEIGHT"; }
    }
    public enum VolumeUnit implements IMeasurableUnit {
        LITRE, MILLILITRE, GALLON;
        @Override public String getUnitName() { return name(); }
        @Override public String getMeasurementType() { return "VOLUME"; }
    }
    public enum TemperatureUnit implements IMeasurableUnit {
        CELSIUS, FAHRENHEIT, KELVIN;
        @Override public String getUnitName() { return name(); }
        @Override public String getMeasurementType() { return "TEMPERATURE"; }
    }
    public QuantityDTO() {}
    public QuantityDTO(double value, IMeasurableUnit unit) { this.value = value; this.unit = unit; }
    public double getValue() { return value; }
    public void setValue(double value) { this.value = value; }
    public IMeasurableUnit getUnit() { return unit; }
    public void setUnit(IMeasurableUnit unit) { this.unit = unit; }
    @Override public String toString() { return "QuantityDTO(" + value + ", " + (unit != null ? unit.getUnitName() : "null") + ")"; }
}