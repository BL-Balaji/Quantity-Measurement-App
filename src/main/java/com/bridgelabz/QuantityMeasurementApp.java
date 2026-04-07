package com.bridgelabz;
import com.bridgelabz.controller.QuantityMeasurementController;
import com.bridgelabz.repository.IQuantityMeasurementRepository;
import com.bridgelabz.repository.QuantityMeasurementCacheRepository;
import com.bridgelabz.service.IQuantityMeasurementService;
import com.bridgelabz.service.QuantityMeasurementServiceImpl;
public class QuantityMeasurementApp {
    private final QuantityMeasurementController controller;
    public QuantityMeasurementApp() {
        IQuantityMeasurementRepository repository = QuantityMeasurementCacheRepository.getInstance();
        IQuantityMeasurementService service = new QuantityMeasurementServiceImpl(repository);
        this.controller = new QuantityMeasurementController(service);
    }
    public void run() { controller.runAllDemonstrations(); }
    public static void main(String[] args) { new QuantityMeasurementApp().run(); }
    // Backward-compat QuantityLength inner class
    public static final class QuantityLength {
        private static final double EPS = 1e-6;
        private final double value; private final LengthUnit unit;
        public QuantityLength(double value, LengthUnit unit) {
            this.value = value; this.unit = java.util.Objects.requireNonNull(unit);
        }
        public double getValue() { return value; }
        public LengthUnit getUnit() { return unit; }
        public QuantityLength convertTo(LengthUnit t) {
            return new QuantityLength(Math.round(t.convertFromBaseUnit(unit.convertToBaseUnit(value))*100.0)/100.0, t);
        }
        public QuantityLength add(QuantityLength o) { return add(o, unit); }
        public QuantityLength add(QuantityLength o, LengthUnit t) {
            double sum = unit.convertToBaseUnit(value) + o.unit.convertToBaseUnit(o.value);
            return new QuantityLength(Math.round(t.convertFromBaseUnit(sum)*100.0)/100.0, t);
        }
        @Override public boolean equals(Object obj) {
            if (!(obj instanceof QuantityLength o)) return false;
            return Math.abs(unit.convertToBaseUnit(value)-o.unit.convertToBaseUnit(o.value)) < EPS;
        }
        @Override public int hashCode() { return java.util.Objects.hash(Math.round(unit.convertToBaseUnit(value)/EPS)); }
        @Override public String toString() { return "Quantity(" + value + ", " + unit + ")"; }
    }
}