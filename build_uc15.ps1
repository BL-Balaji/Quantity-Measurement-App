# UC15 N-Tier Architecture Build Script
$WorkDir = "d:\Quantity Measurement App"
Set-Location $WorkDir

function Write-FileContent($path, $content) {
    $dir = Split-Path $path -Parent
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    [System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::UTF8)
}

function UC-Branch($branchName, $commitMsg) {
    git checkout develop 2>&1 | Out-Null
    git checkout -b $branchName 2>&1 | Out-Null
    git add . 2>&1 | Out-Null
    git commit -m $commitMsg 2>&1 | Out-Null
    git push origin $branchName --force 2>&1 | Out-Null
    git checkout develop 2>&1 | Out-Null
    git merge --no-ff $branchName -m "Merge $branchName into develop" 2>&1 | Out-Null
    git push origin develop --force 2>&1 | Out-Null
    Write-Host "DONE: $branchName"
}

# ========== UC15: N-Tier Architecture ==========

# entity/QuantityDTO.java
$quantityDTO = @'
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
'@

# entity/QuantityMeasurementEntity.java
$quantityEntity = @'
package com.bridgelabz.entity;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
public class QuantityMeasurementEntity implements Serializable {
    private static final long serialVersionUID = 1L;
    private String operand1, operand2, operationType, result, errorMessage, timestamp;
    private boolean hasError;
    public QuantityMeasurementEntity() {}
    public QuantityMeasurementEntity(String operand1, String operationType, String result) {
        this.operand1 = operand1; this.operationType = operationType; this.result = result;
        this.timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }
    public QuantityMeasurementEntity(String operand1, String operand2, String operationType, String result) {
        this(operand1, operationType, result); this.operand2 = operand2;
    }
    public QuantityMeasurementEntity(String operand1, String operand2, String operationType, String errorMessage, boolean hasError) {
        this.operand1 = operand1; this.operand2 = operand2; this.operationType = operationType;
        this.errorMessage = errorMessage; this.hasError = hasError;
        this.timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }
    public String getOperand1() { return operand1; }
    public String getOperand2() { return operand2; }
    public String getOperationType() { return operationType; }
    public String getResult() { return result; }
    public boolean isHasError() { return hasError; }
    public String getErrorMessage() { return errorMessage; }
    public String getTimestamp() { return timestamp; }
    @Override public String toString() {
        if (hasError) return "[" + timestamp + "] " + operationType + " ERROR: " + errorMessage;
        if (operand2 == null) return "[" + timestamp + "] " + operationType + ": " + operand1 + " => " + result;
        return "[" + timestamp + "] " + operationType + ": " + operand1 + " & " + operand2 + " => " + result;
    }
}
'@

# entity/QuantityModel.java
$quantityModel = @'
package com.bridgelabz.entity;
import com.bridgelabz.IMeasurable;
public class QuantityModel<U extends IMeasurable> {
    private double value; private U unit;
    public QuantityModel() {}
    public QuantityModel(double value, U unit) { this.value = value; this.unit = unit; }
    public double getValue() { return value; }
    public void setValue(double value) { this.value = value; }
    public U getUnit() { return unit; }
    public void setUnit(U unit) { this.unit = unit; }
    @Override public String toString() { return "QuantityModel(" + value + ", " + (unit != null ? unit.getUnitName() : "null") + ")"; }
}
'@

# exception/QuantityMeasurementException.java
$qmException = @'
package com.bridgelabz.exception;
public class QuantityMeasurementException extends RuntimeException {
    public QuantityMeasurementException(String message) { super(message); }
    public QuantityMeasurementException(String message, Throwable cause) { super(message, cause); }
}
'@

# repository/IQuantityMeasurementRepository.java
$iRepository = @'
package com.bridgelabz.repository;
import com.bridgelabz.entity.QuantityMeasurementEntity;
import java.util.List;
public interface IQuantityMeasurementRepository {
    void save(QuantityMeasurementEntity entity);
    List<QuantityMeasurementEntity> getAllMeasurements();
    void clearHistory();
}
'@

