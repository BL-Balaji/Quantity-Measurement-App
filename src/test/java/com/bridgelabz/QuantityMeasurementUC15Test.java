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