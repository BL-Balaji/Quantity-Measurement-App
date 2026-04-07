package com.bridgelabz.service;
import com.bridgelabz.entity.QuantityDTO;
public interface IQuantityMeasurementService {
    boolean compare(QuantityDTO dto1, QuantityDTO dto2);
    QuantityDTO convert(QuantityDTO sourceDTO, QuantityDTO targetUnit);
    QuantityDTO add(QuantityDTO dto1, QuantityDTO dto2);
    QuantityDTO subtract(QuantityDTO dto1, QuantityDTO dto2);
    QuantityDTO divide(QuantityDTO dto1, QuantityDTO dto2);
}