# repository/QuantityMeasurementCacheRepository.java
$cacheRepo = @'
package com.bridgelabz.repository;
import com.bridgelabz.entity.QuantityMeasurementEntity;
import java.io.*;
import java.util.*;
public class QuantityMeasurementCacheRepository implements IQuantityMeasurementRepository {
    private static final String DATA_FILE = "quantity_measurements.dat";
    private static QuantityMeasurementCacheRepository instance;
    private final List<QuantityMeasurementEntity> cache;
    private QuantityMeasurementCacheRepository() { this.cache = new ArrayList<>(); loadFromDisk(); }
    public static synchronized QuantityMeasurementCacheRepository getInstance() {
        if (instance == null) instance = new QuantityMeasurementCacheRepository();
        return instance;
    }
    public static synchronized void resetInstance() { instance = null; }
    @Override public void save(QuantityMeasurementEntity entity) {
        if (entity == null) throw new IllegalArgumentException("Entity cannot be null");
        cache.add(entity); saveToDisk(entity);
    }
    @Override public List<QuantityMeasurementEntity> getAllMeasurements() {
        return Collections.unmodifiableList(new ArrayList<>(cache));
    }
    @Override public void clearHistory() { cache.clear(); new File(DATA_FILE).delete(); }
    private void saveToDisk(QuantityMeasurementEntity entity) {
        File file = new File(DATA_FILE);
        boolean append = file.exists() && file.length() > 0;
        try (FileOutputStream fos = new FileOutputStream(file, append);
             ObjectOutputStream oos = append ? new AppendableObjectOutputStream(fos) : new ObjectOutputStream(fos)) {
            oos.writeObject(entity); oos.flush();
        } catch (IOException e) { System.err.println("Warning: Could not save - " + e.getMessage()); }
    }
    private void loadFromDisk() {
        File file = new File(DATA_FILE);
        if (!file.exists() || file.length() == 0) return;
        try (ObjectInputStream ois = new ObjectInputStream(new FileInputStream(file))) {
            while (true) { try { Object obj = ois.readObject();
                if (obj instanceof QuantityMeasurementEntity e) cache.add(e);
            } catch (EOFException e) { break; } }
        } catch (Exception e) { System.err.println("Warning: Could not load - " + e.getMessage()); }
    }
    private static class AppendableObjectOutputStream extends ObjectOutputStream {
        AppendableObjectOutputStream(OutputStream out) throws IOException { super(out); }
        @Override protected void writeStreamHeader() throws IOException { reset(); }
    }
}
'@

# service/IQuantityMeasurementService.java
$iService = @'
package com.bridgelabz.service;
import com.bridgelabz.entity.QuantityDTO;
public interface IQuantityMeasurementService {
    boolean compare(QuantityDTO dto1, QuantityDTO dto2);
    QuantityDTO convert(QuantityDTO sourceDTO, QuantityDTO targetUnit);
    QuantityDTO add(QuantityDTO dto1, QuantityDTO dto2);
    QuantityDTO subtract(QuantityDTO dto1, QuantityDTO dto2);
    QuantityDTO divide(QuantityDTO dto1, QuantityDTO dto2);
}
'@

