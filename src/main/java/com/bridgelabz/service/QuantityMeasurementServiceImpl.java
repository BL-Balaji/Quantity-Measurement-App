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