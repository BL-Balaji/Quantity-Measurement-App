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