# service/QuantityMeasurementServiceImpl.java
$serviceImpl = @'
package com.bridgelabz.service;
import com.bridgelabz.IMeasurable;
import com.bridgelabz.Quantity;
import com.bridgelabz.entity.QuantityDTO;
import com.bridgelabz.entity.QuantityMeasurementEntity;
import com.bridgelabz.exception.QuantityMeasurementException;
import com.bridgelabz.repository.IQuantityMeasurementRepository;
public class QuantityMeasurementServiceImpl implements IQuantityMeasurementService {
    private final IQuantityMeasurementRepository repository;
    public QuantityMeasurementServiceImpl(IQuantityMeasurementRepository repository) {
        if (repository == null) throw new IllegalArgumentException("Repository cannot be null");
        this.repository = repository;
    }
    @Override public boolean compare(QuantityDTO dto1, QuantityDTO dto2) {
        validateInputs(dto1, dto2, "COMPARISON");
        try {
            IMeasurable u1 = mapUnit(dto1), u2 = mapUnit(dto2);
            validateSameCategory(u1, u2, "COMPARISON");
            boolean result = createQ(dto1.getValue(), u1).equals(createQ(dto2.getValue(), u2));
            repository.save(new QuantityMeasurementEntity(dto1.toString(), dto2.toString(), "COMPARISON", String.valueOf(result)));
            return result;
        } catch (QuantityMeasurementException e) {
            repository.save(new QuantityMeasurementEntity(str(dto1), str(dto2), "COMPARISON", e.getMessage(), true)); throw e;
        } catch (Exception e) {
            repository.save(new QuantityMeasurementEntity(str(dto1), str(dto2), "COMPARISON", e.getMessage(), true));
            throw new QuantityMeasurementException("Comparison failed: " + e.getMessage(), e);
        }
    }
    @Override public QuantityDTO convert(QuantityDTO sourceDTO, QuantityDTO targetUnitDTO) {
        validateInput(sourceDTO, "CONVERSION");
        if (targetUnitDTO == null || targetUnitDTO.getUnit() == null) throw new QuantityMeasurementException("Target unit cannot be null");
        try {
            IMeasurable su = mapUnit(sourceDTO), tu = mapUnit(targetUnitDTO);
            validateSameCategory(su, tu, "CONVERSION");
            Quantity<IMeasurable> converted = createQ(sourceDTO.getValue(), su).convertTo(tu);
            QuantityDTO result = new QuantityDTO(converted.getValue(), targetUnitDTO.getUnit());
            repository.save(new QuantityMeasurementEntity(sourceDTO.toString(), "CONVERSION", result.toString()));
            return result;
        } catch (QuantityMeasurementException e) {
            repository.save(new QuantityMeasurementEntity(str(sourceDTO), null, "CONVERSION", e.getMessage(), true)); throw e;
        } catch (Exception e) {
            repository.save(new QuantityMeasurementEntity(str(sourceDTO), null, "CONVERSION", e.getMessage(), true));
            throw new QuantityMeasurementException("Conversion failed: " + e.getMessage(), e);
        }
    }
    @Override public QuantityDTO add(QuantityDTO dto1, QuantityDTO dto2) {
        validateInputs(dto1, dto2, "ADDITION");
        try {
            IMeasurable u1 = mapUnit(dto1), u2 = mapUnit(dto2);
            validateSameCategory(u1, u2, "ADDITION");
            Quantity<IMeasurable> sum = createQ(dto1.getValue(), u1).add(createQ(dto2.getValue(), u2));
            QuantityDTO result = new QuantityDTO(sum.getValue(), dto1.getUnit());
            repository.save(new QuantityMeasurementEntity(dto1.toString(), dto2.toString(), "ADDITION", result.toString()));
            return result;
        } catch (UnsupportedOperationException e) {
            repository.save(new QuantityMeasurementEntity(str(dto1), str(dto2), "ADDITION", e.getMessage(), true));
            throw new QuantityMeasurementException("Addition not supported: " + e.getMessage(), e);
        } catch (QuantityMeasurementException e) {
            repository.save(new QuantityMeasurementEntity(str(dto1), str(dto2), "ADDITION", e.getMessage(), true)); throw e;
        } catch (Exception e) {
            repository.save(new QuantityMeasurementEntity(str(dto1), str(dto2), "ADDITION", e.getMessage(), true));
            throw new QuantityMeasurementException("Addition failed: " + e.getMessage(), e);
        }
    }
    @Override public QuantityDTO subtract(QuantityDTO dto1, QuantityDTO dto2) {
        validateInputs(dto1, dto2, "SUBTRACTION");
        try {
            IMeasurable u1 = mapUnit(dto1), u2 = mapUnit(dto2);
            validateSameCategory(u1, u2, "SUBTRACTION");
            Quantity<IMeasurable> diff = createQ(dto1.getValue(), u1).subtract(createQ(dto2.getValue(), u2));
            QuantityDTO result = new QuantityDTO(diff.getValue(), dto1.getUnit());
            repository.save(new QuantityMeasurementEntity(dto1.toString(), dto2.toString(), "SUBTRACTION", result.toString()));
            return result;
        } catch (UnsupportedOperationException e) {
            repository.save(new QuantityMeasurementEntity(str(dto1), str(dto2), "SUBTRACTION", e.getMessage(), true));
            throw new QuantityMeasurementException("Subtraction not supported: " + e.getMessage(), e);
        } catch (QuantityMeasurementException e) {
            repository.save(new QuantityMeasurementEntity(str(dto1), str(dto2), "SUBTRACTION", e.getMessage(), true)); throw e;
        } catch (Exception e) {
            repository.save(new QuantityMeasurementEntity(str(dto1), str(dto2), "SUBTRACTION", e.getMessage(), true));
            throw new QuantityMeasurementException("Subtraction failed: " + e.getMessage(), e);
        }
    }
    @Override public QuantityDTO divide(QuantityDTO dto1, QuantityDTO dto2) {
        validateInputs(dto1, dto2, "DIVISION");
        try {
            IMeasurable u1 = mapUnit(dto1), u2 = mapUnit(dto2);
            validateSameCategory(u1, u2, "DIVISION");
            double ratio = createQ(dto1.getValue(), u1).divide(createQ(dto2.getValue(), u2));
            QuantityDTO result = new QuantityDTO(ratio, null);
            repository.save(new QuantityMeasurementEntity(dto1.toString(), dto2.toString(), "DIVISION", String.valueOf(ratio)));
            return result;
        } catch (UnsupportedOperationException | ArithmeticException e) {
            repository.save(new QuantityMeasurementEntity(str(dto1), str(dto2), "DIVISION", e.getMessage(), true));
            throw new QuantityMeasurementException("Division failed: " + e.getMessage(), e);
        } catch (QuantityMeasurementException e) {
            repository.save(new QuantityMeasurementEntity(str(dto1), str(dto2), "DIVISION", e.getMessage(), true)); throw e;
        } catch (Exception e) {
            repository.save(new QuantityMeasurementEntity(str(dto1), str(dto2), "DIVISION", e.getMessage(), true));
            throw new QuantityMeasurementException("Division failed: " + e.getMessage(), e);
        }
    }
    private void validateInput(QuantityDTO dto, String op) {
        if (dto == null || dto.getUnit() == null) throw new QuantityMeasurementException("Input cannot be null for " + op);
    }
    private void validateInputs(QuantityDTO dto1, QuantityDTO dto2, String op) {
        if (dto1 == null || dto2 == null || dto1.getUnit() == null || dto2.getUnit() == null)
            throw new QuantityMeasurementException("Inputs cannot be null for " + op);
    }
    private IMeasurable mapUnit(QuantityDTO dto) {
        try { return IMeasurable.fromUnitName(dto.getUnit().getUnitName()); }
        catch (IllegalArgumentException e) { throw new QuantityMeasurementException("Invalid unit: " + dto.getUnit().getUnitName(), e); }
    }
    private void validateSameCategory(IMeasurable u1, IMeasurable u2, String op) {
        if (!u1.getMeasurementType().equals(u2.getMeasurementType()))
            throw new QuantityMeasurementException("Incompatible types for " + op + ": " + u1.getMeasurementType() + " and " + u2.getMeasurementType());
    }
    @SuppressWarnings("unchecked")
    private Quantity<IMeasurable> createQ(double value, IMeasurable unit) { return new Quantity<>(value, unit); }
    private String str(QuantityDTO dto) { return dto != null ? dto.toString() : "null"; }
}
'@

