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