package com.bridgelabz.controller;
import com.bridgelabz.entity.QuantityDTO;
import com.bridgelabz.exception.QuantityMeasurementException;
import com.bridgelabz.service.IQuantityMeasurementService;
public class QuantityMeasurementController {
    private final IQuantityMeasurementService service;
    public QuantityMeasurementController(IQuantityMeasurementService service) {
        if (service == null) throw new IllegalArgumentException("Service cannot be null");
        this.service = service;
    }
    public void performComparison(QuantityDTO dto1, QuantityDTO dto2) {
        try { System.out.println("Comparing " + dto1 + " and " + dto2 + ": " + service.compare(dto1, dto2)); }
        catch (QuantityMeasurementException e) { System.out.println("COMPARISON ERROR: " + e.getMessage()); }
    }
    public void performConversion(QuantityDTO sourceDTO, QuantityDTO targetUnitDTO) {
        try { System.out.println("Converting " + sourceDTO + " to " + targetUnitDTO.getUnit().getUnitName() + ": " + service.convert(sourceDTO, targetUnitDTO)); }
        catch (QuantityMeasurementException e) { System.out.println("CONVERSION ERROR: " + e.getMessage()); }
    }
    public void performAddition(QuantityDTO dto1, QuantityDTO dto2) {
        try { System.out.println("Adding " + dto1 + " and " + dto2 + ": " + service.add(dto1, dto2)); }
        catch (QuantityMeasurementException e) { System.out.println("ADDITION ERROR: " + e.getMessage()); }
    }
    public void performSubtraction(QuantityDTO dto1, QuantityDTO dto2) {
        try { System.out.println("Subtracting: " + service.subtract(dto1, dto2)); }
        catch (QuantityMeasurementException e) { System.out.println("SUBTRACTION ERROR: " + e.getMessage()); }
    }
    public void performDivision(QuantityDTO dto1, QuantityDTO dto2) {
        try { System.out.println("Dividing: " + service.divide(dto1, dto2).getValue()); }
        catch (QuantityMeasurementException e) { System.out.println("DIVISION ERROR: " + e.getMessage()); }
    }
    public void runAllDemonstrations() {
        System.out.println("=== UC15: N-Tier Architecture Demo ===");
        demonstrateLength(); demonstrateWeight(); demonstrateVolume(); demonstrateTemperature();
        System.out.println("=== All demonstrations complete ===");
    }
    private void demonstrateLength() {
        System.out.println("--- Length ---");
        performComparison(new QuantityDTO(1.0, QuantityDTO.LengthUnit.FEET), new QuantityDTO(12.0, QuantityDTO.LengthUnit.INCH));
        performConversion(new QuantityDTO(1.0, QuantityDTO.LengthUnit.FEET), new QuantityDTO(0, QuantityDTO.LengthUnit.INCH));
        performAddition(new QuantityDTO(10.0, QuantityDTO.LengthUnit.FEET), new QuantityDTO(5.0, QuantityDTO.LengthUnit.FEET));
        performSubtraction(new QuantityDTO(10.0, QuantityDTO.LengthUnit.FEET), new QuantityDTO(5.0, QuantityDTO.LengthUnit.FEET));
        performDivision(new QuantityDTO(10.0, QuantityDTO.LengthUnit.FEET), new QuantityDTO(5.0, QuantityDTO.LengthUnit.FEET));
    }
    private void demonstrateWeight() {
        System.out.println("--- Weight ---");
        performComparison(new QuantityDTO(1.0, QuantityDTO.WeightUnit.KILOGRAM), new QuantityDTO(1000.0, QuantityDTO.WeightUnit.GRAM));
        performAddition(new QuantityDTO(5.0, QuantityDTO.WeightUnit.KILOGRAM), new QuantityDTO(2.0, QuantityDTO.WeightUnit.KILOGRAM));
    }
    private void demonstrateVolume() {
        System.out.println("--- Volume ---");
        performComparison(new QuantityDTO(1.0, QuantityDTO.VolumeUnit.LITRE), new QuantityDTO(1000.0, QuantityDTO.VolumeUnit.MILLILITRE));
        performAddition(new QuantityDTO(5.0, QuantityDTO.VolumeUnit.LITRE), new QuantityDTO(2.0, QuantityDTO.VolumeUnit.LITRE));
    }
    private void demonstrateTemperature() {
        System.out.println("--- Temperature ---");
        performComparison(new QuantityDTO(0.0, QuantityDTO.TemperatureUnit.CELSIUS), new QuantityDTO(32.0, QuantityDTO.TemperatureUnit.FAHRENHEIT));
        performConversion(new QuantityDTO(100.0, QuantityDTO.TemperatureUnit.CELSIUS), new QuantityDTO(0, QuantityDTO.TemperatureUnit.FAHRENHEIT));
        System.out.println("(Testing temperature arithmetic rejection...)");
        performAddition(new QuantityDTO(100.0, QuantityDTO.TemperatureUnit.CELSIUS), new QuantityDTO(50.0, QuantityDTO.TemperatureUnit.CELSIUS));
    }
}