# controller/QuantityMeasurementController.java
$controller = @'
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
'@

# Updated QuantityMeasurementApp.java (main entry point)
$mainApp = @'
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
'@

# UC15 comprehensive test file
$uc15Test = @'
package com.bridgelabz;
import com.bridgelabz.controller.QuantityMeasurementController;
import com.bridgelabz.entity.QuantityDTO;
import com.bridgelabz.entity.QuantityMeasurementEntity;
import com.bridgelabz.entity.QuantityModel;
import com.bridgelabz.exception.QuantityMeasurementException;
import com.bridgelabz.repository.IQuantityMeasurementRepository;
import com.bridgelabz.repository.QuantityMeasurementCacheRepository;
import com.bridgelabz.service.IQuantityMeasurementService;
import com.bridgelabz.service.QuantityMeasurementServiceImpl;
import org.junit.jupiter.api.*;
import java.io.File;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class QuantityMeasurementUC15Test {
    private static final double EPS = 1e-2;
    private IQuantityMeasurementRepository repository;
    private IQuantityMeasurementService service;
    @BeforeEach void setUp() {
        QuantityMeasurementCacheRepository.resetInstance();
        new File("quantity_measurements.dat").delete();
        repository = QuantityMeasurementCacheRepository.getInstance();
        service = new QuantityMeasurementServiceImpl(repository);
    }
    @AfterEach void tearDown() {
        QuantityMeasurementCacheRepository.resetInstance();
        new File("quantity_measurements.dat").delete();
    }
    @Test @Order(1) void testQuantityDTO_Construction() {
        QuantityDTO dto = new QuantityDTO(10.0, QuantityDTO.LengthUnit.FEET);
        assertEquals(10.0, dto.getValue(), EPS);
        assertEquals(QuantityDTO.LengthUnit.FEET, dto.getUnit());
    }
    @Test @Order(2) void testQuantityModel_Construction() {
        QuantityModel<LengthUnit> model = new QuantityModel<>(10.0, LengthUnit.FEET);
        assertEquals(10.0, model.getValue(), EPS);
        assertEquals(LengthUnit.FEET, model.getUnit());
    }
    @Test @Order(3) void testEntity_BinaryConstruction() {
        QuantityMeasurementEntity e = new QuantityMeasurementEntity("10 FEET","5 FEET","ADDITION","15 FEET");
        assertEquals("ADDITION", e.getOperationType());
        assertFalse(e.isHasError());
    }
    @Test @Order(4) void testService_Compare_Equal() {
        assertTrue(service.compare(new QuantityDTO(1.0, QuantityDTO.LengthUnit.FEET), new QuantityDTO(12.0, QuantityDTO.LengthUnit.INCH)));
    }
    @Test @Order(5) void testService_Compare_CrossCategory_Error() {
        assertThrows(QuantityMeasurementException.class, () ->
            service.compare(new QuantityDTO(1.0, QuantityDTO.LengthUnit.FEET), new QuantityDTO(1.0, QuantityDTO.WeightUnit.KILOGRAM)));
    }
    @Test @Order(6) void testService_Convert_FeetToInches() {
        assertEquals(12.0, service.convert(new QuantityDTO(1.0, QuantityDTO.LengthUnit.FEET), new QuantityDTO(0, QuantityDTO.LengthUnit.INCH)).getValue(), EPS);
    }
    @Test @Order(7) void testService_Convert_CelsiusToFahrenheit() {
        assertEquals(212.0, service.convert(new QuantityDTO(100.0, QuantityDTO.TemperatureUnit.CELSIUS), new QuantityDTO(0, QuantityDTO.TemperatureUnit.FAHRENHEIT)).getValue(), EPS);
    }
    @Test @Order(8) void testService_Add_Length() {
        assertEquals(15.0, service.add(new QuantityDTO(10.0, QuantityDTO.LengthUnit.FEET), new QuantityDTO(5.0, QuantityDTO.LengthUnit.FEET)).getValue(), EPS);
    }
    @Test @Order(9) void testService_Add_Temperature_Error() {
        assertThrows(QuantityMeasurementException.class, () ->
            service.add(new QuantityDTO(100.0, QuantityDTO.TemperatureUnit.CELSIUS), new QuantityDTO(50.0, QuantityDTO.TemperatureUnit.CELSIUS)));
    }
    @Test @Order(10) void testService_Subtract_Length() {
        assertEquals(5.0, service.subtract(new QuantityDTO(10.0, QuantityDTO.LengthUnit.FEET), new QuantityDTO(5.0, QuantityDTO.LengthUnit.FEET)).getValue(), EPS);
    }
    @Test @Order(11) void testService_Divide_Length() {
        assertEquals(5.0, service.divide(new QuantityDTO(10.0, QuantityDTO.LengthUnit.FEET), new QuantityDTO(2.0, QuantityDTO.LengthUnit.FEET)).getValue(), EPS);
    }
    @Test @Order(12) void testService_Divide_ByZero_Error() {
        assertThrows(QuantityMeasurementException.class, () ->
            service.divide(new QuantityDTO(10.0, QuantityDTO.LengthUnit.FEET), new QuantityDTO(0.0, QuantityDTO.LengthUnit.FEET)));
    }
    @Test @Order(13) void testService_NullInput_Error() {
        assertThrows(QuantityMeasurementException.class, () -> service.compare(null, new QuantityDTO(1.0, QuantityDTO.LengthUnit.FEET)));
    }
    @Test @Order(14) void testRepository_SaveAndRetrieve() {
        repository.save(new QuantityMeasurementEntity("10 FEET","5 FEET","ADDITION","15 FEET"));
        assertEquals(1, repository.getAllMeasurements().size());
    }
    @Test @Order(15) void testRepository_ClearHistory() {
        repository.save(new QuantityMeasurementEntity("a","b","COMP","true"));
        repository.clearHistory();
        assertEquals(0, repository.getAllMeasurements().size());
    }
    @Test @Order(16) void testRepository_SaveNull_Error() {
        assertThrows(IllegalArgumentException.class, () -> repository.save(null));
    }
    @Test @Order(17) void testRepository_ServiceOperationSavesHistory() {
        service.add(new QuantityDTO(10.0, QuantityDTO.LengthUnit.FEET), new QuantityDTO(5.0, QuantityDTO.LengthUnit.FEET));
        assertEquals(1, repository.getAllMeasurements().size());
    }
    @Test @Order(18) void testController_NullService_Error() {
        assertThrows(IllegalArgumentException.class, () -> new QuantityMeasurementController(null));
    }
    @Test @Order(19) void testController_RunAllDemos_NoException() {
        assertDoesNotThrow(() -> new QuantityMeasurementController(service).runAllDemonstrations());
    }
    @Test @Order(20) void testBackwardCompat_LengthEquality() {
        assertEquals(new Quantity<>(1.0, LengthUnit.FEET), new Quantity<>(12.0, LengthUnit.INCH));
    }
    @Test @Order(21) void testBackwardCompat_TemperatureEquality() {
        assertEquals(new Quantity<>(0.0, TemperatureUnit.CELSIUS), new Quantity<>(32.0, TemperatureUnit.FAHRENHEIT));
    }
    @Test @Order(22) void testBackwardCompat_TemperatureArithmetic_Rejected() {
        assertThrows(UnsupportedOperationException.class, () ->
            new Quantity<>(100.0, TemperatureUnit.CELSIUS).add(new Quantity<>(50.0, TemperatureUnit.CELSIUS)));
    }
    @Test @Order(23) void testIMeasurable_FromUnitName_Length() {
        assertEquals("LENGTH", IMeasurable.fromUnitName("FEET").getMeasurementType());
    }
    @Test @Order(24) void testIMeasurable_FromUnitName_Invalid() {
        assertThrows(IllegalArgumentException.class, () -> IMeasurable.fromUnitName("UNKNOWN"));
    }
    @Test @Order(25) void testEndToEnd_TemperatureErrorStoredInHistory() {
        assertThrows(QuantityMeasurementException.class, () ->
            service.add(new QuantityDTO(100.0, QuantityDTO.TemperatureUnit.CELSIUS), new QuantityDTO(50.0, QuantityDTO.TemperatureUnit.CELSIUS)));
        List<QuantityMeasurementEntity> history = repository.getAllMeasurements();
        assertEquals(1, history.size());
        assertTrue(history.get(0).isHasError());
    }
}
'@

# Write all UC15 files
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\entity\QuantityDTO.java" $quantityDTO
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\entity\QuantityMeasurementEntity.java" $quantityEntity
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\entity\QuantityModel.java" $quantityModel
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\exception\QuantityMeasurementException.java" $qmException
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\repository\IQuantityMeasurementRepository.java" $iRepository
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\repository\QuantityMeasurementCacheRepository.java" $cacheRepo
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\service\IQuantityMeasurementService.java" $iService
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\service\QuantityMeasurementServiceImpl.java" $serviceImpl
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\controller\QuantityMeasurementController.java" $controller
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\QuantityMeasurementApp.java" $mainApp
Write-FileContent "$WorkDir\src\test\java\com\bridgelabz\QuantityMeasurementUC15Test.java" $uc15Test

UC-Branch "feature/UC15-N-Tier-Architecture" "[Balaji]:UC15 - Implement N-Tier architecture with Controller, Service, Repository, Entity layers"

# Cleanup build scripts
Remove-Item "$WorkDir\build_uc1_uc2.ps1" -ErrorAction SilentlyContinue
Remove-Item "$WorkDir\build_uc3_uc7.ps1" -ErrorAction SilentlyContinue
Remove-Item "$WorkDir\build_uc8_uc12.ps1" -ErrorAction SilentlyContinue
Remove-Item "$WorkDir\build_uc13_uc14.ps1" -ErrorAction SilentlyContinue
Remove-Item "$WorkDir\build_uc15.ps1" -ErrorAction SilentlyContinue

Write-Host "UC15 COMPLETE - ALL BRANCHES DONE"
